# Changelog

All notable changes to the awesome-statusline plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-01-30

### Changed

- **setup-statusline**: Simplified statusline display format by removing color codes
  - Removed ANSI escape codes from statusline.sh template for cleaner output
  - Updated display format to: `{directory} ({branch}) [model] | 📊 {tokens}`
  - Updated documentation to remove color-related descriptions from setup.sh, SKILL.md, and README.md
  - Changed example output from colored format to plain text format

## [0.1.0] - 2026-01-20

### Added

- **setup-statusline**: Initial release of statusline setup skill
  - Automatic configuration of Claude Code statusline
  - Display directory name, git branch, model name, and token information
  - Safe merging with existing settings.json
  - Automatic backup creation before updates
  - jq-based JSON processing for reliable configuration

[0.1.1]: https://github.com/gendosu/gendosu-claude-plugins/compare/awesome-statusline-v0.1.0...awesome-statusline-v0.1.1
[0.1.0]: https://github.com/gendosu/gendosu-claude-plugins/releases/tag/awesome-statusline-v0.1.0
