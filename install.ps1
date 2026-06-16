# Harness Templates Skill — 一键安装脚本 (Windows PowerShell)
# 用法: .\install.ps1                        从源码安装（git clone 后执行）
#       .\install.ps1 harness-templates.skill   从 .skill 文件安装

param(
    [string]$SkillFile = ""
)

$ErrorActionPreference = "Stop"
$PluginName = "harness-templates"
$PluginsDir = "$env:USERPROFILE\.claude\plugins"
$CacheDir = "$PluginsDir\cache\claude-plugins-official\$PluginName"
$InstalledJson = "$PluginsDir\installed_plugins.json"
$Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.000Z")
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "== Harness Templates Skill 安装 ==" -ForegroundColor Cyan
Write-Host ""

# 判断安装模式
if ($SkillFile -ne "") {
    # === 模式 A：从 .skill 文件安装 ===
    if (-not (Test-Path $SkillFile)) {
        Write-Host "[✗] 找不到 $SkillFile" -ForegroundColor Red
        Write-Host "    用法: .\install.ps1 <harness-templates.skill 路径>"
        exit 1
    }
    Write-Host "[✓] 从 .skill 文件安装: $SkillFile" -ForegroundColor Cyan
    $SourceDir = ""
    $NeedUnzip = $true
} else {
    # === 模式 B：从源码安装（git clone 后） ===
    $SkillMd = Join-Path $ScriptDir "skills/harness-templates/SKILL.md"
    if (Test-Path $SkillMd) {
        Write-Host "[✓] 从源码安装: $ScriptDir" -ForegroundColor Cyan
        $SourceDir = $ScriptDir
        $NeedUnzip = $false
    } else {
        Write-Host "[✗] 找不到 skills/harness-templates/SKILL.md" -ForegroundColor Red
        Write-Host "    请在仓库根目录运行此脚本，或指定 .skill 文件路径"
        exit 1
    }
}

# 创建插件目录
New-Item -ItemType Directory -Force -Path $CacheDir | Out-Null
Write-Host "[✓] 创建目录 $CacheDir" -ForegroundColor Green

# 复制 / 解压文件
if ($NeedUnzip) {
    Expand-Archive -Force -Path $SkillFile -DestinationPath $CacheDir
    Write-Host "[✓] 解压完成" -ForegroundColor Green
    # 处理嵌套目录
    $nestedDir = Join-Path $CacheDir $PluginName
    if (Test-Path $nestedDir) {
        Get-ChildItem $nestedDir | Move-Item -Destination $CacheDir -Force
        Remove-Item $nestedDir -Force
        Write-Host "[✓] 修正目录结构" -ForegroundColor Green
    }
} else {
    Copy-Item -Recurse -Force -Path (Join-Path $SourceDir "skills") -Destination $CacheDir
    if (Test-Path (Join-Path $SourceDir "install.sh")) {
        Copy-Item -Force -Path (Join-Path $SourceDir "install.sh") -Destination $CacheDir
    }
    if (Test-Path (Join-Path $SourceDir "install.ps1")) {
        Copy-Item -Force -Path (Join-Path $SourceDir "install.ps1") -Destination $CacheDir
    }
    Write-Host "[✓] 复制完成" -ForegroundColor Green
}

# 注册到 installed_plugins.json
if (Test-Path $InstalledJson) {
    $json = Get-Content $InstalledJson -Raw | ConvertFrom-Json
    $key = "$PluginName@claude-plugins-official"

    if ($json.plugins.PSObject.Properties.Name -contains $key) {
        Write-Host "[!] $PluginName 已注册，跳过" -ForegroundColor Yellow
    } else {
        $json.plugins | Add-Member -MemberType NoteProperty -Name $key -Value @(
            @{
                scope = "user"
                installPath = $CacheDir
                version = "1.0.0"
                installedAt = $Timestamp
                lastUpdated = $Timestamp
            }
        )
        $json | ConvertTo-Json -Depth 10 | Set-Content $InstalledJson
        Write-Host "[✓] 注册完成" -ForegroundColor Green
    }
} else {
    Write-Host "[!] $InstalledJson 不存在，请先安装 Claude Code" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  安装完成！" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步："
Write-Host "  1. 重启 Claude Code 或执行 /reload-plugins"
Write-Host '  2. 在项目中输入 "帮我配置 Harness 工程" 即可触发'
