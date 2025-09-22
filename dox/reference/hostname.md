# hostname

Show hostname.

## Synopsis

```bash
mulle-template hostname
```

## Description

The `hostname` command displays the hostname of the system where mulle-template is running.

## Options

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help information |

## Examples

### Basic Usage
```bash
# Display hostname
mulle-template hostname

# Output: myhost.example.com
```

### Integration with Scripts
```bash
# Use in conditional logic
if [ "$(mulle-template hostname)" = "production-server" ]; then
    echo "Running on production"
fi
```

## Output Format

The command outputs the system hostname as a string.

## How It Works

The command uses the `MULLE_HOSTNAME` environment variable, which is set by the mulle-bashfunctions library.

## Use Cases

### Environment Detection
```bash
# Detect deployment environment
HOST=$(mulle-template hostname)
case "$HOST" in
    dev-*)
        echo "Development environment"
        ;;
    staging-*)
        echo "Staging environment"
        ;;
    prod-*)
        echo "Production environment"
        ;;
    *)
        echo "Unknown environment"
        ;;
esac
```

### Logging
```bash
# Include hostname in logs
echo "[$(mulle-template hostname)] $(date): Processing started" >> app.log
```

## See Also

- [`uname`](uname.md) - Show system information
- [`environment`](environment.md) - Show environment variables
- [`version`](version.md) - Show version information