# fsed-script

Generate filename sed script file.

## Synopsis

```bash
mulle-template fsed-script [options]
```

## Description

The `fsed-script` command generates a sed script file containing substitution commands for filename expansion. Unlike `fsed` which outputs inline sed expressions, this command creates a reusable script file for filename processing that can be used with `sed -f`.

This command is useful for:
- Creating reusable sed scripts for filename processing
- Generating scripts for batch filename transformations
- Building filename processing pipelines
- Version controlling filename transformation rules

## Options

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help information |
| `-fo <string>` | Specify key opener string for filenames (default: "") |
| `-fc <string>` | Specify key closer string for filenames (default: "") |
| `--no-date-environment` | Don't create substitutions for TIME, YEAR etc. |
| `--boring-environment` | Don't filter out environment keys considered boring |

## Examples

### Basic Script Generation
```bash
# Generate filename sed script
mulle-template fsed-script > filename.sed

# Use the script
echo "template_<|TYPE|>.txt" | sed -f filename.sed
```

### Environment Variables
```bash
# Generate script with specific variables
PROJECT="MyApp" VERSION="1.0" mulle-template fsed-script > rename.sed

# Apply to filenames
echo "backup_<|PROJECT|>_<|VERSION|>.sql" | sed -f rename.sed
```

### Custom Filename Markers
```bash
# Use different markers for filenames
mulle-template fsed-script -fo "{{" -fc "}}" > custom_rename.sed

# Apply custom script
echo "file_{{TYPE}}.txt" | sed -f custom_rename.sed
```

### Batch Processing
```bash
# Generate script for multiple files
mulle-template fsed-script > batch_rename.sed

# Process multiple filenames
for file in *.template; do
    new_name=$(basename "$file" | sed -f batch_rename.sed)
    mv "$file" "${new_name%.template}.txt"
done
```

## Output Format

The command outputs a sed script file with filename substitution commands:

```bash
s/<|PROJECT|>/MyApp/g
s/<|VERSION|>/1.0/g
s/<|TYPE|>/config/g
```

## How It Works

The `fsed-script` command:
1. **Analyzes Environment**: Collects filename-relevant environment variables
2. **Generates Substitutions**: Creates sed `s/pattern/replacement/g` commands
3. **Handles Special Characters**: Properly escapes characters for sed
4. **Outputs Script**: Writes multi-line sed script to stdout

## Use Cases

### File Renaming Scripts
```bash
# Generate renaming script
mulle-template fsed-script > rename_files.sed

# Apply to directory of files
find . -name "*.template" -exec sh -c '
    base=$(basename "$1" .template)
    new_name=$(echo "$base" | sed -f rename_files.sed)
    mv "$1" "${new_name}.txt"
' _ {} \;
```

### Build System Integration
```bash
# Generate filename script for build
mulle-template fsed-script > build/filename_processor.sed

# Use in build process
OUTPUT_NAME=$(echo "<|PROJECT|>_v<|VERSION|>.tar.gz" | sed -f build/filename_processor.sed)
tar -czf "$OUTPUT_NAME" build/
```

### Directory Structure Creation
```bash
# Create organized directory structure
mulle-template fsed-script > organize.sed

# Process files into structured directories
for file in *; do
    if [ -f "$file" ]; then
        dest_dir=$(echo "<|PROJECT|>/<|TYPE|>" | sed -f organize.sed)
        mkdir -p "$dest_dir"
        mv "$file" "$dest_dir/"
    fi
done
```

### CI/CD Pipeline Integration
```bash
# Dynamic artifact naming
export BRANCH_NAME="feature-x"
export BUILD_NUMBER="42"

mulle-template fsed-script > artifact_naming.sed

ARTIFACT_NAME=$(echo "app_<|BRANCH_NAME|>_<|BUILD_NUMBER|>.zip" | sed -f artifact_naming.sed)
```

## Script File Management

### Temporary Scripts
```bash
# Create temporary script
SCRIPT=$(mktemp)
mulle-template fsed-script > "$SCRIPT"

# Use for single operation
new_name=$(echo "file_<|TYPE|>.txt" | sed -f "$SCRIPT")

# Clean up
rm "$SCRIPT"
```

### Persistent Scripts
```bash
# Create named script for reuse
mulle-template fsed-script > "filename_processor_$(date +%Y%m%d).sed"

# Use in automated processes
sed -f filename_processor_$(date +%Y%m%d).sed input.txt
```

