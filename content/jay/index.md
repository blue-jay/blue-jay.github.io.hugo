---
title: Jay Overview
weight: 70
---

## Basic Usage

The command-line tool, **Jay**, has been mentioned throughout this documentation
quite a few times now so it's a good time to talk a little about the tool.

**Jay** uses the brilliant
[github.com/alecthomas/kingpin](github.com/alecthomas/kingpin) package to manage
the help documents, commands, subcommands, and arguments. It takes care of
groundwork so we can focus on the actual tasks.

If you ever want to see the help documents for a command or subcommand, add
`-h` or `--help` to the end and the help documentation should be able to assist.
If you are still having problems, check out the
[Jay GoDoc](https://godoc.org/github.com/blue-jay/jay).

When using **Jay**, there are flags, commands, and subcommands.

The available flags throughout are:

- `-h` or `--help` for help documentation
- `-v` or `--version` for version information

The available commands are:

- `jay env` for managing the env.json file
- `jay find` for locating text inside files in subfolders
- `jay replace` for replacing text inside files in subfolder
- `jay generate` for creating code based on templates using the **text/template** package
- `jay migrate` for managing the database state

The available subcommands are:

- `jay env make` for creating env.json from env.json.example
- `jay env keyshow` for showing newly generated session keys
- `jay env updateshow` for updating env.json with newly generation session keys
- `jay migrate make` for creating a new migration 'up' file and 'down' file
- `jay migrate all` for applying all 'up' migrations
- `jay migrate reset` for applying all 'down' migrations
- `jay migrate refresh` for applying all 'down' then 'up' migrations
- `jay migrate status` for displaying the current database state
- `jay migrate up` for applying only one 'up' migration
- `jay migrate down` for applying one one 'down' migration

There is also a common syntax used by each of the commands, subcommands, and
arguments that make the help documents easy to follow.

- Flags have one or two dashes in the front: `-h, --help`
- Commands follow the application name (jay): `jay migrate`
- Subcommands follow the command: `jay migrate make`
- Arguments follow the command or subcommand: `jay migrate make <description>`
- Required arguments: `<required>`
- Optional arguments: `[<optional>]`