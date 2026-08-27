<?php

declare(strict_types=1);

/**
 * Warqnaa R13 Engine Gold standalone certification runner.
 *
 * Profiles are controlled by environment so pull requests remain fast while
 * release and scheduled CI certify thousands of bounded matches per engine:
 *   WARQNA_GOLD_MATCHES_PER_ENGINE=2000
 *   WARQNA_GOLD_MAX_TRANSITIONS=320
 *   WARQNA_GOLD_REPORT=/tmp/warqnaa-engine-gold.json
 */

if (!function_exists('now')) {
    final class WarqnaaGoldClock
    {
        public function toIso8601String(): string { return gmdate('c'); }
    }
    function now(): WarqnaaGoldClock { return new WarqnaaGoldClock(); }
}

$base = dirname(__DIR__) . '/app/Services/GameEngine';
require_once dirname(__DIR__) . '/app/Services/WarqnaPro/PlayActionNormalizer.php';
foreach ([
    'GameRuleContract.php', 'Card.php', 'DeckFactory.php', 'AbstractCardRules.php',
    'DominoRules.php', 'BasraRules.php', 'BackgammonRules.php', 'JackarooRules.php',
    'ChessRules.php', 'TarneebRules.php', 'GlobalCardEngineRules.php',
    'UniversalSocialGameRules.php', 'EngineRegistry.php', 'GameFactory.php',
] as $file) require_once $base . '/' . $file;

use App\Services\GameEngine\EngineRegistry;
use App\Services\GameEngine\GameFactory;

function goldFail(string $message): never
{
    fwrite(STDERR, "[FAIL] {$message}\n");
    exit(1);
}

function goldEnvInt(string $name, int $default, int $min, int $max): int
{
    $raw = getenv($name);
    $value = $raw === false || $raw === '' ? $default : (int)$raw;
    return max($min, min($max, $value));
}

function goldFinished(array $state): bool
{
    return in_array((string)($state['phase'] ?? ''), ['finished', 'game_over', 'complete', 'completed'], true)
        || array_key_exists('winner', $state) && ($state['phase'] ?? '') !== 'playing';
}

function goldPayload(array $action): array
{
    unset($action['type'], $action['label'], $action['reason'], $action['title']);
    return $action;
}

/** @return array<int,array<string,mixed>> */
function goldOrderedActions(array $actions, array $state): array
{
    $phase = (string)($state['engine_phase'] ?? $state['phase'] ?? '');
    $priority = match ($phase) {
        'bidding' => ['bid', 'pass'],
        'choose_trump' => ['choose_trump'],
        'contract' => ['choose_contract'],
        'draw' => ['draw_discard', 'draw_deck', 'draw'],
        'discard' => ['replace_wild', 'layoff', 'meld_many', 'meld', 'discard'],
        default => [
            'move_piece', 'play_card', 'play_tile', 'move', 'roll', 'draw',
            'move_to_foundation', 'draw_stock', 'replace_wild', 'layoff',
            'meld_many', 'meld', 'discard', 'draw_discard', 'draw_deck',
            'choose_contract', 'choose_trump', 'bid', 'pass_trix', 'pass',
        ],
    };
    $rank = array_flip($priority);
    usort($actions, function(array $a, array $b) use ($rank): int {
        $typeA = (string)($a['type'] ?? '');
        $typeB = (string)($b['type'] ?? '');
        $aRank = $rank[$typeA] ?? 1000;
        $bRank = $rank[$typeB] ?? 1000;
        if ($aRank !== $bRank) return $aRank <=> $bRank;
        // Stable deterministic diversity without selecting resign/offer_draw.
        return strcmp(json_encode($a, JSON_UNESCAPED_UNICODE), json_encode($b, JSON_UNESCAPED_UNICODE));
    });
    return array_values(array_filter($actions, fn($action)=>!in_array(($action['type'] ?? ''), ['wait', 'resign', 'offer_draw', 'organize'], true)));
}

