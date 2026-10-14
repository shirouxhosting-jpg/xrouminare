#!/usr/bin/env bash
# XROUMINARE — roll back to the stock Pterodactyl frontend.
#
# Usage (on the VPS):
#   bash uninstall.sh /var/www/pterodactyl [backup-directory]
#
# If no backup directory is given, the most recent .xrou-backup-* inside the
# panel directory is used. After restoring, the frontend is rebuilt.
set -euo pipefail

PANEL_DIR="${1:-/var/www/pterodactyl}"
[ -d "$PANEL_DIR" ] || { echo "ERROR: panel directory not found." >&2; exit 1; }

if [ -n "${2:-}" ]; then
    BACKUP="$2"
else
    BACKUP="$(ls -1dt "$PANEL_DIR"/.xrou-backup-* 2>/dev/null | head -1 || true)"
fi
[ -n "${BACKUP:-}" ] && [ -d "$BACKUP" ] || { echo "ERROR: no .xrou-backup-* directory found." >&2; exit 1; }

echo "Restoring from $BACKUP ..."
cd "$BACKUP"
find . -type f -print0 | while IFS= read -r -d '' f; do
    rel="${f#./}"
    cp -a "$f" "$PANEL_DIR/$rel"
done
echo "Files restored."

# Remove theme-only files (they are additive, safe to delete on rollback).
rm -rf "$PANEL_DIR/resources/scripts/components/xrou"
rm -f "$PANEL_DIR/resources/scripts/assets/css/xrou-theme.css"

cd "$PANEL_DIR"
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$NODE_MAJOR" -ge 17 ]; then
    export NODE_OPTIONS="--openssl-legacy-provider${NODE_OPTIONS:+ $NODE_OPTIONS}"
fi
yarn build:production
command -v php >/dev/null 2>&1 && php artisan view:clear >/dev/null 2>&1 || true

echo "Stock frontend restored. Hard refresh (Ctrl+F5) the panel."
