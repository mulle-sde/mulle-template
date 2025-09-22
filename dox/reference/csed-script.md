# csed-script

Generate content sed script file.

## Synopsis

```bash
mulle-template csed-script [options]
```

## Description

The `csed-script` command generates a sed script file containing substitution commands for content expansion. Unlike `csed` which outputs inline sed expressions, this command creates a reusable script file that can be used with `sed -f`.

This command is useful for:
- Creating reusable sed scripts for content processing
- Generating scripts that can be edited or version controlled
- Batch processing multiple files with the same substitutions
- Debugging and modifying sed expressions

## Options

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help information |
| `-o <string>` | Specify key opener string (default: "<|") |
| `-c <string>` | Specify key closer string (default: "|>") |
| `--no-date-environment` | Don't create substitutions for TIME, YEAR etc. |
| `--boring-environment` | Don't filter out environment keys considered boring |

## Examples

### Basic Script Generation
```bash
# Generate sed script file
mulle-template csed-script > content.sed

# Use the generated script
sed -f content.sed template.txt > output.txt
```

### Environment Variables
```bash
# Generate script with specific variables
NAME="John" PROJECT="MyApp" mulle-template csed-script > script.sed

# Apply to multiple files
for file in *.template; do
    sed -f script.sed "$file" > "${file%.template}.txt"
done
```

### Custom Markers
```bash
# Use different markers
mulle-template csed-script -o "{{" -c "}}" > custom.sed

# Apply custom script
sed -f custom.sed template.txt > output.txt
```

### Script Reuse
```bash
# Generate once, use multiple times
mulle-template csed-script > template_processor.sed

# Process different files
sed -f template_processor.sed config.template.json > config.json
sed -f template_processor.sed README.template.md > README.md
```

## Output Format

The command outputs a sed script file with one substitution per line:

```bash
s/<|AUTHOR|>/John Doe/g
s/<|PROJECT|>/MyApp/g
s/<|DATE|>/04.09.2025/g
s/<|TIME|>/17:15:30/g
s/<|YEAR|>/2025/g
```

## How It Works

The `csed-script` command:
1. **Analyzes Environment**: Collects all relevant environment variables
2. **Generates Substitutions**: Creates sed `s/pattern/replacement/g` commands
3. **Handles Special Characters**: Properly escapes characters for sed
4. **Outputs Script**: Writes multi-line sed script to stdout

## Use Cases

### Build System Integration
```bash
# Generate sed script in build process
mulle-template csed-script > build/content_processor.sed

# Use in Makefile
process_content:
    mulle-template csed-script > build/content_processor.sed

%.processed: %.template build/content_processor.sed
    sed -f build/content_processor.sed $< > $@
```

### Version Control
```bash
# Generate script for repository
mulle-template csed-script > scripts/process_content.sed
git add scripts/process_content.sed

# Use in CI/CD
sed -f scripts/process_content.sed template.txt > output.txt
```

### Batch Processing
```bash
# Process entire directory
mulle-template csed-script > process_all.sed
find templates/ -name "*.txt" -exec sed -f process_all.sed {} \; > processed.txt
```

### Template Pipeline
```bash
# Multi-stage processing pipeline
mulle-template csed-script > content.sed
mulle-template fsed-script > filename.sed

# Process content first
sed -f content.sed template.txt > temp.txt

# Then process filename
new_name=$(basename template.txt | sed -f filename.sed)
mv temp.txt "$new_name"
```

## Script File Management

### Temporary Scripts
```bash
# Create temporary script
SCRIPT=$(mktemp)
mulle-template csed-script > "$SCRIPT"

# Use script
sed -f "$SCRIPT" input.txt > output.txt

# Clean up
rm "$SCRIPT"
```

### Named Scripts
```bash
# Create named script file
mulle-template csed-script > "process_${PROJECT}_${VERSION}.sed"

# Use with descriptive name
sed -f "process_${PROJECT}_${VERSION}.sed" template.txt > output.txt
```

### Script Modification
```bash
# Generate base script
mulle-template csed-script > base.sed

# Add custom substitutions
echo 's/CUSTOM_PATTERN/Custom Replacement/g' >> base.sed

# Use enhanced script
sed -f base.sed template.txt > output.txt
```

