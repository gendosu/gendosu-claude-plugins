# Claude Code Statusline Configuration Skill

A skill that automatically configures the Claude Code statusline display.

## Overview

Using this skill, you can automatically configure a custom statusline that displays the following information:

- 📁 **Directory name**
- 🌿 **Git branch name** (in parentheses, the current branch)
- 🤖 **Model name** (in square brackets, the model in use)
- 📊 **Token information** (total, input, output, cache reads)

### Display Example

```
gendosu-claude-plugins (main) [Sonnet] | 📊 38.8K (In:37442 Out:0 Cache:0)
```

## Key Features

- ✅ **Automatic Configuration**: Setup complete with a single command
- ✅ **Existing Configuration Protection**: Merges while preserving existing `settings.json`
- ✅ **Automatic Backup**: Creates automatic backup before updating configuration files
- ✅ **Idempotence**: Safe to run multiple times
- ✅ **Error Handling**: Clear error messages

## Usage

### Execution via Skill (Recommended)

During Claude Code interaction, instruct as follows:

```
Set up the statusline
```

Or

```
Setup statusline
```

### Direct Execution

```bash
.claude/skills/setup-statusline/setup.sh
```

## Prerequisites

### Required

- **jq**: Used for JSON processing

#### Installing jq

**macOS:**
```bash
brew install jq
```

**Ubuntu/Debian:**
```bash
sudo apt-get install jq
```

**Fedora/RHEL:**
```bash
sudo dnf install jq
```

**Verification:**
```bash
jq --version
# Output like jq-1.6 indicates success
```

## Configuration Details

### 1. `~/.claude/settings.json`

The following settings are added (existing settings are preserved):

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

### 2. `~/.claude/statusline.sh`

A custom script is created that displays the following information:

- **Directory name**: Retrieves current directory name using `basename`
- **Git branch**: Obtains current branch using `git branch --show-current`
- **Model name**: Uses `model.display_name` passed from Claude Code
- **Token information**: Details of input tokens, output tokens, and cache tokens

## Troubleshooting

### ❌ "jq not found"

**Cause**: `jq` command is not installed

**Solution**: Follow the "Prerequisites" section above to install `jq`

### ❌ "Failed to create ~/.claude/ directory"

**Cause**: You don't have write permissions to the home directory

**Solution**:
```bash
# Check home directory permissions
ls -ld ~/
# Fix permissions if needed
chmod 755 ~/
```

### ❌ Statusline not displaying

**Verification:**
1. Restart Claude Code
2. Verify that `statusLine` section exists in `~/.claude/settings.json`
3. Verify that `~/.claude/statusline.sh` is executable:
   ```bash
   ls -l ~/.claude/statusline.sh
   # Should display something like -rwxr-xr-x
   ```

### ❌ Token information not displaying

**Cause**: The `jq` required for script execution may not be working correctly

**Solution**:
```bash
# Verify jq is correctly installed
jq --version

# Test the script directly to check for errors
echo '{"workspace":{"current_dir":"/app"},"model":{"display_name":"Sonnet"},"context_window":{"current_usage":{"input_tokens":1000,"output_tokens":500}}}' | ~/.claude/statusline.sh
```

## Technical Details

### Script Behavior

1. **JSON Input Reception**: Receives statusline information in JSON format from Claude Code
2. **Data Extraction**: Extracts necessary information using `jq`
3. **Git Information Retrieval**: Obtains Git branch information from the current directory
4. **Formatting**: Formats the string in the specified format
5. **Output**: Outputs the formatted string to standard output

### Design Considerations

- **Error Handling**: Strict error handling with `set -e`
- **Idempotence**: Same results even when run multiple times
- **Backup**: Existing files are saved with `.backup` suffix
- **Security**: Operates only within home directory, no sudo required

## File Structure

```
plugins/awesome-statusline/skills/setup-statusline/
├── SKILL.md
├── README.md
└── setup.sh
```

## License

This skill is provided as part of the awesome-statusline plugin.
