# 02 — Migrations without tears

- **Time box:** 30 minutes
- **Verified by:** copy `phase0/migration_test.rb` into `test/models/`, run
  `bin/rails test test/models/migration_test.rb`, then the three runner
  commands at the bottom

## Brief

Your blog from challenge 01 is "live" now. It has real data. You need to
change the schema four times **without losing a single row**. This is the
whole job of migrations: changing a database that people are already using.

Off-limits: `bin/rails db:reset`, `db:drop`, deleting the database file,
and editing `db/schema.rb` by hand. In production you do not get to start
over, so here you do not either.

## Setup: put real data in first

Replace `db/seeds.rb` with this, then run `bin/rails db:seed`:

```ruby
Article.create!([
  { title: "Getting started with Rails", body: "The first steps." },
  { title: "Understanding migrations",   body: "Schema changes over time." },
  { title: "A tour of Active Record",    body: "Models and queries." }
])
Comment.create!(article: Article.first, author_name: "Dara", body: "Very helpful!")
```

Check it worked: `bin/rails runner 'puts Article.count'` prints 3.
That data must still be there at the end.

## The challenge

Write **four separate migrations**, in this order, running each one
before writing the next:

1. Articles get a `slug` column (short text).
2. Every existing article gets its slug filled in from its title
   (`"Getting started with Rails"` → `"getting-started-with-rails"`),
   and the column gets a **unique index**. Data change and index, one
   migration.
3. In comments, `author_name` was a bad name. Rename it to
   `commenter_name`. Dara's comment must survive with her name intact.
4. Articles get a `views` counter: integer, default 0, and NOT NULL.
   Every **existing** article starts at 50 views, not 0. New articles
   start at 0.

One warning: migration 3 breaks your test data. The file
`test/fixtures/comments.yml` still says `author_name`, and fixtures do
not migrate themselves. After migration 3, rename the key in that file
too, or every test in the app fails while your schema is correct.

## Verify

```bash
cp ../phase0/migration_test.rb test/models/
bin/rails test test/models/migration_test.rb

bin/rails runner 'puts Article.count'         # => 3    seeds survived
bin/rails runner 'puts Article.sum(:views)'   # => 150  the backfill worked
bin/rails runner 'puts Comment.first.commenter_name'  # => Dara
```

The runner commands matter: `rails test` runs against a fresh test
database that never saw your seeds, so only the development database can
prove your data survived. The test file checks the schema; the runner
commands check the data.

## Hints, in order of desperation

1. `bin/rails generate migration AddSlugToArticles slug:string` — the
   generator parses the name and writes most of the migration for you.
2. For the backfill, a migration is just Ruby: loop over
   `Article.find_each` inside `def up`. Look up `String#parameterize`.
3. Renaming is one line: `rename_column :comments, :author_name,
   :commenter_name`. Rails moves the data for you.
4. Migration 4 in order: `add_column ... default: 0, null: false`, then
   `Article.update_all(views: 50)`. If Article behaves strangely inside a
   migration, look up `reset_column_information`.

## When you are green, you should be able to answer

1. `bin/rails db:migrate:status` — what does the `up` / `down` column
   mean, and where does Rails store it?
2. Why did migration 4 need `default: 0` for `null: false` to work on a
   table that already had rows?
3. Run `bin/rails db:rollback`, then `bin/rails db:migrate`. The sum of
   views is 150 again. Now imagine the site had been live and the
   articles had real view counts. What did the rollback destroy, and why
   can `db:migrate` only bring back the 50s, never the real numbers?
4. Try `Article.create!(title: "x", slug: Article.first.slug)`. What
   error do you get, and which of your four migrations is speaking?
5. In migration 2, why is filling the slugs and adding the unique index
   in **that order** the only order that works?

## Stretch (optional)

Run `bin/rails db:rollback STEP=4`, then `bin/rails db:migrate`. Every
migration must come back cleanly. If one of yours cannot roll back, fix
it with a proper `def up` / `def down` pair.
