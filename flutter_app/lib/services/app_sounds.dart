import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Central, non-blocking game sound bus. Every call is fail-safe so audio can
/// never prevent the game from opening or a move from being submitted.
enum SoundChannel { cards, ui, reactions, rewards, social }

class AppSounds {
  AppSounds._();

  static bool enabled = true;
  static double volume = .72;
  static final Map<SoundChannel, double> channelVolumes = <SoundChannel, double>{
    SoundChannel.cards: .82,
    SoundChannel.ui: .58,
    SoundChannel.reactions: .62,
    SoundChannel.rewards: .76,
    SoundChannel.social: .60,
  };
  static final Map<String, AudioPlayer> _players = <String, AudioPlayer>{};
  static final Map<String, DateTime> _lastPlayed = <String, DateTime>{};


  static SoundChannel channelFor(String cue) {
    if (<String>{'card_play','deal','shuffle','round_end','next_round','bid'}.contains(cue)) return SoundChannel.cards;
    if (<String>{'emoji','reaction','gift'}.contains(cue)) return SoundChannel.reactions;
    if (<String>{'win','reward','purchase','booster_activate','ticket_flip'}.contains(cue)) return SoundChannel.rewards;
    if (<String>{'message','notification','invite','room_join','room_create'}.contains(cue)) return SoundChannel.social;
    return SoundChannel.ui;
  }

  static void setChannelVolume(SoundChannel channel, double value) {
    channelVolumes[channel] = value.clamp(0.0, 1.0).toDouble();
  }

  static Future<void> play(String cue, {double? volumeOverride, Duration throttle = const Duration(milliseconds: 45)}) async {
    if (!enabled) return;
    final now = DateTime.now();
    final previous = _lastPlayed[cue];
    if (previous != null && now.difference(previous) < throttle) return;
    _lastPlayed[cue] = now;
    try {
      final player = _players.putIfAbsent(cue, AudioPlayer.new);
      await player.stop();
      final channelVolume = channelVolumes[channelFor(cue)] ?? 1.0;
      final effectiveVolume = (volumeOverride ?? (volume * channelVolume)).clamp(0.0, 1.0).toDouble();
      await player.play(AssetSource('sounds/$cue.wav'), volume: effectiveVolume);
    } catch (error) {
      debugPrint('Sound cue $cue skipped: $error');
    }
  }

  static void fire(String cue, {double? volumeOverride}) {
    unawaited(play(cue, volumeOverride: volumeOverride));
  }

  static Future<void> dispose() async {
    for (final player in _players.values) {
      try { await player.dispose(); } catch (_) {}
    }
    _players.clear();
  }
}
