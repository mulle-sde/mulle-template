# commands

List available commands.

## Synopsis

```bash
mulle-template commands
```

## Description

The `commands` command lists all available commands in mulle-template. This is useful for discovering what operations are available and for scripting purposes.

## Options

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help information |

## Examples

### Basic Usage
```bash
# List all available commands
mulle-template commands

# Output:
# clean
# environment
# libexec-dir
# library-path
# list
# generate
# uname
# version
```

### Integration with Scripts
```bash
# Check if a command exists
if mulle-template commands | grep -q "generate"; then
    echo "generate command is available"
fi

# Count available commands
COMMAND_COUNT=$(mulle-template commands | wc -l)
echo "Number of commands: $COMMAND_COUNT"
```

## Output Format

The command outputs one command name per line, sorted alphabetically.

## How It Works

The command prints a hardcoded list of available commands from the main script's case statement.

## Use Cases

### Command Discovery
```bash
# See all available operations
mulle-template commands

# Get help for each command
for cmd in $(mulle-template commands); do
    echo "=== $cmd ==="
    mulle-template "$cmd" --help 2>/dev/null || echo "No help available"
done
```

### Scripting
```bash
# Validate command availability
REQUIRED_COMMANDS="generate list environment"
for cmd in $REQUIRED_COMMANDS; do
    if ! mulle-template commands | grep -q "^${cmd}$"; then
        echo "ERROR: Required command $cmd not available"
        exit 1
    fi
done
```

### Documentation Generation
```bash
# Generate command list for documentation
echo "# Available Commands"
echo ""
mulle-template commands | while read cmd; do
    echo "- \`$cmd\` - $(mulle-template "$cmd" --help 2>&1 | head -1)"
done
```

## See Also

- [`version`](version.md) - Show version information
- [`libexec-dir`](libexec-dir.md) - Show libexec directory
- [`environment`](environment.md) - Show environment variables