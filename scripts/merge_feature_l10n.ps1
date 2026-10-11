$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
foreach ($taskLocale in @('ar', 'en', 'ur')) {
    $taskArbPath = Join-Path $taskRoot "lib/core/l10n/app_$taskLocale.arb"
    $taskArb = Get-Content -LiteralPath $taskArbPath -Raw | ConvertFrom-Json -AsHashtable
    foreach ($taskMapFile in @('features', 'library', 'planner', 'worship')) {
        $taskMapPath = Join-Path $taskRoot "docs/${taskMapFile}_l10n.json"
        if (-not (Test-Path -LiteralPath $taskMapPath)) { continue }
        $taskMap = Get-Content -LiteralPath $taskMapPath -Raw | ConvertFrom-Json -AsHashtable
        if ($taskMap.ContainsKey($taskLocale)) {
            foreach ($taskKey in $taskMap[$taskLocale].Keys) {
                $taskArb[$taskKey] = $taskMap[$taskLocale][$taskKey]
            }
        } else {
            foreach ($taskKey in $taskMap.Keys) {
                $taskArb[$taskKey] = $taskMap[$taskKey][$taskLocale]
            }
        }
    }
    [System.IO.File]::WriteAllText($taskArbPath, ($taskArb | ConvertTo-Json -Depth 25),
        [System.Text.UTF8Encoding]::new($false))
}
