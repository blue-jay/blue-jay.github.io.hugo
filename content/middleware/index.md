---
title: Middleware
weight: 30
---

## Basic Usage

Middleware, in the context of Go, is applied during routing to provide
features like request/response logging, access controls lists (ACLs), and
header modification. Middleware is either applied to every request (like for
request logging) or specified routes (like for ACLs).

There are a few pieces of middleware included. The package called **csrf**
protects against Cross-Site Request Forgery attacks.
The **logrequest** package will log every request made against the
website to the console. The **rest** package allows the HTTP method to be
changed during a form submission to DELETE or PATCH instead of POST.

## Creating Middleware

An example of a piece of middleware that is applied to every request is
**middleware/logrequest**. When a page is requested, the middleware will
print to the console: the time of the request, remote IP address, HTTP method,
and the URL requested.

[Source](https://github.com/blue-jay/blueprint/blob/master/middleware/logrequest/logrequest.go)
```go
// Package logrequest provides an http.Handler that logs when a request is
// made to the application and lists the remote address, the HTTP method,
// and the URL.
package logrequest

import (
	"fmt"
	"net/http"
	"time"
)

// Handler will log the HTTP requests.
func Handler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Println(time.Now().Format("2006-01-02 03:04:05 PM"), r.RemoteAddr, r.Method, r.URL)
		next.ServeHTTP(w, r)
	})
}
```

This is an example of the minimum code required for middleware:

```go
// Handler
func Handler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Logic BEFORE the other handlers and function goes here
		next.ServeHTTP(w, r)
		// Logic AFTER the other handlers and function goes here
	})
}
```

## Chaining

The more middleware you use, the more it stacks up like this and makes it hard
to read:

```go
return context.ClearHandler(rest.Handler(logrequest.Handler(setUpCSRF)))
```

Before [justinas/alice](https://github.com/justinas/alice), a workaround was to
use a variable and reassign it multiple times like this:

```go
h = setUpCSRF(h)
h = logrequest.Handler(h)
h = rest.Handler(h)
return context.ClearHandler(h)
```

You can see chaining in action in [controller/notepad](https://github.com/blue-jay/blueprint/blob/master/controller/notepad/notepad.go)
where the controller uses the **router.ChainHandler()** function.
The function is a wrapper for
the [justinas/alice](https://github.com/justinas/alice) package which makes
using middleware more scalable and a little "prettier". If you look at the
[lib/boot](https://github.com/blue-jay/blueprint/blob/master/lib/boot/middleware.go)
package, you'll see the **ChainHandler()** function. There is also a **Chain()**
function that can be used to chain middleware for routes or to pass to
**ChainHandler()**.

```go
// Apply middleware to routes individually
router.Get("/notepad", Index, acl.DisallowAnon, logrequest.Handler)
router.Get("/notepad/create", Create, acl.DisallowAnon, logrequest.Handler)

// Use Chain() to apply middleware
c := router.Chain(acl.DisallowAnon, logrequest.Handler)
router.Get("/notepad", Index, c...)
router.Get("/notepad/create", Create, c...)

// Pass Chain() to ChainHandler()
c := router.Chain( // Chain middleware, bottom runs first
	h,                    // Handler to wrap
	setUpCSRF,            // Prevent CSRF
	rest.Handler,         // Support changing HTTP method sent via query string
	logrequest.Handler,   // Log every request
	context.ClearHandler, // Prevent memory leak with gorilla.sessions
)
return router.ChainHandler(c...)
```

**ChainHandler()** accepts one or more of the http.Handler type and returns a
http.Handler.

**Chain()** accepts one or more of the http.Handler type and returns an array of
the alice.Constructor type.

## Apply to Every Request

In [blueprint.go](https://github.com/blue-jay/blueprint/blob/master/blueprint.go),
the application calls **boot.SetUpMiddleware(router.Instance())** which
applies the middleware to the router. The middleware is called on every
request.

[Source](https://github.com/blue-jay/blueprint/blob/master/lib/boot/middleware.go)
```go
// SetUpMiddleware contains the middleware that applies to every request.
func SetUpMiddleware(h http.Handler) http.Handler {
	return router.ChainHandler( // Chain middleware, top middlware runs first
		h,                    // Handler to wrap
		setUpCSRF,            // Prevent CSRF
		rest.Handler,         // Support changing HTTP method sent via query string
		logrequest.Handler,   // Log every request
		context.ClearHandler, // Prevent memory leak with gorilla.sessions
	)
```

## Apply to Specific Routes

In [controller/notepad](https://github.com/blue-jay/blueprint/blob/master/controller/notepad/notepad.go),
the application creates a chain of middleware and then
applies it to only certain routes. In this scenario, the pages are only
accessible if the user is authenticated.

[Source](https://github.com/blue-jay/blueprint/blob/master/controller/notepad/notepad.go)
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
