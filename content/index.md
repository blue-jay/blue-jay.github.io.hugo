---
title: Blue Jay Overview
type: index
weight: 0
---

Blue Jay is a web toolkit for [Go](https://golang.org/). It's a collection of command-line tools and a web blueprint that allows you to easily structure your web application. There is no rigid framework to which you have to conform and the tools are easy to start using.

There are a few components:

- [**Blueprint**](https://github.com/blue-jay/blueprint) is a model-view-controller (MVC) style web skeleton.
- [**Jay**](https://github.com/blue-jay/jay) is a command line tool with find/replace, database migrations, and code generation.
- [**Core**](https://github.com/blue-jay/core) is a collection of packages used
by Blueprint and Jay that can also be used by other projects.

## High Level

Blueprint is a web application with a built-in web server and MySQL integration.
The application has a public home page, authenticated home page, login page,
register page, about page, and a simple notepad to demonstrate GET, POST,
PATCH, and DELETE operations.

The entrypoint for the web app is **blueprint.go** which uses the **boot**
package to load the application settings, create the session store,
connect to the database, set up the views, load the routes, attach the
middleware, and then start the web server.

The front end is built using [Bootstrap](http://getbootstrap.com/) with a few
small changes to fonts and
spacing. The flash messages are customized so they show up at the bottom right
corner of the screen. All of the error and warning messages should display to
the user or in the console. Informational messages are displayed to the user
via flash messages that disappear after 4 seconds.

Blueprint also works well with [npm](https://www.npmjs.com/) and
[Gulp](http://gulpjs.com/). A Gulp script is
included that automates the compiling of SASS, concatenation of JavaScript,
generation of favicons, and copying of static assets like Bootstrap and jQuery
(which are managed by npm) to the **asset/static** folder.

Jay is a command-line tool that pairs nicely with Blueprint. It has find/replace
functionality to make code refactoring is a little easier. It performs database
migration to easily update your database when sharing code
between teams. Jay provides template-based code generation that allows you to
build files like controllers, models, middleware, or even multiple views.
All templates (*.gen files) are parsed using
the **text/template** package from the Go standard library and all generation
instructions (*.json files) allow you to specify which variables to pass via
**Jay** as well as in which folder to create the templates. You can also build
collections of templates to generate more than one file set which is great when
you want to scaffold out a component with CRUD (create, read, update, and delete).

## Quick Start Website with Jay

1. To download Blueprint, run the following command: `go get github.com/blue-jay/blueprint`
1. To download Jay, run the following command: `go get github.com/blue-jay/jay`
1. In your terminal, CD to the **blueprint** folder.
1. Run this command to create the env.json file from env.json.example: `jay env make`
1. Set the environment variable, JAYCONFIG, to the env.json file path. For example:
  * On Windows: `SET JAYCONFIG=C:\bluejay\workspace\src\github.com\blue-jay\blueprint\env.json`
  * On Linux/OS X: `export JAYCONFIG=$HOME/workspace/src/github.com/blue-jay/blueprint/env.json`
1. Start a MySQL instance.
1. Edit the **MySQL** section of env.json to match your database login information.
1. Create the database and tables using the command: `jay migrate:mysql all`
1. Run the application: `go run blueprint.go`
1. Open your web browser to http://localhost and you should see the welcome page.
1. Navigate to the register page at http://localhost/register and create a new user.
1. You can now login at http://localhost/login.

### OS Specific Instructions

There are also more detailed guides available by operating system:

- [Setup for Amazon AMI](https://github.com/blue-jay/blueprint/wiki/Blueprint-Setup-for-Amazon-AMI)
- [Setup for Ubuntu AMI](https://github.com/blue-jay/blueprint/wiki/Blueprint-Setup-for-Ubuntu-AMI)
- [Setup for OS X](https://github.com/blue-jay/blueprint/wiki/Blueprint-Setup-for-OS-X)
- [Setup for Windows](https://github.com/blue-jay/blueprint/wiki/Blueprint-Setup-for-Windows)

## Quick Start Website without Jay

1. To download Blueprint, run the following command: `go get github.com/blue-jay/blueprint`
1. Start a MySQL instance.
1. Make a copy of env.json.example and name it: **env.json**
1. Edit the **MySQL** section in **env.json** so the connection information matches your MySQL instance.
1. In the **Session** section, you should generate new passwords for the following keys:
  * AuthKey should be a 64 byte password and then base64 encoded
  * EncryptKey should be a 32 byte password and then base64 encoded
  * CSRFKey should be a 32 byte password and then base64 encoded
1. Create a database called **blueprint** in MySQL.
1. Import **migration/mysql/20160630_020000.000000_init.up.sql** to create the tables.
1. In your terminal, CD to the **blueprint** folder.
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
An example is the **github.com/core/view** package which provides thread-safe template caching.

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
