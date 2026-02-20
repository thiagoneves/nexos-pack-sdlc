#!/usr/bin/env bash
# nexos installer
# Usage: curl -fsSL https://raw.githubusercontent.com/<user>/nexos/main/install.sh | bash

set -euo pipefail

NEXOS_HOME="${NEXOS_HOME:-$HOME/.nexos}"
REPO_URL="https://github.com/thiagoneves/nexos.git"

echo "Installing nexos..."

# Clone or update
if [[ -d "$NEXOS_HOME" ]]; then
  echo "Updating existing installation..."
  cd "$NEXOS_HOME" && git pull --quiet
else
  echo "Cloning nexos..."
  git clone --depth 1 "$REPO_URL" "$NEXOS_HOME"
fi

# Make CLI executable
chmod +x "$NEXOS_HOME/bin/nexos"

# Add to PATH if not already there
SHELL_RC=""
if [[ -f "$HOME/.zshrc" ]]; then
  SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
  SHELL_RC="$HOME/.bashrc"
fi

if [[ -n "$SHELL_RC" ]]; then
  if ! grep -q 'NEXOS_HOME' "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# nexos" >> "$SHELL_RC"
    echo "export NEXOS_HOME=\"$NEXOS_HOME\"" >> "$SHELL_RC"
    echo 'export PATH="$NEXOS_HOME/bin:$PATH"' >> "$SHELL_RC"
    echo "Added nexos to PATH in $SHELL_RC"
    echo "Run: source $SHELL_RC"
  else
    echo "nexos already in PATH"
  fi
fi

echo ""
echo "nexos installed successfully!"
echo ""
echo "Usage:"
echo "  nexos init --tool claude-code    # Initialize project"
echo "  nexos install <user/pack-repo>   # Install a pack"
echo "  nexos help                       # Show all commands"
