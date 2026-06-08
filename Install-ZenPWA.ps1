<#
.SYNOPSIS
    Automated installation and configuration of FirefoxPWA for Zen Browser.

.DESCRIPTION
    1. SILENT INSTALLATION: Silently downloads and installs the latest native
       'FirefoxPWA' runtime MSI installer from GitHub.
    2. AUTOMATED CONFIGURATION: Locates the active Zen Browser profile.
    3. LINK ROUTING ENHANCEMENT: Appends 'firefoxpwa.openOutOfScopeInDefaultBrowser'
       to route out-of-scope interactions correctly.
    4. ELEGANT DESIGN: Injects custom CSS to eliminate legacy borders for Zen.
    5. CLEAN HANDLING: Exits with a safe warning if Zen is currently running.
#>

$ErrorActionPreference = 'Stop'

# --- 1. Clean Handling: Check if Zen Browser is running ---
$zenProcesses = Get-Process -Name 'zen' -ErrorAction SilentlyContinue
if ($zenProcesses) {
    Write-Host 'WARNING: Zen Browser is currently open.' -ForegroundColor Yellow
    Write-Host 'Please close Zen Browser so configuration files can be safely modified without locks.' -ForegroundColor Yellow
    Exit
}

Write-Host 'Zen Browser is closed. Proceeding with seamless installation...' -ForegroundColor Green

# --- 2. Silent Installation from GitHub ---
Write-Host 'Fetching the latest FirefoxPWA runtime release...' -ForegroundColor Cyan
$githubApiUrl = 'https://api.github.com/repos/filips123/PWAsForFirefox/releases/latest'

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $release = Invoke-RestMethod -Uri $githubApiUrl
    
    # Corrected asset pattern matching to cleanly capture lowercase names with '_64' formatting
    $asset = $release.assets | Where-Object { $_.name -match 'firefoxpwa-.*-x86_64\.msi$' }
    
    if (-not $asset) { throw 'Could not locate x86_64 MSI installer in the latest release.' }

    $tempMsiPath = Join-Path $env:TEMP $asset.name
    Write-Host "Downloading $($asset.name)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tempMsiPath

    Write-Host 'Installing FirefoxPWA silently...' -ForegroundColor Cyan
    $installArgs = '/i "' + $tempMsiPath + '" /qn /norestart'
    $installProcess = Start-Process -FilePath 'msiexec.exe' -ArgumentList $installArgs -Wait -NoNewWindow -PassThru

    if ($installProcess.ExitCode -ne 0) {
        throw "MSI Installation failed with exit code $($installProcess.ExitCode)"
    }
    Write-Host 'FirefoxPWA runtime successfully installed.' -ForegroundColor Green
} catch {
    Write-Error "Runtime download or installation failed: $_"
    Exit
}

# --- 3. Locate Zen Browser Profile ---
$zenAppData = Join-Path $env:APPDATA 'zen\Profiles'
if (-not (Test-Path $zenAppData)) {
    Write-Host "Zen Browser profiles directory not found at $zenAppData." -ForegroundColor Red
    Exit
}

$profiles = Get-ChildItem -Path $zenAppData -Directory
if ($profiles.Count -eq 0) {
    Write-Host 'No Zen Browser profiles found. Please run Zen at least once.' -ForegroundColor Red
    Exit
}

Write-Host 'Enhancing Zen Browser Profile configurations...' -ForegroundColor Cyan
foreach ($profile in $profiles) {
    $profilePath = $profile.FullName
    Write-Host " -> Injecting into profile: $($profile.Name)"

    # --- 4. Link Routing Enhancement ---
    $userJsPath = Join-Path $profilePath 'user.js'
    $linkRoutePref = 'user_pref("firefoxpwa.openOutOfScopeInDefaultBrowser", true);'
    $cssEnablePref = 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'

    if (Test-Path $userJsPath) {
        $currentJs = Get-Content $userJsPath -Raw
        if ($currentJs -notmatch 'firefoxpwa\.openOutOfScopeInDefaultBrowser') {
            Add-Content -Path $userJsPath -Value "`n$linkRoutePref"
        }
        if ($currentJs -notmatch 'toolkit\.legacyUserProfileCustomizations\.stylesheets') {
            Add-Content -Path $userJsPath -Value "`n$cssEnablePref"
        }
    } else {
        Set-Content -Path $userJsPath -Value "$linkRoutePref`n$cssEnablePref"
    }
    Write-Host '    + user.js preferences perfectly orchestrated.'

    # --- 5. Elegant Design (Seamless CSS Injection) ---
    $chromeDir = Join-Path $profilePath 'chrome'
    if (-not (Test-Path $chromeDir)) { New-Item -ItemType Directory -Path $chromeDir | Out-Null }

    $userChromePath = Join-Path $chromeDir 'userChrome.css'
    $cssOverrides = @"

/* FirefoxPWA / Zen Browser Seamless Overrides */
:root {
    --zen-borders-radius: 0px !important;
    --uc-window-control-width: 0px !important;
    --uc-window-parts-padding: 0px !important;
}

#main-window, #tabbrowser-tabpanels, #appcontent {
    border: none !important;
    box-shadow: none !important;
    border-radius: 0 !important;
}
"@

    if (Test-Path $userChromePath) {
        $existingCss = Get-Content $userChromePath -Raw
        if ($existingCss -notmatch 'FirefoxPWA / Zen Browser Seamless Overrides') {
            Add-Content -Path $userChromePath -Value $cssOverrides
        }
    } else {
        Set-Content -Path $userChromePath -Value $cssOverrides
    }
    Write-Host '    + Custom CSS injected. Borders eliminated.'
}

# Cleanup
Remove-Item $tempMsiPath -ErrorAction SilentlyContinue

Write-Host '`n[SUCCESS] Zen Browser FirefoxPWA integration is fully operational!' -ForegroundColor Green
