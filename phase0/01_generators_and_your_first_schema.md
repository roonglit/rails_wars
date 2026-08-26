# 01 — Generators and your first schema

- **Time box:** 30 minutes
- **Verified by:** copy `phase0/schema_test.rb` into `test/models/`, then `bin/rails test test/models/schema_test.rb`

## Brief

You are starting a blog. There is no code yet. You will create the app,
then use generators to build two tables: articles and comments.

Off-limits: do not edit `db/schema.rb` by hand. The test reads the real
database, so hand-editing the schema file will not help you anyway.

## The commands to run

```bash
rails new blog_practice
cd blog_practice
# ... your generator commands go here ...
bin/rails db:migrate
# then copy the test in and run it:
cp ../phase0/schema_test.rb test/models/
bin/rails test test/models/schema_test.rb
```

Copy the test in **before** you generate anything, if you want to see it
fail first. Red before green is the honest order.

## The challenge

Make the test green by generating two models:

1. **Article** — a title (short text), a body (long text), and a
   `published_at` date-and-time. A draft has no `published_at`, so that
   column must allow null. The title must be **required at the database
   level**. The generator will not do that part for you.
2. **Comment** — belongs to an article, and has an `author_name` (short
   text) and a `body` (long text). The link to the article must have a
   foreign key and an index.

## Hints, in order of desperation

1. `bin/rails generate model --help` shows the column syntax.
2. Short text is `string`, long text is `text`, date-and-time is
   `datetime`. A link to another table is `references`.
3. "Required at the database level" means `null: false` on the column.
   Open the migration file the generator created, edit it, **then** run
   `bin/rails db:migrate`.
4. `article:references` gives you the foreign key, the index, and the
   `null: false` all at once. That is why it exists.

## When you are green, you should be able to answer

1. Open `db/schema.rb`. Where did this file come from? Who wrote it?
2. Run `bin/rails db:migrate` a second time. Why does nothing happen?
3. Look at the migration timestamps in `db/migrate/`. Why are migration
   files named with timestamps instead of 1, 2, 3?
4. In `bin/rails dbconsole`, run `.schema comments`. Which parts of that
   SQL did `article:references` produce?
5. You edited a migration before running it. When is editing a migration
   after running it a bad idea, and what do you do instead?

## Stretch (optional)

Delete `db/development.sqlite3`, then bring the whole database back with
one command. Which command did you pick, and what is the difference
between `db:migrate` and `db:schema:load`?
