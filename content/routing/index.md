---
title: Routing
weight: 20
---

## Basic Usage

When a user requests a page from your application, the routes determine which
page is shown. The route is a URL that is mapped to a controller function.
To simplify the organization, the routes are stored in the controller files.
The controller files are all organized under the **controller** folder.

## Routing

In the **bootstrap** package, the **RegisterServices()** function
calls the **controller.LoadRoutes()** function. The **LoadRoutes()** function in
 the **controller** package loads the routes for each of the individual
 controllers:

```go
// LoadRoutes loads the routes for each of the controllers.
func LoadRoutes() {
	about.Load()
	debug.Load()
	register.Load()
	login.Load()
	home.Load()
	static.Load()
	status.Load()
	notepad.Load()
}
```

Here is the **Load()** function from the **controller/notepad** package:

```go
func Load() {
	// Add middleware that disallows anonymous access
	c := router.Chain(acl.DisallowAnon)

	// Map HTTP methods and URLs to functions with the middleware chain
	router.Get("/notepad", Index, c...)
	router.Get("/notepad/create", Create, c...)
	router.Post("/notepad/create", Store, c...)
	router.Get("/notepad/view/:id", Show, c...)
	router.Get("/notepad/edit/:id", Edit, c...)
	router.Patch("/notepad/edit/:id", Update, c...)
	router.Delete("/notepad/:id", Destroy, c...)
}
```

There are a few things to note here. The **router** references the
**lib/router** package which is a thread-safe wrapper for the
[julienschmidt/httprouter](http://github.com/julienschmidt/httprouter) package.
The **router.Chain()** function uses the
[justinas/alice](http://github.com/justinas/alice) package
to help with middleware chaining.

This is one way to build your wrapper packages that live in the **lib** folder.
If you want to use a different router, you can modify the **lib/router**
package easily and will only have to change a few lines of code in your
controllers.

## Static Assets

You can serve the **asset/static** folder with your CSS, JavaScript, and images so
they are accessible. You would access an asset like this:
`http://example.com/static/favicon.ico`

[Source](https://github.com/blue-jay/blueprint/blob/master/controller/static/static.go)
```go
// Package static serves static files like CSS, JavaScript, and images.
package static

import (
	"net/http"
	"os"
	"path"

	"github.com/blue-jay/blueprint/controller/status"
	"github.com/blue-jay/blueprint/lib/asset"
	"github.com/blue-jay/blueprint/lib/router"
)

// Load the routes.
func Load() {
	// Serve static files
	router.Get("/static/*filepath", Index)
}

// Index maps static files.
func Index(w http.ResponseWriter, r *http.Request) {
	// File path
	path := path.Join(asset.Config().Folder, r.URL.Path[1:])

	// Only serve files
	if fi, err := os.Stat(path); err == nil && !fi.IsDir() {
		http.ServeFile(w, r, path)
		return
	}

	status.Error404(w, r)
}
```

## Error Pages

A few errors pages are already defined for you like the **404** (Page Not Found)
and **405** (Method Not Allowed) pages.

[Source](https://github.com/blue-jay/blueprint/blob/master/controller/status/status.go)
```go
// Package status provides all the error pages like 404, 405, 500, 501,
// and the page when a CSRF token is invalid.
package status

import (
	"net/http"

	"github.com/blue-jay/blueprint/lib/router"
	"github.com/blue-jay/blueprint/lib/view"
)

// Load the routes.
func Load() {
	router.MethodNotAllowed(Error405)
	router.NotFound(Error404)
}

// Error404 - Page Not Found.
func Error404(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusNotFound)
	v := view.New("status/index")
	v.Vars["title"] = "404 Not Found"
	v.Vars["message"] = "Page could not be found."
	v.Render(w, r)
}

// Error405 - Method Not Allowed.
func Error405(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusMethodNotAllowed)
	v := view.New("status/index")
	v.Vars["title"] = "405 Method Not Allowed"
	v.Vars["message"] = "Method is not allowed."
	v.Render(w, r)
}
```