#!/usr/bin/env bash
# Dailybot skill pack setup — creates symlinks so each sub-skill is independently
# discoverable by any agent platform.
#
# Usage:
#   ./setup                 # auto-detect agent platform
#   ./setup --host claude   # explicit: Claude Code
#   ./setup --host cursor   # explicit: Cursor
#   ./setup --host codex    # explicit: OpenAI Codex
#   ./setup --host auto     # detect all installed agents
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACK_DIR="$SCRIPT_DIR/skills/dailybot"
PACK_NAME="dailybot"

if [ ! -d "$PACK_DIR" ]; then
  echo "Pack directory not found at $PACK_DIR" >&2
  echo "This script must run from the root of the agent-skill repository." >&2
  exit 1
fi

# ─── Parse flags ──────────────────────────────────────────────
HOST=""
while [ $# -gt 0 ]; do
  case "$1" in
    --host)
      if [ $# -lt 2 ] || [ -z "${2:-}" ]; then
        echo "Missing value for --host" >&2
        exit 1
      fi
      HOST="$2"; shift 2 ;;
    --host=*) HOST="${1#--host=}"; shift ;;
    -h|--help)
      echo "Usage: ./setup.sh [--host claude|cursor|codex|windsurf|copilot|cline|gemini|auto]"
      echo ""
      echo "Creates symlinks for each Dailybot sub-skill so your agent discovers them."
      echo "Run without --host to auto-detect, or specify an agent explicitly."
      exit 0
      ;;
    *) shift ;;
  esac
done

# ─── Agent skill directory map ────────────────────────────────
resolve_skills_dir() {
  local agent="$1"
  case "$agent" in
    claude)   echo "$HOME/.claude/skills" ;;
    cursor)   echo "$HOME/.cursor/skills" ;;
    codex)    echo "$HOME/.codex/skills" ;;
    windsurf) echo "$HOME/.codeium/windsurf/skills" ;;
    copilot)  echo "$HOME/.copilot/skills" ;;
    cline)    echo "$HOME/.cline/skills" ;;
    gemini)   echo "$HOME/.gemini/skills" ;;
    *) echo "" ;;
  esac
}

# ─── Sub-skills to link ──────────────────────────────────────
SKILLS=("report" "messages" "email" "health" "checkin" "kudos" "teams" "forms" "chat")

# ─── Link one agent ──────────────────────────────────────────
link_agent() {
  local agent="$1"
  local skills_dir
  skills_dir="$(resolve_skills_dir "$agent")"
  if [ -z "$skills_dir" ]; then
    echo "Unknown agent: $agent" >&2
    return 1
  fi

  mkdir -p "$skills_dir"

  local linked=()

  # Ensure the pack directory itself is accessible.
  # If the repo was cloned directly into the skills dir (e.g. ~/.cursor/skills/dailybot/),
  # no pack-level symlink is needed. Otherwise, create one pointing at PACK_DIR.
  local pack_target="$skills_dir/$PACK_NAME"
  if [ ! -e "$pack_target" ] && [ "$PACK_DIR" != "$pack_target" ]; then
    ln -snf "$PACK_DIR" "$pack_target"
    echo "  $PACK_NAME -> $PACK_DIR"
  fi

  for skill in "${SKILLS[@]}"; do
    local skill_dir="$PACK_DIR/$skill"
    if [ -f "$skill_dir/SKILL.md" ]; then
      local link_name="dailybot-$skill"
      local target="$skills_dir/$link_name"
      if [ -L "$target" ] || [ ! -e "$target" ]; then
        ln -snf "$skill_dir" "$target"
        linked+=("$link_name")
      else
        echo "  skipped $link_name (real file/directory exists)" >&2
      fi
    fi
  done

  if [ ${#linked[@]} -gt 0 ]; then
    echo "  linked: ${linked[*]}"
  fi
}

# ─── Auto-detect installed agents ────────────────────────────
detect_agents() {
  local found=()
  # Check for agent-specific directories or commands
  [ -d "$HOME/.claude" ]                   && found+=("claude")
  [ -d "$HOME/.cursor" ]                   && found+=("cursor")
  command -v codex >/dev/null 2>&1         && found+=("codex")
  [ -d "$HOME/.codex" ]                    && found+=("codex")
  [ -d "$HOME/.codeium/windsurf" ]         && found+=("windsurf")
  [ -d "$HOME/.copilot" ]                  && found+=("copilot")
  [ -d "$HOME/.cline" ]                    && found+=("cline")
  [ -d "$HOME/.gemini" ]                   && found+=("gemini")

  # Deduplicate
  if [ ${#found[@]} -gt 0 ]; then
    printf '%s\n' "${found[@]}" | sort -u
  fi
}

# ─── Main ─────────────────────────────────────────────────────
echo "Dailybot skill pack setup"
echo "Pack directory: $PACK_DIR"
echo ""

if [ -z "$HOST" ] || [ "$HOST" = "auto" ]; then
  agents=()
  while IFS= read -r line; do
    [ -n "$line" ] && agents+=("$line")
  done < <(detect_agents)
  if [ "${#agents[@]}" -eq 0 ]; then
    echo "No known agent platforms detected."
    echo "Install the pack manually by cloning into your agent's skill directory."
    echo "See README.md for paths."
    exit 0
  fi
  for agent in "${agents[@]}"; do
    echo "[$agent]"
    link_agent "$agent"
  done
else
  echo "[$HOST]"
  link_agent "$HOST"
fi

echo ""
echo "Done. Available skills:"
echo "  dailybot-report    — report progress after completing work"
echo "  dailybot-messages  — check for pending messages from the team"
echo "  dailybot-email     — send emails via Dailybot"
echo "  dailybot-health    — announce agent status and receive messages"
echo "  dailybot-checkin   — list and complete pending check-ins"
echo "  dailybot-kudos     — give kudos to a teammate or to a whole team"
echo "  dailybot-teams     — list, inspect, and resolve teams (used by kudos / chat)"
echo "  dailybot-forms     — list and submit form responses"
echo "  dailybot-chat      — send / edit bot messages on Slack/Teams/Discord/Google Chat"
echo ""
echo "The root 'dailybot' skill acts as a router if your agent discovers it."
