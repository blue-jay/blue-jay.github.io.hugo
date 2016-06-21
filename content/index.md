---
date: 2016-03-08T21:07:13+01:00
title: Toolkit Overview
type: index
weight: 0
---

[![Go Report Card](https://goreportcard.com/badge/github.com/blue-jay/blueprint)](https://goreportcard.com/report/github.com/blue-jay/blueprint)
[![GoDoc](https://godoc.org/github.com/blue-jay/blueprint?status.svg)](https://godoc.org/github.com/blue-jay/blueprint)

Blue Jay is a web toolkit for [Go](https://golang.org/). It's a collection of command-line tools and a web blueprint that allows you to easily structure your web application. There is no rigid framework to which you have to conform.

There are a few components:

- [**Blueprint**](https://github.com/blue-jay/blueprint) is a model-view-controller (MVC) style web skeleton.

- [**Jay**](https://github.com/blue-jay/jay) is a command line tool with modules for find/replace, database migrations, and code generation.

## Why Blue Jay?

### Fun Answer
After 300 stars on GitHub, I realized people really liked the boilerplate 
Model-View-Controller (MVC) web application in Go called
[gowebapp](https://github.com/josephspurrier/gowebapp) so I gave it a better
name and improved the documentation.

### Real Answer
Go is a blast to code in and it's great being part of a helpful community.
Blue Jay provides a quickstart for developers with a lean web skeleton called
**Blueprint** that demonstrates how to structure a web application with sample
code.

One of the things you'll notice while using Blueprint is how to abstract out
external packages to make it easy to swap out components. Ultimately, you should
be able to write code once and use it in all of your other projects. The **lib**
folder is a great place for all these packages with very few dependencies.

You'll also notice certain packages need to be thread-safe when building web applications.
An example is the **lib/view** package which provides thread-safe template caching.

The other reason for Blue Jay is the command-line tool, **jay**, which provides an easy way
to find/replace in a project when refactoring, migrate your database forwards or backwards, and
generate a file or sets or files using the Go [html/template](https://golang.org/pkg/html/template/)
package. Code generation can help you build faster and more efficiently with less mistakes.

## Why Go?

One of the big draws to Go is the rich standard library. The standard library includes a web server,
web-safe templating, and
many other tools necessary to build a web application. Any features missing from the standard library are
written by other Go developers who are happy to contribute to the thriving community.

Go allows you to write code that compiles to the majority of the architectures we use today so all your
code is pretty much portable. Go excels when you want to write command line apps instead of just scripts,
but that's not the language's only niche.
The designers of Go wanted to build a language that solved problems between the Google development teams.
It's a modern language that allows you to easily multi-thread your applications.

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