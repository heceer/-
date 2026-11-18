# 中文脚本与 GPT-SoVITS 配音

## 输入

每期至少准备：

- 纯中文脚本和逐镜分镜稿
- 用户有权使用的参考录音
- 期数、标题、目标时长和分镜顺序

脚本先做文本检查：删除英文单词、拉丁字母、URL、英文缩写和不可读公式；数学和专业表达改写为中文名称。字幕要求无句号，脚本是否保留中文句号由后续字幕规则决定。

## 配音顺序

1. 按分镜把脚本拆成 8 段或实际分镜数量
2. 每段控制在约五十字切分范围内，避免一次生成整期
3. 在 GPT-SoVITS 推理 WebUI 固定 V3 + v2ProPlus、全中文、`cut2`、语速 `1.15`
4. 每个 scene 保存独立 WAV；同时保留完整口播 WAV
5. 用实际 WAV 样本数计算 scene 边界，不使用估算时长
6. 生成 `音频/配音与分镜清单.json`

## 清单最低字段

```json
{
  "ep": 37,
  "title": "隔天就忘，复习到底怎么排才落地？",
  "audio": "音频/第37期_全中文口播.wav",
  "parameters": {
    "language": "all_zh",
    "gpt": "GPT_SoVITS/pretrained_models/s1v3.ckpt",
    "sovits": "GPT_SoVITS/pretrained_models/v2Pro/s2Gv2ProPlus.pth",
    "speed": 1.15,
    "split": "cut2",
    "batch_size": 1,
    "parallel_infer": false
  },
  "scenes": [
    {
      "scene": 0,
      "text": "中文分镜文案",
      "voice": "音频/分镜配音/01_分镜.wav",
      "start_sample": 0,
      "stop_sample": 296960,
      "coverage": 1.0,
      "max_gap": 0
    }
  ]
}
```

## 音质验收

必须同时看三类证据：

- 参考录音与合成音色的实际试听
- 独立 ASR 或人工抽听确认中文没有漏字、错字和英语误读
- 分镜 WAV 的时长、样本边界和全期音频连续性

不要因为推理程序没有报错就声称“声音像本人”。如果音色不合格，优先回看参考录音质量、模型配对、切分和语速。