## Variable Control

### Selective Variables
```bash
# Include only specific variables
env -i NAME="$NAME" PROJECT="$PROJECT" mulle-template csed-script > selective.sed

# Use selective script
sed -f selective.sed template.txt > output.txt
```

### All Variables
```bash
# Include all environment variables
mulle-template csed-script --boring-environment > all_vars.sed

# Useful for complex templates
sed -f all_vars.sed complex_template.txt > output.txt
```

### Date/Time Control
```bash
# Exclude automatic date variables
mulle-template csed-script --no-date-environment > no_date.sed

# Include custom date format
export BUILD_DATE="$(date +%Y-%m-%d)"
mulle-template csed-script > custom_date.sed
```

## Troubleshooting

### Empty Script
```bash
# Check environment variables
env | grep -v '^_' | head -10

# Set test variables
TEST_VAR="test" mulle-template csed-script

# Include boring variables
mulle-template csed-script --boring-environment
```

### Sed Errors
```bash
# Check script syntax
mulle-template csed-script | sed -n '1p'  # Check first line

# Test script on simple input
echo "Test <|VAR|> content" | sed -f <(mulle-template csed-script)
```

### File Permissions
```bash
# Ensure script is executable by sed
mulle-template csed-script > script.sed
chmod 644 script.sed  # sed doesn't need execute permission

# Check file creation
ls -la script.sed
```

### Special Characters
```bash
# Handle variables with special characters
export PATH_VAR="/usr/local/bin:/usr/bin"
mulle-template csed-script  # Automatically handles escaping

# Manual escaping if needed
export SAFE_PATH="$(printf '%q' "$PATH_VAR")"
```

## Advanced Usage

### Script Analysis
```bash
# Count substitutions in script
mulle-template csed-script | wc -l

# List all variables being substituted
mulle-template csed-script | sed 's/s\/<|\([^|>]*\)|>.*/\1/'

# Find specific variable
mulle-template csed-script | grep "PROJECT"
```

### Conditional Processing
```bash
# Generate script only if variables exist
if [ -n "$REQUIRED_VAR" ]; then
    mulle-template csed-script > processor.sed
    sed -f processor.sed template.txt > output.txt
else
    echo "Required variable missing"
    exit 1
fi
```

### Script Optimization
```bash
# Remove unnecessary substitutions
mulle-template csed-script | grep -v "UNUSED_VAR" > optimized.sed

# Sort for better performance
mulle-template csed-script | sort > sorted.sed
```

### Integration with Other Tools
```bash
# Use with find and xargs
find . -name "*.template" -print0 | \
    xargs -0 -I {} sh -c '
        output="${1%.template}.txt"
        mulle-template csed-script | sed -f - "$1" > "$output"
    ' _ {}
```

### Error Handling
```bash
# Safe script generation
if ! mulle-template csed-script > script.sed 2>/dev/null; then
    echo "Failed to generate sed script"
    exit 1
fi

# Validate script before use
if [ ! -s script.sed ]; then
    echo "Generated script is empty"
    exit 1
fi
```

## Performance Considerations

### Large Scripts
```bash
# Limit script size
mulle-template csed-script | head -50 > limited.sed

# Split large scripts
mulle-template csed-script | split -l 100 - script_part_

# Process with multiple scripts
for part in script_part_*; do
    sed -f "$part" input.txt > temp.txt
    mv temp.txt input.txt
done
```

### Script Caching
```bash
# Cache script for multiple uses
SCRIPT_CACHE="build/content_processor.sed"
if [ ! -f "$SCRIPT_CACHE" ] || [ "$SCRIPT_CACHE" -ot .env ]; then
    mulle-template csed-script > "$SCRIPT_CACHE"
fi

# Use cached script
sed -f "$SCRIPT_CACHE" template.txt > output.txt
```

## See Also

- [`csed`](csed.md) - Emit sed statement for content expansion
- [`fsed-script`](fsed-script.md) - Generate filename sed script file
- [`generate`](generate.md) - Create files from templates
- [`list`](list.md) - List variables in templates