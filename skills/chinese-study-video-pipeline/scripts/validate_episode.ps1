[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$TaskJson)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $TaskJson)) { throw "任务文件不存在：$TaskJson" }
$task = Get-Content -LiteralPath $TaskJson -Raw | ConvertFrom-Json
foreach ($field in @('episode','scheduled_at','title','body','video','cover_horizontal','cover_vertical','hashtags')) {
  if ($null -eq $task.$field -or [string]::IsNullOrWhiteSpace([string]$task.$field)) { throw "任务字段为空：$field" }
}
foreach ($path in @($task.video,$task.cover_horizontal,$task.cover_vertical)) {
  if (-not (Test-Path -LiteralPath $path)) { throw "素材不存在：$path" }
}
$hash = (Get-FileHash -LiteralPath $task.video -Algorithm SHA256).Hash.ToLower()
if ($task.preflight.video_sha256 -and $hash -ne $task.preflight.video_sha256.ToLower()) { throw '视频哈希已变化' }
if ($task.title -match '[A-Za-z]' -or $task.body -match '[A-Za-z]') { throw '标题或正文包含拉丁字母' }
if ($task.body -match '。') { throw '正文含句号，请按当前中文发布规则清理' }
if ($task.hashtags.Count -lt 3) { throw '话题数量不足' }
if ($task.scheduled_at -notmatch '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$') { throw '时间必须是 YYYY-MM-DD HH:mm' }
Write-Output "PASS episode=$($task.episode) schedule=$($task.scheduled_at) hash=$hash"
