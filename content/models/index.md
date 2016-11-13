---
title: Models
weight: 50
---

## Basic Usage

It's a good idea to abstract the database layer out so if you need to make
changes, you don't have to look through the controllers to find the queries. All
the queries are stored in the **model** folder.

Blue Jay supports MySQL by default, but can easily be expanded to use other
database systems. There is also a PostgreSQL package you can use
[here](https://github.com/blue-jay/core/blob/master/storage/driver/postgresql/postgresql.go).
The instructions are at the bottom of this page.

## Connect to the database

You only need to connect to the database once. The connection pool is
handled by the [go-sql-driver/mysql](https://github.com/go-sql-driver/mysql)
package. The connection is started by the **lib/boot** package:

[Source](https://github.com/blue-jay/blueprint/blob/master/lib/boot/boot.go)
```go
// Connect to the MySQL database
mysqlDB, _ := config.MySQL.Connect(true)
```

## Model Layout

Every model should have a table name, a struct to represent the columns, and a
Connection interface. The interface makes the model much more testable so it can
be easily mocked and interchanged.

A good interface for each model looks like this:

```
// Connection is an interface for making queries.
type Connection interface {
	Exec(query string, args ...interface{}) (sql.Result, error)
	Get(dest interface{}, query string, args ...interface{}) error
	Select(dest interface{}, query string, args ...interface{}) error
}
```

And a good create function looks like this:

```
// Create adds an item.
func Create(db Connection, name string, userID string) (sql.Result, error) {
	result, err := db.Exec(fmt.Sprintf(`
		INSERT INTO %v
		(name, user_id)
		VALUES
		(?,?)
		`, table),
		name, userID)
	return result, err
}
```

# CRUD Operations

Below are common operations and how controllers can interact with models.
All the controller functions are from
[notepad.go](https://github.com/blue-jay/blueprint/blob/master/controller/notepad/notepad.go)
and the model functions
are from [note.go](https://github.com/blue-jay/blueprint/blob/master/model/note/note.go).

## Create an Item

Use **db.Exec()** to create an item or a table.

### Controller
```go
// Store handles the create form submission.
func Store(w http.ResponseWriter, r *http.Request) {
	c := flight.Context(w, r)

	if !c.FormValid("name") {
		Create(w, r)
		return
	}

	_, err := note.Create(c.DB, r.FormValue("name"), c.UserID)
	if err != nil {
		c.FlashError(err)
		Create(w, r)
		return
	}

	c.FlashSuccess("Item added.")
	c.Redirect(uri)
}
```

### Model
```go
// Create adds an item.
func Create(db Connection, name string, userID string) (sql.Result, error) {
	result, err := db.Exec(fmt.Sprintf(`
		INSERT INTO %v
		(name, user_id)
		VALUES
		(?,?)
		`, table),
		name, userID)
	return result, err
}
```

## Get an Item by Item ID

Use **db.Get()** to get a single item.

### Controller
```go
// Show displays a single item.
func Show(w http.ResponseWriter, r *http.Request) {
	c := flight.Context(w, r)

	item, _, err := note.ByID(c.DB, c.Param("id"), c.UserID)
	if err != nil {
		c.FlashError(err)
		c.Redirect(uri)
		return
	}

	v := c.View.New("note/show")
	v.Vars["item"] = item
	v.Render(w, r)
}
```

### Model
```go
// ByID gets item by ID.
func ByID(db Connection, ID string, userID string) (Item, bool, error) {
	result := Item{}
	err := db.Get(&result, fmt.Sprintf(`
		SELECT id, name, user_id, created_at, updated_at, deleted_at
		FROM %v
		WHERE id = ?
			AND user_id = ?
			AND deleted_at IS NULL
		LIMIT 1
		`, table),
		ID, userID)
	return result, err == sql.ErrNoRows, err
}
```

## Get Items by User ID

Use **db.Select()** to get multiple items.

### Controller
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

### Model
```go
// ByUserID gets all entities for a user.
func ByUserID(db Connection, userID string) ([]Item, bool, error) {
	var result []Item
	err := db.Select(&result, fmt.Sprintf(`
		SELECT id, name, user_id, created_at, updated_at, deleted_at
		FROM %v
		WHERE user_id = ?
			AND deleted_at IS NULL
		`, table),
		userID)
	return result, err == sql.ErrNoRows, err
}
```

## Update an Item

Use **db.Exec()** to update one or more items.

### Controller
```go
// Update handles the edit form submission.
func Update(w http.ResponseWriter, r *http.Request) {
	c := flight.Context(w, r)

	if !c.FormValid("name") {
		Edit(w, r)
		return
	}

	_, err := note.Update(c.DB, r.FormValue("name"), c.Param("id"), c.UserID)
	if err != nil {
		c.FlashError(err)
		Edit(w, r)
		return
	}

	c.FlashSuccess("Item updated.")
	c.Redirect(uri)
}
```

### Model
```go
// Update makes changes to an existing item.
func Update(db Connection, name string, ID string, userID string) (sql.Result, error) {
	result, err := db.Exec(fmt.Sprintf(`
		UPDATE %v
		SET name = ?
		WHERE id = ?
			AND user_id = ?
			AND deleted_at IS NULL
		LIMIT 1
		`, table),
		name, ID, userID)
	return result, err
}
```

## Soft Delete an Item

A soft delete leaves the item in the database, but marks it as deleted with a
timestamp.

### Controller
```go
// Destroy handles the delete form submission.
func Destroy(w http.ResponseWriter, r *http.Request) {
	c := flight.Context(w, r)

	_, err := note.DeleteSoft(c.DB, c.Param("id"), c.UserID)
	if err != nil {
		c.FlashError(err)
	} else {
		c.FlashNotice("Item deleted.")
	}

	c.Redirect(uri)
}
```

### Model
```go
// Delete marks an item as removed.
func DeleteSoft(db Connection, ID string, userID string) (sql.Result, error) {
	result, err := db.Exec(fmt.Sprintf(`
		UPDATE %v
		SET deleted_at = NOW()
		WHERE id = ?
			AND user_id = ?
			AND deleted_at IS NULL
		LIMIT 1
		`, table),
		ID, userID)
	return result, err
}
```

## Hard Delete an Item

A hard delete removes the item from the database.

### Controller
```go
// Destroy handles the delete form submission.
func Destroy(w http.ResponseWriter, r *http.Request) {
	c := flight.Context(w, r)

	_, err := note.DeleteHard(c.DB, c.Param("id"), c.UserID)
	if err != nil {
		c.FlashError(err)
	} else {
		c.FlashNotice("Item deleted.")
	}

	c.Redirect(uri)
}
```

### Model
```go
// DeleteHard removes an item.
func DeleteHard(db Connection, ID string, userID string) (sql.Result, error) {
	result, err := db.Exec(fmt.Sprintf(`
		DELETE FROM %v
		WHERE id = ?
			AND user_id = ?
			AND deleted_at IS NULL
		`, table),
		ID, userID)
	return result, err
}
```

## PostgreSQL Support
To use PostgreSQL, you need to a few lines of code. The migration support is
not built into [Jay](https://github.com/blue-jay/jay) yet so you'll have to run
them manually.

Add the PostgreSQL structure to the env.json.example file:
```json
"PostgreSQL":{
	"Username":"root",
	"Password":"",
	"Database":"blueprint",
	"Hostname":"127.0.0.1",
	"Port":5432,
	"Parameter":"",
	"MigrationFolder":"migration/postgresql",
	"Extension":"sql"
},
```

Ensure the JSON is readable by to the **Info** struct in **lib/env** so add this
line:
```go
PostgreSQL postgresql.Info `json:"PostgreSQL"`
```

Add these lines to the **RegisterServices()** function in **lib/boot**:
```go
// Connect to the PostgreSQL database
postgresqldb, _ := config.PostgreSQL.Connect(true)
```

If you want to replace MySQL, you can change the line at the bottom of the
**RegisterServices()** function in **lib/boot** to pass PostgreSQL instead of
MySQL:
```go
// Store the database connection in flight
flight.StoreDB(postgresqldb)
```

If you want to add instead of replacing MySQL, you need to:
- Add a new function to the **lib/flight** package similar to **StoreDB()**
- And a new line to the **Info** struct in the **lib/flight**
- Add the new variable to the **Context()** function in **lib/flight**
