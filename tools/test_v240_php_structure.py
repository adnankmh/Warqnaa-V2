#!/usr/bin/env python3
"""Dependency-free structural gate for the R12 PHP surface.

CI still runs PHP's native lexer and PHPUnit. This gate catches truncated files,
unbalanced delimiters and unterminated comments/strings on machines where PHP is
not installed, so a source package cannot silently skip every PHP-level check.
"""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FILES = (
    "backend-laravel/app/Console/Commands/CompetitiveTick.php",
    "backend-laravel/app/Http/Controllers/AdminCompetitiveController.php",
    "backend-laravel/app/Http/Controllers/CompetitiveController.php",
    "backend-laravel/app/Http/Controllers/MobileCompetitiveController.php",
    "backend-laravel/app/Http/Controllers/MobileGameController.php",
    "backend-laravel/app/Http/Controllers/RoomController.php",
    "backend-laravel/app/Http/Controllers/TournamentController.php",
    "backend-laravel/app/Services/Competitive/CompetitiveMatchmakingService.php",
    "backend-laravel/app/Services/Competitive/CompetitiveRatingService.php",
    "backend-laravel/app/Services/Competitive/CompetitiveSeasonService.php",
    "backend-laravel/app/Services/Competitive/TournamentBracketService.php",
    "backend-laravel/app/Services/WarqnaPro/CompetitionService.php",
    "backend-laravel/app/Services/WarqnaPro/TournamentSettlementService.php",
    "backend-laravel/database/migrations/2026_08_21_000240_r12_competitive_arena.php",
    "backend-laravel/tests/Feature/V240CompetitiveArenaTest.php",
)

OPEN = {"(": ")", "[": "]", "{": "}"}
CLOSE = {value: key for key, value in OPEN.items()}


def fail(message: str) -> None:
    raise SystemExit("[FAIL] " + message)


def validate(relative: str) -> None:
    path = ROOT / relative
    if not path.is_file():
        fail(f"missing {relative}")
    text = path.read_text(encoding="utf-8")
    if not text.lstrip().startswith("<?php"):
        fail(f"{relative}: missing PHP opening tag")

    stack: list[tuple[str, int]] = []
    state = "code"
    line = 1
    start_line = 1
    index = 0
    while index < len(text):
        char = text[index]
        nxt = text[index + 1] if index + 1 < len(text) else ""
        if char == "\n":
            line += 1

        if state == "line_comment":
            if char == "\n":
                state = "code"
            index += 1
            continue
        if state == "block_comment":
            if char == "*" and nxt == "/":
                state = "code"
                index += 2
            else:
                index += 1
            continue
        if state in {"single", "double"}:
            quote = "'" if state == "single" else '"'
            if char == "\\":
                index += 2
                continue
            if char == quote:
                state = "code"
            index += 1
            continue

        if char == "/" and nxt == "/":
            state = "line_comment"; start_line = line; index += 2; continue
        if char == "#":
            state = "line_comment"; start_line = line; index += 1; continue
        if char == "/" and nxt == "*":
            state = "block_comment"; start_line = line; index += 2; continue
        if char == "'":
            state = "single"; start_line = line; index += 1; continue
        if char == '"':
            state = "double"; start_line = line; index += 1; continue
        if char in OPEN:
            stack.append((char, line))
        elif char in CLOSE:
            if not stack or stack[-1][0] != CLOSE[char]:
                fail(f"{relative}:{line}: unmatched {char}")
            stack.pop()
        index += 1

    if state in {"single", "double", "block_comment"}:
        fail(f"{relative}:{start_line}: unterminated {state.replace('_', ' ')}")
    if stack:
        char, opened = stack[-1]
        fail(f"{relative}:{opened}: unclosed {char}")
    print(f"[PASS] {relative}")


def main() -> None:
    for relative in FILES:
        validate(relative)
    print("V240 R12 PHP STRUCTURE GATE: PASS")


if __name__ == "__main__":
    main()
