---
date: 2016-06-30T21:07:13+01:00
title: Assets
weight: 10
---

## Basic Usage

Out of the box, all of the static assets like CSS and JavaScript are ready to
demo. If you want to make changes to the file, it's best to use the tools
provided. The **asset** folder contains a **dynamic** folder and a **static**
folder.

The **dynamic** folder contains the Syntactically Awesome Style Sheets (SASS),
individual JavaScript files, and a large PNG image which is used to generate
favicons for different platforms like Android, iPhone, etc. The dynamic folder
holds some of the assets required to generate the assets in the **static**
folder. *This is the folder you want to make your changes.*

The **static** folder contains the minified CSS and JavaScript as well as
the generated favicons. The **static** folder is designed to be served up
so the files can be accessed like this:

```html
<!-- Favicons -->
<link rel="apple-touch-icon" sizes="57x57" href="/static/favicon/apple-touch-icon-57x57.png?v1.0=3eepn6WlLO">
<link rel="apple-touch-icon" sizes="60x60" href="/static/favicon/apple-touch-icon-60x60.png?v1.0=3eepn6WlLO">
<link rel="apple-touch-icon" sizes="72x72" href="/static/favicon/apple-touch-icon-72x72.png?v1.0=3eepn6WlLO">
<!-- CSS and Fonts -->
<link media="all" rel="stylesheet" type="text/css" href="/static/css/bootstrap.min.css?1466973904" />
<link media="all" rel="stylesheet" type="text/css" href="//fonts.googleapis.com/css?family=Open+Sans:300,400,bold,italic" />
<link media="all" rel="stylesheet" type="text/css" href="/static/css/all.css?1466973904" />
```

Check out the [Controllers](/controllers) and [Views](/views) pages for how
the files are served and how to append timestamps to them to manage caching.

If you make changes to any of the files in the **dynamic** folder, you still
need a way to compile/minify them and then move them to the **static** folder
so we'll use Gulp to do that.

## Install npm

The Node Package Manager (npm) helps install packages that work with NodeJS.
If you don't have NodeJS and npm installed, you can install the latest version
from https://nodejs.org.

## Install Gulp and Dependencies

Once npm is installed, you can open your terminal and CD to the root of the
project folder. You can then run these commands:

```bash
# Install Gulp Globally
npm install -g gulp-cli

# Install Glup Locally with Dependencies from package.json
npm install
```

## Gulp

Once the environment is set up, you should have your terminal open to the root
of the project folder. There are a couple commands you can use with Gulp that
are in the [gulpfile.js](https://github.com/blue-jay/blueprint/blob/master/gulpfile.js).

```bash
# Compile the SASS from asset/dynamic/sass and store CSS in asset/static/css/all.css
gulp sass

# Concat the JavaScript from asset/dynamic/js and store JS in asset/static/js/all.js
gulp javascript

# Copy the jQuery files from node_modules/jquery to asset/static/js
gulp jquery

# Copy the Bootstrap files from node_modules/bootstrap to asset/static
gulp bootstrap

# Copy the Underscore files from note_modules/underscore to asset/static/js
gulp underscore

# Run tasks favicon-generate and favicon-inject
gulp favicon

# Generate favicons from asset/dynamic/logo.png and copy to /asset/static/favicon
gulp favicon-generate

# Generate view/partial/favicon.tmpl with favicon tags
gulp favicon-inject

# Update the asset/dynamic/favicon/data.json file with the latest version from the RealFaviconGenerator website
gulp favicon-update

# Run the sass and javascript tasks when any of the files change
gulp watch

# Run all the tasks once
gulp init

# Run just the sass and javascript tasks once
gulp default
```

It best to run `gulp watch` so when you are working in the SASS and JavaScript
files, they will automatically update for you