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
bootstrap/	     - package for initial set up of the application
controller/	     - packages with routes and application logic
database/
|----migration/  - SQL files for migration database up and down
generate/	     - template pairs (.gen and .json) for generating code using jay
lib/             - packages with minimum dependencies
middleware/      - packages that return a http.Handler to wrap around routes for ACL, request logging, etc
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

The project is organized into the following folders:

```text
env/       - package that creates and updates the env.json config file
find/      - package that finds case-sensitive matched text in files
generate/  - package that generates code from template pairs
lib/       - packages with minimum dependencies
migrate/   - package that handles the database migrations
replace/   - package that replaces case-sensitive matched text in files
```

The following file exists at the project root:

```text
jay.go     - entrypoint for the application
```

## Jay External Go Packages

There are a few external packages used in Jay:

```text
github.com/gorilla/securecookie   - generate random keys for authentication and encryption
github.com/go-sql-driver/mysql 	  - MySQL driver
github.com/jmoiron/sqlx 		  - MySQL general purpose extensions
gopkg.in/alecthomas/kingpin.v2    - command-line and flag parser
```