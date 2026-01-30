---
name: setup-statusline
description: Setup Claude Code statusline configuration automatically (global)
trigger: When the user instructs to "set up the statusline", "setup statusline", "configure statusline", "statusline setup", or similar in natural language such as "initialize the status bar", "set up status line", etc.
---

# Claude Code Statusline Configuration Skill

**MANDATORY**: This skill **MUST** be used when the user requests Claude Code statusline configuration.

## Trigger Conditions

Automatically use this skill when any of the following instructions are given:
- "Set up the statusline"
- "Setup statusline"
- "Configure statusline"
- "Statusline setup"
- "Set up the status bar"
- "Initialize status line"
- "Claude Code statusline"

## Purpose

- Automatically configure Claude Code statusline display
- Add statusline configuration to global settings (`~/.claude/settings.json`)
- Create a custom script (`~/.claude/statusline.sh`)
- Safely merge while preserving existing settings

## Skill Invocation Method

This skill is invoked using the Skill tool:

```
Skill(skill="setup-statusline")
```

No arguments are required.

## Execution Steps

### 1. Running Setup

```bash
.claude/skills/setup-statusline/setup.sh
```

This script automatically executes the following:
1. **Prerequisites Check**: Verify `jq` command installation
2. **Directory Creation**: Check/create `~/.claude/` directory
3. **Settings File Merge**: Add statusLine section to `~/.claude/settings.json` (preserving existing settings)
4. **Script Creation**: Create `~/.claude/statusline.sh` and grant execute permission

### 2. Configuration Details

**Configuration to be added (`~/.claude/settings.json`):**
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

**Script to be created (`~/.claude/statusline.sh`):**
- Directory name
- Git branch name (in parentheses)
- Model name (in square brackets)
- Token information (total, input, output, cache)

### 3. Display Example

```
gendosu-claude-plugins (main) [Sonnet] | 📊 38.8K (In:37442 Out:0 Cache:0)
```

### 4. Execution Result Determination

- ✅ **Success**: Script exits with code 0 and displays success message
- ❌ **Failure**: Script exits with non-zero code and displays error message

## Important Rules

1. **Existing Settings Protection**: Existing `settings.json` settings are preserved
2. **Automatic Backup Creation**: Automatically creates `.backup` files when updating configuration
3. **Idempotence**: Safe to run multiple times
4. **jq Required**: `jq` command is necessary for JSON operations

## Security

- Script permissions: 755 (rwxr-xr-x)
- Configuration file permissions: 644 (rw-r--r--)
- Operates only within home directory
- No sudo privileges required

## Troubleshooting

### When jq is not found

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

### When permission errors occur

Check permissions for `~/.claude/` directory:
```bash
ls -ld ~/.claude/
chmod 755 ~/.claude/
```

## References

- [README.md](README.md) - Detailed usage instructions and troubleshooting
