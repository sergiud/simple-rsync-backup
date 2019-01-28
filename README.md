# Simple rsync backup

This repository contains a very basic rsync backup script. The bash script can
be used to backup data both on Windows, for instance, using the Cygwin
environment, or on Linux.

## Features

* Incremental backups
* Backups can be canceled and resumed later

## Usage

The backup configuration is provided by a Bash script `~/.srbrc` that stores the
source directories for backup in an array variable called `src`. The destination
directory is specified by the variable `dst`. Additionally, one may provide the
name of the file containing a list of excluded files passed to `rsync` using the
`--exclude-from` parameter.

An example of a `.srbrc`:

```bash
src[0]=/cygdrive/d/Data1
src[1]=/cygdrive/d/Data2
dst=/cygdrive/e/Backup
exclude=~/.srbrc.d/excluded.txt
```
