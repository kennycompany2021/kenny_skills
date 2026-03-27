# Kenny Skills - Claude Code Marketplace Installer
# PowerShell 5.1+ compatible (Windows built-in)
#
# Usage:
#   powershell -ExecutionPolicy Bypass -c "iwr 'https://raw.githubusercontent.com/kennycompany2021/kenny_skills/main/install.ps1' -UseBasicParsing | iex"

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$MARKETPLACE_ID = "kenny-skills"
$PLUGIN_ID      = "doc-toolkit"
$PLUGIN_FULL_ID = "$PLUGIN_ID@$MARKETPLACE_ID"
$GITHUB_REPO    = "kennycompany2021/kenny_skills"

$settingsPath        = "$env:USERPROFILE\.claude\settings.json"
$installedPluginPath = "$env:USERPROFILE\.claude\plugins\installed_plugins.json"
$cachePath           = "$env:USERPROFILE\.claude\plugins\cache\$MARKETPLACE_ID\$PLUGIN_ID\1.0.0"

# UTF8 without BOM - PS 5.1 compatible
function Save-JsonFile($path, $obj) {
    $json = $obj | ConvertTo-Json -Depth 10
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($path, $json, $utf8NoBom)
}

Write-Host ""
Write-Host "  Kenny Skills - Claude Code Installer" -ForegroundColor Cyan
Write-Host "  =====================================" -ForegroundColor Cyan
Write-Host ""

# ── 1. settings.json ──────────────────────────────────────────────────────────

if (-not (Test-Path $settingsPath)) {
    Write-Host "  [!] settings.json not found - creating..." -ForegroundColor Yellow
    $newSettings = [PSCustomObject]@{ enabledPlugins = [PSCustomObject]@{}; extraKnownMarketplaces = [PSCustomObject]@{} }
    Save-JsonFile $settingsPath $newSettings
}

$settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

# extraKnownMarketplaces
if (-not ($settings.PSObject.Properties.Name -contains "extraKnownMarketplaces")) {
    $settings | Add-Member -MemberType NoteProperty -Name "extraKnownMarketplaces" -Value ([PSCustomObject]@{})
}

if ($settings.extraKnownMarketplaces.PSObject.Properties.Name -contains $MARKETPLACE_ID) {
    Write-Host "  [SKIP] Marketplace already registered: $MARKETPLACE_ID" -ForegroundColor DarkGray
} else {
    $settings.extraKnownMarketplaces | Add-Member -MemberType NoteProperty -Name $MARKETPLACE_ID -Value (
        [PSCustomObject]@{ source = [PSCustomObject]@{ source = "github"; repo = $GITHUB_REPO } }
    )
    Write-Host "  [OK]   Marketplace registered: $MARKETPLACE_ID" -ForegroundColor Green
}

# enabledPlugins
if (-not ($settings.PSObject.Properties.Name -contains "enabledPlugins")) {
    $settings | Add-Member -MemberType NoteProperty -Name "enabledPlugins" -Value ([PSCustomObject]@{})
}

if ($settings.enabledPlugins.PSObject.Properties.Name -contains $PLUGIN_FULL_ID) {
    Write-Host "  [SKIP] Plugin already enabled: $PLUGIN_FULL_ID" -ForegroundColor DarkGray
} else {
    $settings.enabledPlugins | Add-Member -MemberType NoteProperty -Name $PLUGIN_FULL_ID -Value $true
    Write-Host "  [OK]   Plugin enabled: $PLUGIN_FULL_ID" -ForegroundColor Green
}

Save-JsonFile $settingsPath $settings
Write-Host "  [OK]   settings.json saved" -ForegroundColor Green

# ── 2. installed_plugins.json ─────────────────────────────────────────────────

if (-not (Test-Path $installedPluginPath)) {
    Write-Host "  [!] installed_plugins.json not found - skipping" -ForegroundColor Yellow
} else {
    $installed = Get-Content $installedPluginPath -Raw | ConvertFrom-Json

    if (-not ($installed.PSObject.Properties.Name -contains "plugins")) {
        $installed | Add-Member -MemberType NoteProperty -Name "plugins" -Value ([PSCustomObject]@{})
    }

    if ($installed.plugins.PSObject.Properties.Name -contains $PLUGIN_FULL_ID) {
        Write-Host "  [SKIP] Install record exists: $PLUGIN_FULL_ID" -ForegroundColor DarkGray
    } else {
        $now = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        $entry = @([PSCustomObject]@{
            scope       = "user"
            installPath = $cachePath
            version     = "1.0.0"
            installedAt = $now
            lastUpdated = $now
        })
        $installed.plugins | Add-Member -MemberType NoteProperty -Name $PLUGIN_FULL_ID -Value $entry
        Save-JsonFile $installedPluginPath $installed
        Write-Host "  [OK]   Install record added: $PLUGIN_FULL_ID" -ForegroundColor Green
    }
}

# ── Done ──────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  Done! Restart Claude Code to activate the skills." -ForegroundColor Cyan
Write-Host ""
Write-Host "  Available skills:" -ForegroundColor White
Write-Host "    doc-toolkit:ppt    - PPT-style HTML presentation" -ForegroundColor Gray
Write-Host "    doc-toolkit:report - Report-style HTML document" -ForegroundColor Gray
Write-Host ""
