---
date: 2016-03-08T21:07:13+01:00
title: Controllers
weight: 40
---

## Basic Usage

The controller files are all organized under the **controller** folder. The
controllers handle the interactions between the models and the views as well as
specify which routes to map to which functions.

It's a good idea to follow a naming convention for the different pieces.
Laravel developers will notice it's the same convention Taylor Orwell uses.

| Method | Path              | Function | View        |
|:------:|:-----------------:|:--------:|:------------:
| GET    | /notepad          | Index    | index.tmpl  |
| GET    | /notepad/create   | Create   | create.tmpl |
| POST   | /notepad          | Store    |             |
| GET    | /notepad/view/:id | Show     | show.tmpl   |
| GET    | /notepad/edit/:id | Edit     | edit.tmpl   |
| PATCH  | /notepad/edit/:id | Update   |             |
| DELETE | /notepad/:id      | index    |             |

For example, below is a controller that follows the naming convention. Notice
the model name ("note") matches the view folder ("note/index"). The model does
not need to match the controller because you'll be working with many different
models in your controllers.

```go
func Load() {
	...
	// "Get" is the Method
	// "/notepad" is the Path
	router.Get("/notepad", Index, acl.DisallowAnon)
	...
}

// "Index" is the Function
func Index(w http.ResponseWriter, r *http.Request) {
	c := flight.Context(w, r)

	items, err := note.ByUserID(c.UserID)
	if err != nil {
		c.FlashError(err)
		items = []note.Item{}
	}

	// "index" is the View
	v := view.New("note/index")
	v.Vars["first_name"] = c.Sess.Values["first_name"]
	v.Vars["items"] = items
	v.Render(w, r)
}
```

## Access a Session

```go
// Get the current session
sess := session.Instance(r)
...
// Save the session after you are finished making changes
sess.Save(r, w)
```

## Trigger Flash Message

```go
sess.AddFlash(view.Flash{"Sorry, no brute force :-)", view.FlashNotice})
sess.Save(r, w) // Ensure you save the session after making a change to it
```

## Validate a Form

```go
if validate, missingField := form.Required(r, "email", "password"); !validate {
	sess.AddFlash(flash.Info{"Field missing: " + missingField, flash.Error})
	sess.Save(r, w)
	LoginGET(w, r)
	return
}
```

## Render a Template

```go
// Set the template name
v := view.New("auth/login")

// Refill form fields from a POST operation
form.Repopulate(r.Form, v.Vars, "email")

// Render the template
v.Render(w, r)
```

## Return Flash over Ajax

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

## Interact with a Model

```go
// Get database result
result, err := user.ByEmail(email)

if err == model.ErrNoResult {
	// User does not exist
} else if err != nil {
	// Display error message
} else if passhash.MatchString(result.Password, password) {
	// Password matches!	
} else {
	// Password does not match
}
```

## Send an Email

```go
// Email a user
err := email.Send(email.ReadConfig().From, "This is the subject", "This is the body!")
if err != nil {
	log.Println(err)
	sess.AddFlash(view.Flash{"An error occurred on the server. Please try again later.", view.FlashError})
	sess.Save(r, w)
	return
}
```