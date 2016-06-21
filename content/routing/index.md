---
date: 2016-03-08T21:07:13+01:00
title: Routing
weight: 20
---

## Basic Usage

When a user requests a page from your application, the routes determine which
page is shown. The URL is mapped to a controller function. For that reason,
the routes are stored in the controller file. The controller files are all
organized under the **controller** folder.

## Routing

In the **bootstrap** package, the **RegisterServices()** function
calls the **controller.LoadRoutes()** function.

The **LoadRoutes()** function in the **controller** package loads the routes
for each of the individual controllers:

```go
// LoadRoutes loads the routes for each of the controllers
func LoadRoutes() {
	about.Load()
	debug.Load()
	auth.LoadRegister()
	auth.LoadLogin()
	core.LoadIndex()
	core.LoadError()
	core.LoadStatic()
	notepad.Load()
}
```

Here is the **Load()** function from the **controller/notepad** package:

```go
func Load() {
	// Add middleware that disallows anonymous access
	c := router.Chain(acl.DisallowAnon)

	// Map HTTP methods and URLs to functions wrapped in the middleware chain
	router.Get("/notepad", Index, c...)
	router.Get("/notepad/create", Create, c...)
	router.Post("/notepad", Store, c...)
	router.Get("/notepad/view/:id", Show, c...)
	router.Get("/notepad/edit/:id", Edit, c...)
	router.Patch("/notepad/edit/:id", Update, c...)
	router.Delete("/notepad/:id", Destroy, c...)
}
```

There are a few things to note here. The **router** references the
**lib/router** package which is a wrapper for the
[julienschmidt/httprouter](http://github.com/julienschmidt/httprouter) package.
The **router.Chain()** function uses the
[justinas/alice](http://github.com/justinas/alice) package
to help with middleware chaining.

This is one way to build your wrapper packages that live in the **lib** folder.
If you want to use a different router, you can modify the **lib/router**
package easily and will only have to change a few lines of code in your
controllers.

## Static Assets

You can serve your **static** folder with your CSS, JavaScript, and images so
they are accessible. You would access an asset like this:
`http://example.com/static/favicon.ico`

[Source](https://github.com/blue-jay/blueprint/blob/master/controller/core/static.go)
```go
package core

import (
	"net/http"
	"strings"

	"github.com/blue-jay/blueprint/lib/router"
)

func LoadStatic() {
	// Required so the trailing slash is not redirected
	router.Instance().RedirectTrailingSlash = false

	// Serve static files, no directory browsing
	router.Get("/static/*filepath", Static)
}

// Static maps static files
func Static(w http.ResponseWriter, r *http.Request) {
	// Disable listing directories
	if strings.HasSuffix(r.URL.Path, "/") {
		Error404(w, r)
		return
	}
	http.ServeFile(w, r, r.URL.Path[1:])
}
```

## Error Pages

You can specify the **404** (Page Not Found) and **405** (Method Not Allowed)
behaviors.

[Source](https://github.com/blue-jay/blueprint/blob/master/controller/core/error.go)
```go
package core

import (
	"fmt"
	"net/http"

	"github.com/blue-jay/blueprint/lib/router"
)

func LoadError() {
	router.MethodNotAllowed(Error405)
	router.NotFound(Error404)
}

// Error404 - Page Not Found
func Error404(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusNotFound)
	fmt.Fprint(w, "Not Found 404")
}

// Error405 - Method Not Allowed
func Error405(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusMethodNotAllowed)
	fmt.Fprint(w, "Method Not Allowed 405")
}
```