---
title: Controllers
weight: 40
---

## Basic Usage

The controller files are all organized under the **controller** folder. The
controllers handle the interactions between the models and the views as well as
specify which routes to map to which functions.

It's a good idea to follow a naming convention for the different pieces.
Laravel developers will notice it's very similar, but with a few changes.

| Method | Path              | Function | View        |
|:------:|:-----------------:|:--------:|:------------:
| GET    | /notepad          | Index    | index.tmpl  |
| GET    | /notepad/create   | Create   | create.tmpl |
| POST   | /notepad/create   | Store    |             |
| GET    | /notepad/view/:id | Show     | show.tmpl   |
| GET    | /notepad/edit/:id | Edit     | edit.tmpl   |
| PATCH  | /notepad/edit/:id | Update   |             |
| DELETE | /notepad/:id      | Destroy  |             |

Here is a controller that follows the naming convention. Notice
the model name (**note**) matches the view folder (**note/index**). The model does
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

Sessions provide access to flash messages as well as variables that are set at
login. You **must** remember to save the sessions once you make a change to
them.

```go
// Get the current session
sess := session.Instance(r)
...
// Save the session after you are finished making changes
sess.Save(r, w)
```

## Trigger Flash Message

Flash messages will appear to the user on next page load. They only display
once. The built-in messages are tied to Bootstrap classes:

- flash.Success is green (alert-success)
- flash.Warning is yellow (alert-warning)
- flash.Notice is blue (alert-info)
- flash.Error is red (alert-danger)

```go
sess.AddFlash(flash.Info{"Welcome to Blueprint!", flash.Success})
sess.Save(r, w) // Ensure you save the session after making a change to it
```

## Validate a Form

The **form** package makes it easy to validate required fields. It works on the 
inputs: text, textarea, checkbox, radio, and select. The function, 
**form.Required()**, requires the request and then any number of fields
as it is a variadic function.

```go
if valid, missingField := form.Required(r, "email", "password"); !valid {
	sess.AddFlash(flash.Info{"Field missing: " + missingField, flash.Error})
	sess.Save(r, w)
	LoginGET(w, r)
	return
}
```

## Repopulate Form Fields

The **form** package can also repopulate the form fields after a submission that
is missing information. It is also a
variadic function so it can accepts more than one field. You'll need to use
blocks from the **form** package in your view as well. Check out the
[Views](/views/#repopulate-form-fields) page to see how to use them.

```go
// Index displays the login page.
func Index(w http.ResponseWriter, r *http.Request) {
	v := view.New("login/index")
	form.Repopulate(r.Form, v.Vars, "email")
	v.Render(w, r)
}
```

## Render a Template

You can render a template a few ways (check out the [Views](/views)
page for more clarification):

```go
// Render without adding any variables
view.New("about/index").Render(w, r)

// Render with variables
session := session.Instance(r)
v := view.New("home/index")
v.Vars["first_name"] = session.Values["first_name"]
v.Render(w, r)

// Render with different base template (base.tmpl is used by default)
v := view.New("home/index").Base("single")
v.Render(w, r)
```

## Return Flash over Ajax

If you're using Ajax to retrieve content, you can also retrieve the flash
messages this way so they can be displayed without refreshing the page. There is
JavaScript that is already designed to show a Flash message and it's called:
**ShowFlash()**. You'll just need to make a call to the page and then pass the
output to **ShowFlash()**. The code is below.

Code for the controller:
```go
// Load the routes.
func Load() {
	router.Get("/flashes", Index)
}

// Index displays the flash messages in JSON.
func Index(w http.ResponseWriter, r *http.Request) {
	// Get session
	sess := session.Instance(r)

	// Set the flash message
	sess.AddFlash(flash.Info{"An error occurred on the server. Please try again later.", flash.Error})
	sess.Save(r, w)

	// Display the flash messages as JSON
	flash.SendFlashes(w, r)
}
```

Code in JavaScript:
```javascript
$.get("/flashes", function(data) {
	showFlash(data);
});
```

## Interact with a Model

The models contain all the SQL code so the controllers just call the model
functions to interact with the data.

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

There is also a simple package that sends emails once the SMTP settings in
env.json point to your SMTP server.

```go
// Email a user
err := email.Send(email.Config().From, "This is the subject", "This is the body!")
if err != nil {
	log.Println(err)
	sess.AddFlash(flash.Info{"An error occurred on the server. Please try again later.", flash.Error})
	sess.Save(r, w)
	return
}
```