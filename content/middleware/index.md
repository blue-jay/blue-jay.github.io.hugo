---
date: 2016-06-20T21:07:13+01:00
title: Middleware
weight: 30
---

## Basic Usage

Middleware, in the context of Go, is applied during routing to provide
features like request/response logging, access controls lists (ACLs), and
header modification. Middleware is either applied to every request (for request
logging) or specified routes (for ACLs).

There are a few pieces of middleware included. The package called csrfbanana 
protects against Cross-Site Request Forgery attacks and prevents double submits. 
The package httprouterwrapper provides helper functions to make funcs compatible 
with httprouter. The package logrequest will log every request made against the 
website to the console. The package pprofhandler enables pprof so it will work 
with httprouter.

## Creating Middleware

An example of a piece of middleware that is applied to every request is
**lib/middleware/logrequest**. When a page is requested, the middleware will
print to the console the time of the request, remote IP address, HTTP method,
and the URL requested.

[Source](https://github.com/blue-jay/blueprint/blob/master/lib/middleware/logrequest/logrequest.go)
```go
package logrequest

import (
	"fmt"
	"net/http"
	"time"
)

// Handler will log the HTTP requests
func Handler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Log the request
		fmt.Println(time.Now().Format("2006-01-02 03:04:05 PM"), r.RemoteAddr, r.Method, r.URL)
		next.ServeHTTP(w, r)
	})
}
```

You can use this template for writing your own middleware:

```go
// Handler will log the HTTP requests
func Handler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Logic BEFORE the other handlers and function goes here
		next.ServeHTTP(w, r)
		// Logic AFTER the other handlers and function goes here
	})
}
```

## Chaining

Chaining prevents middleware from stacking up which is hard to read.

```go
return context.ClearHandler(rest.Handler(logrequest.Handler(setUpBanana)))
```
Before [justinas/alice](https://github.com/justinas/alice), a workaround was to
use the variable and reassign it multiple times like this:

```go
h = setUpBanana(h)
h = logrequest.Handler(h)
h = rest.Handler(h)
return context.ClearHandler(h)
```

In [controller/notepad](https://github.com/blue-jay/blueprint/blob/master/controller/notepad/notepad.go),
the application uses the **router.ChainHandler()** function. The function is a wrapper for
the [justinas/alice](https://github.com/justinas/alice) package which makes
using middleware more scalable and a little "prettier". If you look at the
[bootstrap](https://github.com/blue-jay/blueprint/blob/master/bootstrap/bootstrap.go)
package, you'll see the **ChainHandler()** function.

```go
// Middleware contains the middleware that applies to every request
func SetUpMiddleware(h http.Handler) http.Handler {
	return router.ChainHandler( // Chain middleware, bottom runs first
		context.ClearHandler, // Clear handler for Gorilla Context
		rest.Handler,         // Support changing HTTP method sent via form input
		logrequest.Handler,   // Log every request
		setUpBanana)          // Prevent CSRF and double submits
}
```

There is also a **Chain()** function that can be used to chain middleware for routes
or to pass to **ChainHandler()**.

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
	context.ClearHandler, // Clear handler for Gorilla Context
	rest.Handler,         // Support changing HTTP method sent via form input
	logrequest.Handler,   // Log every request
	setUpBanana)          // Prevent CSRF and double submits
return router.ChainHandler(c...)
```

**ChainHandler()** accepts one or more of the http.Handler type and returns a
http.Handler.
**Chain()** accepts one or more of the http.Handler type and returns an array of
the alice.Constructor type.

## Apply to Every Request

In [blueprint.go](https://github.com/blue-jay/blueprint/blob/master/blueprint.go),
the application calls **bootstrap.SetUpMiddleware(router.Instance())** which
applies the middleware to the router. The middleware is called on every
request.

[Source](https://github.com/blue-jay/blueprint/blob/master/bootstrap/bootstrap.go)
```go
// Middleware contains the middleware that applies to every request
func SetUpMiddleware(h http.Handler) http.Handler {
	return router.ChainHandler( // Chain middleware, bottom runs first
		context.ClearHandler, // Clear handler for Gorilla Context
		rest.Handler,         // Support changing HTTP method sent via form input
		logrequest.Handler,   // Log every request
		setUpBanana)          // Prevent CSRF and double submits
}
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