function goldAssertState(string $engine, int $match, int $step, array $state, array $players): void
{
    $prefix = "{$engine} match {$match} step {$step}";
    if (json_encode($state, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) === false) goldFail("{$prefix}: state is not JSON serializable");
    if (!isset($state['phase']) || !is_string($state['phase'])) goldFail("{$prefix}: phase is missing");
    $statePlayers = array_values(array_map('strval', (array)($state['players'] ?? [])));
    if (!$statePlayers || count($statePlayers) !== count(array_unique($statePlayers))) goldFail("{$prefix}: player identifiers are empty or duplicated");
    if (!goldFinished($state) && isset($state['turn']) && !in_array((string)$state['turn'], $statePlayers, true)) goldFail("{$prefix}: active turn does not belong to a player");
    foreach ((array)($state['hands'] ?? []) as $player => $hand) {
        if (!is_array($hand) || in_array(null, $hand, true) || in_array('', $hand, true)) goldFail("{$prefix}: invalid hand item for {$player}");
    }
    if (!empty($state['last_error']) || !empty($state['last_error_message'])) goldFail("{$prefix}: " . ($state['last_error_message'] ?? $state['last_error']));
    if (isset($state['state_hash']) && $state['state_hash'] !== null && !preg_match('/^[a-f0-9]{64}$/', (string)$state['state_hash'])) goldFail("{$prefix}: invalid state hash");
}

$expectedEngines = [
    'tarneeb', 'tarneeb_41', 'tarneeb_61', 'syrian_tarneeb', 'tarneeb_400',
    'trix', 'trix_partner', 'trix_complex', 'hand', 'hand_partner',
    'saudi_hand', 'banakil', 'pinochle', 'solitaire_multiplayer', 'baloot',
    'basra', 'domino', 'backgammon', 'jackaroo', 'chess',
];
$registryEngines = array_keys(EngineRegistry::all());
sort($expectedEngines); sort($registryEngines);
if ($expectedEngines !== $registryEngines) goldFail('EngineRegistry differs from the R13 certified engine set');
$engineOrdinals = array_flip($registryEngines);

// Optional local/diagnostic filter. CI release certification leaves this unset
// and still runs the full engine set. It lets maintainers stress one engine
// with thousands of deterministic matches without paying the cost of every
// other engine during a focused regression investigation.
$engineFilter = trim((string)(getenv('WARQNA_GOLD_ENGINE_FILTER') ?: ''));
if ($engineFilter !== '') {
    $requested = array_values(array_unique(array_filter(array_map('trim', explode(',', $engineFilter)))));
    $unknown = array_values(array_diff($requested, $registryEngines));
    if ($unknown) goldFail('Unknown WARQNA_GOLD_ENGINE_FILTER value(s): '.implode(', ', $unknown));
    $registryEngines = array_values(array_filter($registryEngines, fn($engine) => in_array($engine, $requested, true)));
    if (!$registryEngines) goldFail('WARQNA_GOLD_ENGINE_FILTER selected no engines');
}

$matchesPerEngine = goldEnvInt('WARQNA_GOLD_MATCHES_PER_ENGINE', 25, 1, 5000);
$maxTransitions = goldEnvInt('WARQNA_GOLD_MAX_TRANSITIONS', 160, 20, 600);
$reportPath = trim((string)(getenv('WARQNA_GOLD_REPORT') ?: ''));
$started = hrtime(true);
$report = [
    'contract' => 'r13_engine_gold_v1',
    'release' => '0.8.0+250',
    'matches_per_engine' => $matchesPerEngine,
    'max_transitions' => $maxTransitions,
    'engines' => [],
];

