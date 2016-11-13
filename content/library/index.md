---
title: Library
weight: 65
---

## Basic Usage

If you look through the [**Core**](https://github.com/blue-jay/core) library,
you'll see packages that provide
different functionality. These packages are designed to be shared and used
through the application. Since Blueprint is a web application, some of the
packages must be thread-safe to ensure they won't throw any errors if they are
accessed at the same time by two separate threads.

As you create your own packages, you can store them in the **blueprint/lib**
folder to keep them organized and separate.

It's a good idea to keep them light on dependencies so you can reuse them again
in later projects. Packages that are too tightly-coupled require time to rework
so you might as well do it right from the start.

Let's take a look at the **email** package in sections. The first of the
three sections is the package declaration and import section. Notice how the
only packages the **email** package uses are part of the standard library. This
is a good indicator that the package could be moved to a different project
without rewriting.

[Source](https://github.com/blue-jay/core/blob/master/email/email.go)
```go
// Package email provides email sending via SMTP.
package email

import (
	"encoding/base64"
	"fmt"
	"net/smtp"
)
```

The Info struct holds the details for the SMTP server and it should be
added to the **Info** struct of the **lib/env** package
and then parsed from the env.json file. See the [Configuration](/configuration/)
section for more information about adding to env.json.

```go
// Info holds the details for the SMTP server.
type Info struct {
	Username string
	Password string
	Hostname string
	Port     int
	From     string
}
```

The final section of the **email** package sends an
email using the configuration settings. You'll notice the function is a
struct method which makes it really easy to use from the **flight** package.

```go
// Send an email.
func (c Info) Send(to, subject, body string) error {
	auth := smtp.PlainAuth("", c.Username, c.Password, c.Hostname)

	// Create the header
	header := make(map[string]string)
	header["From"] = c.From
	header["To"] = to
	header["Subject"] = subject
	header["MIME-Version"] = "1.0"
	header["Content-Type"] = `text/plain; charset="utf-8"`
	header["Content-Transfer-Encoding"] = "base64"

	// Set the message
	message := ""
	for k, v := range header {
		message += fmt.Sprintf("%s: %s\r\n", k, v)
	}
	message += "\r\n" + base64.StdEncoding.EncodeToString([]byte(body))

	// Send the email
	err := smtp.SendMail(
		fmt.Sprintf("%s:%d", c.Hostname, c.Port),
		auth,
		c.From,
		[]string{to},
		[]byte(message),
	)

	return err
}
```

To use in a controller, you would get the context from the **flight** package
and then from the **Config** variable, you could access the **email** struct and then
the `Send()` function.

```go
// Index sends an email.
func Index(w http.ResponseWriter, r *http.Request) {
	c := flight.Context(w, r)

	err := c.Config.Email.Send("This is the subject", "This is the body!")
	if err != nil {
		c.FlashError(err)
		return
	}
}
```

## Code Generation

A new **lib** package can be generated using this command: `jay generate lib/default package:value`
