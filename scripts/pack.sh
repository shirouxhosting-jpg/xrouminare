#!/usr/bin/env bash
# XROUMINARE — pack the theme files into a deployable bundle.
# Run from the project root (or anywhere): packs the modified/new files
# from panel/ into theme-bundle/ which install.sh copies onto a VPS.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PANEL="$ROOT/panel"
BUNDLE="$ROOT/theme-bundle"

FILES=(
    "tailwind.config.js"
    "resources/views/templates/wrapper.blade.php"
    "resources/scripts/assets/css/xrou-theme.css"
    "resources/scripts/assets/css/GlobalStylesheet.ts"
    "resources/scripts/components/App.tsx"
    "resources/scripts/components/MessageBox.tsx"
    "resources/scripts/components/xrou/index.ts"
    "resources/scripts/components/xrou/themeStore.ts"
    "resources/scripts/components/xrou/Logo.tsx"
    "resources/scripts/components/xrou/ThemeToggle.tsx"
    "resources/scripts/components/xrou/Card.tsx"
    "resources/scripts/components/xrou/Badge.tsx"
    "resources/scripts/components/xrou/EmptyState.tsx"
    "resources/scripts/components/xrou/Skeleton.tsx"
    "resources/scripts/components/xrou/StatCard.tsx"
    "resources/scripts/components/xrou/ServerCard.tsx"
    "resources/scripts/components/xrou/AppShell.tsx"
    "resources/scripts/components/xrou/PasswordField.tsx"
    "resources/scripts/components/xrou/navIcons.ts"
    "resources/scripts/components/elements/Button.tsx"
    "resources/scripts/components/elements/Input.tsx"
    "resources/scripts/components/elements/Modal.tsx"
    "resources/scripts/components/elements/GreyRowBox.tsx"
    "resources/scripts/components/elements/ScreenBlock.tsx"
    "resources/scripts/components/elements/DropdownMenu.tsx"
    "resources/scripts/components/elements/dialog/style.module.css"
    "resources/scripts/components/elements/activity/style.module.css"
    "resources/scripts/components/elements/button/style.module.css"
    "resources/scripts/components/server/console/Console.tsx"
    "resources/scripts/components/server/console/style.module.css"
    "resources/scripts/components/auth/LoginFormContainer.tsx"
    "resources/scripts/components/auth/LoginContainer.tsx"
    "resources/scripts/components/dashboard/DashboardContainer.tsx"
    "resources/scripts/routers/DashboardRouter.tsx"
    "resources/scripts/routers/ServerRouter.tsx"
)

[ -d "$PANEL" ] || { echo "panel/ source not found at $PANEL" >&2; exit 1; }

rm -rf "$BUNDLE"
mkdir -p "$BUNDLE"

missing=0
for f in "${FILES[@]}"; do
    if [ -f "$PANEL/$f" ]; then
        mkdir -p "$BUNDLE/$(dirname "$f")"
        cp "$PANEL/$f" "$BUNDLE/$f"
    else
        echo "MISSING: $f" >&2
        missing=1
    fi
done

[ "$missing" -eq 0 ] || { echo "Bundle incomplete" >&2; exit 1; }

count=$(find "$BUNDLE" -type f | wc -l)
echo "Packed $count files into $BUNDLE"