### Script Modification
```bash
# Generate base script
mulle-template fsed-script > base_filename.sed

# Add custom filename rules
echo 's/_debug$/_release/' >> base_filename.sed
echo 's/\.template$/.processed/' >> base_filename.sed

# Use enhanced script
echo "config_debug.template" | sed -f base_filename.sed
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

### Custom Variables
```bash
# Define custom filename variables
export COMPONENT="frontend"
export BUILD_TYPE="minified"

# Generate script
mulle-template fsed-script > custom_filename.sed

# Use in filename templates
echo "<|COMPONENT|>_<|BUILD_TYPE|>.js" | sed -f custom_filename.sed
```

### Including All Variables
```bash
# Include all environment variables
mulle-template fsed-script --boring-environment > all_vars_filename.sed

# Useful for complex filename schemes
echo "<|USER|>_<|PROJECT|>_<|TIMESTAMP|>.backup" | sed -f all_vars_filename.sed
```

## Troubleshooting

### Empty Script
```bash
# Check filename-relevant variables
env | grep -E '(PROJECT|VERSION|TYPE)'

# Set test variables
PROJECT="test" VERSION="1.0" mulle-template fsed-script

# Include more variables
mulle-template fsed-script --boring-environment
```

### Filename Markers Not Working
```bash
# Check marker syntax
echo "<|PROJECT|>_file.txt" | mulle-template fsed-script

# Use custom markers
echo "{{PROJECT}}_file.txt" | mulle-template fsed-script -fo "{{" -fc "}}"
```

### Special Characters in Filenames
```bash
# Handle spaces and special chars
export PROJECT="My Project"
mulle-template fsed-script  # Automatically handles escaping

# Manual escaping if needed
export SAFE_PROJECT="My_Project"
```

### Variable Not Substituted
```bash
# Check variable is set and exported
export MY_VAR="value"
echo "<|MY_VAR|>.txt" | mulle-template fsed-script | sed -f -

# Verify variable name format
echo "$MY_VAR" | grep '^[A-Za-z_][A-Za-z0-9_]*$'
```

## Advanced Usage

### Script Analysis
```bash
# Count substitutions
mulle-template fsed-script | wc -l

# List variables being processed
mulle-template fsed-script | sed 's/s\/<|\([^|>]*\)|>.*/\1/'

# Find specific variable
mulle-template fsed-script | grep "PROJECT"
```

### Conditional Processing
```bash
# Generate script only if required variables exist
if [ -n "$PROJECT" ] && [ -n "$VERSION" ]; then
    mulle-template fsed-script > filename_processor.sed
    echo "<|PROJECT|>_v<|VERSION|>.zip" | sed -f filename_processor.sed
else
    echo "Required variables missing"
fi
```

### Integration with File Operations
```bash
# Safe filename generation
generate_filename() {
    local template="$1"
    local base_name=$(echo "$template" | mulle-template fsed-script | sed -f -)

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

### Pipeline with Content Processing
```bash
# Combined content and filename processing
mulle-template csed-script > content.sed
mulle-template fsed-script > filename.sed

# Process both content and filename
original="template_<|TYPE|>.txt"
processed_content=$(sed -f content.sed "$original")
new_filename=$(echo "$original" | sed -f filename.sed)

echo "$processed_content" > "$new_filename"
```

## Performance Considerations

### Large Scripts
```bash
# Limit script size for performance
mulle-template fsed-script | head -20 > limited_filename.sed

# Split large scripts
mulle-template fsed-script | split -l 50 - filename_part_

# Process with multiple scripts
for part in filename_part_*; do
    sed -f "$part" -i input.txt
done
```

### Script Caching
```bash
# Cache script for multiple uses
SCRIPT_CACHE="build/filename_processor.sed"
if [ ! -f "$SCRIPT_CACHE" ] || [ "$SCRIPT_CACHE" -ot .env ]; then
    mulle-template fsed-script > "$SCRIPT_CACHE"
fi

# Use cached script
sed -f "$SCRIPT_CACHE" -i *.txt
```

### Optimization Techniques
```bash
# Remove unnecessary substitutions
mulle-template fsed-script | grep -v "UNUSED_VAR" > optimized_filename.sed

# Sort for better performance
mulle-template fsed-script | sort > sorted_filename.sed
```

## See Also

- [`fsed`](fsed.md) - Emit sed statement for filename expansion
- [`csed-script`](csed-script.md) - Generate content sed script file
- [`generate`](generate.md) - Create files from templates
- [`list`](list.md) - List variables in templates