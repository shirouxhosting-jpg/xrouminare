#!/usr/bin/env bash
# XROUMINARE theme installer for Pterodactyl Panel v1.11.x.
#
# Usage (on the VPS, as root or the panel owner):
#   bash install.sh /var/www/pterodactyl
#
# What it does:
#   1. Verifies the panel directory & version.
#   2. Backs up every file that will be overwritten to
#      <panel>/.xrou-backup-<timestamp>/.
#   3. Copies the XROUMINARE theme files into the panel source.
#   4. Rebuilds the frontend assets.
#   5. Clears compiled blade views (wrapper template changed).
#
# It never touches the database and never modifies backend logic.
set -euo pipefail

PANEL_DIR="${1:-/var/www/pterodactyl}"
BUNDLE_DIR="$(cd "$(dirname "$0")/../theme-bundle" && pwd)"

[ -d "$PANEL_DIR" ] || { echo "ERROR: panel directory $PANEL_DIR not found." >&2; exit 1; }
[ -f "$PANEL_DIR/composer.json" ] || { echo "ERROR: $PANEL_DIR does not look like a Pterodactyl panel." >&2; exit 1; }
[ -d "$BUNDLE_DIR" ] || { echo "ERROR: theme-bundle/ not found. Run scripts/pack.sh first (see README)." >&2; exit 1; }

command -v yarn >/dev/null 2>&1 || { echo "ERROR: yarn is required (npm i -g yarn or corepack enable)." >&2; exit 1; }

# --- version check ----------------------------------------------------------
if command -v php >/dev/null 2>&1; then
    VERSION="$(php -r "\$c = json_decode(file_get_contents('$PANEL_DIR/composer.json'), true); echo \$c['version'] ?? '';")"
    if [ -z "$VERSION" ]; then
        VERSION="$(grep -oP "'version' => '\K[^']+" "$PANEL_DIR/config/app.php" | head -1 || echo unknown)"
    fi
    echo "Detected panel version: $VERSION"
    if [ "$VERSION" = "canary" ] || [ -z "$VERSION" ]; then
        echo "NOTE: version reads as 'canary' — verify manually that the panel is v1.11.x."
    elif [[ "$VERSION" != 1.11* ]]; then
        echo "WARNING: this theme targets v1.11.x. Continuing anyway — verify visually after build."
    fi
else
    echo "WARNING: php CLI not found; skipping version detection."
fi

# --- backup -----------------------------------------------------------------
BACKUP="$PANEL_DIR/.xrou-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
cd "$BUNDLE_DIR"
while IFS= read -r -d '' f; do
    rel="${f#./}"
    if [ -f "$PANEL_DIR/$rel" ]; then
        mkdir -p "$BACKUP/$(dirname "$rel")"
        cp -a "$PANEL_DIR/$rel" "$BACKUP/$rel"
    fi
done < <(find . -type f -print0)
echo "Backup of overwritten files saved to $BACKUP"

# --- copy theme -------------------------------------------------------------
cd "$BUNDLE_DIR"
find . -type f -print0 | while IFS= read -r -d '' f; do
    rel="${f#./}"
    mkdir -p "$PANEL_DIR/$(dirname "$rel")"
    cp -a "$f" "$PANEL_DIR/$rel"
done
echo "Theme files copied."

# --- build ------------------------------------------------------------------
cd "$PANEL_DIR"
echo "Installing JS dependencies (this can take a few minutes)..."
yarn install --ignore-engines --network-timeout 600000

NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$NODE_MAJOR" -ge 17 ]; then
    export NODE_OPTIONS="--openssl-legacy-provider${NODE_OPTIONS:+ $NODE_OPTIONS}"
fi
echo "Building production assets..."
yarn build:production

# --- finish -----------------------------------------------------------------
if command -v php >/dev/null 2>&1; then
    php artisan view:clear >/dev/null 2>&1 || true
fi
if command -v chown >/dev/null 2>&1 && [ -n "${SUDO_USER:-}" ]; then
    chown -R "$SUDO_USER":"$SUDO_USER" "$PANEL_DIR/public/assets" || true
fi

echo ""
echo "XROUMINARE theme installed successfully."
echo " - Theme mode: toggle Light/System/Dark in the sidebar footer (saved in the browser)."
echo " - Rollback:   bash $(cd "$(dirname "$0")" && pwd)/uninstall.sh $PANEL_DIR"
echo " - Hard refresh (Ctrl+F5) the panel in your browser to pick up the new assets."
