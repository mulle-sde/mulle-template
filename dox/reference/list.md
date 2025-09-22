# list

List variables contained in template files.

## Synopsis

```bash
mulle-template list <file> ...
```

## Description

The `list` command analyzes template files and extracts all variable names enclosed in `<|KEY|>` markers. It displays a sorted, unique list of all variables found in the specified template files.

This command is useful for:
- Analyzing template dependencies
- Debugging template syntax
- Understanding what environment variables are needed
- Validating template structure
- Documentation generation

## Options

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help information |

## Examples

### Basic Usage
```bash
# List variables in a single template
mulle-template list template.txt

# List variables in multiple templates
mulle-template list template1.txt template2.txt

# List variables from stdin
echo "Hello <|NAME|>, welcome to <|PROJECT|>!" | mulle-template list -
```

### Template Analysis
```bash
# Analyze all templates in directory
find templates/ -name "*.txt" -exec mulle-template list {} \;

# Check for missing variables
TEMPLATE_VARS=$(mulle-template list template.txt)
for var in $TEMPLATE_VARS; do
    if [ -z "${!var}" ]; then
        echo "Missing variable: $var"
    fi
done
```

### Validation Scripts
```bash
# Validate template syntax
if mulle-template list template.txt >/dev/null 2>&1; then
    echo "Template syntax is valid"
else
    echo "Template syntax error"
fi

# Count variables in template
VAR_COUNT=$(mulle-template list template.txt | wc -l)
echo "Template contains $VAR_COUNT variables"
```

### Documentation Generation
```bash
# Generate variable documentation
echo "# Template Variables" > vars.md
echo "" >> vars.md
mulle-template list template.txt | while read var; do
    echo "- \`$var\` - Description of $var" >> vars.md
done
```

## Template Syntax Examples

### Basic Variables
```bash
# Template content
Hello <|NAME|>, welcome to <|PROJECT|>!

# Output:
# NAME
# PROJECT
```

### Default Values
```bash
# Template with defaults
Hello <|NAME:-Anonymous|>, from <|COMPANY:-ACME Corp|>!

# Output (same as without defaults):
# NAME
# COMPANY
```

### Complex Templates
```bash
# Multi-line template
Project: <|PROJECT|>
Author: <|AUTHOR|>
Version: <|VERSION|>
Date: <|DATE|>

# Output:
# AUTHOR
# DATE
# PROJECT
# VERSION
```

### Nested Variables
```bash
# Variables in file paths or complex expressions
Output: <|OUTPUT_DIR|>/<|PROJECT|>_v<|VERSION|>.tar.gz

# Output:
# OUTPUT_DIR
# PROJECT
# VERSION
```

## Output Format

The command outputs one variable name per line, sorted alphabetically and with duplicates removed:

```
AUTHOR
DATE
NAME
PROJECT
VERSION
```

## How It Works

The `list` command uses sed to extract text between `<|` and `|>` markers:

```bash
sed -n -e 's/[^<]*<|\([A-Za-z_][A-Za-z0-9_]*\)|>/\1\n/gp' "$@" \
    | sed -e '/^$/d' \
    | sort -u
```

This regex pattern:
- `\([A-Za-z_][A-Za-z0-9_]*\)` - Captures variable names (must start with letter/underscore, followed by letters/numbers/underscores)
- `[^<]*<|` - Matches any text before `<|`
- `|>` - Matches the closing `|>`

## Use Cases

### Template Validation
```bash
# Check template before generation
VARS=$(mulle-template list template.txt)
if [ -n "$VARS" ]; then
    echo "Template requires these variables:"
    echo "$VARS"
else
    echo "Template has no variables"
fi
```

### Environment Setup
```bash
# Generate environment setup script
cat > setup-env.sh << 'EOF'
#!/bin/bash
# Environment setup for template generation

EOF

mulle-template list template.txt | while read var; do
    echo "export $var=\"${!var:-}\"  # Set $var" >> setup-env.sh
done
```

### CI/CD Integration
```bash
# Check all required variables are set
MISSING_VARS=""
for var in $(mulle-template list template.txt); do
    if [ -z "${!var}" ]; then
        MISSING_VARS="$MISSING_VARS $var"
    fi
done

if [ -n "$MISSING_VARS" ]; then
    echo "Missing environment variables:$MISSING_VARS"
    exit 1
fi
```

### Template Inventory
```bash
# Analyze all templates in project
find . -name "*.template" -o -name "*.tpl" | while read template; do
    echo "=== $template ==="
    mulle-template list "$template"
    echo
done > template-inventory.txt
```

### Dependency Analysis
```bash
# Find templates that use specific variables
find templates/ -name "*.txt" -exec sh -c '
    if mulle-template list "$1" | grep -q "^PROJECT$"; then
        echo "$1 uses PROJECT variable"
    fi
' _ {} \;
```

## Troubleshooting

### No Output
```bash
# Check if template exists
ls -la template.txt

# Check template content
cat template.txt

# Verify template has variables
grep '<|.*|>' template.txt
```

### Syntax Errors
```bash
# Check for malformed markers
grep -n '<|' template.txt
grep -n '|>' template.txt

# Look for unmatched markers
sed -n 's/.*<|\([^|>]*\)|>.*/\1/p' template.txt
```

### Variable Name Issues
```bash
# Check variable name format
mulle-template list template.txt | grep -v '^[A-Za-z_][A-Za-z0-9_]*$'

# Variables must start with letter or underscore
# Variables can contain letters, numbers, underscores
```

### File Access Issues
```bash
# Check file permissions
ls -la template.txt

# Try with absolute path
mulle-template list /full/path/to/template.txt

# Check if file is readable
head -5 template.txt
```

## Variable Naming Rules

Variables must follow these rules:
- Start with a letter (A-Z, a-z) or underscore (_)
- Contain only letters, numbers (0-9), and underscores
- Be enclosed in `<|` and `|>` markers
- Not contain spaces or special characters

### Valid Examples
```
<|NAME|>
<|PROJECT_NAME|>
<|_PRIVATE_VAR|>
<|VERSION_1_0|>
```

### Invalid Examples
```
<|123INVALID|>    # Starts with number
<|VAR-NAME|>      # Contains hyphen
<|VAR NAME|>      # Contains space
<|VAR@NAME|>      # Contains special char
```

## See Also

- [`generate`](generate.md) - Create files from templates
- [`csed`](csed.md) - Apply content sed operations
- [`fsed`](fsed.md) - Apply filename sed operations