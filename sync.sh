#!/usr/bin/env bash
# Copy the live configs into this repo, then commit and push if anything changed.
# Meant to run daily from cron/systemd. Configs already symlinked to the repo are skipped.
# Aborts without committing if a staged change looks like a secret.

set -euo pipefail
export PATH="/usr/local/bin:/usr/bin:/bin"

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-sync.log"
mkdir -p "$(dirname "$LOG")"
exec >> "$LOG" 2>&1
exec 9> "$DOTFILES/.git/sync.lock"
flock -n 9 || { echo "$(date -Iseconds) already running"; exit 0; }

log() { echo "$(date -Iseconds) $*"; }

EXCLUDES=(--exclude 'plugins/hassio/settings.json' --exclude '*.bak' --exclude '*.log')

# sync_dir <live dir> <repo dir>
sync_dir() {
    local src="$1" dst="$2"
    [ -L "$src" ] && return      # already a symlink into the repo
    [ -d "$src" ] || { log "missing $src, skipped"; return; }
    mkdir -p "$dst"
    rsync -a --delete "${EXCLUDES[@]}" "$src/" "$dst/"
}

# sync_file <live file> <repo file>
sync_file() {
    local src="$1" dst="$2"
    [ -L "$src" ] && return
    [ -f "$src" ] || { log "missing $src, skipped"; return; }
    mkdir -p "$(dirname "$dst")"
    rsync -a "$src" "$dst"
}

sync_dir  "$HOME/.config/hypr"                   "$DOTFILES/config/hypr"
sync_dir  "$HOME/.config/noctalia"               "$DOTFILES/config/noctalia"
sync_dir  "$HOME/.config/alacritty"              "$DOTFILES/config/alacritty"
sync_file "$HOME/.config/ghostty/config.ghostty" "$DOTFILES/config/ghostty/config.ghostty"
for s in sunshine-start.sh sunshine-connect.sh sunshine-disconnect.sh sunshine-after-sleep.sh; do
    sync_file "$HOME/.local/bin/$s" "$DOTFILES/bin/$s"
done

cd "$DOTFILES"
git add -A

if git diff --cached --quiet; then
    log "no changes"
    exit 0
fi

# Secret guard: JWTs (Home Assistant tokens), private LAN IPs, common key names with a value.
if git diff --cached -U0 | grep -E '^\+' | grep -qiE \
    'eyJ[A-Za-z0-9_-]{10,}\.|(^|[^0-9])(10|192\.168|172\.(1[6-9]|2[0-9]|3[01]))\.[0-9]+\.[0-9]+|"(token|apikey|api_key|password|secret)[A-Za-z]*" *: *"[^"]+"'; then
    log "ABORT: staged changes look like a secret, nothing committed. Check: git -C $DOTFILES diff --cached"
    git reset -q
    exit 1
fi

git commit -q -m "chore: sync configs $(date +%F)"
if git push -q; then
    log "pushed $(git rev-parse --short HEAD)"
else
    log "push failed, commit kept locally"
    exit 1
fi
