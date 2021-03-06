---
title: Configuration
weight: 10
---

## Basic Usage

Throughout this documentation, keep in mind everything in Blueprint is configurable.
You are not using a framework so don't be afraid to change code. You don't need to
use any of the components included with Blueprint, but it does give you a nice foundation to
start from. If you want to use YAML instead of JSON, it's recommended to create a wrapper
library in the **lib** folder and then load your env.yaml file via the **blueprint.go**
file.

## Jay Command: env

One of the first steps before using Blueprint is to create **env.json**. You can make
a copy of **env.json.example** and then name it **env.json**, just be sure to
generate a new **AuthKey**, **EncryptKey**, and **CSRFKey** in the **Session** section.

You can also use **jay** to create the env.json file with new session keys.
Just CD to the **blueprint** folder and then run: `jay env make`

Here are the commands you can use with `jay env`:

```bash
# Create a new env.json file from env.json.example with newly generated session keys
jay env make

# Show a new set of session keys that can be copied and pasted into env.json
jay env keyshow

# Generate a new set of session keys and automatically apply them to env.json
env env keyupdate
```

The **env.json** file is a good place to set variables for the application so
you don't have to hardcode them. If you want to add any of your own settings,
you can add them to **env.json** and update the **Info** struct
in the **lib/env** package. Here is an example **env.json**:

```json
{
	"Asset":{
		"Folder":"asset"
	},
	"Email":{
		"Username":"",
		"Password":"",
		"Hostname":"",
		"Port":25,
		"From":""
	},
	"Form":{
		"FileStorageFolder":"filestorage"
	},
	"Generation":{
		"TemplateFolder":"generate"
	},
	"MySQL":{
		"Username":"root",
		"Password":"",
		"Database":"blueprint",
		"Charset":"utf8mb4",
		"Collation":"utf8mb4_unicode_ci",
		"Hostname":"127.0.0.1",
		"Port":3306,
		"Parameter":"parseTime=true",
		"Migration":{
			"Folder":"migration/mysql",
			"Table":"migration_blueprint",
			"Extension":"sql"
		}
	},
	"Server":{
		"Hostname":"",
		"UseHTTP":true,
		"UseHTTPS":false,
		"RedirectToHTTPS":false,
		"HTTPPort":80,
		"HTTPSPort":443,
		"CertFile":"tls/server.crt",
		"KeyFile":"tls/server.key"
	},
	"Session":{
		"AuthKey":"PzCh6FNAB7/jhmlUQ0+25sjJ+WgcJeKR2bAOtnh9UnfVN+WJSBvY/YC80Rs+rbMtwfmSP4FUSxKPtpYKzKFqFA==",
		"EncryptKey":"3oTKCcKjDHMUlV+qur2Ve664SPpSuviyGQ/UqnroUD8=",
		"CSRFKey":"xULAGF5FcWvqHsXaovNFJYfgCt6pedRPROqNvsZjU18=",
		"Name":"sess",
		"Options":{
			"Path":"/",
			"Domain":"",
			"MaxAge":28800,
			"Secure":false,
			"HttpOnly":true
		}
	},
	"Template":{
		"Root":"base",
		"Children":[
			"partial/favicon",
			"partial/menu",
			"partial/footer"
		]
	},
	"View":{
		"BaseURI":"/",
		"Extension":"tmpl",
		"Folder":"view",
		"Caching":true
	}
}
```

## Production

When you move your application to production, you should make the following
changes:

- Set **Server**.**Hostname** to the server
- Set **Server**.**UseHTTPS** to true
- Generate a certificate and key for HTTPS and place in the **tls** folder
- Set **Session**.**Secure** to true

## Configuration Structure

The **env.json** file contains the configuration for Blueprint and Jay. It removes the need
to hardcode any of these values and makes it easy to move Blueprint to another system
with a different setup. The **env.json** file is parsed to the
**Info** struct from the **lib/env** package:

[Source](https://github.com/blue-jay/blueprint/blob/master/lib/env/env.go)
```go
// Info contains the application settings.
type Info struct {
  Asset      asset.Info    `json:"Asset"`
  Email      email.Info    `json:"Email"`
  Form       form.Info     `json:"Form"`
  Generation generate.Info `json:"Generation"`
  MySQL      mysql.Info    `json:"MySQL"`
  Server     server.Info   `json:"Server"`
  Session    session.Info  `json:"Session"`
  Template   view.Template `json:"Template"`
  View       view.Info     `json:"View"`
  path       string
}
```

The **Info** struct is a container that nests structs from packages in
the **Core** library that need variables configured. The **Path** variable is
the location of the env.json file. Here is a list mapping the JSON keys to
structs:

```text
Asset     - Info struct in core/asset
Email     - Info struct in core/email
Form      - Info struct in core/form
Generate  - Info struct in core/generate
MySQL     - Info struct in core/mysql
Server    - Info struct in core/server
Session   - Info struct in core/session
Template  - Template struct in core/view
View      - Info struct in core/view
```

## Using Flight

The **flight** package provides access to the session variables, env.json settings,
database connections, views, and general shortcuts. It's mostly designed for
controllers, but it can be used by other packages as well.

To use package, you would call the **flight.Context()** function like this:

```go
// Index displays the items.
func Index(w http.ResponseWriter, r *http.Request) {
	c := flight.Context(w, r)

	items, _, err := note.ByUserID(c.DB, c.UserID)
	if err != nil {
		c.FlashError(err)
		items = []note.Item{}
	}

	v := c.View.New("note/index")
	v.Vars["items"] = items
	v.Render(w, r)
}
```

Flight needs a **http.ResponseWriter** and a **http.Request** so it can access
the sessions variables and provide shortcuts for the following tasks:

- reading URL parameters: c.Param(name string)
- redirecting to a page: c.Redirect(urlStr string)
- validation a form and sets a flash message: c.FormValid(fields ...string)
- repopulating a form: c.Repopulate(v map[string]interface{}, fields ...string)
- setting flash messages and then saving the session: c.FlashSuccess(message string)

Flight also provides access to the following:

- configuration settings from env.json: `c.Config.Asset.Folder`
- session: `c.Sess.Values["email"]`
- current user ID: `c.UserID`
- view package: `c.View.New("home/index")`
- database connection: `items, _, err := note.ByUserID(c.DB, c.UserID)`

It is not a requirement to use the **flight** package, but it makes working
with the different web components much easier. Feel free to modify the package
to fit your needs. Just make sure it is thread-safe.

## Enable HTTPS

To enable HTTPS:

1. Set **UseHTTPS** to **true** in the **env.json** file
1. Create a folder called **tls** in the project root folder
1. Place your own certificate and key files in the **tls** folder

**Note:** If you want to redirect HTTP to HTTPS, you can set **RedirectToHTTPS** to **true** in the **env.json** file as well.

## Tip: Add a Section

To add a new key called **Captcha**, your workflow would consist of the
following:

1. Create a new package in the **lib** folder called **captcha**
1. Create a struct called **Info** in the **lib/captcha** package
1. Add the struct to the **Info** struct in the **lib/env** package
1. Add the **Captcha** key and any values to the **env.json** file
1. Add code to the **RegisterServices()** function in the **lib/boot** package to pass the any additional settings to the **lib/flight** package at start up
1. Add code to your controllers that references uses **flight.Context()** to retrieve your **lib/captcha** package settings

## Tip: Remove a Section

To remove the **Email** key, your workflow would consist of the following:

1. Remove the **Email** key and value from the **env.json** file
1. Remove the **Email** nested struct from the **Info** struct in the **lib/env** package
1. Remove any code setting up the package from the **RegisterServices()** function in the **boot** package
1. Remove the **lib/email** package from the filesystem
1. Find any references to the **lib/email** package in your code using the jay command line, `jay find . "lib/email"`,
then delete the imports and referencing code