foreach ($registryEngines as $key) {
    $engineIndex = (int)($engineOrdinals[$key] ?? 0);
    $meta = EngineRegistry::get($key);
    if (!$meta) goldFail("{$key}: registry metadata missing");
    $playerCount = max((int)($meta['min'] ?? 2), min((int)($meta['max'] ?? 4), 4));
    if (in_array($key, ['hand_partner', 'banakil', 'pinochle', 'baloot'], true) || str_contains($key, 'tarneeb') || str_contains($key, 'trix')) $playerCount = 4;
    $players = array_map(fn(int $i)=>"gold:p{$i}", range(0, $playerCount - 1));
    $engineStarted = hrtime(true);
    $transitions = 0;
    $completed = 0;
    $bounded = 0;

    for ($match = 1; $match <= $matchesPerEngine; $match++) {
        $seed = 250000000 + ($engineIndex * 100000) + $match;
        $rules = GameFactory::make($key);
        $state = $rules->initialState($players, [
            'seed' => $seed,
            'target' => str_contains($key, 'tarneeb') ? 31 : ($key === 'domino' ? 20 : null),
            'player_count' => $playerCount,
            'single_round' => true,
            'singleRound' => true,
            'turn_seconds' => 7,
        ]);
        goldAssertState($key, $match, 0, $state, $players);
        if (isset($state['_global_engine']['seed']) && (int)$state['_global_engine']['seed'] !== $seed) goldFail("{$key} match {$match}: supplied replay seed was not preserved");

        for ($step = 1; $step <= $maxTransitions; $step++) {
            if (goldFinished($state)) { $completed++; break; }
            $turn = (string)($state['turn'] ?? '');
            if ($turn === '' || !in_array($turn, $players, true)) goldFail("{$key} match {$match} step {$step}: missing active turn");
            $actions = method_exists($rules, 'availableActions') ? $rules->availableActions($state, $turn) : [];
            $ordered = goldOrderedActions(is_array($actions) ? $actions : [], $state);
            $selected = null;
            $selectedState = null;
            $before = json_encode($state, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            foreach ($ordered as $candidate) {
                $type = (string)($candidate['type'] ?? '');
                if ($type !== '' && (!method_exists($rules, 'validate') || $rules->validate($state, $turn, $type, goldPayload($candidate)))) {
                    $preview = $rules->apply($state, $turn, $type, goldPayload($candidate));
                    $previewJson = json_encode($preview, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
                    if (empty($preview['last_error']) && empty($preview['last_error_message']) && $previewJson !== $before) {
                        $selected = $candidate;
                        $selectedState = $preview;
                        break;
                    }
                }
            }
            if ($selected !== null) {
                $state = $selectedState;
            } elseif (method_exists($rules, 'onTurnTimeout')) {
                $state = $rules->onTurnTimeout($state);
            } else {
                goldFail("{$key} match {$match} step {$step}: active engine deadlock");
            }
            goldAssertState($key, $match, $step, $state, $players);
            $after = json_encode($state, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            if ($before === $after) goldFail("{$key} match {$match} step {$step}: legal action/timeout made no transition");
            $transitions++;
            if ($step === $maxTransitions) $bounded++;
        }
    }

    $elapsedMs = (hrtime(true) - $engineStarted) / 1_000_000;
    $report['engines'][$key] = [
        'matches' => $matchesPerEngine,
        'completed' => $completed,
        'bounded' => $bounded,
        'transitions' => $transitions,
        'elapsed_ms' => round($elapsedMs, 3),
        'status' => 'gold',
    ];
    echo "[GOLD] {$key}: {$matchesPerEngine} matches, {$transitions} legal transitions, {$completed} completed, {$bounded} bounded\n";
}

$report['total_matches'] = count($registryEngines) * $matchesPerEngine;
$report['total_transitions'] = array_sum(array_column($report['engines'], 'transitions'));
$report['elapsed_ms'] = round((hrtime(true) - $started) / 1_000_000, 3);
$report['status'] = 'pass';
if ($reportPath !== '') {
    $directory = dirname($reportPath);
    if (!is_dir($directory) && !mkdir($directory, 0775, true) && !is_dir($directory)) goldFail("cannot create report directory {$directory}");
    if (file_put_contents($reportPath, json_encode($report, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) . "\n") === false) goldFail("cannot write report {$reportPath}");
}
echo "\n[PASS] R13 Engine Gold certified {$report['total_matches']} bounded matches across " . count($registryEngines) . " engines with {$report['total_transitions']} validated transitions.\n";
