# SoftDiary → Codemagic

## Repo

GitHub: *(filled after push)*

## Quick start on Codemagic

1. Open [https://codemagic.io](https://codemagic.io) and sign in with **GitHub**
2. **Add application** → select the `SoftDiary` / `softdiary` repository
3. Project type: **Other** (native iOS) / scan for `codemagic.yaml`
4. Start workflow **SoftDiary iOS Debug** first (no signing needed)

## App Store IPA workflow

Before running **SoftDiary App Store IPA**:

1. Codemagic → Team settings → **Code signing identities**
   - Upload distribution certificate + App Store provisioning profile for `com.softdiary.app`
   - Or use automatic signing via App Store Connect API key
2. (Optional) **Integrations → App Store Connect** — add API key, then uncomment `integrations` / `publishing.app_store_connect` in `codemagic.yaml`
3. Set Team ID in Xcode / Codemagic signing to your Apple Developer Team

## Local files

| File | Purpose |
|------|---------|
| `codemagic.yaml` | CI workflows |
| `SoftDiary.xcodeproj` | Xcode project |
| `project.yml` | XcodeGen source (optional regenerate) |

## Support URLs (App Store Connect)

- Support: https://softdiary-support.454071867.workers.dev
- Privacy: https://softdiary-support.454071867.workers.dev/privacy
- Terms: https://softdiary-support.454071867.workers.dev/terms
