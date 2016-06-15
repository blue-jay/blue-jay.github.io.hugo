---
date: 2016-03-08T21:07:13+01:00
title: Toolkit Overview
type: index
weight: 0
---

[![Go Report Card](https://goreportcard.com/badge/github.com/blue-jay/blueprint)](https://goreportcard.com/report/github.com/blue-jay/blueprint)
[![GoDoc](https://godoc.org/github.com/blue-jay/blueprint?status.svg)](https://godoc.org/github.com/blue-jay/blueprint)

Blue Jay is a toolkit designed to get your web application off the ground. It's a collection of command line tools along with a web blueprint that is flexible enough to fit any project, yet provides a foundation so you can focus on the task instead of designing your own tools. You can easily change the structure and there is no rigid framework to which you have to conform. Even the command line tools like code generation and database migration are portable so they can be used outside your project.

There are a few components:

- **Blueprint** is a model-view-controller (MVC) style web skeleton

- **Jay** is a command line tool with modules for find/replace, database migrations, and code generation

## Why Blue Jay?

There are a few web frameworks for Go, but we support the Go mentality that you should keep
your application dependency lean. Less dependencies means less bugs.
It's also great to start developing your application right away instead of learning
all the features of a framework and then developing once you are proficient enough.
Blue Jay provides a lean web skeleton called Blueprint to demonstrate how to structure
a web application without locking developers to a framework. Blueprint includes well thought out
example code that demonstrates a typical web workflow.

One of the things you'll notice while using Blueprint is how to abstract out
external packages to make it easy to swap out components. Ultimately, you should
be able to write code once and use it in all of your other projects. The **lib**
folder is a great place for all these packages with very few dependencies.

You'll also notice certain packages need to be thread-safe when building web applications.
An example is the **lib/view** package which provides thread-safe template caching.

The other reason for Blue Jay is the command line tools in **jay**. jay provides an easy way
to find/replace in a project when refactoring, migrate your database forwards or backwards, and
generate a file or sets or files using the Go [html/template](https://golang.org/pkg/html/template/)
package. Code generation can help you build faster and more efficiently which is a perfect compliment
to Blueprint.

## Why Go?

One of the big draws to Go is the rich standard library. The standard library includes a web server,
web-safe templating, and
many other tools necessary to build a web application. Any features missing from the standard library are
written by other Go developers who are happy to contribute to the thriving community.

Go allows you to write code that compiles to the majority of the architectures we use today so all your
code is pretty much portable. Go accels when you want to write command line apps instead of just scripts,
but that's not the language's only niche.
The designers of Go wanted to build a language that solved problems between the Google development teams.
It's a modern language that allows you to easily multi-thread your applications safely so you can use the
power of the hardware.

## High Level

Blueprint is a complete web application with built-in web server.
It requires MySQL so you'll need to set up your own instance of the database.
The application has a public home page, authenticated home page, login page, register page,
about page, and a simple notepad to demonstrate GET, POST, UPDATE, and DELETE operations.

The entrypoint for the web app is **blueprint.go**. The file calls the **bootstrap** package
which loads the application settings, creates the session store, connects to the database,
sets up the view, loads the routes, attaches the middleware, and starts the web server.

The front end is built using Bootstrap with a few small changes to fonts and spacing. The flash 
messages are customized so they show up at the bottom right of the screen.

All of the error and warning messages should display to the 
user or in the console. Informational messages are displayed to the user via 
flash messages that disappear after 4 seconds.

## Quick Start with MySQL

1. To download, run the following command: `go get github.com/blue-ray/blueprint`
1. Start a MySQL instance and import **database/quickstart.sql** to create the database and tables.
1. Make a copy of env.json.example and name it: **env.json**
1. Edit the **Database** section in **config/config.json** so the connection information matches your MySQL instance.
1. Use `go run` from the root of the project directory.
1. Open your web browser to http://localhost and you should see the welcome page.
1. Navigate to the register page at http://localhost/register and create a new user.
1. You can now login at http://localhost/login and try the Notepad app.

## Structure

The project is organized into the following root folders:

```text
bootstrap	- initial set up of the application
controller	- page logic and routes
database	- migration scripts
generate	- templates used with code generation command line tool
lib			- packages accessible throughout the application
model		- database structs representing tables and queries
static		- statically served files like CSS and JSS
template	- HTML templates parsed using the Go html/template package
```

The following files exist at the project root:

```text
blueprint.go 		- entrypoint for the application
env.json.example 	- variables for the application
```

## External Packages

There are a few external packages that must be retrieved using `go get`:

```text
github.com/gorilla/context				- registry for global request variables
github.com/gorilla/sessions				- cookie and filesystem sessions
github.com/go-sql-driver/mysql 			- MySQL driver
github.com/jmoiron/sqlx 				- MySQL general purpose extensions
github.com/josephspurrier/csrfbanana 	- CSRF protection for gorilla sessions
github.com/julienschmidt/httprouter 	- high performance HTTP request router
github.com/justinas/alice				- middleware chaining
golang.org/x/crypto/bcrypt 				- password hashing algorithm
```

## JavaScript

You can trigger a flash notification using JavaScript.

```javascript
flashError("You must type in a username.");

flashSuccess("Record created!");

flashNotice("There seems to be a piece missing.");

flashWarning("Something does not seem right...");
```



## Database

It's a good idea to abstract the database layer out so if you need to make 
changes, you don't have to look through business logic to find the queries. All
the queries are stored in the models folder.

This project supports BoltDB, MongoDB, and MySQL. All the queries are stored in
the same files so you can easily change the database without modifying anything
but the config file.

The user.go and note.go files are at the root of the model directory and are a
compliation of all the queries for each database type. There are a few hacks in
the models to get the structs to work with all the supported databases.

Connect to the database (only once needed in your application):

```go
// Connect to database
database.Connect(config.Database)
```

Read from the database:

```go
result := User{}
err := database.DB.Get(&result, "SELECT id, password, status_id, first_name FROM user WHERE email = ? LIMIT 1", email)
return result, err
```

Write to the database:

```go
_, err := database.DB.Exec("INSERT INTO user (first_name, last_name, email, password) VALUES (?,?,?,?)", firstName, lastName, email, password)
return err
```

## Middleware

There are a few pieces of middleware included. The package called csrfbanana 
protects against Cross-Site Request Forgery attacks and prevents double submits. 
The package httprouterwrapper provides helper functions to make funcs compatible 
with httprouter. The package logrequest will log every request made against the 
website to the console. The package pprofhandler enables pprof so it will work 
with httprouter. In route.go, all the individual routes use alice to make 
chaining very easy.

## Screenshots

Public Home:

![Image of Public Home](https://cloud.githubusercontent.com/assets/2394539/11319464/e2cd0eac-9045-11e5-9b24-5e480240cd69.jpg)

About:

![Image of About](https://cloud.githubusercontent.com/assets/2394539/11319462/e2c4d2d2-9045-11e5-805f-8b40598c92c3.jpg)

Register:

![Image of Register](https://cloud.githubusercontent.com/assets/2394539/11319466/e2d03500-9045-11e5-9c8e-c28fe663ed0f.jpg)

Login:

![Image of Login](https://cloud.githubusercontent.com/assets/2394539/11319463/e2cd1a00-9045-11e5-8b8e-68030d870cbe.jpg)

Authenticated Home:

![Image of Auth Home](https://cloud.githubusercontent.com/assets/2394539/14809208/75f340d2-0b59-11e6-8d2a-cd26ee872281.PNG)

View Notes:

![Image of Notepad View](https://cloud.githubusercontent.com/assets/2394539/14809205/75f08432-0b59-11e6-8737-84ee796bd82e.PNG)

Add Note:

![Image of Notepad Add](https://cloud.githubusercontent.com/assets/2394539/14809207/75f338f8-0b59-11e6-9719-61355957996c.PNG)

Edit Note:

![Image of Notepad Edit](https://cloud.githubusercontent.com/assets/2394539/14809206/75f33970-0b59-11e6-8acf-b3d533477aac.PNG)

## Feedback

All feedback is welcome. Let me know if you have any suggestions, questions, or criticisms. 
If something is not idiomatic to Go, please let me know know so we can make it better.