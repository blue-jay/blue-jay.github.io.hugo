---
title: Structure
weight: 5
---

It helps to understand the folder structure so you know where each of the
components lives.

## Blueprint Structure

The project is organized into the following folders:

```text
asset/
|----dynamic/    - private assets like SASS files, single JavaScript files, and logo.png for favicon generation
|----static/     - public assets like CSS, JavaScript, and favicon.ico for Android, Apple, etc
boot/            - package for initial set up of the application
controller/	     - packages with routes and application logic
filestorage/     - files uploaded from an HTML form
generate/	     - template pairs (.gen and .json) for generating code using jay
lib/             - packages you'll build that are used by the application (recommended to build with minimum dependencies)
middleware/      - packages that return a http.Handler to wrap around routes for ACL, request logging, etc
migration/       - migration database files
|----mysql/      - MySQL files for migrating database up and down
model/		     - packages with database queries and structs matching tables
view/            - HTML templates parsed using the Go html/template package
viewfunc/        - packages that return a template.FuncMap for use in views
viewmodify/      - packages that modify view prior to rendering to add varibles like CSRF token and auth level
```

The following files exist at the project root:

```text
blueprint.go     - entrypoint for the application
env.json.example - application config template for variables
gulpfile.js      - Gulp configuration that compiles SASS, concatenates JavaScript, etc
package.json     - npm configuration that loads Gulp, Boostrap, Underscore.js, etc
```

## Blueprint External Go Packages

There are a few external packages used in Blueprint:

```text
github.com/gorilla/context				- registry for global request variables
github.com/gorilla/csrf                 - CSRF protection for gorilla sessions
github.com/gorilla/sessions				- cookie and filesystem sessions
github.com/go-sql-driver/mysql 			- MySQL driver
github.com/husobee/vestigo              - HTTP router with wildcards
github.com/jmoiron/sqlx 				- MySQL general purpose extensions
github.com/justinas/alice				- middleware chaining
golang.org/x/crypto/bcrypt 				- password hashing algorithm
```

## Jay Structure

The project is simply a command-line interface for packages in the Core library
https://github.com/blue-jay/core. The packages that Jay uses from the Core
library are:

```text
env/       - package that creates and updates the env.json config file
find/      - package that finds case-sensitive matched text in files
generate/  - package that generates code from template pairs
migrate/   - package that handles the database migrations
replace/   - package that replaces case-sensitive matched text in files
```

The following file exists at the project root of Jay:

```text
jay.go     - entrypoint for the application
```

## Jay External Go Packages

There is only one external packages used in Jay (not including the Core
library):

```text
gopkg.in/alecthomas/kingpin.v2    - command-line and flag parser
```

## Core Structure

The Core project contains many packages that are all divided into individual
folders. Each is well documented so the
[GoDoc](https://godoc.org/github.com/blue-jay/core) page should provide enough
information on each one.