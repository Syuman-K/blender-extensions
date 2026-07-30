# 自作アドオンの最新ZIPを集めて Blender 拡張リポジトリを更新・公開する。
#
# 各開発リポジトリの blender_manifest.toml から id とバージョンを読み、
# dist/<id>-<version>.zip をここへコピー → index.json を再生成 →
# git commit & push する。push 後、Blender の Get Extensions で
# リポジトリを Sync すると Update ボタンに新版が出る。
#
# 使い方:
#   powershell -ExecutionPolicy Bypass -File .\publish.ps1
#   powershell -ExecutionPolicy Bypass -File .\publish.ps1 -NoPush   # 生成だけ

param([switch]$NoPush)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$dev = Split-Path $root -Parent

# 集約対象の開発リポジトリ(dist/ に blender extension build 済みZIPがあること)
$sources = @(
    "evenmesh", "phaseporter", "sculptbase",
    "hollowkit", "auto_support_gen", "partsplit"
)

function Find-Blender {
    if ($env:BLENDER -and (Test-Path $env:BLENDER)) { return $env:BLENDER }
    $c = Get-Command blender.exe -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    $guess = Get-ChildItem "C:\Program Files\Blender Foundation" -Recurse `
        -Filter blender.exe -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending | Select-Object -First 1
    if ($guess) { return $guess.FullName }
    return $null
}

$blender = Find-Blender
if (-not $blender) { throw "Blender not found. Set `$env:BLENDER." }

# 既存ZIPを消してから最新版だけを置き直す
Get-ChildItem $root -Filter "*.zip" | Remove-Item -Force

foreach ($name in $sources) {
    $repo = Join-Path $dev $name
    $manifest = Join-Path $repo "blender_manifest.toml"
    if (-not (Test-Path $manifest)) {
        Write-Warning "skip ${name}: blender_manifest.toml がない"
        continue
    }
    $text = Get-Content $manifest -Raw
    $id = [regex]::Match($text, '(?m)^id\s*=\s*"([^"]+)"').Groups[1].Value
    $ver = [regex]::Match($text, '(?m)^version\s*=\s*"([^"]+)"').Groups[1].Value
    $zip = Join-Path $repo ("dist\{0}-{1}.zip" -f $id, $ver)
    if (-not (Test-Path $zip)) {
        Write-Warning ("skip ${name}: {0} が未ビルド (build.ps1 を先に実行)" -f
            (Split-Path $zip -Leaf))
        continue
    }
    Copy-Item $zip $root
    Write-Host ("  + {0}-{1}.zip" -f $id, $ver)
}

& $blender --command extension server-generate --repo-dir $root --html
if ($LASTEXITCODE -ne 0) { throw "server-generate failed ($LASTEXITCODE)" }
Write-Host "index.json / index.html を再生成しました"

if (-not $NoPush) {
    Push-Location $root
    try {
        git add -A
        git commit -m "Update extension index"
        git push origin main
        Write-Host "push 完了 — Blender 側で Sync すると Update に反映されます"
    } finally {
        Pop-Location
    }
}
