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

```go
// Package email provides email sending via SMTP.
package email

import (
	"encoding/base64"
	"fmt"
	"net/smtp"
	"sync"
)
```

The next section shows the thread-safe configuration that is used in many of
the lib packages. The Info struct holds the details for the SMTP server and is
public so it can be nested in the **Info** struct of the **boot** package
and then parsed from the env.json file. See the [Configuration](/configuration/)
section for more information about adding to env.json.

There are also a few methods standard to the lib packages:

- SetConfig() - allows the **boot** package to store the Info struct to a package level variable
- ResetConfig() - allows test packages to reset the configuration
- Config() - returns the configuration so the values can be accessed by other packages

All of these methods are thread-safe so they can be called by external packages
and by the functions within the package itself.

```go
// *****************************************************************************
// Thread-Safe Configuration
// *****************************************************************************

var (
	info      Info
	infoMutex sync.RWMutex
)

// Info holds the details for the SMTP server.
type Info struct {
	Username string
	Password string
	Hostname string
	Port     int
	From     string
}

// SetConfig stores the config.
func SetConfig(i Info) {
	infoMutex.Lock()
	info = i
	infoMutex.Unlock()
}

// ResetConfig removes the config.
func ResetConfig() {
	infoMutex.Lock()
	info = Info{}
	infoMutex.Unlock()
}

// Config returns the config.
func Config() Info {
	infoMutex.RLock()
	defer infoMutex.RUnlock()
	return info
}
```

The final section of the **email** package contains the ability to send an
email using the configuration settings. You'll notice the **Config()** function
through the code. This ensures the values are accessed in a thread-safe manner
so there is no problem if another package tries to change a value at the same
time.

```go
// Send mails an email.
func Send(to, subject, body string) error {
	auth := smtp.PlainAuth("", Config().Username, Config().Password, Config().Hostname)

	header := make(map[string]string)
	header["From"] = Config().From
	header["To"] = to
	header["Subject"] = subject
	header["MIME-Version"] = "1.0"
	header["Content-Type"] = `text/plain; charset="utf-8"`
	header["Content-Transfer-Encoding"] = "base64"

	message := ""
	for k, v := range header {
		message += fmt.Sprintf("%s: %s\r\n", k, v)
	}
	message += "\r\n" + base64.StdEncoding.EncodeToString([]byte(body))

	// Send the email
	err := smtp.SendMail(
		fmt.Sprintf("%s:%d", Config().Hostname, Config().Port),
		auth,
		Config().From,
		[]string{to},
		[]byte(message),
	)

	return err
}
```

## Code Generation

A new **lib** package can be generated with the thread-safe configuration using
this command: `jay generate lib/default package:value`