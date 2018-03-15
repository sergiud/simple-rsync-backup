# Simple rsync backup

This repository contains a very basic rsync backup script. The bash script is
mostly used to backup data on Windows using Cygwin.

## Usage

The script expects a `backup.conf` in its directory. The configuration file
itself is a Bash script as well and stores the source directories for backup in
an array variable named `src`. The destination directory is specified by the
variable `dst`. Additionally, one may provide the name of the file containing a
list of excluded files passed to `rsync` using the `--exclude-from` parameter.

A typical `backup.conf` looks as follows:

```bash
src[0]=/cygdrive/d/Data1
src[1]=/cygdrive/d/Data2
dst=/cygdrive/e/Backup
exclude=excluded.txt
```
