# mulle-template

🕋 Template generator for text files

![Last version](https://img.shields.io/github/tag/mulle-sde/mulle-template.svg)

Generates a text file from a template file or a folder of files from a folder
of templates.


A template file could look like this:

`template`:

```
// Author: <|AUTHOR:-unknown|>
#include <stdio.h>

int  main( int argc, char *argv[])
{
   printf( "%s\n", "<|MESSAGE:-Hello World|>");
   return( 0);
}
```

And would be transformed by `mulle-template` using the contents of the
environment with `MESSAGE="VfL Bochum 1848" mulle-template generate template -`
into:


```
// Author: unknown
#include <stdio.h>

int  main( int argc, char *argv[])
{
   printf( "%s\n", "VfL Bochum 1848");
   return( 0);
}
```

Executable       | Description
-----------------|--------------------------------
`mulle-template` | Template generator



## Commands


### csed

**csed** generates `sed` replacement strings from the current environment
suitable for replacing file contents.

You can experiment with key delimiters other than '<|' and '>' with the
`--opener` and `--closer` options.

E.g.

```
mulle-template --clean-env -DAUTHOR=moi \
          csed --opener '${' \
               --closer '}' \
               --no-date-environment \
               --no-boring-environment
```

Should produce:

```
-e 's/\${AUTHOR\(:-[^}]*\)\{0,1\}}/moi/g' -e 's/\${[^}]*:-\([^}]*\)}/\1/g'
```

Check the commands usage to see a description of the available options.


### fsed

**fsed** generates `sed` replacement strings from the current environment
suitable for replacing filenames. The environment variable must contain one of
the uppercase words `EXTENSION`, `DIRECTORY`, `FILENAME` or must end with
`_NAME`, `_IDENTIFIER`, `_DIR`, `_FILE`, `_EXT` to be considered a suitable
replacement key.

You can experiment with key delimiters for the filenames with the options
`--filename-opener` and --`filename-closer`.

E.g.

```
mulle-template --clean-env -DFILENAME=myfile fsed --filename-opener "_"
```

Should produce:

```
-e 's/_FILENAME/myfile/g'
```

### generate

The **generate** command generates sed expressions with **csed** and
**fsed** and applies them to the contents of a directory or to a single file.

The filenames are transformed with the **fsed** and the contents of each
file are transformed with **csed**. The transformation is done using `sed`
of course.

A template file contains regular text that is copied unchanged and keys
delimited by "<|" and "|>" (e.g. <|FOO|>). These are substituted with values
found in the environment variables. For unset variables you can supply a default
substitution value (e.g. <|FOO:-no foo|>).

You have a few options, outside of those mentioned in the **fsed** and **csed**
commands, to customize the templating operation.


#### --without-template-dir

Usually the template directory is copied along with the files. So the command
`mulle-template generate templates foo`  with a directory:

```
templates
├── file1
└── file2
```

will produce

```
foo
└── templates
    ├── file1
    └── file2
```

If you don't like that, you can use the option `--without-template-dir`.

#### --no-permissions

Usually **mulle-template** copies the permissions of the template file over
to the generated file. This can be turned off with `--no-permissions`.

#### --overwrite

Usually **mulle-template** does not overwrite existing files. You can do so
by either specifing the `--overwrite` option or the `-f` flag (which comes
before the `generate` command)

#### --file

Picking out a single file. Sometimes it is convenient to just reinstall a
single file from a batch of template files. In combination with
`--overwrite` the `--file` option allows you to do just that.

#### --header-file / --footer-file

For source files it is often convenient to prepend a copyright header and
other personal information. If the template has a line containing
<|HEADER|> only or <|FOOTER|> only, then the contents of the files given by
--header-file or --footer-file are inserted. These contents will also undergo
template expansion.


## Install

See [mulle-sde-developer](//github.com/mulle-sde/mulle-sde-developer) how
to install mulle-sde.


## Documentation

If there is documentation outside of this README it is in the various
command help texts within **mulle-template** or in the
[mulle-sde WiKi](//github.com/mulle-sde/mulle-sde/wiki).


## Author

[Nat!](//www.mulle-kybernetik.com/weblog) for
[Mulle kybernetiK](//www.mulle-kybernetik.com) and
[Codeon GmbH](//www.codeon.de)

