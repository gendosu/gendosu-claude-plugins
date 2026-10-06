# awesome-statusline

Claude Code statusline setup skill for automatic statusline configuration.

## Overview

The awesome-statusline plugin provides an automated setup skill for configuring Claude Code's status line display. It automatically configures your status line to show essential information like directory name, Git branch, model name, token usage statistics, and rate limit usage (5-hour / weekly) with reset times.

## Features

- ✅ **Automated Setup**: One-command statusline configuration
- ✅ **Preserve Existing Settings**: Safely merges with existing `settings.json`
- ✅ **Automatic Backups**: Creates backups before updating settings
- ✅ **Idempotent**: Safe to run multiple times
- ✅ **Rich Display**: Shows directory, Git branch, model, token information, and rate limit usage with reset times

### Display Example

```
skillth (feature/setup-statusline) [Sonnet] | 📊 38.8K (In:37442 Out:0 Cache:0) | 5h:24%(→12:21) 7d:41%(→10/9 10:21)
```

## Installation

### Add Marketplace

```bash
/plugin marketplace add gendosu/gendosu-claude-plugins
```

### Install Plugin

```bash
/plugin install awesome-statusline@gendosu-claude-plugins
```

## Usage

Simply ask Claude Code to set up your statusline:

```
ステータスラインを設定して
```

Or in English:

```
Setup my statusline
```

The skill will automatically:
1. Check for required dependencies (`jq`)
2. Create necessary directories (`~/.claude/`)
3. Merge settings into `~/.claude/settings.json`
4. Create status line script `~/.claude/statusline.sh`
5. Set proper file permissions

## Configuration

After installation, the following files will be created/updated:

### `~/.claude/settings.json`

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

### `~/.claude/statusline.sh`

A shell script that generates the status line display with:
- Directory name
- Git branch name (in parentheses)
- Model name (in brackets)
- Token statistics (total, input, output, cache)
- Rate limit usage with reset times (`5h:24%(→12:21) 7d:41%(→10/9 10:21)`; claude.ai Pro/Max only, hidden when unavailable)

## Prerequisites

- **jq**: Required for JSON processing

### Installing jq

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

## Troubleshooting

### jq Not Found

Install jq following the instructions in the Prerequisites section.

### Statusline Not Displaying

1. Restart Claude Code
2. Verify `~/.claude/settings.json` contains the `statusLine` section
3. Check that `~/.claude/statusline.sh` is executable:
   ```bash
   ls -l ~/.claude/statusline.sh
   # Should show: -rwxr-xr-x
   ```

### Permission Errors

Check directory permissions:
```bash
ls -ld ~/.claude/
chmod 755 ~/.claude/
```

## Project Structure

```
plugins/awesome-statusline/
├── .claude-plugin/
│   └── plugin.json           # Plugin configuration
├── skills/
│   └── setup-statusline/
│       ├── SKILL.md          # Skill metadata
│       ├── README.md         # Skill documentation
│       └── setup.sh          # Setup script
├── README.md                 # This file (English)
├── README.ja.md              # Japanese documentation
└── LICENSE                   # MIT License
```

## Documentation

- [Setup Statusline Skill Documentation](./skills/setup-statusline/README.md) - Detailed usage guide

## License

MIT License - See [LICENSE](./LICENSE) for details

## Author

**Gendosu**

## Repository

https://github.com/gendosu/gendosu-claude-plugins

## Version

0.1.0
