---
title: Toolkit Overview
type: index
weight: 0
---

Blue Jay is a web toolkit for [Go](https://golang.org/). It's a collection of command-line tools and a web blueprint that allows you to easily structure your web application. There is no rigid framework to which you have to conform and Blueprint is very easy to start using.

There are a few components:

- [**Blueprint**](https://github.com/blue-jay/blueprint) is a model-view-controller (MVC) style web skeleton.
- [**Jay**](https://github.com/blue-jay/jay) is a command line tool with find/replace, database migrations, and code generation.

## High Level

Blueprint is a complete web application with a built-in web server.
It supports MySQL so you'll need to set up your own instance of the database.
The application has a public home page, authenticated home page, login page, register page,
about page, and a simple notepad to demonstrate GET, POST, UPDATE, and DELETE operations.

The entrypoint for the web app is **blueprint.go**. The file uses the **bootstrap** package
to load the application settings, create the session store, connect to the database,
set up the view, load the routes, attach the middleware, and then start the web server.

The front end is built using Bootstrap with a few small changes to fonts and spacing. The flash 
messages are customized so they show up at the bottom right of the screen. All of the error and
warning messages should display to the 
user or in the console. Informational messages are displayed to the user via 
flash messages that disappear after 4 seconds.

Blueprint also works well with [npm](https://www.npmjs.com/) and
[Gulp](http://gulpjs.com/). A Gulp script is
included that automates the compiling of SASS, concatenation of JavaScript,
generation of favicons, and copying of static assets like Bootstrap and jQuery
managed by npm to the **asset/static** folder. They are great tools that speed up
web development.

Jay is a command-line tool that plays nice with Blueprint. It has a find/replace
functionality so code refactoring is a little easier. It performs database
migration to help with moving your database between states when sharing code
between teams. Jay provides template-based code generation that allows you to
build controllers, models and middleware, as well as multiple views and any
other file you would like to build. All templates (*.gen files) are parsed using
the **text/template** package from the Go standard library and all generation
instructions (*.json files) allow you to specify which variables to pass via
**jay** as well as in which folder to create the templates. You can also build
collections of templates and generate more than one file set which is great when
you want to scaffold out a component using (create, read, update, and delete)
CRUD.

## Quick Start Website with Jay

1. To download Blueprint, run the following command: `go get github.com/blue-ray/blueprint`
1. To download Jay, run the following command: `go get github.com/blue-ray/jay`
1. Open your terminal and CD to the **blueprint** folder.
1. Run this command to create the env.json file from env.json.example: `jay env make`
1. Set the environment variable, JAYCONFIG, to the env.json file path. For example:
  * On Windows: `SET JAYCONFIG=C:\bluejay\workspace\src\github.com\blue-jay\blueprint\env.json`
  * On Linux/OS X: `export JAYCONFIG=$HOME/workspace/src/github.com/blue-jay/blueprint/env.json`
1. Start a MySQL instance.
1. Edit the **Database** section of env.json to match your database login information.
1. Create the database and tables using the command: `jay migrate all`
1. Run the application using the command: `go run blueprint.go`
1. Open your web browser to http://localhost and you should see the welcome page.
1. Navigate to the register page at http://localhost/register and create a new user.
1. You can now login at http://localhost/login.

## Quick Start Website without Jay

1. To download Blueprint, run the following command: `go get github.com/blue-ray/blueprint`
1. Start a MySQL instance.
1. Make a copy of env.json.example and name it: **env.json**
1. Edit the **Database** section in **env.json** so the connection information matches your MySQL instance.
1. Create a database called **blueprint**.
1. Import **database/migration/20160630_020000_a.up.sql** to create the tables.
1. Open your terminal and CD to the **blueprint** folder.
1. Run the application using the command: `go run blueprint.go`
1. Open your web browser to http://localhost and you should see the welcome page.
1. Navigate to the register page at http://localhost/register and create a new user.
1. You can now login at http://localhost/login.

## Why Blue Jay?

After 300 stars on GitHub, I realized people really liked the boilerplate 
Model-View-Controller (MVC) web application in Go called
[gowebapp](https://github.com/josephspurrier/gowebapp) so I rewrote it with
better documentation.

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
but that's not the only niche.
The designers of Go wanted to build a language that solved problems between the Google development teams.
It's a modern language that allows you to easily multi-thread your applications. It's a "get stuff done"
language.

## Screenshots

### Public Home

![Image of Public Home](/images/home_anon.png)

### About

![Image of About](/images/about.png)

### Register

![Image of Register](/images/register.png)

### Login

![Image of Login](/images/login.png)

### Authenticated Home

![Image of Auth Home](/images/home_auth.png)

### View All Notes

![Image of Notepad View](/images/notepad_index.png)

### Add Note

![Image of Notepad Add](/images/notepad_create.png)

### View One Note

![Image of Notepad Edit](/images/notepad_view.png)

### Edit Note

![Image of Notepad Edit](/images/notepad_edit.png)

## Feedback

All feedback is welcome. Let me know if you have any suggestions, questions, or criticisms. 
If something is not idiomatic to Go, please let me know know so we can make it better.