---
title: Find and Replace
weight: 80
---

## Basic Usage

**Jay** includes the ability to do a case-sensitive find and replace. This is
great when you have many files to look through and need simple way to
find and replace quickly.

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