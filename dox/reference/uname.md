# uname

mulle-template's simplified uname(1).

## Synopsis

```bash
mulle-template uname
```

## Description

The `uname` command displays simplified system information, similar to the standard Unix `uname` command but with mulle-template specific formatting and information.

## Options

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help information |

## Examples

### Basic Usage
```bash
# Display system information
mulle-template uname

# Output: linux
```

### Integration with Scripts
```bash
# Use in conditional logic
if [ "$(mulle-template uname)" = "darwin" ]; then
    echo "Running on macOS"
elif [ "$(mulle-template uname)" = "linux" ]; then
    echo "Running on Linux"
fi
```

## Output Format

The command outputs a single word identifying the operating system:

- `linux` - Linux systems
- `darwin` - macOS systems
- `mingw` - Windows systems (MinGW)
- `sunos` - Solaris systems

## How It Works

The command uses the `MULLE_UNAME` environment variable, which is set by the mulle-bashfunctions library during initialization.

## Use Cases

### Platform Detection
```bash
# Detect platform for conditional processing
PLATFORM=$(mulle-template uname)
case "$PLATFORM" in
    darwin)
        echo "macOS specific configuration"
        ;;
    linux)
        echo "Linux specific configuration"
        ;;
    mingw)
        echo "Windows specific configuration"
        ;;
esac
```

### Build System Integration
```bash
# Use in build scripts
PLATFORM=$(mulle-template uname)
if [ "$PLATFORM" = "mingw" ]; then
    EXE_EXT=".exe"
else
    EXE_EXT=""
fi
```

## See Also

- [`hostname`](hostname.md) - Show hostname
- [`environment`](environment.md) - Show environment variables
- [`version`](version.md) - Show version information