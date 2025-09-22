# environment

Show environment variables.

## Synopsis

```bash
mulle-template environment
```

## Description

The `environment` command displays all environment variables that are currently set, sorted alphabetically. This is useful for debugging template processing and understanding what variables are available for substitution.

## Options

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help information |

## Examples

### Basic Usage
```bash
# Display all environment variables
mulle-template environment

# Output:
# HOME=/home/user
# PATH=/usr/local/bin:/usr/bin:/bin
# PWD=/current/directory
# ...
```

### Integration with Scripts
```bash
# Check for specific variables
if mulle-template environment | grep -q "MY_VAR"; then
    echo "MY_VAR is set"
fi

# Count environment variables
VAR_COUNT=$(mulle-template environment | wc -l)
echo "Number of environment variables: $VAR_COUNT"
```

## Output Format

The command outputs environment variables in the format `KEY=VALUE`, one per line, sorted alphabetically by key.

## How It Works

The command uses the standard `env` command to display environment variables, with output sorted using `LC_ALL=C sort` for consistent ordering.

## Use Cases

### Debugging Templates
```bash
# Check what variables are available for template substitution
mulle-template environment | grep "PROJECT\|VERSION"

# Verify specific variable values
mulle-template environment | grep "^MY_VAR="
```

### Template Development
```bash
# See all available variables for template creation
mulle-template environment > available_vars.txt

# Check variable naming conventions
mulle-template environment | grep '^[A-Z_][A-Z0-9_]*='
```

### Build System Integration
```bash
# Export environment for build scripts
eval $(mulle-template environment | sed 's/^/export /')

# Create environment file
mulle-template environment > build.env
```

### Variable Validation
```bash
# Check for required variables
REQUIRED_VARS="PROJECT VERSION AUTHOR"
for var in $REQUIRED_VARS; do
    if ! mulle-template environment | grep -q "^${var}="; then
        echo "ERROR: Required variable $var not set"
        exit 1
    fi
done
```

## See Also

- [`hostname`](hostname.md) - Show hostname
- [`uname`](uname.md) - Show system information
- [`version`](version.md) - Show version information