# SoftDiary

A cute, minimal journal iOS app built with SwiftUI. Diary artwork uses **code-drawn character portraits** instead of photo-library images for the portrait feature.

## Features

- Write entries: title, body, date, tags, writing prompts
- **Mood portraits + 6 poses** (Idle / Wave / Cheer / Shy / Sit / Sleep)
- Home search and mood / tag / favorites filters
- Calendar: browse portrait journals by day
- Mood stats: distribution bars, streaks, favorites wall
- Portrait gallery: preview combos and jump into writing
- Favorite, edit, delete
- Local JSON storage — no account, no network required

## Open

```bash
cd "/Users/zhoujie/MyPoject/工具/马甲/空2"
xcodegen generate
open SoftDiary.xcodeproj
```

## Before shipping

1. Add a 1024 App Icon
2. Disable `seedDemoIfNeeded` for production builds if desired
3. Provide a privacy policy (recommended even for fully local apps)
