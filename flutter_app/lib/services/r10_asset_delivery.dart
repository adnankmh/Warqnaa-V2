import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class R10AssetRecord {
  const R10AssetRecord({
    required this.id,
    required this.localAsset,
    required this.kind,
    required this.delivery,
    required this.version,
    required this.bytes,
    required this.sha256Hex,
    this.url,
    this.thumbnailUrl,
  });

  final String id;
  final String localAsset;
  final String kind;
  final String delivery;
  final int version;
  final int bytes;
  final String sha256Hex;
  final String? url;
  final String? thumbnailUrl;

  factory R10AssetRecord.fromJson(Map<String, dynamic> json) => R10AssetRecord(
        id: json['id']?.toString() ?? '',
        localAsset: json['local_asset']?.toString() ?? '',
        kind: json['kind']?.toString() ?? 'visual',
        delivery: json['delivery']?.toString() ?? 'ondemand',
        version: int.tryParse(json['version']?.toString() ?? '') ?? 1,
        bytes: int.tryParse(json['bytes']?.toString() ?? '') ?? 0,
        sha256Hex: json['sha256']?.toString() ?? '',
        url: _nullable(json['url']),
        thumbnailUrl: _nullable(json['thumbnail_url']),
      );

  static String? _nullable(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? null : text;
  }
}

/// R10 layered delivery manager.
///
/// 1) A compact bundled WebP/OGG derivative is always a safe fallback.
/// 2) A versioned manifest can switch premium content to a CDN without an APK update.
/// 3) Remote image bytes are SHA-256 verified before display and held in a bounded
///    memory cache. Browser/OS HTTP caching remains available underneath.
/// 4) Data Saver asks for the CDN thumbnail first, then falls back to the standard URL.
class R10AssetDelivery extends ChangeNotifier {
  R10AssetDelivery._();
  static final R10AssetDelivery instance = R10AssetDelivery._();

  static const _manifestPrefsKey = 'r10_asset_manifest_cache';
  static const _dataSaverPrefsKey = 'r10_data_saver';
  static const _manifestFetchedPrefsKey = 'r10_asset_manifest_fetched_at';
  static const int _memoryBudget = 18 * 1024 * 1024;

  final Map<String, R10AssetRecord> _byLocalAsset = <String, R10AssetRecord>{};
  final Map<String, Uint8List> _memory = <String, Uint8List>{};
  final List<String> _memoryOrder = <String>[];
  int _memoryBytes = 0;

