#!/bin/bash

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Help message
show_help() {
    cat << EOF
Claude Code Statusline Configuration Script

Usage:
  $0 [OPTIONS]

Options:
  --help    Display this help message

Description:
  This script automatically configures Claude Code statusline display.
  It executes the following processes:
    1. Verify jq command installation
    2. Check/create ~/.claude/ directory
    3. Add statusLine configuration to ~/.claude/settings.json (preserving existing settings)
    4. Create ~/.claude/statusline.sh script

Prerequisites:
  - jq command must be installed
    macOS:        brew install jq
    Ubuntu/Debian: sudo apt-get install jq
    Fedora/RHEL:  sudo dnf install jq

Configuration includes:
  - Directory name
  - Git branch name (in parentheses)
  - Model name (in square brackets)
  - Token information (total, input, output, cache)

Example:
  $0
EOF
}

# Check jq installation
check_jq_installed() {
    echo -e "${BLUE}Checking prerequisites...${NC}"

    if ! command -v jq &> /dev/null; then
        echo -e "${RED}❌ jq not found${NC}"
        echo ""
        echo "Please install jq:"
        echo "  macOS:         brew install jq"
        echo "  Ubuntu/Debian: sudo apt-get install jq"
        echo "  Fedora/RHEL:   sudo dnf install jq"
        echo ""
        exit 1
    fi

    echo -e "${GREEN}✅ jq found${NC}"
}

# Check/create ~/.claude/ directory
check_claude_dir() {
    local CLAUDE_DIR="$HOME/.claude"

    echo -e "${BLUE}Checking Claude directory...${NC}"

    if [ ! -d "$CLAUDE_DIR" ]; then
        echo -e "${YELLOW}~/.claude/ directory not found. Creating...${NC}"
        mkdir -p "$CLAUDE_DIR" || {
            echo -e "${RED}❌ Failed to create ~/.claude/ directory${NC}"
            exit 1
        }
        echo -e "${GREEN}✅ ~/.claude/ directory created${NC}"
    else
        echo -e "${GREEN}✅ ~/.claude/ directory found${NC}"
    fi
}

# Merge settings.json
merge_settings() {
    local SETTINGS_FILE="$HOME/.claude/settings.json"
    local STATUSLINE_CONFIG='{"type":"command","command":"~/.claude/statusline.sh","padding":0}'

    echo -e "${BLUE}Updating settings.json...${NC}"

    if [ -f "$SETTINGS_FILE" ]; then
        # Create backup
        cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup"
        echo -e "${YELLOW}Backed up existing settings: $SETTINGS_FILE.backup${NC}"

        # Merge JSON
        jq ". + {\"statusLine\": $STATUSLINE_CONFIG}" "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"
        mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        echo -e "${GREEN}✅ settings.json updated (existing settings preserved)${NC}"
    else
        # Create new
        echo "{\"statusLine\": $STATUSLINE_CONFIG}" | jq '.' > "$SETTINGS_FILE"
        echo -e "${GREEN}✅ settings.json created${NC}"
    fi
}

# Create statusline.sh
create_statusline_script() {
    local SCRIPT_FILE="$HOME/.claude/statusline.sh"

    echo -e "${BLUE}Creating statusline.sh...${NC}"

    # Backup existing file
    if [ -f "$SCRIPT_FILE" ]; then
        cp "$SCRIPT_FILE" "$SCRIPT_FILE.backup"
        echo -e "${YELLOW}Backed up existing script: $SCRIPT_FILE.backup${NC}"
    fi

    # Create script
    cat > "$SCRIPT_FILE" << 'EOF'
#!/bin/bash

input=$(cat)

current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')

# Get Git branch information
git_branch=""
if [ -d "$current_dir/.git" ] || git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)
    if [ -n "$git_branch" ]; then
        git_branch=" ($git_branch)"
    fi
fi

# Get token information
usage=$(echo "$input" | jq '.context_window.current_usage')
token_info=""

if [ "$usage" != "null" ]; then
    input_tokens=$(echo "$usage" | jq -r '.input_tokens // 0')
    output_tokens=$(echo "$usage" | jq -r '.output_tokens // 0')
    cache_creation=$(echo "$usage" | jq -r '.cache_creation_input_tokens // 0')
    cache_read=$(echo "$usage" | jq -r '.cache_read_input_tokens // 0')

    # Calculate total tokens
    total=$((input_tokens + output_tokens + cache_creation + cache_read))

    # Display tokens in K (thousands) unit
    if [ $total -gt 1000 ]; then
        # Use awk to display with 1 decimal place
        total_display=$(awk "BEGIN {printf \"%.1f\", $total / 1000}")"K"
    else
        total_display="$total"
    fi

    token_info=" | 📊 ${total_display} (In:${input_tokens} Out:${output_tokens} Cache:${cache_read})"
fi

printf "%s%s [%s]%s" \
    "$(basename "$current_dir")" \
    "$git_branch" \
    "$model_name" \
    "$token_info"
EOF

    # Set execute permission
    chmod +x "$SCRIPT_FILE"
    echo -e "${GREEN}✅ statusline.sh created (execute permission granted)${NC}"
}

# Main process
main() {
    # Check --help option
    if [ "$1" == "--help" ]; then
        show_help
        exit 0
    fi

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Claude Code Statusline Configuration${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    # Execute each process
    check_jq_installed
    echo ""

    check_claude_dir
    echo ""

    merge_settings
    echo ""

    create_statusline_script
    echo ""

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ Setup completed!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "The statusline will be displayed when you launch Claude Code next time."
    echo ""
    echo -e "Display example:"
    echo -e "  gendosu-claude-plugins (main) [Sonnet] | 📊 38.8K (In:37442 Out:0 Cache:0)"
    echo ""
}

# Execute script
main "$@"
