#!/bin/zsh
# Open SoftDiary in Xcode without RVM Ruby env (fixes ipatool / nkf errors)
killall Xcode 2>/dev/null
sleep 1
env -i \
  HOME="$HOME" \
  USER="$USER" \
  LOGNAME="$LOGNAME" \
  TMPDIR="$TMPDIR" \
  PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/homebrew/bin" \
  LANG="${LANG:-en_US.UTF-8}" \
  /usr/bin/open -a Xcode "$(cd "$(dirname "$0")" && pwd)/SoftDiary.xcodeproj"
