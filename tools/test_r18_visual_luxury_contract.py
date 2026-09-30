from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = (ROOT / 'flutter_app/lib/r8_play_experience.dart').read_text(encoding='utf-8')

checks = {
    'R18 release anchor': "warqnaaR18VisualLuxury = 'R18-visual-luxury-1'" in SRC,
    'luxury brand header': 'class _R18BrandHeader' in SRC and 'أكثر من لعبة… مجتمع واحد' in SRC,
    'tournament hero': 'class _R18Hero' in SRC and 'R12CompetitiveArenaPage' in SRC,
    'profile/reaction/booster feature panel': all(x in SRC for x in ['Profile gradients & themes', 'Animated & voiced reactions', 'Glowing boosters']),
    'responsive discovery shelf': 'class _R18DiscoveryShelf' in SRC and 'box.maxWidth < 660' in SRC,
    'game-art tiles use shipped assets': 'r101GameArtAsset(game.id)' in SRC,
    'game palettes remain distinct': all(x in SRC for x in ["id.contains('tarneeb')", "id.contains('trix')", "id.contains('hand')", "id == 'banakil'", "id == 'baloot'", "id == 'basra'"]),
    'compact cards preserve 48px minimum': 'viewport < 340 ? 48.0' in SRC,
    'hand overlap preserves 44px exposed hit area': '.clamp(44.0, width + 6)' in SRC,
    'table seat semantics retained': "label: '$name, $detail', button: true" in SRC,
    'presentation seat rotation retained': 'int r8RelativeSeat' in SRC,
}

failed = [name for name, ok in checks.items() if not ok]
for name, ok in checks.items():
    print(f"[{'PASS' if ok else 'FAIL'}] {name}")
if failed:
    raise SystemExit('R18 VISUAL LUXURY CONTRACT FAILED: ' + ', '.join(failed))
print('R18 VISUAL LUXURY CONTRACT: PASS')
