#!/usr/bin/env bash
set -euo pipefail

link_agent() {
  local target="$1"
  local label="$2"

  local candidate
  candidate="$(/bin/ls -t /nix/store/*${label}.plist 2>/dev/null | /usr/bin/head -n 1 || true)"

  if [ -z "$candidate" ]; then
    return 0
  fi

  local current
  current="$(/usr/bin/readlink "$target" 2>/dev/null || true)"

  if [ "$current" != "$candidate" ]; then
    /bin/ln -sfn "$candidate" "$target"
    /bin/launchctl bootout "gui/$UID" "$target" 2>/dev/null || true
    /bin/launchctl bootstrap "gui/$UID" "$target" 2>/dev/null || true
  fi

  /bin/launchctl kickstart -k "gui/$UID/$label" 2>/dev/null || true
}

link_agent "$HOME/Library/LaunchAgents/com.steipete.clawdbot.gateway.nix.plist" \
  "com.steipete.clawdbot.gateway.nix"

link_agent "$HOME/Library/LaunchAgents/com.steipete.clawdbot.gateway.nix-test.plist" \
  "com.steipete.clawdbot.gateway.nix-test"

link_agent "$HOME/Library/LaunchAgents/com.steipete.clawdbot.gateway.prod.plist" \
  "com.steipete.clawdbot.gateway.prod"
