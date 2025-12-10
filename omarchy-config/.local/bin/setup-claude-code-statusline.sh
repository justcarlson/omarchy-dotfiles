#!/bin/bash
# Setup Claude Code status line with git info and context percentage
# Based on: https://www.aihero.dev/creating-the-perfect-claude-code-status-line

set -e

echo "Setting up Claude Code status line..."

# Install ccstatusline
echo "📦 Installing ccstatusline..."
if npm install -g ccstatusline; then
    echo "✅ ccstatusline installed"
else
    echo "❌ Failed to install ccstatusline"
    exit 1
fi

# Create config directories
mkdir -p ~/.config/ccstatusline
mkdir -p ~/.claude

# Create ccstatusline config
echo "📝 Creating ccstatusline config..."
cat > ~/.config/ccstatusline/settings.json << 'EOF'
{
  "version": 3,
  "lines": [
    [
      {
        "id": "1",
        "type": "context-percentage",
        "color": "yellow",
        "bold": true,
        "rawValue": true
      }
    ],
    [],
    []
  ],
  "flexMode": "full-minus-40",
  "compactThreshold": 60,
  "colorLevel": 2,
  "inheritSeparatorColors": false,
  "globalBold": false,
  "powerline": {
    "enabled": false,
    "separators": [""],
    "separatorInvertBackground": [false],
    "startCaps": [],
    "endCaps": [],
    "autoAlign": false
  }
}
EOF

# Create git status script
echo "📝 Creating statusline-command.sh..."
cat > ~/.claude/statusline-command.sh << 'EOF'
#!/bin/bash
# Read JSON input
input=$(cat)

# Extract cwd from JSON
cwd=$(echo "$input" | sed -n 's/.*"current_dir":"\([^"]*\)".*/\1/p')

# Git information
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  # Get repo name relative to ~/repos/ or just basename
  if [[ "$cwd" == "$HOME/repos/"* ]]; then
    repo_name=$(echo "$cwd" | sed "s|^$HOME/repos/||")
  else
    repo_name=$(basename "$cwd")
  fi

  # Get branch
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

  # Count staged files
  staged=$(git -C "$cwd" --no-optional-locks diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')

  # Count unstaged files
  unstaged=$(git -C "$cwd" --no-optional-locks diff --name-only 2>/dev/null | wc -l | tr -d ' ')

  # Count untracked files
  untracked=$(git -C "$cwd" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

  printf '\033[01;36m%s\033[00m | \033[01;32m%s\033[00m | S: \033[01;33m%s\033[00m | U: \033[01;33m%s\033[00m | A: \033[01;33m%s\033[00m' \
    "$repo_name" "$branch" "$staged" "$unstaged" "$untracked"
else
  # Not a git repo
  printf '\033[01;36m%s\033[00m' "$(basename "$cwd")"
fi
EOF

# Create wrapper script
echo "📝 Creating statusline-wrapper.sh..."
cat > ~/.claude/statusline-wrapper.sh << 'EOF'
#!/bin/bash
# Read JSON input once
input=$(cat)

# Get git info
git_info=$(echo "$input" | bash ~/.claude/statusline-command.sh)

# Get context percentage from ccstatusline
context_pct=$(echo "$input" | npx ccstatusline 2>/dev/null || echo "?%")

# Combine outputs
printf '%s | %s' "$git_info" "$context_pct"
EOF

# Make scripts executable
chmod +x ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-wrapper.sh

# Update Claude settings
CLAUDE_SETTINGS=~/.claude/settings.json
echo "📝 Updating Claude settings..."

if [ -f "$CLAUDE_SETTINGS" ]; then
    # Check if statusLine already exists
    if grep -q '"statusLine"' "$CLAUDE_SETTINGS"; then
        echo "⚠️  statusLine already configured in settings.json"
    else
        # Add statusLine to existing config (before last closing brace)
        sed -i 's/}$/,"statusLine":{"type":"command","command":"bash ~\/.claude\/statusline-wrapper.sh"}}/' "$CLAUDE_SETTINGS"
        echo "✅ Added statusLine to existing settings"
    fi
else
    # Create new settings file
    cat > "$CLAUDE_SETTINGS" << 'EOF'
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-wrapper.sh"
  }
}
EOF
    echo "✅ Created new settings.json"
fi

echo ""
echo "✅ Claude Code status line setup complete!"
echo ""
echo "Your status line will show:"
echo "  repo/path | branch | S: staged | U: unstaged | A: added | context%"
echo ""
echo "Restart Claude Code to see the new status line."
