---
paths:
  - "README*.md"
  - "plugins/*/README*.md"
  - "**/*.md"
---

# Documentation Standards

## README Synchronization

- **Root README**: `README.ja.md` should be synchronized with `README.md`
  - `README.md`: English version (primary)
  - `README.ja.md`: Japanese version (synchronized)

- **Plugin README**: For each plugin in `plugins/*/`:
  - `plugins/<plugin-name>/README.md`: English version (primary)
  - `plugins/<plugin-name>/README.ja.md`: Japanese version (synchronized)

## Documentation Updates

When making changes that affect user-facing functionality:
- Update relevant README files in both English and Japanese
- Keep documentation in sync across language versions
- Ensure examples and code snippets are consistent
