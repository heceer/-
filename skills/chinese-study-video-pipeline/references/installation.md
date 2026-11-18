# 安装 GPT-SoVITS

## 原则

优先使用官方仓库和对应 release 的安装说明，不混用不同版本的代码、GPT 模型和 SoVITS 模型。当前项目使用的是 Windows 本地运行时，项目内实际验证过的路径是 `D:\01_WORK\01_兼职\GPT-SoVITS`。

官方入口：<https://github.com/RVC-Boss/GPT-SoVITS>。GitHub 的 README 是版本变化时的第一依据，本文只记录本项目已验证的操作边界。

## Windows 本地安装

1. 确认显卡驱动、CUDA/PyTorch 组合和磁盘空间满足当前 release 要求
2. 按官方 README 选择源码安装或集成包，不把另一台机器的 `runtime`、权重目录和源码混拼
3. 源码安装完成后，先运行仓库提供的安装脚本或依赖安装命令；保留安装日志
4. 确认以下关键文件或等价的当前版本文件存在：
   - `GPT_SoVITS/pretrained_models/s1v3.ckpt`
   - `GPT_SoVITS/pretrained_models/v2Pro/s2Gv2ProPlus.pth`
   - 推理 WebUI 入口
5. 先做健康检查，再开始批量合成。不要把第一次打开网页或模型加载成功当作音质验收

## 本项目的隐藏 WebUI

本项目有 `launch_web_hidden.py`，它会：

- 使用项目自带 `runtime/python.exe`
- 推理页默认端口 `9872`
- 主 WebUI 默认端口 `9874`
- 绑定 `127.0.0.1`，不主动公开到公网
- 将日志写入 `installation_logs/`
- 通过 `/config` 检查端口是否真的是 GPT-SoVITS 页面

检查推理页：

```powershell
Set-Location 'D:\01_WORK\01_兼职\GPT-SoVITS'
& .\runtime\python.exe .\launch_web_hidden.py inference --check
```

启动推理页：

```powershell
& .\runtime\python.exe .\launch_web_hidden.py inference
```

如果是其他版本或其他目录，先检查脚本参数和官方 README，不要盲目复制端口或模型路径。

## 模型与参数基线

- GPT：V3，对应 `s1v3.ckpt` 或当前 release 的等价 V3 权重
- SoVITS：v2ProPlus，对应 `s2Gv2ProPlus.pth`
- 语言：全中文
- 切分：`cut2`，约五十字一段
- 语速：`1.15`
- `batch_size=1`
- `parallel_infer=false`

模型路径和版本必须写入每期 `配音与分镜清单.json`，否则后续无法判断音色差异来自脚本、参数还是模型。
