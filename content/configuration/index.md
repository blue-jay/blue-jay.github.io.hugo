---
title: Configuration
weight: 10
---

## Basic Usage

Throughout this documentation, keep in mind everything in Blueprint is configurable.
You are not using a framework so don't be afraid to change code. You don't need to
use any of the components included with Blueprint, but it does give you a nice foundation to
start from. If you want to use YAML instead of JSON, it's recommended to create a wrapper
library in the **lib** folder and then load your env.yaml file via the **bootstrap**
package.

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
in the **bootstrap** package. Here is an example **env.json**:

```json
{
  "Asset":{
    "Folder":"asset"
  },
  "Database":{
    "Type":"MySQL",
    "MySQL":{  
      "Username":"root",
      "Password":"",
      "Database":"blueprint",
      "Charset":"utf8mb4",
      "Collation":"utf8mb4_unicode_ci",
      "Hostname":"127.0.0.1",
      "Port":3306,
      "Parameter":"parseTime=true"
    }
  },
  "Email":{
    "Username":"",
    "Password":"",
    "Hostname":"",
    "Port":25,
    "From":""
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
- Generate the tls certs and use HTTPS
- Set **Session**.**Secure** to true

## Configuration Structure

The **env.json** file contains the configuration for Blueprint. It removes the need
to hardcode any of these values and makes it easy to move Blueprint to another system
with a different setup. The **env.json** file is parsed and held in the
**Info** struct from the **bootstrap** package:

```go
// Info contains the application settings.
type Info struct {
	Asset    asset.Info    `json:"Asset"`
	Database database.Info `json:"Database"`
	Email    email.Info    `json:"Email"`
	Server   server.Info   `json:"Server"`
	Session  session.Info  `json:"Session"`
	Template view.Template `json:"Template"`
	View     view.Info     `json:"View"`
}
```

The **Info** struct is simply a container that nests structs from packages in the **lib** folder
that need variables configured. Here is a list mapping the JSON keys to structs:

```text
Asset       - Info struct in lib/asset
Database	- Info struct in lib/database
Email		- Info struct in lib/email
Server		- Info struct in lib/server
Session		- Info struct in lib/session
Template	- Template struct in lib/view
View		- Info struct in lib/view
```

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
1. Add the **Captcha** key and any values to the **env.json** file
1. Add code to the **RegisterServices()** function in the **bootstrap** package to pass the config to the **lib/captcha** package at start up
1. Add code to your controllers that references your **lib/captcha** package

## Tip: Remove a Section

To remove the **Email** key, your workflow would consist of the following:

1. Remove the **Email** key and value from the **env.json** file
1. Remove the **Email** nested struct from the **Info** struct in the **bootstrap** package
1. Remove any code setting up the package from the **RegisterServices()** function in the **bootstrap** package
1. Remove the **lib/email** package from the filesystem
1. Find any references to the **lib/email** package in your code using the jay command line, `jay find . "lib/email"`,
then delete the imports and referencing code