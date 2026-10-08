# SoftDiary → Codemagic

## Repository

- **GitHub**: https://github.com/dale454071867/SoftDiary  
- **Branch**: `main`  
- **Config**: `codemagic.yaml`（仓库根目录）

## 在 Codemagic 添加应用

1. 打开 https://codemagic.io 并用 **GitHub** 登录  
2. 授权访问账号 `dale454071867`（若未授权点 Connect repository）  
3. **Add application** → 选择 **SoftDiary**  
4. Project type 选检测 `codemagic.yaml` / Other（native iOS）  
5. 先跑工作流 **SoftDiary iOS Debug**（无需证书）

直接入口（登录后）：  
https://codemagic.io/apps

## 工作流说明

| Workflow ID | 名称 | 用途 |
|-------------|------|------|
| `ios-debug` | SoftDiary iOS Debug | 无签名模拟器构建，验证 CI |
| `ios-appstore` | SoftDiary App Store IPA | 需上传证书/描述文件后打 IPA |

## App Store IPA 前置

1. Codemagic → Team settings → **Code signing identities**  
   - 上传 Distribution Certificate + App Store Profile（`com.softdiary.app`）  
2. （可选）**Integrations → App Store Connect** 添加 API Key  
3. 在 `codemagic.yaml` 里取消注释 `integrations` / TestFlight publishing  

## Support URLs（App Store Connect）

- Support: https://softdiary-support.454071867.workers.dev  
- Privacy: https://softdiary-support.454071867.workers.dev/privacy  
- Terms: https://softdiary-support.454071867.workers.dev/terms  

## 本地更新后推送

```bash
cd "/Users/zhoujie/MyPoject/工具/马甲/空2"
git add -A
git commit -m "Update SoftDiary"
git push origin main
```

推送后 Codemagic 可手动 Start build，或按 yaml 里配置的触发条件自动构建。
