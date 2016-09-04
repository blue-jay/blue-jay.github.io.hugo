---
title: Code Generation
weight: 90
---

## Basic Usage

Code generation makes it easy to build out new features so you don't have to
retype or copy and paste the same code over again. It's especially useful when
prototyping and need to see how something will look or work.

**Note**: The `jay generate` commands requires the environment variable,
**JAYCONFIG**, to point to the env.json file path. The generation folder
containing the templates is specified in the env.json file under
**Generation.TemplateFolder**.

**Jay** tries to make it easy to generate code by using tools that you already
know: the **text/template** package from the standard Go library and JSON.

A template pair consists of a .json file and a .gen file. The .gen file contains
the **text/template** parsable code. The .json file contains other information
needed for the generation process like:

* config.type - either 'single' if creating one file or 'collection' if referencing one or more other .json files
* config.output - relative path at which to create the file
* config.parse - either true or false

In the .json file, any other keys outside these three will be applied directly
to the .gen file. If you leave a key blank, that tells `jay generate` that it
needs to be passed via command-line.

Don't worry, there are already a boatload of templates ready to use. They are
organized by type in the **generate** folder of Blueprint. If .json file does
not have a .gen pair in the same folder, then it has a **config.parse** value
of **collection** which means it references other .json files with a
**config.parse** value of **single**.

The **flight** package is a helper package that reduces a lot of code from the
controller. It contains functions to simplify the use of flash messages,
form validation, form repopulation, and URL parameters.

- controller
  - bare.gen | bare.json - creates a bare controller with only placeholder functions
  - default.gen | default.json - creates a controller with CRUD ready code with the **flight** package
  - noflight.gen | noflight.json - creates a controller with CRUD ready code without the **flight** package
- crud
  - bare.json - creates a bare controller, model, and four views
  - default.json - creates a controller, model, and four views CRUD ready with the **flight** package
  - noflight.json - creates a controller, model, and four views CRUD ready without the **flight** package
- lib
  - default.gen | default.json - creates a thread-safe wrapper package
- middleware
  - default.gen | default.json - creates a middleware package
- model
  - bare.gen | bare.json - creates a bare model with only placeholder functions
  - default.gen | default.json - creates a model with CRUD ready code
- view
  - bare.json - creates four bare views with only a basic structure
  - create.gen | create.json - creates a CRUD ready creation form view
  - create_bare.gen | create_bare.json - creates a bare view with only a basic structure
  - default.json - creates four views with CRUD ready code
  - edit.gen | edit.json - creates a CRUD ready edit form view
  - edit_bare.gen | edit_bare.json - creates a bare view with only a basic structure
  - index.gen | index.json - creates a CRUD ready display view
  - index_bare.gen | index_bare.json - creates a bare view with only a basic structure
  - show.gen | show.json - creates a CRUD ready display view
  - show_bare.gen | show_bare.json - creates a bare view with only a basic structure
  - single.gen | single.json - creates a bare view with only a basic structure
- viewfunc
  - default.gen | default.json - creates a FuncMap package for use with the **html/template** package
- viewmodify
  - default.gen | default.json - creates a package to modify the **lib/view** package before rendering

Let's view a couple examples.

## Middleware Example

The **generate/middleware/default.gen** file contains this template. The
{{.package}} variable is the only required variable for this template so it must
be added to the .json file as a key with blank value. This forces `jay generate`
to require the user to pass a **package** variable before it will generate the
template.

```go
// Package {{.package}}
package {{.package}}

import (
	"net/http"
)

// Handler
func Handler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Logic BEFORE the other handlers and function goes here
		next.ServeHTTP(w, r)
		// Logic AFTER the other handlers and function goes here
	})
}
```

The **generate/middleware/default.json** file contains this JSON. The
**config.type** is set to **single** because it's only generating one file. The
**config.output** is the relative path where the file will be generated. Notice
that the **config.output** also uses the **package** variable. This is the
beauty of the `jay generate` tool: the .json files are actually parsed
multiple times (limit is set to 100) to ensure all variables are set.

In the first iteration of parsing, the **package** key is set to value passed
via the command-line. In the second iteration of parsing, the **{{.package}}**
variables are set to the same value because the top level **package** key
becomes a variable itself.

All first level keys (config.type, config.output, package) become variables
after the first iteration of parsing. If a variable is misspelled and is never
filled, a helpful error will display to the command-line.

The folder structure of the templates (model, controller, etc) has no effect
on the generation, it's purely to aid with organization of the template pairs.

```json
{
	"config.type": "single",
	"config.output": "middleware/{{.package}}/{{.package}}.go",
	"package": ""
}
```

To generate this template, the command would look like this. The **package**
key is separated from the value by a colon (:). An argument of `package:`
without a value is also acceptable, but would end up creating a file called
**.go** in the **middleware** folder.

```bash
jay generate middleware/default package:test
```

The final output would be to the file, **middleware/test/test.go**, and would
look like this:

```go
// Package test
package test

import (
	"net/http"
)

// Handler
func Handler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Logic BEFORE the other handlers and function goes here
		next.ServeHTTP(w, r)
		// Logic AFTER the other handlers and function goes here
	})
}
```

## Controller Example

This is a snippet of the template in **generate/controller/bare.gen**. In this
template, there are two variables: **package** and **url**.

