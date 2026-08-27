# Rails Wars

Practice challenges for Rails, in the spirit of Codewars. Pick a
challenge, run its tests, see them fail, write code until they pass.
Each challenge takes about 30 minutes and teaches one thing.

## What you need

- Ruby 3.2 or newer (this repo was built and tested on Ruby 4.0 with
  Rails 8.1)
- The Rails gem, for Phase 0 only: `gem install rails`
- SQLite (already on most systems)
- Internet, the first time you run each Phase 1 file (it installs its
  own gems)

## The order

Do the challenges in this order. Each one builds on the one before.

| # | Challenge | Where |
|---|-----------|-------|
| 1 | Generators and your first schema | `phase0/01_generators_and_your_first_schema.md` |
| 2 | Migrations without tears | `phase0/02_migrations_without_tears.md` |
| 3 | Associations | `01_associations.rb` |
| 4 | has_many :through | `02_has_many_through.rb` |
| 5 | Scopes | `03_scopes.rb` |

**Phase 0** (challenges 1–2): you build a small real Rails app called
`blog_practice`. You keep it — challenge 2 continues where challenge 1
stopped. Read the markdown brief, it tells you every step.

**Phase 1** (challenges 3–5): single Ruby files. They are not part of
any Rails app. There is nothing to install and nothing to set up. Run
one like this:

```bash
ruby 01_associations.rb
```

Edit only the section marked MODELS, then run it again.

## The rules

1. Run the tests **before** you write any code. Watch them fail first.
   Red before green — that is the whole method.
2. Never edit the tests or the schema. If the tests are wrong, tell us —
   do not "fix" them.
3. In Phase 0, do not edit `db/schema.rb` by hand. The tests read the
   real database, so it would not help you anyway.
4. When you are green, answer the questions at the end of the challenge.
   They are the real test. Be ready to explain your answers.

## Stuck?

Every challenge has hints, ordered from small nudge to almost the
answer. Read them one at a time, not all at once. If you are still
stuck after hint 4 and 30 minutes, stop and ask — that usually means we
wrote the challenge badly, and we want to know.
