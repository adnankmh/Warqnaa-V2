from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def require(text: str, needle: str, context: str) -> None:
    assert needle in text, f"Missing {context}: {needle}"


def forbid(text: str, needle: str, context: str) -> None:
    assert needle not in text, f"Forbidden {context}: {needle}"


def main() -> None:
    hand_ui = read("flutter_app/lib/r8_play_experience.dart")
    main_dart = read("flutter_app/lib/main.dart")
    local_engine = read("flutter_app/lib/engines/local_game_engine.dart")
    hand_rules = read("backend-laravel/app/Services/GameEngine/HandRules.php")
    banakil_rules = read("backend-laravel/app/Services/GameEngine/PinochleRules.php")
    registry = read("backend-laravel/app/Services/GameEngine/EngineRegistry.php")
    mobile_comp = read("backend-laravel/app/Http/Controllers/MobileCompetitiveController.php")
    admin_comp = read("backend-laravel/app/Http/Controllers/AdminCompetitiveController.php")
    routes = read("backend-laravel/routes/api.php")
    appeal_model = read("backend-laravel/app/Models/CompetitionAppeal.php")
    appeal_migration = read("backend-laravel/database/migrations/2026_10_06_000801_create_competition_appeals.php")

    # Complete hand remains on-screen. R28 intentionally removes horizontal
    # hand scrolling and computes overlap from the actual visible viewport.
    require(hand_ui, "R28 invariant: the complete hand always stays inside the visible table", "full-hand viewport invariant")
    require(hand_ui, "final usable = math.max(1.0, viewport - sidePadding * 2);", "responsive hand usable width")
    require(hand_ui, "final step = count <= 1 ? 0.0 : math.max(0.0, (usable - width) / (count - 1));", "adaptive overlap")
    require(hand_ui, "Align(alignment: Alignment.bottomCenter, child: cards)", "centered complete hand")
    hand_block = hand_ui[hand_ui.index("class R8CardHand"):hand_ui.index("class R8TableSeat")]
    forbid(hand_block, "SingleChildScrollView", "horizontal hand scrolling")

    # Suit rendering and grouping presentation stay deterministic and original.
    for symbol, label in (("♣", "clubs"), ("♦", "diamonds"), ("♠", "spades"), ("♥", "hearts")):
        require(main_dart, symbol, f"{label} suit symbol")
    require(main_dart, "_rummyGroupingAccent", "Hand/Banakil group-color helper")
    require(main_dart, "سحب عدة أوراق من النار", "Banakil multi-card fire control")
    require(main_dart, "_chooseBanakilDiscardStack", "Banakil fire stack chooser")

    # Strong/playable casual deals must be symmetric for every seat and must
    # never depend on identity, purchases, Pasha, level, or a privileged seat.
    require(local_engine, "deal_policy': 'balanced_casual_local'", "transparent casual deal policy")
    require(local_engine, "deal_fairness': 'symmetric_all_seats'", "symmetric deal fairness")
    require(local_engine, "_balancePremiumHands", "trick-game balanced deal scenarios")
    require(local_engine, "_balanceCasualRummyHands", "Hand/Banakil balanced deal scenarios")
    require(local_engine, "final scenario = attempt % 4", "multiple rotating deal scenarios")
    for forbidden in ("displayName", "username", "vipDays", "pasha", "purchase", "wallet"):
        # The local engine itself must not use identity/economy inputs to shape a hand.
        forbid(local_engine, forbidden, f"deal favoritism input {forbidden}")

    # Manual order and multi-meld suggestions are server validated.
    require(hand_rules, "$action === 'organize'", "server-authoritative manual order")
    require(hand_rules, "sameCardMultiset", "same-card multiset guard")
    require(hand_rules, "manual_hand_order", "manual order persistence")
    require(hand_rules, "availableActions", "server action hints")
    require(hand_rules, "'meld_many'", "multi-group Hand action")
    require(hand_rules, "nonOverlappingMeldCandidates($candidates, $hand)", "legal non-overlapping meld suggestions")

    # Banakil has its distinct multi-card discard/fire pickup.
    require(banakil_rules, "'draw_discard_stack'", "Banakil multi-card discard action")
    require(banakil_rules, "array_splice($state['discard']", "consecutive fire pickup")
    require(registry, "draw_discard_stack", "Banakil action catalog exposure")

    # Competition recording/appeals are user-visible and reviewer decisions
    # are permissioned, auditable, and delegable by the primary admin.
    require(appeal_model, "class CompetitionAppeal", "appeal model")
    require(appeal_migration, "competition_appeals", "appeal persistence")
    require(mobile_comp, "submitAppeal", "player appeal submission")
    require(mobile_comp, "48 ساعة", "appeal time window")
    require(admin_comp, "competition_review", "delegated competition-review permission")
    require(admin_comp, "reviewerAccess", "primary-admin reviewer delegation")
    require(admin_comp, "appealAction", "admin appeal adjudication")
    require(routes, "/competitive/matches/{match}/appeals", "player appeal route")
    require(routes, "/admin/competitive/appeals/{appeal}", "reviewer decision route")

    print("R28 Hand/Banakil/competition integrity contract: PASS")


if __name__ == "__main__":
    main()
