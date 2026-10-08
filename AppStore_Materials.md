# SoftDiary — App Store Submission Materials

> App display name: **SoftDiary**  
> Bundle ID: `com.softdiary.app`  
> Language: English (UI)  
> Platform: iOS 17.0+  
> Version: 1.0.0

---

## 1. Basic Info

| Field | Value |
|------|--------|
| App Name | SoftDiary |
| Subtitle (30 chars) | Cute journal with portraits |
| Primary Category | Lifestyle |
| Secondary Category | Health & Fitness（可选） / Productivity（可选） |
| Content Rights | Does not contain third-party content you don’t own |
| Age Rating | 4+（无限制内容） |
| Price | Free（后续可加 IAP） |

**Subtitle alternatives（≤30）**
- Mood journal & doodles
- Portrait diary & sketches
- Soft daily mood notes

---

## 2. Promotional Text (170 chars)

```
SoftDiary is a cute local journal: mood portraits, doodles, photos, voice notes, themes, lock, and export — all on your device.
```

---

## 3. Description (App Store)

```
SoftDiary is a soft, cartoon-style journal for everyday feelings.

Capture your day with mood portraits, doodles, photos, and voice notes. Browse by calendar, see mood stats, lock your journal, switch cute themes, and export entries when you want to share or keep a backup.

FEATURES
• Write journal entries with title, body, tags, and writing prompts
• Mood portraits with 6 poses (Idle, Wave, Cheer, Shy, Sit, Sleep)
• Draw doodles with colors, brush sizes, and eraser
• Add photos from Library or Camera
• Record voice notes and play them back
• Search, filter by mood / tag / favorites
• Calendar view for daily entries
• Mood stats, streaks, and favorites wall
• Portrait gallery to preview poses and jump into writing
• App lock with 4-digit PIN and Face ID / Touch ID
• 6 theme skins
• Export one entry (card / text) or all entries as a text file
• Fully local storage — no account required

PRIVACY FIRST
Your journals, photos, doodles, and voice notes stay on your device by default. SoftDiary only uses Camera, Photos, Microphone, and Face ID when you choose those features.

Start a gentle daily habit with SoftDiary.
```

---

## 4. Keywords (100 chars, comma-separated, no spaces after commas if you want to save chars)

```
journal,diary,mood,portrait,doodle,sketch,voice,notes,calendar,lock,theme,cute,local,habits
```

（实际粘贴时注意总长度 ≤100，可按需删减：`habits` / `cute` / `theme`）

Suggested trimmed set:
```
journal,diary,mood,portrait,doodle,voice,notes,calendar,lock,theme,cute,local
```

---

## 5. What’s New (1.0.0)

```
Welcome to SoftDiary 1.0!

• Mood portraits and poses
• Doodles, photos, and voice notes
• Calendar, stats, and favorites
• Themes, PIN / Face ID lock, and export
• Fully local journaling
```

---

## 6. App Review Notes（给审核看）

```
SoftDiary is a local journal app. No login is required.

Test tips:
1. On launch, tap “Enter Journal”. Terms/Privacy links are available on the splash screen.
2. Tap “Write Journal” on Home to create an entry.
3. Optional features needing permission:
   - Photos / Camera: add images to an entry
   - Microphone: record a voice note
   - Face ID: enable App Lock in Settings, then set a 4-digit PIN and turn on biometrics
4. All journal data is stored locally on device.

Demo content may appear on first launch for preview; it can be deleted by the user.
```

---

## 7. Privacy（App Privacy / 营养标签）

### Data Not Collected（若确实无统计/广告 SDK）
若当前版本无第三方分析、广告、云同步，可声明：

- **Data Collection**: Data Not Collected  
  （或仅声明设备上处理、不收集到开发者服务器）

### 若按权限细分说明（推荐写在 Privacy Policy）

| Permission | Purpose | Linked to User | Used for Tracking |
|------------|---------|----------------|-------------------|
| Camera | Take journal photos | No | No |
| Photo Library | Choose journal photos | No | No |
| Microphone | Record voice notes | No | No |
| Face ID | Unlock app lock | No | No |

**Storage:** local device only (Documents / app sandbox).  
**No account / no server sync in 1.0.**

Privacy Policy & Terms: in-app (Settings + splash links).  
若审核要求 URL，需自行托管英文页面，例如：
- `https://your-domain.com/softdiary/privacy`
- `https://your-domain.com/softdiary/terms`

（应用内已有完整英文正文，可直接复制上线。）

---

## 8. Screenshot Plan（建议文案）

尺寸按当前设备：6.7" / 6.5" 等各准备一套。

| # | Screen | Caption |
|---|--------|---------|
| 1 | Home + write card | Soft days, soft notes |
| 2 | Write entry + mood portrait | Pick a mood portrait |
| 3 | Doodle / photos / voice | Draw, snap, or speak |
| 4 | Calendar | Relive days on the calendar |
| 5 | Stats / themes / lock | Themes, lock, and insights |

Caption tips: ≤30–40 characters, English, no competitor names.

---

## 9. Support & Contact

| Field | Suggested |
|------|-----------|
| Support URL | `https://softdiary-support.454071867.workers.dev` |
| Privacy Policy URL | `https://softdiary-support.454071867.workers.dev/privacy` |
| Terms of Use URL | `https://softdiary-support.454071867.workers.dev/terms` |
| Marketing URL | （可选）同上 Support URL |
| Copyright | `© 2026 SoftDiary` |
| Contact Email | `support@softdiary.app`（页面上已写，可改成你的真实邮箱） |

---

## 10. Build / Archive Checklist

1. Open with clean Ruby env (avoid RVM breaking `ipatool`):
   ```bash
   ./open-xcode-clean.sh
   ```
2. Select Team + unique Bundle ID if needed  
3. Version `1.0.0`, Build `1`  
4. Release / Any iOS Device → **Product → Archive**  
5. Distribute App → App Store Connect  
6. In App Store Connect fill:
   - Description / Keywords / Screenshots  
   - Privacy Policy URL  
   - App Privacy questionnaire  
   - Review Notes（第 6 节）  

---

## 11. One-line Pitch（可选）

English:  
**SoftDiary — a cute local journal with mood portraits, doodles, photos, and voice notes.**

中文备忘（不上架文案，仅你自己用）：  
**SoftDiary：卡通风本地日记，立绘心情 + 涂鸦 + 照片 + 语音。**

---

## 12. In-App Legal Titles（与应用内一致）

- Terms of Use  
- Privacy Policy  

正文位置：`SoftDiary/Legal/LegalDocuments.swift`  
上架若需网页版，直接导出该英文正文即可。