```go
// Package {{.package}}
package {{.package}}

import (
	"net/http"

	"github.com/blue-jay/blueprint/controller/status"

	"github.com/blue-jay/core/router"
)

var (
	uri = "/{{.url}}"
)

// Load the routes.
func Load() {
	c := router.Chain()
	router.Get(uri, Index, c...)
	router.Get(uri+"/create", Create, c...)
	router.Post(uri+"/create", Store, c...)
	router.Get(uri+"/view/:id", Show, c...)
	router.Get(uri+"/edit/:id", Edit, c...)
	router.Patch(uri+"/edit/:id", Update, c...)
	router.Delete(uri+"/:id", Destroy, c...)
}

// Index displays the items.
func Index(w http.ResponseWriter, r *http.Request) {
	status.Error501(w, r)
}

// Create displays the create form.
func Create(w http.ResponseWriter, r *http.Request) {
	status.Error501(w, r)
}

...
```

The **generate/controller/bare.json** file contains this JSON.

```json
{
	"config.type": "single",
	"config.output": "controller/{{.package}}/{{.package}}.go",
	"package": "",
	"url": ""
}
```

To generate this template, the command would look like this. Notice the second
variable, **url**.

```bash
jay generate controller/bare package:monkey url:banana
```

The final output would be to the file, **controller/monkey/monkey.go**, and
would look like this:

```go
// Package monkey
package monkey

import (
	"net/http"

	"github.com/blue-jay/blueprint/controller/status"

	"github.com/blue-jay/core/router"
)

var (
	uri = "/banana"
)

// Load the routes.
func Load() {
	c := router.Chain()
	router.Get(uri, Index, c...)
	router.Get(uri+"/create", Create, c...)
	router.Post(uri+"/create", Store, c...)
	router.Get(uri+"/view/:id", Show, c...)
	router.Get(uri+"/edit/:id", Edit, c...)
	router.Patch(uri+"/edit/:id", Update, c...)
	router.Delete(uri+"/:id", Destroy, c...)
}

// Index displays the items.
func Index(w http.ResponseWriter, r *http.Request) {
	status.Error501(w, r)
}

// Create displays the create form.
func Create(w http.ResponseWriter, r *http.Request) {
	status.Error501(w, r)
}

...
```

## Single View Example

The **generate/view/single.gen** file contains this template. We don't actually
want to parse this code because it's a view itself. We can tell the parser
not to parse in the single.json file by setting the value of **config.parse** to
**false**.

```html
{{define "title"}}{{end}}
{{define "head"}}{{end}}
{{define "content"}}
<div class="container">
	<div class="page-header">
		<h1>{{template "title" .}}</h1>
	</div>
	
	<p>Not Implemented</p>
	
	{{template "footer" .}}
</div>
{{end}}
{{define "foot"}}{{end}}
```

The **generate/view/single.json** file contains this JSON. Again, we set
**config.parse** to false and only use the variables for specifying the
**config.output** path. The variables are not used inside the single.json
template at all.

```json
{
	"config.type": "single",
	"config.output": "view/{{.model}}/{{.name}}.tmpl",
	"config.parse": false,
	"model": "",
	"name": ""
}
```

To generate this template, the command would look like this. Notice the second
variable, **url**.

```bash
jay generate view/single model:test name:create
```

The final output would be to the file, **view/test/create.tmpl**, and
would look like this - no difference from the template itself since it was not
parsed, just copied.

```html
{{define "title"}}{{end}}
{{define "head"}}{{end}}
{{define "content"}}
<div class="container">
	<div class="page-header">
		<h1>{{template "title" .}}</h1>
	</div>
	
	<p>Not Implemented</p>
	
	{{template "footer" .}}
</div>
{{end}}
{{define "foot"}}{{end}}
```

# Multiple View Example

The **generate/view/default.json** file contains this JSON, but does not have
a matching default.gen file. This is because the .json file simply passes
variables to other .json files which have matching .gen files that generate
files. First, the **config.type** key has a value of **collection**, that's how
you know it doesn't have a matching .gen file. Next, the **config.collection**
key contains an array of items that specify which template pairs to pass
variables to.

The **model** key under each template receives the **model** variable from the
root of the package which is required from the command-line.

```json
{
	"config.type": "collection",
	"config.collection": [
		{
			"view/create": {
				"model": "{{.model}}"
			}
		},
		{
			"view/edit": {
				"model": "{{.model}}"
			}
		},
		{
			"view/index": {
				"model": "{{.model}}"
			}
		},
		{
			"view/show": {
				"model": "{{.model}}"
			}
		}
	],
	"model": ""
}
```

In this example, the default.json file will pass variables to the following
files:

- generate/view/create.json
- generate/view/edit.json
- generate/view/index.json
- generate/view/show.json

The files are all still relative to the root **generate** folder. Also, if you
look at each of the four files, you'll see that they require only one variable:
**model**. Here is the contents of **generate/view/create.json**:

```json
{
	"config.type": "single",
	"config.output": "view/{{.model}}/create.tmpl",
	"config.parse": false,
	"model": ""
}
```

To generate all four of these templates, the command would look like this.

```bash
jay generate view/default model:test
```

The final output would be to the following files:

- view/test/create.json
- view/test/edit.json
- view/test/index.json
- view/test/show.json

## CRUD Example

If you put all those piece above together, you can generate the controller,
model, and all four views necessary for a working CRUD component in a single
command.

The **generate/crud/default.json** file contains this JSON:

```json
{
	"config.type": "collection",
	"config.collection": [
		{
			"model/default": {
				"package": "{{.model}}",
				"table": "{{.model}}"
			}
		},
		{
			"controller/default": {
				"package": "{{.controller}}",
				"url": "{{.controller}}",
				"model": "{{.model}}",
				"view": "{{.view}}"
			}
		},
		{
			"view/default": {
				"model": "{{.view}}"
			}
		}
	],
	"model": "",
	"controller": "",
	"view": ""
}
```

To generate all the components, the command would look like this.

```bash
jay generate crud/default model:note controller:notepad view:note
```