---
name: chinese-study-video-pipeline
description: Build Chinese-only study videos from reference audio and scripts, using GPT-SoVITS for voice cloning, scene-aligned images and subtitles for rendering, and a recoverable Douyin Creator Center workflow for scheduled publishing. Use when someone needs the full local pipeline from installation or debugging through dubbing, audiovisual QA, and platform publishing.
---

# 中文考研视频流水线

这是一套可恢复的本地生产流程，输入一集中文脚本、参考录音和分镜素材，输出经过音画审校的成片、双比例封面、发布文案、发布任务清单，以及抖音作品管理页的提交凭证。

## 适用边界

- 默认只处理中文脚本、中文配音、中文字幕和中文话题
- 默认使用本地 GPT-SoVITS WebUI，不把“程序推理成功”当作音色验收
- 抖音发布通过已登录的创作者中心页面；不绕过登录、验证码或平台审核
- 平台页面是外部状态，必须以作品管理页的标题、时间和状态作为最终证据
- 通过 `state` 和任务 JSON 恢复；不要把临时草稿或聊天记录当作检查点

## 工作阶段

1. **安装与基线**：阅读 [references/installation.md](references/installation.md)，确认官方版本、运行时、模型和 WebUI 健康状态
2. **调试与恢复**：遇到启动、端口、模型、浏览器或超时问题，先读 [references/troubleshooting.md](references/troubleshooting.md)
3. **脚本与配音**：按 [references/dubbing.md](references/dubbing.md) 清理中文脚本、切分分镜、合成逐镜音频并生成清单
4. **成片与审校**：按 [references/video-production.md](references/video-production.md) 绑定图片、字幕和音频，检查音画同步及字幕样式
5. **发布设置**：按 [references/douyin-publishing.md](references/douyin-publishing.md) 生成任务 JSON、设置双封面、AI章节、声明、话题和定时发布

## 首次使用

```powershell
# 1. 复制模板
Copy-Item templates\publish-task.json .\第NN期_发布任务.json

# 2. 生成或填写单期任务清单
.\scripts\prepare_episode.ps1 `
  -Episode 37 `
  -EpisodeFolder 'D:\项目\37_主题_2026-11-18' `
  -Title '隔天就忘，复习到底怎么排才落地？' `
  -Video 'D:\项目\06_视频成品\2026-11-18_第37期\第37期_主题.mp4' `
  -CoverHorizontal 'D:\项目\06_视频成品\2026-11-18_第37期\第37期_封面_4比3.png' `
  -CoverVertical 'D:\项目\06_视频成品\2026-11-18_第37期\第37期_封面_3比4.png' `
  -ReviewJson 'D:\项目\04_审校记录\全中文密集版\第37期_成片复核.json' `
  -CopyFile 'D:\项目\06_视频成品\2026-11-18_第37期\06_发布文案.txt' `
  -ScheduledAt '2026-11-18 14:30' `
  -Hashtags '考研,考研备考,间隔复习,老兔学长' `
  -OutputDir 'D:\项目\07_抖音发布'

# 3. 发布前再次校验
.\scripts\validate_episode.ps1 -TaskJson 'D:\项目\07_抖音发布\第37期_发布任务.json'
```

## 不可破坏的验收规则

- 脚本、标题、正文和字幕不得出现英文；脚本内容不能靠发布阶段临时删除
- 字幕使用白字黑框、画面下方、无句号；以实际音频时序为准
- 语音默认参数：V3 GPT + v2ProPlus SoVITS、`cut2`、每段约五十字、语速 `1.15`、单批次、关闭并行推理
- 每期至少保留：全中文口播、逐镜 WAV/JSON、成片、SRT、横竖封面、复核 JSON、发布任务 JSON
- 发布前集中核对：期数、素材哈希、标题正文、话题实体、双封面、声明、AI章节、位置热点和绝对时间
- 点击发布只做一次；出现“正在发布”或跳转后先去作品管理核对，不重新上传
- 审核中、定时发布中和已发布是三个不同状态，不得混写

## 恢复入口

1. 先读取单期任务 JSON 的 `state`、`last_confirmed_step` 和 `scheduled_at`
2. 若状态是 `提交待确认`，先查询作品管理，禁止再次点击发布
3. 若状态是 `编辑中`，只从最后确认步骤继续，先核对当前 UI
4. 若平台条目已经存在，以平台条目为准，更新本地记录并保存凭证
5. 若缺少证据，标记为 `uncertain`，不要声称完成

详细格式、字段和失败处理分别见 references，不要把所有阶段重新压进本文件。

