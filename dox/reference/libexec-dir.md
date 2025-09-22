# libexec-dir

Print path to mulle-template libexec directory.

## Synopsis

```bash
mulle-template libexec-dir
```

## Description

The `libexec-dir` command prints the path to the mulle-template libexec directory, which contains internal scripts and executables used by mulle-template. This is primarily used for debugging, development, and integration with other tools.

## Options

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help information |

## Examples

### Basic Usage
```bash
# Print libexec directory path
mulle-template libexec-dir

# Output: /usr/local/libexec/mulle-template
```

### Integration with Scripts
```bash
# Use in shell scripts
LIBEXEC_DIR=$(mulle-template libexec-dir)
echo "Libexec directory: $LIBEXEC_DIR"

# Check if libexec directory exists
if [ -d "$(mulle-template libexec-dir)" ]; then
    echo "Libexec directory exists"
fi
```

### Development Usage
```bash
# List contents of libexec directory
ls -la "$(mulle-template libexec-dir)"

# Check for specific internal scripts
find "$(mulle-template libexec-dir)" -name "*.sh" -type f
```

## Output Format

The command outputs a single line containing the absolute path to the libexec directory:

```
/usr/local/libexec/mulle-template
```

## How It Works

The command retrieves the `MULLE_TEMPLATE_LIBEXEC_DIR` environment variable, which is set during mulle-template initialization to point to the directory containing internal scripts and executables.

## Use Cases

### Debugging
```bash
# Check libexec directory contents for troubleshooting
ls -la "$(mulle-template libexec-dir)"

# Verify internal scripts are present
test -f "$(mulle-template libexec-dir)/mulle-template-generate.sh" && echo "Generate script found"
```

### Development
```bash
# Access internal scripts for development
LIBEXEC="$(mulle-template libexec-dir)"
cat "$LIBEXEC/mulle-template-generate.sh" | head -20
```

### Integration Testing
```bash
# Verify installation integrity
LIBEXEC_DIR=$(mulle-template libexec-dir)
if [ ! -d "$LIBEXEC_DIR" ]; then
    echo "ERROR: Libexec directory missing"
    exit 1
fi

# Check for required internal files
for script in "mulle-template-generate.sh"; do
    if [ ! -f "$LIBEXEC_DIR/$script" ]; then
        echo "ERROR: Required script $script missing"
        exit 1
    fi
done
```

### Build System Integration
```bash
# Use in build scripts
export MULLE_TEMPLATE_LIBEXEC_DIR=$(mulle-template libexec-dir)

# Reference internal scripts in build process
"$MULLE_TEMPLATE_LIBEXEC_DIR/mulle-template-generate.sh" --help
```

## Troubleshooting

### Command Not Found
```bash
# Check if mulle-template is properly installed
which mulle-template

# Verify libexec directory exists
mulle-template libexec-dir 2>/dev/null || echo "Command failed"
```

### Empty Output
```bash
# Check environment
env | grep MULLE_TEMPLATE

# Try running with verbose output
mulle-template -v libexec-dir
```

### Permission Issues
```bash
# Check permissions on libexec directory
ls -ld "$(mulle-template libexec-dir)"

# Verify read access
test -r "$(mulle-template libexec-dir)" && echo "Readable" || echo "Not readable"
```

## See Also

- [`version`](version.md) - Show version information
- [`uname`](uname.md) - Show system information
- [`environment`](environment.md) - Show environment variables