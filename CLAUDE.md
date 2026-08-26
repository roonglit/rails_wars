# CLAUDE.md

## What this repo is

A set of Rails practice challenges for junior developers, in the spirit of
Codewars: pick a challenge, get failing tests, write code until green. Roughly
30 minutes each, one concept per challenge.

The audience is **fresh juniors** — they know Ruby, they are shaky on Rails
conventions. English is a second language for most of them, so briefs are
written in short, plain sentences.

Challenges are inspired by RailsCasts: each one teaches a single topic that
stands on its own.

---

## Structure

### Phase 0 — generators and the app itself (`phase0/`)

Real Rails apps. Learners run `rails new`, `rails generate`, `rails db:migrate`.
This is where they learn where files live and how to change a schema without
destroying data.

- Each challenge is a markdown brief.
- Most ship a companion test file that the learner copies into `test/models/`.
- The tests **introspect the schema** (`connection.columns`, `.indexes`,
  `.foreign_keys`) rather than testing behaviour. This is deliberate: it makes
  generator work auto-gradeable, and it means a learner cannot cheat by
  hand-editing `db/schema.rb`.

Learners run `rails new` exactly twice across the whole phase. Everything else
happens in one practice app (`blog_practice`) that grows. Repeated `rails new`
teaches nothing and burns four minutes of `bundle install` per challenge.

### Phase 1 — ActiveRecord semantics (repo root, `NN_topic.rb`)

Single self-contained Ruby files. No Rails app at all.

- `bundler/inline` installs gems
- in-memory SQLite
- schema defined inline and marked *do not edit*
- model stubs with `TODO` comments — the only editable section
- failing Minitest assertions

Run with `ruby 01_associations.rb`. Boots in about a second.

The app is deliberately absent here. By this point schema-building is a solved
skill and the app is noise; the point is model-layer semantics.

### Phase 2 — not yet written

Controllers, Turbo Frames, Turbo Streams, Stimulus, background jobs. These need
a full request cycle, so they go back to a real app: one seeded repo, one branch
per challenge.

---

## Hard rules

1. **Never weaken a test to make it pass.** If a test cannot go green, the
   challenge is wrong — fix the brief, the schema, or the stub. The tests are
   the specification.
2. **Every challenge must be verified in both directions.** Red against the
   stub, green against a reference solution. A challenge that is already green
   before the learner writes anything is broken.
3. **Reference solutions live in `solutions/`**, mirroring the challenge
   filenames. `solutions/` is gitignored so learners do not stumble on it.
4. **Do not add a test that a competent junior cannot satisfy in 30 minutes.**
   If a challenge consistently overruns, split it rather than trimming the
   questions.
5. Pin gem versions to whatever Rails version is installed locally. Check
   first; do not assume.

---

## Writing conventions

### Phase 0 brief

```
Header (number, topic, time box, how it is verified)
Brief — the situation in 3-4 sentences, and what is off-limits
The commands to run
The challenge proper
Hints, in order of desperation  (4 hints, increasingly explicit)
When you are green, you should be able to answer  (5 questions)
Stretch  (one extension, explicitly optional)
```

### Phase 1 file

```
Header comment block (number, topic, time box, run command)
BRIEF
SCHEMA          — do not edit
MODELS          — TODO stubs, the only editable section
TESTS           — do not edit, ordered easy to hard
Closing comment: 4 questions + stretch
```

### In both

- The last two or three assertions should push past the obvious case into
  something that actually bites people in production.
- Questions must be answerable only by having done the work — not lookup-able.
  Prefer "turn the logger on and confirm" over "what does X mean".
- Assertion failure messages are teaching moments. Write them as guidance
  (`"published_at must allow null — drafts have no date"`), not as
  `"Expected true, got false"`.
- Hints escalate: hint 1 points at the docs, hint 4 nearly gives it away.

---

## Verification protocol

When adding or changing a challenge:

```
1. Run it against the stub          → must be RED, and must not crash
2. Write the reference solution     → solutions/NN_topic.rb
3. Run it against the solution      → must be GREEN
4. Time yourself doing it cold      → if over ~20 min for you, it is over
                                       30 for a junior; split it
```

For Phase 0, this means actually creating a scratch app, running the
generators, and copying the test file in — not reasoning about whether it would
work.

Report failures honestly. A challenge that does not run is worse than no
challenge, because it burns the learner's whole time box on our bug.