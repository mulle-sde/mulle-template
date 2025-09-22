# fsed

Emit sed statement for filename expansion.

## Synopsis

```bash
mulle-template fsed [options]
```

## Description

The `fsed` command generates sed expressions for substituting `<|KEY|>` markers in filenames with environment variable values. It outputs the sed command that can be used to perform filename expansion during template processing.

This command is useful for:
- Generating reusable sed scripts for filename processing
- Understanding how mulle-template processes filenames
- Creating custom filename transformation pipelines
- Debugging filename substitution logic

## Options

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help information |
| `-fo <string>` | Specify key opener string for filenames (default: "") |
| `-fc <string>` | Specify key closer string for filenames (default: "") |
| `--no-date-environment` | Don't create substitutions for TIME, YEAR etc. |
| `--boring-environment` | Don't filter out environment keys considered boring |

## Examples

### Basic Usage
```bash
# Generate sed expression for filename substitution
mulle-template fsed

# Use with environment variables
PROJECT="MyApp" VERSION="1.0" mulle-template fsed

# Apply to filename
echo "MyApp_<|VERSION|>.txt" | mulle-template fsed | sed -f -
```

### Custom Filename Markers
```bash
# Use different markers for filenames
mulle-template fsed -fo "{{" -fc "}}"

# Mixed markers for content and filenames
mulle-template fsed -fo "{{" -fc "}}"
```

### Integration with Processing
```bash
# Process filename with generated sed
echo "template_<|TYPE|>.txt" | mulle-template fsed | sed -f -

# Create reusable sed script
mulle-template fsed > filename-sed.sed
echo "config_<|ENV|>.json" | sed -f filename-sed.sed
```

### Pipeline Processing
```bash
# Chain with content processing
echo "template_<|TYPE|>.txt" | \
    mulle-template fsed | sed -f - | \
    mulle-template csed | sed -f -
```

## Output Format

The command outputs a sed expression that can be used with the `-e` option:

```bash
-e 's/{{\([^}}]*\)}}/\1/g;s/<|PROJECT|>/MyApp/g'
```

Or as a multi-line sed script when used with fsed-script.

## How It Works

The `fsed` command analyzes environment variables and generates sed substitution commands specifically for filename processing:

1. **Variable Selection**: Focuses on variables relevant to filenames (PROJECT, VERSION, TYPE, etc.)
2. **Pattern Generation**: Creates sed patterns for filename marker replacement
3. **Escaping**: Properly escapes special characters for sed
4. **Sorting**: Orders substitutions by variable name length (longest first)

## Use Cases

### Filename Template Processing
```bash
#!/bin/bash
# Process filename templates

TEMPLATE_NAME="$1"
OUTPUT_DIR="$2"

# Generate final filename
FINAL_NAME=$(echo "$TEMPLATE_NAME" | mulle-template fsed | sed -f -)

# Copy with new name
cp "$TEMPLATE_NAME" "$OUTPUT_DIR/$FINAL_NAME"
```

### Batch File Renaming
```bash
# Rename files based on templates
for file in *.template; do
    new_name=$(basename "$file" .template | mulle-template fsed | sed -f -)
    mv "$file" "${new_name}.txt"
done
```

### Build System Integration
```bash
# Generate output filenames in build scripts
OUTPUT_FILE=$(echo "build_<|PROJECT|>_<|VERSION|>.tar.gz" | mulle-template fsed | sed -f -)

# Create archive with dynamic name
tar -czf "$OUTPUT_FILE" build/
```

### Directory Structure Creation
```bash
# Create directory structure with variable names
PROJECT_DIR=$(echo "<|PROJECT|>_v<|VERSION|>" | mulle-template fsed | sed -f -)
mkdir -p "$PROJECT_DIR"/{src,docs,tests}

# Copy templates to structured directories
find templates/ -name "*.txt" -exec sh -c '
    rel_path="${1#templates/}"
    dest_dir="'"$PROJECT_DIR"'"
    dest_file=$(echo "$rel_path" | mulle-template fsed | sed -f -)
    mkdir -p "$dest_dir/$(dirname "$dest_file")"
    cp "$1" "$dest_dir/$dest_file"
' _ {} \;
```

### CI/CD Pipeline Integration
```bash
# Dynamic artifact naming
export BRANCH_NAME="feature-x"
export BUILD_NUMBER="42"

ARTIFACT_NAME=$(echo "app_<|BRANCH_NAME|>_<|BUILD_NUMBER|>.zip" | mulle-template fsed | sed -f -)

# Package application
zip -r "$ARTIFACT_NAME" dist/
```

## Filename Variable Selection

### Default Filename Variables
The command focuses on variables commonly used in filenames:
- `PROJECT` - Project name
- `VERSION` - Version number
- `TYPE` - File type or category
- `ENV` - Environment (dev, prod, staging)
- `ARCH` - Architecture
- `PLATFORM` - Platform/OS

