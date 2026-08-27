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

**Phase 1** (challenges 3–5): plain Ruby, no Rails app, nothing to
install or set up. Each challenge is two files:

- `models/01_associations.rb` — **the only file you edit.** The brief
  and your empty models are here.
- `01_associations.rb` — the runner: schema and tests. Do not edit it,
  but do read it — the tests are the specification.

Run a challenge from the repo root, then edit your models file, then
run again:

```bash
ruby 01_associations.rb
```

## The rules

1. Run the tests **before** you write any code. Watch them fail first.
   Red before green — that is the whole method.
2. Never edit the tests or the schema. If the tests are wrong, tell us —
   do not "fix" them.
3. In Phase 0, do not edit `db/schema.rb` by hand. The tests read the
   real database, so it would not help you anyway.
4. When you are green, answer the questions at the end of the challenge.
   They are the real test. Be ready to explain your answers.

## Submitting your work

Commit and push to `main`. That is the whole submission — the grader
runs by itself on every push. Open the **Actions** tab of your repo to
see your grade: green check means pass, and the run's summary page shows
a table with one row per challenge.

The grader fetches the official tests and runs your code against those,
never against the copies in your repo. So editing the tests does
nothing — the only way to green is to do the work. (That is also how
Codewars does it.)

For Phase 0, commit the whole `blog_practice` folder. The grader runs
its tests in there.

## Stuck?

Every challenge has hints, ordered from small nudge to almost the
answer. Read them one at a time, not all at once. If you are still
stuck after hint 4 and 30 minutes, stop and ask — that usually means we
wrote the challenge badly, and we want to know.
