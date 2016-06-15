---
date: 2016-03-08T21:07:13+01:00
title: Controllers
weight: 20
---

## Basic Usage

The controller files are all organized under the **controller** folder. The controllers
handle much of the interactions between the models and the views as well as specify
which routes map to which functions.

## Routing

In the **bootstrap** package, the **RegisterServices()** function calls: `controller.LoadRoutes()`
The **LoadRoutes()** function in the **controller** package loads the routes for each of the individual controllers:

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
var (
	uri = "/notepad"
)

func Load() {
	c := router.Chain(acl.DisallowAnon)
	router.Get(uri, Index, c...)
	router.Get(uri+"/create", Create, c...)
	router.Post(uri, Store, c...)
	router.Get(uri+"/view/:id", Show, c...)
	router.Get(uri+"/edit/:id", Edit, c...)
	router.Patch(uri+"/edit/:id", Update, c...)
	router.Delete(uri+"/:id", Destroy, c...)
}
```

There are a few things to note here. The **router** references the **lib/router** package
which is a wrapper for the [julienschmidt/httprouter](http://github.com/julienschmidt/httprouter) package.
The **router.Chain()** function uses the [justinas/alice](http://github.com/justinas/alice) package
to help with middleware chaining.

This may start to sound like a framework, but it's actually a good way to build your wrapper
packages that live in the **lib** folder. If you want to use a different router, you can modify
the **lib/router** package easily and you won't have to change any code in your controllers.

It's a good idea to follow a naming convention for the controller functions (Laravel developers
will notice it's the same convention Taylor Orwell uses).


### These are a few things you can do with controllers.

Access a gorilla session:

```go
// Get the current session
sess := session.Instance(r)
...
// Close the session after you are finished making changes
sess.Save(r, w)
```

Trigger 1 of 4 different types of flash messages on the next page load (no other code needed):

```go
sess.AddFlash(view.Flash{"Sorry, no brute force :-)", view.FlashNotice})
sess.Save(r, w) // Ensure you save the session after making a change to it
```

Validate form fields are not empty:

```go
// Ensure a user submitted all the required form fields
if validate, missingField := view.Validate(r, []string{"email", "password"}); !validate {
	sess.AddFlash(view.Flash{"Field missing: " + missingField, view.FlashError})
	sess.Save(r, w)
	LoginGET(w, r)
	return
}
```

Render a template:

```go
// Create a new view
v := view.New(r)

// Set the template name
v.Name = "login/login"

// Assign a variable that is accessible in the form
v.Vars["token"] = csrfbanana.Token(w, r, sess)

// Refill any form fields from a POST operation
view.Repopulate([]string{"email"}, r.Form, v.Vars)

// Render the template
v.Render(w)
```

Return the flash messages during an Ajax request:

```go
// Get session
sess := session.Instance(r)

// Set the flash message
sess.AddFlash(view.Flash{"An error occurred on the server. Please try again later.", view.FlashError})
sess.Save(r, w)

// Display the flash messages as JSON
v := view.New(r)
v.SendFlashes(w)
```

Handle the database query:

```go
// Get database result
result, err := model.UserByEmail(email)

if err == sql.ErrNoRows {
	// User does not exist
} else if err != nil {
	// Display error message
} else if passhash.MatchString(result.Password, password) {
	// Password matches!	
} else {
	// Password does not match
}
```

Send an email:

```go
// Email a user
err := email.SendEmail(email.ReadConfig().From, "This is the subject", "This is the body!")
if err != nil {
	log.Println(err)
	sess.AddFlash(view.Flash{"An error occurred on the server. Please try again later.", view.FlashError})
	sess.Save(r, w)
	return
}
```

Validate a form if the Google reCAPTCHA is enabled in the config:

```go
// Validate with Google reCAPTCHA
if !recaptcha.Verified(r) {
	sess.AddFlash(view.Flash{"reCAPTCHA invalid!", view.FlashError})
	sess.Save(r, w)
	RegisterGET(w, r)
	return
}
```