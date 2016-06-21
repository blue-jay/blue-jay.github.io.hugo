---
date: 2016-03-08T21:07:13+01:00
title: Views
weight: 60
---

## Basic Usage

Views contain the HTML served by your application and separate your controller / application logic from your presentation logic. The views are parsed by the [html/template](https://golang.org/pkg/html/template/) package.

A view should include the four **define** blocks (**title**, **head**, **content**, and **foot**) and may look like this:

```html
{{define "title"}}Welcome{{end}}
{{define "head"}}{{end}}
{{define "content"}}
<div class="container">
	<div class="page-header">
		<h1>Hello, {{.first_name}}</h1>
	</div>
	<p>You have arrived. Click {{LINK "notepad" "here"}} to view your notepad.</p>
	{{template "footer" .}}
</div>
{{end}}
{{define "foot"}}{{end}}
```

Since this view is stored at **view/index/auth.tmpl**, we may render it using the **view** helper package like so:

```go
// import "github.com/blue-jay/blueprint/lib/view"
v := view.New("index/auth")
v.Vars["first_name"] = session.Values["first_name"]
v.Render(w, r)
```

If you don't have to pass any variables to the template, you could shorten it like this:

```go
// import "github.com/blue-jay/blueprint/lib/view"
view.New("index/auth").Render(w, r)
```

## Base Template

By default, the **view/base.tmpl** template is used as the base template (as specified in env.json). If you want to
change the base template for a template, you can try this:

```go
v := view.New("index/auth").Base("alternate")
v.Render(w, r)
```

A shorter way to specify the view with a different base template and then render is like this:

```go
view.New("about/about").Base("alternate").Render(w, r)
```

## View Package

The optional **lib/view** package is a wrapper for the Go [html/template](https://golang.org/pkg/html/template/) package
and provides the following:

* thread-safe template caching
* easy way to extend the list of functions available in templates
* easy way to modify the variables available in templates

The set up of the **view** package is handled by the **bootstrap** package:

```go
// import "github.com/blue-jay/blueprint/lib/view"
// Set up the views
view.SetConfig(config.View)
view.SetTemplates(config.Template.Root, config.Template.Children)

// Set up the functions for the views
view.SetFunctions(
	extend.Assets(config.View),
	extend.Link(config.View),
	extend.NoEscape(),
	extend.PrettyTime(),
)

// Set up the variables for the views
view.SetVariables(
	modify.AuthLevel,
	modify.BaseURI,
	modify.Token,
	flash.Modify,
)
```

## Organization

The HTML templates are organized into folders under the **view** folder:

```text
about/about.tmpl	- quick blurb about the app
auth/login.tmpl		- login page
auth/register.tmpl	- register page
index/anon.tmpl		- public home page
index/auth.tmpl		- home page once you login
note/create.tmpl	- create a note
note/edit.tmpl		- edit a note
note/index.tmpl		- view all notes
note/show.tmpl		- view a note
partial/footer.tmpl	- footer at the bottom of all pages
partial/menu.tmpl	- menu at the top of all pages
base.tmpl			- base template for all pages
```

## Included Functions

There are a few functions that are included to make working with the templates 
and static files easier:

```html
<!-- CSS files with timestamps -->
{{CSS "static/css/normalize3.0.0.min.css"}}
parses to
<link rel="stylesheet" type="text/css" href="/static/css/normalize3.0.0.min.css?1435528339" />

<!-- JS files with timestamps -->
{{JS "static/js/jquery1.11.0.min.js"}}
parses to
<script type="text/javascript" src="/static/js/jquery1.11.0.min.js?1435528404"></script>

<!-- Hyperlinks -->
{{LINK "register" "Create a new account."}}
parses to
<a href="/register">Create a new account.</a>

<!-- Output an unescaped variable (not a safe idea, but it is useful when troubleshooting) -->
{{.SomeVariable | NOESCAPE}}

<!-- Time format -->
{{.SomeTime | PRETTYTIME}}
parses to format
3:04 PM 01/02/2006
```

## Included Variables

There are a few variables you can use in templates as well:

```html
<!-- Use AuthLevel=auth to determine if a user is logged in (if session.Values["id"] != nil) -->
{{if eq .AuthLevel "auth"}}
You are logged in.
{{else}}
You are not logged in.
{{end}}

<!-- Use BaseURI to print the base URL specified in the env.json file -->
<li><a href="{{.BaseURI}}about">About</a></li>

<!-- Use token to output the CSRF token in a form -->
<input type="hidden" name="token" value="{{.token}}">
```

## Header and Footer

It's also easy to add template-specific code before the closing </head> and </body> tags:

```html
<!-- Code is added before the closing </head> tag -->
{{define "head"}}<meta name="robots" content="noindex">{{end}}

...

<!-- Code is added before the closing </body> tag -->
{{define "foot"}}{{JS "//www.google.com/recaptcha/api.js"}}{{end}}
```

## JavaScript

There are a few built-in functions that you can use to trigger a flash notification using JavaScript.

```javascript
flashError("An error occurred on the server.");

flashSuccess("Item added!");

flashNotice("Item deleted.");

flashWarning("Field missing: email");
```