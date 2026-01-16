# Skill Creator Plugin

A Claude Code plugin that provides comprehensive guidance for creating effective skills.

## Overview

This plugin extends Claude Code with the skill-creator skill from [Anthropic's official skills repository](https://github.com/anthropics/skills/tree/main/skills/skill-creator). It provides expert guidance on designing, implementing, and packaging custom skills that extend Claude's capabilities.

## Features

- **Comprehensive Skill Creation Guide**: Learn how to create effective skills with specialized knowledge, workflows, and tool integrations
- **Design Patterns**: Best practices for progressive disclosure, output patterns, and workflow structures
- **Utility Scripts**: Tools for initializing, validating, and packaging skills
- **Reference Documentation**: Detailed guides for output patterns and workflow design

## Bundled Resources

### Scripts

- `init_skill.py` - Initialize a new skill from template
- `package_skill.py` - Package a skill into a distributable .skill file
- `quick_validate.py` - Validate skill structure and metadata

### References

- `output-patterns.md` - Patterns for template-based and example-based outputs
- `workflows.md` - Sequential and conditional workflow structures

## Usage

The skill-creator skill is automatically triggered when you ask Claude to help you create a new skill or update an existing skill.

Example triggers:
- "Help me create a new skill for..."
- "I want to build a skill that..."
- "Update my existing skill to..."

## Installation

1. Clone or copy this plugin to your Claude Code plugins directory:
```bash
cp -r skill-creator ~/.claude/plugins/
```

2. Restart Claude Code to load the plugin

## Project Structure

```
skill-creator/
├── .claude-plugin/
│   └── plugin.json              # Plugin configuration
├── skills/
│   └── skill-creator/
│       ├── SKILL.md             # Main skill documentation
│       ├── LICENSE.txt          # Apache License 2.0
│       ├── references/          # Reference documentation
│       │   ├── output-patterns.md
│       │   └── workflows.md
│       └── scripts/             # Utility scripts
│           ├── init_skill.py
│           ├── package_skill.py
│           └── quick_validate.py
├── LICENSE                      # Plugin license
└── README.md                    # This file
```

## Prerequisites

- [Claude Code](https://claude.com/claude-code) installed
- Python 3.7+ (for utility scripts)
- PyYAML library (install with `pip install pyyaml`)

## License

This plugin packages the skill-creator skill from Anthropic's skills repository, which is licensed under the Apache License 2.0. See LICENSE.txt for complete terms.

## Acknowledgments

- Original skill from [Anthropic Skills Repository](https://github.com/anthropics/skills)
- Designed for the Claude Code plugin ecosystem
