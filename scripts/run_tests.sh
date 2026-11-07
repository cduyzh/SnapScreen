#!/bin/bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

APP_BIN="$PROJECT_DIR/.build.noindex/iScreenshot.app/Contents/MacOS/cduyzhShot"
if [ ! -x "$APP_BIN" ]; then
    echo "===> 未找到可执行文件，正在构建 iScreenshot..."
    ./build_app.sh
fi

echo "===> 运行 iScreenshot 自动化功能与健壮性测试套件..."
"$APP_BIN" --test
echo "===> iScreenshot 自动化测试全部通过！"
