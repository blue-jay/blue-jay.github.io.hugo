---
date: 2016-03-08T21:07:13+01:00
title: Configuration
weight: 10
---

## Basic Usage

Throughout this documentation, keep in mind everything in Blueprint is configurable.
You are not using a framework so you don't have to follow rules. You don't need to
use any of the components with Blueprint, but it does give you a nice foundation to
start from. If you want to use YAML instead of JSON, I recommend creating a wrapper
library in the **lib** folder and then loading your env.yaml file via the **bootstrap**
package.

One of the first steps before using Blueprint is to create **env.json**. You can make
a copy of **env.json.example** and then name it **env.json**. The **env.json** file is a
good place to set variables for the application so you
don't have to hardcode them. If you want to add any 
of your own settings, you can add them to **env.json** and update the **Info** struct
in the **bootstrap** package. Here is an example **env.json**:

```json
{
	"Database": {
		"Type": "MySQL",
		"MySQL": {
			"Username": "root",
			"Password": "",
			"Database": "blueprint",
			"Hostname": "127.0.0.1",
			"Port": 3306,
			"Parameter": "?parseTime=true"
		}
	},
	"Email": {
		"Username": "",
		"Password": "",
		"Hostname": "",
		"Port": 25,
		"From": ""
	},
	"Server": {
		"Hostname": "",
		"UseHTTP": true,
		"UseHTTPS": false,
		"RedirectToHTTPS": false,
		"HTTPPort": 80,
		"HTTPSPort": 443,
		"CertFile": "tls/server.crt",
		"KeyFile": "tls/server.key"
	},
	"Session": {
		"SecretKey": "@r4B?EThaSEh_drudR7P_hub=s#s2Pah",
		"Name": "sess",
		"Options": {
			"Path": "/",
			"Domain": "",
			"MaxAge": 28800,
			"Secure": false,
			"HttpOnly": true
		}
	},
	"Template": {
		"Root": "base",
		"Children": [
			"partial/menu",
			"partial/footer"
		]
	},
	"View": {
		"BaseURI": "/",
		"Extension": "tmpl",
		"Folder": "template",
		"Caching": true
	}
}
```

## Configuration Structure

The **env.json** file contains the configuration for Blueprint. It removes the need
to hardcode any of these values and makes it easy to move Blueprint to another system
with a different set up.

The **env.json** file is parsed and the result is stored in the **Info** struct from the
**bootstrap** package:

```go
// Info contains the application settings
type Info struct {
	Database database.Info   `json:"Database"`
	Email    email.SMTPInfo  `json:"Email"`
	Server   server.Server   `json:"Server"`
	Session  session.Session `json:"Session"`
	Template view.Template   `json:"Template"`
	View     view.View       `json:"View"`
}
```

The **Info** struct is simply a container that nests structs from packages in the **lib** folder
that need variables configured. Here is a list mapping the JSON keys to structs:

```text
Database	- Info struct in lib/database
Email		- SMTPInfo struct in lib/email
Server		- Server struct in lib/server
Session		- Session struct in lib/session
Template	- Template struct in lib/view
View		- View struct in lib/view
```

## Enable HTTPS

To enable HTTPS:

1. Set **UseHTTPS** to true
1. Create a folder called **tls** in the project root folder 
1. Place your own certificate and key files in the **tls** folder

**Note:** If you want to redirect HTTP to HTTPS, you can set **RedirectToHTTPS** to true as well.

## Tip: Add a Section

To add a new key called **Captcha**, you could do the following:

1. Create a new package in the **lib** folder called **captcha**
1. Create a struct called **Info** in the **lib/captcha** package
1. Add the **Captcha** key and any values to the **env.json** file
1. Add code to the **RegisterServices()** function that passes the parsed config to the **lib/captcha** package
1. Add code to your controllers that references your **lib/captcha** package

## Tip: Remove a Section

To remove the **Email** key, you could do the following:

1. Remove the **Email** key and value from the **env.json** file
1. Remove the **Email** nested struct from the **Info** struct in the **bootstrap** package
1. Remove any code setting up the package from the **RegisterServices()** function in the **bootstrap** package
1. Remove the **lib/email** package from the filesystem
1. Find any references to the **lib/email** package in your code using the jay command line, `jay find "lib/email" "*.go"`,
then delete the imports and referencing code