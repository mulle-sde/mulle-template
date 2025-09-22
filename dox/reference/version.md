# version

Show version information.

## Synopsis

```bash
mulle-template version
```

## Description

The `version` command displays the version of mulle-template that is currently installed.

## Options

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help information |

## Examples

### Basic Usage
```bash
# Display version
mulle-template version

# Output: 1.1.4
```

### Integration with Scripts
```bash
# Check version in scripts
VERSION=$(mulle-template version)
echo "mulle-template version: $VERSION"

# Version comparison
if [ "$(mulle-template version)" = "1.1.4" ]; then
    echo "Correct version installed"
fi
```

## Output Format

The command outputs the version number as a simple string:

```
1.1.4
```

## How It Works

The command prints the value of the `MULLE_EXECUTABLE_VERSION` variable, which is set at build time.

## Use Cases

### Version Checking
```bash
# Verify installation
if mulle-template version >/dev/null 2>&1; then
    echo "mulle-template is installed: $(mulle-template version)"
else
    echo "mulle-template is not installed"
fi
```

### Compatibility Checks
```bash
# Check minimum version
CURRENT=$(mulle-template version)
REQUIRED="1.1.0"

if [ "$CURRENT" = "$REQUIRED" ] || [ "$CURRENT" \> "$REQUIRED" ]; then
    echo "Version requirement met"
else
    echo "Version $REQUIRED or higher required, found $CURRENT"
fi
```

### Build System Integration
```bash
# Include version in build info
echo "#define MULLE_TEMPLATE_VERSION \"$(mulle-template version)\"" > version.h
```

## See Also

- [`uname`](uname.md) - Show system information
- [`hostname`](hostname.md) - Show hostname
- [`libexec-dir`](libexec-dir.md) - Show libexec directory