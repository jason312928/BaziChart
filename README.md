<p align="center">
  <img src="Resources/AppIcon.png" width="112" alt="八字排盘图标">
</p>

<h1 align="center">八字排盘 · BaziChart</h1>

<p align="center">
  一款原生、离线、注重隐私的 macOS 八字排盘工具。
</p>

<p align="center">
  <a href="README_EN.md">English</a>
  ·
  <a href="PRIVACY.md">隐私</a>
  ·
  <a href="CONTRIBUTING.md">参与贡献</a>
</p>

<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/platform-macOS%2026%2B-111111">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6.2-F05138?logo=swift&logoColor=white">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-2ea44f">
  <img alt="Network" src="https://img.shields.io/badge/network-not%20required-0f766e">
</p>

![八字排盘主界面](docs/assets/app-overview.png)

八字排盘把四柱、十神、藏干、十二运、空亡、纳音和神煞放在同一个工作区里，并将大运、流年、流月、流日串成可连续浏览的时间线。它没有账号、云服务和埋点，打开即可使用。

## 为什么做这个项目

不少排盘工具依赖网页、账号或远程接口；信息被切成多层页面，查看一个月份或日期时需要反复跳转。BaziChart 选择了另一条路：

- **原生 macOS 体验**：SwiftUI 构建，支持键盘快捷键、系统材质、窗口缩放和深色界面。
- **完整离线计算**：排盘与地区查询均在本机完成，不依赖网络 API。
- **真太阳时校正**：按经度和均时差修正出生时间，可随时关闭并对照北京时间结果。
- **全国区县检索**：内置行政区划索引，支持省、市、区县名称及行政代码搜索。
- **运盘连续浏览**：从大运进入流年、流月和流日，保留当前选择，减少上下文切换。
- **档案与复制**：常用命例保存在本机，可搜索、载入，并复制结构化排盘文本。
- **结果透明**：界面注明所用历法库与起运参数，核心计算有固定命例测试。

## 功能概览

| 模块 | 内容 |
| --- | --- |
| 命盘 | 四柱、十神、藏干、十二运、空亡、纳音、神煞 |
| 运盘 | 大运、流年、流月、流日联动选择 |
| 时间 | 公历出生时间、目标流盘日期、北京时间 |
| 地区 | 全国区县搜索、自定义经度、真太阳时校正 |
| 五行 | 日主、五行数量与直观平衡条 |
| 档案 | 本地保存、搜索、载入和删除 |
| 导出 | 一键复制完整文本结果 |

## 系统要求

- macOS 26 Tahoe 或更高版本
- Apple Silicon Mac（当前已验证构建）
- 源码构建需要 Swift 6.2

项目使用了 macOS 26 的 SwiftUI 视觉 API，因此当前没有向更早系统回退。
源码本身没有绑定特定 CPU；Intel 构建需要在对应架构、具备 macOS 26 SDK 的环境中自行验证。

## 安装

### 下载发布版

在 GitHub 的 **Releases** 页面下载与你 Mac 架构对应的 `BaziChart-macOS-*.zip`，解压后将“八字排盘”拖入“应用程序”。

首次打开未签名的社区构建时，macOS 可能提示无法验证开发者。请在 Finder 中右键 App，选择“打开”。不要从非本项目 Releases 页面下载构建包。

### 从源码运行

克隆仓库后进入项目目录：

```bash
cd BaziChart
./script/build_and_run.sh
```

只构建自包含的 `.app`：

```bash
./script/build_and_run.sh build
```

输出位于 `dist/八字排盘.app`。

## 开发

```bash
swift build
./script/test.sh
```

代码结构：

```text
Sources/BaziChart/
├── App/          # App 入口
├── Models/       # 排盘模型与计算
├── Services/     # 行政区划检索
├── Stores/       # 状态、缓存与本地档案
├── Support/      # 视觉系统与通用样式
└── Views/        # SwiftUI 界面
```

更详细的实现说明见 [架构文档](docs/ARCHITECTURE.md)。

## 隐私

BaziChart 不创建账号，不接入分析服务，也不会将姓名、出生时间、地区或排盘结果发送到网络。保存的命例使用 macOS `UserDefaults` 留在当前用户设备上。

公开截图、Issue 或日志前，请自行移除真实姓名和出生信息。完整说明见 [隐私政策](PRIVACY.md)。

## 准确性与使用边界

本项目用于传统历法研究、文化交流与个人娱乐，不构成医疗、法律、财务、心理或其他专业建议。不同流派在换日、起运和真太阳时算法上可能存在差异，重要用途请自行复核。

## 参与贡献

Bug 报告、命例校验、界面改进和文档修订都欢迎。提交前请阅读 [贡献指南](CONTRIBUTING.md) 与 [行为准则](CODE_OF_CONDUCT.md)。

## 致谢

- [6tail/lunar-swift](https://github.com/6tail/lunar-swift) 提供农历与 EightChar 基础能力。
- [uiwjs/province-city-china](https://github.com/uiwjs/province-city-china) 提供行政区划数据来源。

第三方许可证见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

## License

[MIT](LICENSE)
