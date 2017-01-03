---
title: Database Migration
weight: 80
---

## Basic Usage

Database migrations are a great way to manage incremental database changes.
The migration state is stored in the same database (the one specified in
env.json) and recorded in the **migration** table. This is how the
`jay migrate:mysql status`command knows which migration was performed last.

Each incremental change should have a set of two files: an 'up' file and a
'down' file. The 'up' file contains code (like SQL) which is applied to the
database you add features or fix bugs in your database. The 'down' file contains
the code to remove the change or undo it.

More than one migration can now be run on a database. You just have to specify
a different table value in the env.json file under the MySQL.Migration.Table key.

**Note 1**: The `jay migrate` commands requires the environment variable,
**JAYCONFIG**, to point to the env.json file path. The migration folder is specified
in the env.json file under **MySQL.Migration.Folder**. If the environment variable
is not set, you can specify the --config or -c flag and pass the path to env.json.

**Note 2**: Make sure you do not create any migrations with a date earlier than
any applied migrations. Jay will not go back and apply them. They must be
created sequentially.

When you start using **Blueprint** you'll see two migration files already exist
in the **migration/mysql** folder:

* 20160630_020000.000000_init.up.sql - adds the initial tables and data
* 20160630_020000.000000_init.down.sql - removes the tables and data

**Jay** provides a few commands to make the migrations easier. Here is a list
of the commands:

```bash
jay migrate:mysql make "test" # Create new migration
jay migrate:mysql all         # Advance all migrations
jay migrate:mysql reset       # Rollback all migrations
jay migrate:mysql refresh     # Rollback all migrations then advance all migrations
jay migrate:mysql status      # See last 'up' migration
jay migrate:mysql up          # Apply only the next 'up' migration
jay migrate:mysql down        # Apply only the current 'down' migration
```

## Workflow

Let's walk through an typical workflow. Assume the **blueprint** folder is the
root of a git repository. Developer Joe needs to add a feature to the
application to store books. Joe creates a new branch called feature-store-books.
He needs to create a new table called **book** so he creates a new database
migration: `jay migrate:mysql make "feature-store-books"`. He opens the 'up' file
and adds the SQL query to create a new table with the following columns: title,
author, and publication_date. In the 'down' file, he writes the code to drop the
table. He also writes the code to create, read, update, and
delete the books in his Go code and then performs a `git merge` and then a
`git push`. Developer Steve needs to add an additional column to the
**book** table called: publisher. Steve performs a `git pull` to download the
latest code from the repository. In order to update his local database to the
latest version of code, runs: `jay migrate:mysql all`. Then, Steve creates a new
migration for the new requirement: `jay migrate:mysql make "feature-add-publisher"`.
Steve adds the SQL `ADD COLUMN` code to the new 'up' file and the SQL
`DROP COLUMN` code to the new 'down' file and then performs a `git merge` and a
`git push` again.

## migrate make

The `jay migrate:mysql make [description]` command create a new 'up' and 'down'
migration in the **database/migration** folder.

## migrate all

The `jay migrate:mysql all` command finds the current status of the database and then
applies all the code from each of the 'up' files in chronological order based on
filename.

## migrate reset

The `jay migrate:mysql reset` command finds the current status of the database and
then applies all the code from each of the 'down' files in reverse chronological
order based on filename which should remove all tables and data with the
exception of an an empty **migration** table.

**Note:** If any tables were created outside of the migrations, they should
still be in the database.

## migrate refresh

The `jay migrate:mysql refresh` command runs a `jay migrate reset` and then applies
all the code from each of the 'up' files in chronological order based on
filename.

## migrate status

The `jay migrate:mysql status` command reads the latest record in the **migration**
table which is the last 'up' file that was applied to the database.

## migrate up

The `jay migrate:mysql up` command applies only the code in the next 'up' file in
chronological order based on filename.

## migrate down

The `jay migrate:mysql down` command applies only the code in the current 'down' file.

## Other Database Changes

If the 'up' and 'down' files are written properly, tables created manually
outside the migrations should be left untouched by the `jay migrate` commands.
The only changes `jay migrate` makes to the database outside of the migrations
are the creation of the database itself based on the settings in env.json and
the modification of the **migration** table.
