# GitHub Setup / 上线设置

这份文件用于首次创建 GitHub 仓库时核对设置。

## Repository

建议仓库名：

```text
BaziChart
```

建议英文简介：

```text
A native, offline and privacy-first Bazi chart app for macOS.
```

建议中文简介：

```text
原生、离线、注重隐私的 macOS 八字排盘工具。
```

建议 Topics：

```text
bazi
four-pillars
swift
swiftui
macos
chinese-calendar
lunar-calendar
offline-first
privacy
```

## Recommended Settings

- Default branch: `main`
- Enable Issues and Discussions
- Enable private vulnerability reporting
- Enable Dependabot alerts and security updates
- Require the `CI / build-and-test` check before merging
- Require pull requests for the default branch once outside contributors arrive
- Disable Wiki unless it will be maintained
- Use `docs/assets/app-overview.png` as the social preview

## Before the First Push

- Review the default sample chart and screenshot for personal information.
- Confirm the MIT license is the intended license.
- Confirm the name `BaziChart` and bundle identifier `app.bazichart.macos`.
- Review the third-party notices.
- Run `./script/test.sh`.
- Run `./script/build_and_run.sh build`.
- Confirm only the contents of this directory are uploaded, not its parent workspace.

## First Release

After the repository is public:

1. Update the README if the final repository URL changes any installation instructions.
2. Commit the reviewed source.
3. Create and push tag `v0.1.0`.
4. Wait for the Release workflow.
5. Download and test the exact archive attached to the GitHub Release.
6. Add the release link to the repository sidebar.

Do not upload signing certificates, provisioning profiles, Apple credentials, real saved profiles or files from the parent workspace.
