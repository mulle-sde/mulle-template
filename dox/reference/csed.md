# csed

Emit sed statement for content expansion.

## Synopsis

```bash
mulle-template csed [options]
```

## Description

The `csed` command generates sed expressions for substituting `<|KEY|>` markers in template content with environment variable values. It outputs the sed command that can be used to perform content expansion on template files.

This command is useful for:
- Generating reusable sed scripts for content processing
- Understanding how mulle-template processes templates
- Creating custom template processing pipelines
- Debugging template substitution logic

## Options

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help information |
| `-o <string>` | Specify key opener string (default: "<|") |
| `-c <string>` | Specify key closer string (default: "|>") |
| `-fo <string>` | Specify key opener string for filenames |
| `-fc <string>` | Specify key closer string for filenames |
| `--no-date-environment` | Don't create substitutions for TIME, YEAR etc. |
| `--boring-environment` | Don't filter out environment keys considered boring |

## Examples

### Basic Usage
```bash
# Generate sed expression for content substitution
mulle-template csed

# Use with environment variables
NAME="John" PROJECT="MyApp" mulle-template csed

# Apply to template file
mulle-template csed | sed -f - template.txt
```

### Custom Markers
```bash
# Use different markers
mulle-template csed -o "{{" -c "}}"

# Mixed markers for content and filenames
mulle-template csed -o "<|" -c "|>" -fo "{{" -fc "}}"
```

### Integration with Sed
```bash
# Process template with generated sed
sed "$(mulle-template csed)" template.txt > output.txt

# Create reusable sed script
mulle-template csed > content-sed.sed
sed -f content-sed.sed template.txt > output.txt
```

### Pipeline Processing
```bash
# Chain with other commands
mulle-template csed | sed -f - template.txt | mulle-template fsed | sed -f - -
```

## Output Format

The command outputs a sed expression that can be used with the `-e` option:

```bash
-e 's/<|AUTHOR|>/John Doe/g;s/<|PROJECT|>/MyApp/g;s/<|DATE|>/04.09.2025/g'
```

Or as a multi-line sed script when used with csed-script.

## How It Works

The `csed` command analyzes environment variables and generates sed substitution commands:

1. **Variable Collection**: Gathers all relevant environment variables
2. **Pattern Generation**: Creates sed patterns for `<|KEY|>` replacement
3. **Escaping**: Properly escapes special characters for sed
4. **Sorting**: Orders substitutions by variable name length (longest first)

## Use Cases

### Template Processing Scripts
```bash
#!/bin/bash
# Process template with environment variables

TEMPLATE="$1"
OUTPUT="$2"

if [ -z "$TEMPLATE" ] || [ -z "$OUTPUT" ]; then
    echo "Usage: $0 <template> <output>"
    exit 1
fi

# Generate and apply sed
mulle-template csed | sed -f - "$TEMPLATE" > "$OUTPUT"
```

### Batch Processing
```bash
# Process multiple templates
for template in *.template; do
    output="${template%.template}.txt"
    mulle-template csed | sed -f - "$template" > "$output"
done
```

### Custom Template Engines
```bash
# Create custom processing pipeline
process_template() {
    local template="$1"
    local output="$2"

    # Apply content substitutions
    mulle-template csed | sed -f - "$template" |
    # Apply filename substitutions
    mulle-template fsed | sed -f - - > "$output"
}
```

### Debugging Template Issues
```bash
# See what substitutions would be made
echo "Generated sed command:"
mulle-template csed

# Test specific variable substitution
NAME="Test" mulle-template csed | grep "NAME"
```

### CI/CD Integration
```bash
# Use in build scripts
export BUILD_NUMBER="123"
export GIT_COMMIT="abc123"
export BRANCH="main"

mulle-template csed | sed -f - config.template.json > config.json
```

## Variable Selection

### Default Behavior
- Includes all environment variables except "boring" ones
- Adds automatic DATE, TIME, YEAR variables
- Filters out system variables (PATH, HOME, etc.)

### Boring Variables (excluded by default)
```bash
# System variables
PATH, HOME, USER, SHELL, PWD, OLDPWD

# Terminal variables
TERM, COLORTERM, LINES, COLUMNS

# Locale variables
LANG, LC_*, LANGUAGE

# Process variables
PPID, PID, RANDOM, SECONDS

# Bash-specific
BASH*, HIST*, PROMPT*, PS1
```

### Including Boring Variables
```bash
# Include all variables
mulle-template csed --boring-environment

# Include specific "boring" variable
export CUSTOM_PATH="/custom/path"
mulle-template csed --boring-environment | grep "CUSTOM_PATH"
```

### Date/Time Control
```bash
# Exclude automatic date variables
mulle-template csed --no-date-environment

# Include only specific date format
export BUILD_DATE="$(date +%Y-%m-%d)"
mulle-template csed
```

## Sed Script Generation

### Single Line (csed)
```bash
# For use with sed -e
mulle-template csed
# Output: -e 's/<|VAR|>/value/g;s/<|VAR2|>/value2/g'
```

### Multi-Line Script (csed-script)
```bash
# For use with sed -f
mulle-template csed-script > script.sed
# Output:
# s/<|VAR|>/value/g
# s/<|VAR2|>/value2/g
```

## Troubleshooting

### No Output
```bash
# Check environment variables
env | grep -E '^[A-Z_]+='

# Include boring variables
mulle-template csed --boring-environment

# Set test variables
TEST_VAR="test" mulle-template csed
```

### Sed Errors
```bash
# Check for special characters in values
echo "$VAR_WITH_SPECIAL_CHARS"

# Escape values manually if needed
export SAFE_VAR="$(printf '%q' "$UNSAFE_VAR")"
```

### Variable Not Substituted
```bash
# Check variable name format
echo "$VARIABLE_NAME" | grep '^[A-Z_][A-Z0-9_]*$'

# Verify variable is exported
export MY_VAR="value"
mulle-template csed | grep "MY_VAR"
```

### Performance Issues
```bash
# Limit variables for large environments
mulle-template csed | head -20  # First 20 substitutions

# Use specific variables only
unset $(env | grep -v 'ESSENTIAL_VAR' | cut -d= -f1)
mulle-template csed
```

## Advanced Usage

### Conditional Processing
```bash
# Process only if variables are set
if [ -n "$REQUIRED_VAR" ]; then
    mulle-template csed | sed -f - template.txt > output.txt
else
    echo "Required variable REQUIRED_VAR not set"
    exit 1
fi
```

### Template Validation
```bash
# Check template compatibility
TEMPLATE_VARS=$(sed -n 's/.*<|\([^|>]*\)|>.*/\1/p' template.txt | sort -u)
SED_VARS=$(mulle-template csed | sed 's/.*s\/<|\([^|>]*\)|>.*/\1/' | sort -u)

MISSING_VARS=$(comm -23 <(echo "$TEMPLATE_VARS") <(echo "$SED_VARS"))
if [ -n "$MISSING_VARS" ]; then
    echo "Missing variables: $MISSING_VARS"
fi
```

### Custom Escaping
```bash
# Handle special characters in values
export SPECIAL_VAR="value/with/slashes"
mulle-template csed  # Automatically escapes for sed
```

## See Also

- [`fsed`](fsed.md) - Emit sed statement for filename expansion
- [`csed-script`](csed-script.md) - Generate content sed script file
- [`generate`](generate.md) - Create files from templates
- [`list`](list.md) - List variables in templates