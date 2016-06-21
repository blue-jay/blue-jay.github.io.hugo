---
date: 2016-03-08T21:07:13+01:00
title: Models
weight: 50
---

## Basic Usage

It's a good idea to abstract the database layer out so if you need to make 
changes, you don't have to look through business logic to find the queries. All
the queries are stored in the **model** folder.

Blue Jay supports MySQL by default, but can easily be expanded to use other
database systems.

## Connect to the database

You only need to connect to the database once. The connection pool is
automatically handled by the [go-sql-driver/mysql](https://github.com/go-sql-driver/mysql)
package.

```go
// Connect to database
database.Connect(config.Database)
```

## Create an Item

Use **database.SQL.Exec()** to create an item or a table.

### Controller
```go
_, err := note.Create(r.FormValue("note"), userID)
if err != nil {
	log.Println(err)
	sess.AddFlash(flash.Info{"An error occurred on the server. Please try again later.", flash.Error})
	sess.Save(r, w)
	Create(w, r)
	return
}
```

### Model
```go
// Create adds an item
func Create(content string, userID string) (sql.Result, error) {
	result, err := database.SQL.Exec(fmt.Sprintf(`
		INSERT INTO %v
		(content, user_id)
		VALUES
		(?,?)
		`, table),
		content, userID)
	return result, model.StandardError(err)
}
```

## Get an Item by Item ID

Use **database.SQL.Get()** to get a single item.

### Controller
```go
item, err := note.ByID(params.ByName("id"), userID)
if err != nil { // If the note doesn't exist
	log.Println(err)
	sess.AddFlash(flash.Info{"An error occurred on the server. Please try again later.", flash.Error})
	sess.Save(r, w)
	http.Redirect(w, r, uri, http.StatusFound)
	return
}
```

### Model
```go
// ByID gets item by ID
func ByID(ID string, userID string) (Item, error) {
	result := Item{}
	err := database.SQL.Get(&result, fmt.Sprintf(`
		SELECT id, content, user_id, created_at, updated_at, deleted_at
		FROM %v
		WHERE id = ?
			AND user_id = ?
			AND deleted_at IS NULL
		LIMIT 1
		`, table),
		ID, userID)
	return result, model.StandardError(err)
}
```

## Get Items by User ID

Use **database.SQL.Select()** to get multiple items.

### Controller
```go
items, err := note.ByUserID(userID)
if err != nil {
	log.Println(err)
	sess.AddFlash(flash.Info{"An error occurred on the server. Please try again later.", flash.Error})
	sess.Save(r, w)
	items = []note.Item{}
}
```

### Model
```go
// ByUserID gets all items for a user
func ByUserID(userID string) ([]Item, error) {
	var result []Item
	err := database.SQL.Select(&result, fmt.Sprintf(`
		SELECT id, content, user_id, created_at, updated_at, deleted_at
		FROM %v
		WHERE user_id = ?
			AND deleted_at IS NULL
		`, table),
		userID)
	return result, model.StandardError(err)
}
```

## Update an Item

Use **database.SQL.Exec()** to update one or more items.

### Controller
```go
_, err := note.Update(r.FormValue("note"), params.ByName("id"), userID)
if err != nil {
	log.Println(err)
	sess.AddFlash(flash.Info{"An error occurred on the server. Please try again later.", flash.Error})
	sess.Save(r, w)
	Edit(w, r)
	return
}
```

### Model
```go
// Update makes changes to an existing item
func Update(content string, ID string, userID string) (sql.Result, error) {
	result, err := database.SQL.Exec(fmt.Sprintf(`
		UPDATE %v
		SET content = ?
		WHERE id = ?
			AND user_id = ?
			AND deleted_at IS NULL
		LIMIT 1
		`, table),
		content, ID, userID)
	return result, model.StandardError(err)
}
```

## Soft Delete an Item

A soft delete leaves the item in the database, but marks it as deleted with a
timestamp.

### Controller
```go
_, err := note.Delete(params.ByName("id"), userID)
if err != nil {
	log.Println(err)
	sess.AddFlash(flash.Info{"An error occurred on the server. Please try again later.", flash.Error})
	sess.Save(r, w)
} else {
	sess.AddFlash(flash.Info{"Item deleted.", flash.Notice})
	sess.Save(r, w)
}
```

### Model
```go
// Delete marks an item as removed
func Delete(ID string, userID string) (sql.Result, error) {
	result, err := database.SQL.Exec(fmt.Sprintf(`
		UPDATE %v
		SET deleted_at = NOW()
		WHERE id = ?
			AND user_id = ?
			AND deleted_at IS NULL
		LIMIT 1
		`, table),
		ID, userID)
	return result, model.StandardError(err)
}
```

## Hard Delete an Item

A hard delete removes the item from the database.

### Controller
```go
_, err := note.DeleteHard(params.ByName("id"), userID)
if err != nil {
	log.Println(err)
	sess.AddFlash(flash.Info{"An error occurred on the server. Please try again later.", flash.Error})
	sess.Save(r, w)
} else {
	sess.AddFlash(flash.Info{"Item deleted.", flash.Notice})
	sess.Save(r, w)
}
```

### Model
```go
// Delete removes an item
func DeleteHard(ID string, userID string) (sql.Result, error) {
	result, err := database.SQL.Exec(fmt.Sprintf(`
		DELETE FROM %v
		WHERE id = ?
			AND user_id = ?
			AND deleted_at IS NULL
		`, table),
		ID, userID)
	return result, model.StandardError(err)
}
```

## Handling Errors

You can define your own errors for your models in the
[model](https://github.com/blue-jay/blueprint/blob/master/model/model.go)
package. This is another abstraction that makes it easy to change out database
systems without having to rewrite code in your controllers.

You can manage the errors like this:

```go
var (
	// ErrNoResult is when no results are found
	ErrNoResult = errors.New("Result not found.")
)

// StrandardError returns a model defined error
func StandardError(err error) error {
	if err == sql.ErrNoRows {
		return ErrNoResult
	}

	return err
}
```

In your controller, you can check the error like this:

```go
if err == model.ErrNoResult {
	sess.AddFlash(flash.Info{"Password is incorrect", flash.Warning})
	sess.Save(r, w)
}
```