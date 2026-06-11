# 参与贡献 / Contributing

感谢你愿意改进 BaziChart。小而清楚的提交最容易审查和合并。

## 提交 Issue

- 先搜索现有 Issue，避免重复。
- Bug 请写明 macOS 版本、设备架构、复现步骤和预期结果。
- 命例计算问题请提供可公开的测试数据，并说明你采用的流派或规则。
- 不要发布真实姓名、精确出生信息或其他未经同意的个人资料。

## 本地开发

```bash
swift build
./script/test.sh
./script/build_and_run.sh
```

提交 Pull Request 前，请确保：

1. `./script/test.sh` 通过。
2. `./script/build_and_run.sh build` 能生成自包含 App。
3. 新增计算规则有固定命例测试。
4. 用户可见变化同步更新中英文文档。
5. 没有提交 `.build`、`dist`、用户档案或签名凭据。

## Pull Request

说明问题、解决方式和验证方法。界面改动请附前后截图；算法改动请说明参考规则和边界条件。一次 PR 尽量只解决一个主题。

---

Thank you for improving BaziChart. Small, focused changes are the easiest to review and merge.

## Opening an Issue

- Search existing issues first.
- For bugs, include the macOS version, CPU architecture, reproduction steps and expected result.
- For calculation discrepancies, provide a shareable test case and state the convention or school being used.
- Do not post real names, precise birth data or personal information without consent.

## Local Development

```bash
swift build
./script/test.sh
./script/build_and_run.sh
```

Before opening a pull request:

1. Make sure `./script/test.sh` passes.
2. Build a self-contained app with `./script/build_and_run.sh build`.
3. Add a fixed test case for new calculation rules.
4. Update both Chinese and English user-facing documentation.
5. Do not commit build output, profiles, signing material or credentials.

Describe the problem, the approach and the verification performed. Include before/after screenshots for interface changes and references plus edge cases for calculation changes. Keep each pull request focused on one topic.