### Custom Filename Variables
```bash
# Define custom filename variables
export COMPONENT="frontend"
export BUILD_TYPE="debug"

# Use in filename templates
echo "<|COMPONENT|>_<|BUILD_TYPE|>.js" | mulle-template fsed | sed -f -
# Output: frontend_debug.js
```

### Including All Variables
```bash
# Include all environment variables in filename processing
mulle-template fsed --boring-environment

# Useful for complex filename templates
echo "<|USER|>_<|PROJECT|>_<|DATE|>.backup" | mulle-template fsed --boring-environment | sed -f -
```

## Sed Script Generation

### Single Line (fsed)
```bash
# For use with sed -e
mulle-template fsed
# Output: -e 's/<|VAR|>/value/g;s/<|VAR2|>/value2/g'
```

### Multi-Line Script (fsed-script)
```bash
# For use with sed -f
mulle-template fsed-script > filename.sed
# Output:
# s/<|VAR|>/value/g
# s/<|VAR2|>/value2/g
```

## Troubleshooting

### No Output
```bash
# Check filename-relevant variables
env | grep -E '(PROJECT|VERSION|TYPE|ENV)'

# Include more variables
mulle-template fsed --boring-environment

# Set test variables
PROJECT="test" VERSION="1.0" mulle-template fsed
```

### Filename Markers Not Working
```bash
# Check marker syntax
echo "<|PROJECT|>_file.txt" | mulle-template fsed

# Use custom markers
echo "{{PROJECT}}_file.txt" | mulle-template fsed -fo "{{" -fc "}}"
```

### Special Characters in Filenames
```bash
# Handle spaces and special chars
export PROJECT="My Project"
echo "<|PROJECT|>.txt" | mulle-template fsed | sed -f -

# Escape manually if needed
export SAFE_PROJECT="My_Project"
```

### Variable Not Substituted
```bash
# Check variable is set and exported
export MY_VAR="value"
echo "<|MY_VAR|>.txt" | mulle-template fsed | sed -f -

# Verify variable name format
echo "$MY_VAR" | grep '^[A-Za-z_][A-Za-z0-9_]*$'
```

## Advanced Usage

### Complex Filename Templates
```bash
# Multi-variable filenames
echo "<|PROJECT|>-<|VERSION|>-<|ARCH|>-<|OS|>.tar.gz" | mulle-template fsed | sed -f -

# Nested directory structures
echo "releases/<|VERSION|>/<|PLATFORM|>/<|PROJECT|>.exe" | mulle-template fsed | sed -f -
```

### Conditional Filename Processing
```bash
# Process only if variables are set
if [ -n "$PROJECT" ] && [ -n "$VERSION" ]; then
    FINAL_NAME=$(echo "<|PROJECT|>_v<|VERSION|>.zip" | mulle-template fsed | sed -f -)
    echo "Final name: $FINAL_NAME"
else
    echo "Required variables not set"
fi
```

### Filename Validation
```bash
# Check filename template compatibility
TEMPLATE_VARS=$(echo "$FILENAME_TEMPLATE" | sed 's/.*<|\([^|>]*\)|>.*/\1/' | sort -u)
SED_VARS=$(mulle-template fsed | sed 's/.*s\/<|\([^|>]*\)|>.*/\1/' | sort -u)

MISSING=$(comm -23 <(echo "$TEMPLATE_VARS") <(echo "$SED_VARS"))
if [ -n "$MISSING" ]; then
    echo "Missing filename variables: $MISSING"
fi
```

### Integration with File Operations
```bash
# Safe file operations with validation
generate_filename() {
    local template="$1"
    local base_name=$(echo "$template" | mulle-template fsed | sed -f -)

    # Validate generated filename
    if [[ "$base_name" =~ [^a-zA-Z0-9._-] ]]; then
        echo "Invalid characters in filename: $base_name" >&2
        return 1
    fi

    echo "$base_name"
}

# Usage
TEMPLATE_FILE="backup_<|DATE|>.sql"
OUTPUT_FILE=$(generate_filename "$TEMPLATE_FILE")
[ $? -eq 0 ] && mysqldump db > "$OUTPUT_FILE"
```

## Performance Considerations

### Large Variable Sets
```bash
# Limit variables for performance
mulle-template fsed | head -10  # First 10 substitutions

# Use specific variables only
env -i PROJECT="$PROJECT" VERSION="$VERSION" mulle-template fsed
```

### Caching Sed Scripts
```bash
# Generate once, reuse multiple times
mulle-template fsed > filename_sed_cache.sed

# Use cached script
for file in *.template; do
    new_name=$(basename "$file" .template | sed -f filename_sed_cache.sed)
    mv "$file" "${new_name}.txt"
done
```

## See Also

- [`csed`](csed.md) - Emit sed statement for content expansion
- [`fsed-script`](fsed-script.md) - Generate filename sed script file
- [`generate`](generate.md) - Create files from templates
- [`list`](list.md) - List variables in templates