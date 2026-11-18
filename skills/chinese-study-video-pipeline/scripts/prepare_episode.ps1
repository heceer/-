[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][int]$Episode,
  [Parameter(Mandatory=$true)][string]$EpisodeFolder,
  [Parameter(Mandatory=$true)][string]$Title,
  [Parameter(Mandatory=$true)][string]$Video,
  [Parameter(Mandatory=$true)][string]$CoverHorizontal,
  [Parameter(Mandatory=$true)][string]$CoverVertical,
  [Parameter(Mandatory=$true)][string]$ReviewJson,
  [Parameter(Mandatory=$true)][string]$CopyFile,
  [Parameter(Mandatory=$true)][ValidatePattern('^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$')][string]$ScheduledAt,
  [Parameter(Mandatory=$true)][string]$Hashtags,
  [Parameter(Mandatory=$true)][string]$OutputDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
foreach ($path in @($EpisodeFolder,$Video,$CoverHorizontal,$CoverVertical,$ReviewJson,$CopyFile)) {
  if (-not (Test-Path -LiteralPath $path)) { throw "路径不存在：$path" }
}
$hashtagsList = @($Hashtags -split '[,，]' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if ($hashtagsList.Count -lt 3) { throw '至少提供三个话题，用逗号分隔' }
if ($hashtagsList | Where-Object { $_ -match '[A-Za-z]' -or $_ -match '\s' }) { throw '话题必须是无空格中文短语' }

$review = Get-Content -LiteralPath $ReviewJson -Raw | ConvertFrom-Json
$hash = (Get-FileHash -LiteralPath $Video -Algorithm SHA256).Hash.ToLower()
if ($review.sha256 -and $hash -ne $review.sha256.ToLower()) {
  throw "视频哈希与复核记录不一致：$hash / $($review.sha256)"
}
$lines = Get-Content -LiteralPath $CopyFile
if ($lines.Count -gt 0 -and $lines[0].Trim() -eq $Title.Trim()) {
  if ($lines.Count -gt 1) { $lines = $lines[1..($lines.Count - 1)] } else { $lines = @() }
}
$body = ($lines -join "`n")
$body = $body -replace '(?ms)\r?\n置顶评论：.*$',''
$body = $body -replace '。',''
$body = $body.Trim()
if ($body -match '[A-Za-z]') { throw '正文包含拉丁字母，禁止进入全中文发布流程' }
if ($body -match '\.(com|cn|net)') { throw '正文包含 URL' }

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$task = [ordered]@{
  episode = $Episode
  timezone = 'Asia/Shanghai'
  scheduled_at = $ScheduledAt
  title = $Title
  body = $body
  hashtags = @($hashtagsList)
  episode_folder = $EpisodeFolder
  video = $Video
  cover_horizontal = $CoverHorizontal
  cover_vertical = $CoverVertical
  review_json = $ReviewJson
  declaration = '无需添加自主声明'
  chapters = '平台AI生成并保存'
  location = ''
  hot_topic = ''
  state = '待上传'
  preflight = [ordered]@{
    video_sha256 = $hash
    video_hash_matches_review = (-not [string]::IsNullOrWhiteSpace([string]$review.sha256) -and $hash -eq $review.sha256.ToLower())
    seconds = $review.seconds
    assets_exist = $true
    chinese_only = $true
    periods_removed = $true
  }
}
$out = Join-Path $OutputDir ("第{0}期_发布任务.json" -f $Episode)
$task | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $out -Encoding UTF8
Write-Output $out
