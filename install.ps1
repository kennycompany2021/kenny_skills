# Kenny Skills - Claude Code Marketplace Installer
# 사용법: PowerShell에서 실행
#   .\install.ps1
# 또는 원격 실행:
#   powershell -ExecutionPolicy Bypass -Command "iwr 'https://raw.githubusercontent.com/kennycompany2021/kenny_skills/main/install.ps1' -OutFile '$env:TEMP\ks-install.ps1'; & '$env:TEMP\ks-install.ps1'"

$ErrorActionPreference = "Stop"

$MARKETPLACE_ID   = "kenny-skills"
$PLUGIN_ID        = "doc-toolkit"
$PLUGIN_FULL_ID   = "$PLUGIN_ID@$MARKETPLACE_ID"
$GITHUB_REPO      = "kennycompany2021/kenny_skills"

$settingsPath        = "$env:USERPROFILE\.claude\settings.json"
$installedPluginPath = "$env:USERPROFILE\.claude\plugins\installed_plugins.json"
$cachePath           = "$env:USERPROFILE\.claude\plugins\cache\$MARKETPLACE_ID\$PLUGIN_ID\1.0.0"

Write-Host ""
Write-Host "  Kenny Skills - Claude Code Installer" -ForegroundColor Cyan
Write-Host "  =====================================" -ForegroundColor Cyan
Write-Host ""

# ── 1. settings.json ──────────────────────────────────────────────────────────

if (-not (Test-Path $settingsPath)) {
    Write-Host "  [!] settings.json 없음 - 새로 생성합니다" -ForegroundColor Yellow
    @{ enabledPlugins = @{}; extraKnownMarketplaces = @{} } |
        ConvertTo-Json -Depth 5 | Set-Content $settingsPath -Encoding UTF8NoBOM
}

$settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

# extraKnownMarketplaces 키 확보
if (-not ($settings.PSObject.Properties.Name -contains "extraKnownMarketplaces")) {
    $settings | Add-Member -MemberType NoteProperty -Name "extraKnownMarketplaces" -Value ([PSCustomObject]@{})
}

# kenny-skills 마켓플레이스 등록
if ($settings.extraKnownMarketplaces.PSObject.Properties.Name -contains $MARKETPLACE_ID) {
    Write-Host "  [SKIP] 마켓플레이스 이미 등록됨: $MARKETPLACE_ID" -ForegroundColor DarkGray
} else {
    $settings.extraKnownMarketplaces | Add-Member -MemberType NoteProperty -Name $MARKETPLACE_ID -Value (
        [PSCustomObject]@{ source = [PSCustomObject]@{ source = "github"; repo = $GITHUB_REPO } }
    )
    Write-Host "  [OK]   마켓플레이스 등록: $MARKETPLACE_ID" -ForegroundColor Green
}

# enabledPlugins 키 확보
if (-not ($settings.PSObject.Properties.Name -contains "enabledPlugins")) {
    $settings | Add-Member -MemberType NoteProperty -Name "enabledPlugins" -Value ([PSCustomObject]@{})
}

# 플러그인 활성화
if ($settings.enabledPlugins.PSObject.Properties.Name -contains $PLUGIN_FULL_ID) {
    Write-Host "  [SKIP] 플러그인 이미 활성화됨: $PLUGIN_FULL_ID" -ForegroundColor DarkGray
} else {
    $settings.enabledPlugins | Add-Member -MemberType NoteProperty -Name $PLUGIN_FULL_ID -Value $true
    Write-Host "  [OK]   플러그인 활성화: $PLUGIN_FULL_ID" -ForegroundColor Green
}

$settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8NoBOM
Write-Host "  [OK]   settings.json 저장 완료" -ForegroundColor Green

# ── 2. installed_plugins.json ─────────────────────────────────────────────────

if (-not (Test-Path $installedPluginPath)) {
    Write-Host "  [!] installed_plugins.json 없음 - 건너뜁니다" -ForegroundColor Yellow
} else {
    $installed = Get-Content $installedPluginPath -Raw | ConvertFrom-Json

    if (-not ($installed.PSObject.Properties.Name -contains "plugins")) {
        $installed | Add-Member -MemberType NoteProperty -Name "plugins" -Value ([PSCustomObject]@{})
    }

    if ($installed.plugins.PSObject.Properties.Name -contains $PLUGIN_FULL_ID) {
        Write-Host "  [SKIP] 설치 기록 이미 존재: $PLUGIN_FULL_ID" -ForegroundColor DarkGray
    } else {
        $now = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        $entry = @(
            [PSCustomObject]@{
                scope       = "user"
                installPath = $cachePath
                version     = "1.0.0"
                installedAt = $now
                lastUpdated = $now
            }
        )
        $installed.plugins | Add-Member -MemberType NoteProperty -Name $PLUGIN_FULL_ID -Value $entry
        $installed | ConvertTo-Json -Depth 10 | Set-Content $installedPluginPath -Encoding UTF8NoBOM
        Write-Host "  [OK]   설치 기록 추가: $PLUGIN_FULL_ID" -ForegroundColor Green
    }
}

# ── 완료 ──────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  설치 완료!" -ForegroundColor Cyan
Write-Host "  Claude Code를 재시작하면 스킬이 활성화됩니다." -ForegroundColor White
Write-Host ""
Write-Host "  사용 가능한 스킬:" -ForegroundColor White
Write-Host "    - doc-toolkit:ppt    (PPT형 발표자료 HTML 생성)" -ForegroundColor Gray
Write-Host "    - doc-toolkit:report (보고서형 문서 HTML 생성)" -ForegroundColor Gray
Write-Host ""
