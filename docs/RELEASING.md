# Release Checklist / 发布清单

1. Update `CHANGELOG.md`.
2. Update `CFBundleShortVersionString` and `CFBundleVersion` in `script/build_and_run.sh`.
3. Run:

   ```bash
   ./script/test.sh
   ./script/build_and_run.sh build
   ```

4. Launch `dist/八字排盘.app` on a clean macOS user account and verify location search, profile persistence and copy output.
5. Confirm that no profile, signing file, credential or personal screenshot is included.
6. Commit the release changes and create a tag such as `v0.1.0`.
7. Push the tag. The release workflow builds an architecture-labelled `BaziChart-macOS-*.zip` and attaches it to a GitHub Release.
8. Download the uploaded archive and test that exact artifact before announcing the release.

Current automated builds are unsigned. Code signing and notarization should be added before presenting releases as trusted end-user downloads.
