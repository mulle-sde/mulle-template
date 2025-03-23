### 1.1.3

* fix single quote escaping

### 1.1.2

* Fixed escaping of special characters (quotes, backslashes, etc.) in template substitutions
* Various small improvements

### 1.1.1

* Various small improvements

### 1.0.3

* -D can now take values with linefeeds

### 1.0.2

* Various small improvements

### 1.0.1

* Various small improvements

# 1.0.0

* big function rename to `<tool>`::`<file>`::`<function>` to make it easier to read hopefully
* a footer comment can be passed in via the commandline, in addition to regular footer. The text is treated in a special way as \\n gets expanded into proper linefeeds
* uses mulle-bashfunctions 4 now
* can now run under zsh if bash is not available


### 0.0.4

* Various small improvements

### 0.0.3

* improve README.md with an example

### 0.0.2

* use env instead of printenv for compatibility

### 0.0.1

* split off from mulle-sde
