---
paths:
  - "plugins/**/*"
  - "plugins/*/.claude-plugin/plugin.json"
  - "plugins/*/CHANGELOG.md"
---

# Plugin Versioning and Changelog

When modifying files in any plugin directory (`plugins/*/`):

1. **Update Plugin Version**: Increment the version in `plugins/<plugin-name>/.claude-plugin/plugin.json` based on the nature of changes:
   - **Major** (x.0.0): Breaking changes or major feature additions
   - **Minor** (0.x.0): New features, backward-compatible changes
   - **Patch** (0.0.x): Bug fixes, documentation updates, minor improvements

2. **Document Changes**: Add an entry to `plugins/<plugin-name>/CHANGELOG.md` following [Keep a Changelog](https://keepachangelog.com/) format:
   - Use categories: Added, Changed, Deprecated, Removed, Fixed, Security
   - Include the version number and date
   - Describe what changed and why it matters