  bool dataSaver = false;
  bool cdnEnabled = false;
  String mode = 'hybrid';
  DateTime? manifestFetchedAt;
  int manifestEntries = 0;
  int ondemandEntries = 0;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    dataSaver = prefs.getBool(_dataSaverPrefsKey) ?? false;
    manifestFetchedAt = DateTime.tryParse(prefs.getString(_manifestFetchedPrefsKey) ?? '');
    final cached = prefs.getString(_manifestPrefsKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        final decoded = jsonDecode(cached);
        if (decoded is Map) _applyManifest(Map<String, dynamic>.from(decoded));
      } catch (_) {
        // Corrupt/stale metadata must never block app startup.
      }
    }
  }

  Future<void> refresh(WarqnaApiClient api, {Map<String, dynamic>? bootstrap}) async {
    final summary = bootstrap?['asset_delivery'];
    if (summary is Map) {
      cdnEnabled = summary['cdn_enabled'] == true || summary['cdn_enabled'] == 1;
      mode = summary['mode']?.toString() ?? mode;
      ondemandEntries = int.tryParse(summary['ondemand_entries']?.toString() ?? '') ?? ondemandEntries;
    }
    try {
      final manifest = await api.assetManifestR10();
      _applyManifest(manifest);
      manifestFetchedAt = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_manifestPrefsKey, jsonEncode(manifest));
      await prefs.setString(_manifestFetchedPrefsKey, manifestFetchedAt!.toIso8601String());
    } catch (error) {
      debugPrint('R10 asset manifest refresh deferred: $error');
    }
    notifyListeners();
  }

  void _applyManifest(Map<String, dynamic> manifest) {
    mode = manifest['mode']?.toString() ?? mode;
    cdnEnabled = manifest['cdn_enabled'] == true || manifest['cdn_enabled'] == 1;
    final entries = manifest['entries'];
    if (entries is! List) return;
    _byLocalAsset.clear();
    for (final raw in entries) {
      if (raw is! Map) continue;
      final record = R10AssetRecord.fromJson(Map<String, dynamic>.from(raw));
      if (record.localAsset.isNotEmpty) _byLocalAsset[record.localAsset] = record;
    }
    manifestEntries = _byLocalAsset.length;
    ondemandEntries = _byLocalAsset.values.where((e) => e.delivery == 'ondemand').length;
  }

  Future<void> setDataSaver(bool value) async {
    if (dataSaver == value) return;
    dataSaver = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dataSaverPrefsKey, value);
    notifyListeners();
  }

  R10AssetRecord? recordFor(String localAsset) => _byLocalAsset[localAsset];

  String? remoteUrlFor(String localAsset) {
    final record = recordFor(localAsset);
    if (record == null || !cdnEnabled || mode == 'local') return null;
    if (dataSaver && record.thumbnailUrl != null) return record.thumbnailUrl;
    return record.url;
  }

  ImageProvider provider(String localAsset) {
    final remote = remoteUrlFor(localAsset);
    return remote == null ? AssetImage(localAsset) : NetworkImage(remote);
  }

  Future<Uint8List?> verifiedRemoteBytes(String localAsset) async {
    final record = recordFor(localAsset);
    final remote = remoteUrlFor(localAsset);
    if (record == null || remote == null) return null;
    final cacheKey = '${record.id}:${record.version}:${dataSaver ? 'saver' : 'full'}';
    final cached = _memory[cacheKey];
    if (cached != null) {
      _touch(cacheKey);
      return cached;
    }
    try {
      final response = await http.get(Uri.parse(remote), headers: const {'Accept':'image/avif,image/webp,image/*'}).timeout(const Duration(seconds: 15));
      if (response.statusCode < 200 || response.statusCode >= 300 || response.bodyBytes.isEmpty) return null;
      final bytes = response.bodyBytes;
      // Thumbnail bytes intentionally have a different digest; verify the canonical
      // asset only when the full URL is requested.
      if (!dataSaver && record.sha256Hex.isNotEmpty) {
        final digest = sha256.convert(bytes).toString();
        if (digest.toLowerCase() != record.sha256Hex.toLowerCase()) {
          debugPrint('R10 asset integrity mismatch: ${record.id}');
          return null;
        }
      }
      _put(cacheKey, bytes);
      return bytes;
    } catch (_) {
      return null;
    }
  }

  void _touch(String key) {
    _memoryOrder.remove(key);
    _memoryOrder.add(key);
  }

  void _put(String key, Uint8List bytes) {
    final old = _memory.remove(key);
    if (old != null) _memoryBytes -= old.lengthInBytes;
    _memory[key] = bytes;
    _memoryBytes += bytes.lengthInBytes;
    _touch(key);
    while (_memoryBytes > _memoryBudget && _memoryOrder.isNotEmpty) {
      final evict = _memoryOrder.removeAt(0);
      final removed = _memory.remove(evict);
      if (removed != null) _memoryBytes -= removed.lengthInBytes;
    }
  }

  void clearMemoryCache() {
    _memory.clear();
    _memoryOrder.clear();
    _memoryBytes = 0;
    notifyListeners();
  }

  int get memoryCacheBytes => _memoryBytes;
}

class R10AssetImage extends StatefulWidget {
  const R10AssetImage({
    super.key,
    required this.localAsset,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.filterQuality = FilterQuality.medium,
    this.borderRadius,
  });

  final String localAsset;
  final BoxFit fit;
  final double? width;
  final double? height;
  final FilterQuality filterQuality;
  final BorderRadius? borderRadius;

  @override
  State<R10AssetImage> createState() => _R10AssetImageState();
}

class _R10AssetImageState extends State<R10AssetImage> {
  late Future<Uint8List?> _future;

  @override
  void initState() {
    super.initState();
    R10AssetDelivery.instance.addListener(_deliveryChanged);
    _future = R10AssetDelivery.instance.verifiedRemoteBytes(widget.localAsset);
  }

  void _deliveryChanged() {
    if (!mounted) return;
    setState(() => _future = R10AssetDelivery.instance.verifiedRemoteBytes(widget.localAsset));
  }

  @override
  void didUpdateWidget(covariant R10AssetImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localAsset != widget.localAsset) {
      _future = R10AssetDelivery.instance.verifiedRemoteBytes(widget.localAsset);
    }
  }

  @override
  void dispose() {
    R10AssetDelivery.instance.removeListener(_deliveryChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        final image = bytes == null
            ? Image.asset(widget.localAsset, fit: widget.fit, width: widget.width, height: widget.height, filterQuality: widget.filterQuality)
            : Image.memory(bytes, fit: widget.fit, width: widget.width, height: widget.height, filterQuality: widget.filterQuality, gaplessPlayback: true);
        if (widget.borderRadius == null) return image;
        return ClipRRect(borderRadius: widget.borderRadius!, child: image);
      },
    );
  }
}
