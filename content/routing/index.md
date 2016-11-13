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

In the **boot** package, the **RegisterServices()** function
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

[Source](https://github.com/blue-jay/blueprint/blob/master/controller/static/static.go)
```go
// Package static serves static files like CSS, JavaScript, and images.
package static

import (
	"net/http"
	"os"
	"path"

	"github.com/blue-jay/blueprint/controller/status"
	"github.com/blue-jay/blueprint/lib/flight"

	"github.com/blue-jay/core/router"
)

// Load the routes.
func Load() {
	// Serve static files
	router.Get("/static/*filepath", Index)
}

// Index maps static files.
func Index(w http.ResponseWriter, r *http.Request) {
	c := flight.Context(w, r)

	// File path
	path := path.Join(c.Config.Asset.Folder, r.URL.Path[1:])

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

	"github.com/blue-jay/blueprint/lib/flight"
	"github.com/blue-jay/core/router"
)

// Load the routes.
func Load() {
	router.MethodNotAllowed(Error405)
	router.NotFound(Error404)
}

// Error404 - Page Not Found.
func Error404(w http.ResponseWriter, r *http.Request) {
	c := flight.Context(w, r)
	w.WriteHeader(http.StatusNotFound)
	v := c.View.New("status/index")
	v.Vars["title"] = "404 Not Found"
	v.Vars["message"] = "Page could not be found."
	v.Render(w, r)
}

// Error405 - Method Not Allowed.
func Error405(allowedMethods string) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		c := flight.Context(w, r)
		w.WriteHeader(http.StatusMethodNotAllowed)
		v := c.View.New("status/index")
		v.Vars["title"] = "405 Method Not Allowed"
		v.Vars["message"] = "Method is not allowed."
		v.Render(w, r)
	}
}
...
```
