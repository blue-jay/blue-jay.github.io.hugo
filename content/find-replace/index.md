---
title: Find and Replace
weight: 75
---

## Basic Usage

**Jay** includes the ability to do a case-sensitive find and replace. This is
great when you have many files to look through and need simple way to
find and replace quickly.

## Find Usage

```bash
usage: jay find <folder> <text> [<extension>] [<recursive>] [<filename>]

Search for files containing matching text.

Flags:
  -h, --help     Show context-sensitive help (also try --help-long and
                 --help-man).
  -v, --version  Show application version.

Args:
  <folder>       Folder to search
  <text>         Case-sensitive text to find.
  [<extension>]  File name or extension to search in. Use * as a wildcard.
                 Directory names are not valid.
  [<recursive>]  True to search in subfolders. Default: true
  [<filename>]   True to include file path in results if matched. Default: false
```

## Replace Usage

```bash
usage: jay replace <folder> <find> [<replace>] [<extension>] [<recursive>] [<filename>] [<commit>]

Search for files containing matching text and then replace it with new text.

Flags:
  -h, --help     Show context-sensitive help (also try --help-long and
                 --help-man).
  -v, --version  Show application version.

Args:
  <folder>       Folder to search
  <find>         Case-sensitive text to replace.
  [<replace>]    Text to replace with.
  [<extension>]  File name or extension to search in. Use * as a wildcard.
                 Directory names are not valid.
  [<recursive>]  True to search in subfolders. Default: true
  [<filename>]   True to include file path in results if matched. Default: false
  [<commit>]     True to makes the changes instead of just displaying them.
                 Default: true
```

## Find and Replace Examples

Here are examples are how to use find and replace:

```bash
# Find the word "red" in all *.go files in the current folder and in subfolders.
jay find . red

# Find the word "red" in all files in the current folder only.
jay find . red "*.*" false

# Find the word "red" in *.go files in current folder and in subfolders and 
# include file paths that match also.
jay find . red "*.go" true true

# Replace the word "red" with the word "blue" in all *.go files in the current
# folder and in subfolders.
jay replace . red blue

# Replace the word "red" with the word "blue" in all *.go files in current
# folder only.
jay replace . red blue "*.go" false

# Change the name of the project in current folder and in subfolders and all
# imports to another repository.
jay replace . "blue-jay/blueprint" "user/project"
```