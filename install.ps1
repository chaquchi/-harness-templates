# Harness Templates Skill — 一键安装脚本 (Windows PowerShell)
# 用法: .\install.ps1 [harness-templates.skill 路径]

param(
    [string]$SkillFile = "harness-templates.skill"
)

$ErrorActionPreference = "Stop"
$PluginName = "harness-templates"
$PluginsDir = "$env:USERPROFILE\.claude\plugins"
$CacheDir = "$PluginsDir\cache\claude-plugins-official\$PluginName"
$InstalledJson = "$PluginsDir\installed_plugins.json"
$Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.000Z")

Write-Host "== Harness Templates Skill 安装 ==" -ForegroundColor Cyan
Write-Host ""

# 1. 检查 .skill 文件
if (-not (Test-Path $SkillFile)) {
    Write-Host "[✗] 找不到 $SkillFile" -ForegroundColor Red
    Write-Host "    用法: .\install.ps1 <harness-templates.skill 路径>"
    exit 1
}
Write-Host "[✓] 找到 $SkillFile" -ForegroundColor Green

# 2. 创建插件目录
New-Item -ItemType Directory -Force -Path $CacheDir | Out-Null
Write-Host "[✓] 创建目录 $CacheDir" -ForegroundColor Green

# 3. 解压
Expand-Archive -Force -Path $SkillFile -DestinationPath $CacheDir
Write-Host "[✓] 解压完成" -ForegroundColor Green

# 4. 处理嵌套目录
$nestedDir = Join-Path $CacheDir $PluginName
if (Test-Path $nestedDir) {
    Get-ChildItem $nestedDir | Move-Item -Destination $CacheDir -Force
    Remove-Item $nestedDir -Force
    Write-Host "[✓] 修正目录结构" -ForegroundColor Green
}

# 5. 注册到 installed_plugins.json
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
Write-Host '  2. 在项目中输入 /harness-templates 或'
Write-Host '     "帮我配置 Harness 工程" 即可触发'
