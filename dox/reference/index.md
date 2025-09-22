# mulle-template Command Reference

## Overview

**mulle-template** is a command-line tool for generating files from templates by substituting keys enveloped in <| |> with values found in the environment. It provides a structured way to create source files from templates, supporting both single file generation and directory-based template processing.

## Command Categories

### Core Operations
- **[`generate`](generate.md)** - Create a source file from a template
- **[`list`](list.md)** - List variables contained in a template file

### Template Processing
- **[`csed`](csed.md)** - Apply content sed operations
- **[`fsed`](fsed.md)** - Apply filename sed operations
- **[`csed-script`](csed-script.md)** - Generate content sed script
- **[`fsed-script`](fsed-script.md)** - Generate filename sed script

### System & Info
- **[`libexec-dir`](libexec-dir.md)** - Print path to mulle-template libexec
- **[`uname`](uname.md)** - mulle-template's simplified uname(1)
- **[`version`](version.md)** - Show version information
- **[`hostname`](hostname.md)** - Show hostname
- **[`environment`](environment.md)** - Show environment variables
- **[`commands`](commands.md)** - List available commands

## Quick Start Examples

### Basic Template Generation
```bash
# Generate a file from a template
mulle-template generate template.txt -

# Generate with environment variables
mulle-template --clean-env -DAUTHOR="John Doe" generate template.txt output.txt

# List variables in a template
mulle-template list template.txt
```

### Template Processing
```bash
# Apply content sed operations
mulle-template csed -e 's/old/new/g' template.txt

# Apply filename sed operations
mulle-template fsed -e 's/\.template$/.txt/' template.txt

# Generate sed scripts
mulle-template csed-script template.txt
mulle-template fsed-script template.txt
```

### System Information
```bash
# Show version
mulle-template version

# Show environment
mulle-template environment

# Show system info
mulle-template uname
mulle-template hostname
```

## Command Reference Table

| Command | Category | Description |
|---------|----------|-------------|
| `generate` | Core | Create a source file from a template |
| `list` | Core | List variables contained in a template file |
| `csed` | Template | Apply content sed operations |
| `fsed` | Template | Apply filename sed operations |
| `csed-script` | Template | Generate content sed script |
| `fsed-script` | Template | Generate filename sed script |
| `libexec-dir` | System | Print path to mulle-template libexec |
| `uname` | System | mulle-template's simplified uname(1) |
| `version` | System | Show version information |
| `hostname` | System | Show hostname |
| `environment` | System | Show environment variables |
| `commands` | System | List available commands |

## Getting Help

### Command Help
```bash
# Get help for a specific command
mulle-template <command> --help

# List all available commands
mulle-template commands

# Get detailed command information
mulle-template <command> --help --verbose
```

### Documentation
- Each command has a dedicated documentation file in this reference
- Use `--help` for quick command usage
- Check template syntax with `mulle-template list`

## Common Workflows

### Basic Template Generation
1. **Create** a template file with <|KEY|> placeholders
2. **Set** environment variables for substitution
3. **Generate** the output file: `mulle-template generate template.txt output.txt`

### Batch Processing
1. **Prepare** multiple templates in a directory
2. **Set** common environment variables
3. **Process** each template: `mulle-template generate template1.txt output1.txt`

### Template Analysis
1. **List** variables: `mulle-template list template.txt`
2. **Check** syntax and identify missing variables
3. **Set** required environment variables
4. **Generate** final output

## Troubleshooting

### Common Issues
```bash
# Check template syntax
mulle-template list template.txt

# Verify environment variables
mulle-template environment | grep KEY

# Test with clean environment
mulle-template --clean-env -DKEY=value generate template.txt -
```

### Template Problems
```bash
# Check for syntax errors in template
cat template.txt | grep '<|.*|>'

# Verify variable names
mulle-template list template.txt

# Test substitution
mulle-template --clean-env -DNAME="test" generate template.txt -
```

### Environment Issues
```bash
# Check current environment
mulle-template environment

# Use clean environment for testing
mulle-template --clean-env generate template.txt -

# Set multiple variables
mulle-template -DVAR1=value1 -DVAR2=value2 generate template.txt output.txt
```

## Advanced Usage

### Complex Templates
```bash
# Template with defaults
printf "<|DATE|>\\nHello <|NAME:-Unknown|>\\n" > template.txt
mulle-template generate template.txt -

# Multi-line templates
cat > template.txt <<EOF
Project: <|PROJECT|>
Author: <|AUTHOR|>
Date: <|DATE|>
EOF
mulle-template -DPROJECT="MyApp" -DAUTHOR="John" generate template.txt -
```

### Sed Operations
```bash
# Content replacement
mulle-template csed -e 's/OLD/NEW/g' template.txt

# Filename transformation
mulle-template fsed -e 's/\.template$/.txt/' template.txt

# Generate reusable scripts
mulle-template csed-script template.txt > replace.sed
mulle-template fsed-script template.txt > rename.sed
```

### Integration with Scripts
```bash
# Process multiple templates
for template in *.template; do
    output="${template%.template}.txt"
    mulle-template generate "$template" "$output"
done

# Conditional generation
if [ ! -f output.txt ]; then
    mulle-template generate template.txt output.txt
fi
```

## Related Documentation

- **[TODO.md](TODO.md)** - Current development status and process guide
- **[README.md](../../README.md)** - Project overview and installation
- **[mulle-sde.md](../mulle-sde.md)** - Build system guidelines
- **[mulle-fetch.md](../mulle-fetch.md)** - Fetching and cloning documentation