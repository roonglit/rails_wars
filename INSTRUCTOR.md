# Instructor guide

How to run Rails Wars with a group of juniors. Learners: this file is
not for you, and reading it will not help you pass anything.

## How the system works (30 seconds)

Each junior gets their own private copy of this repo via GitHub's
template feature. Every push runs `.github/workflows/grade.yml` in
their repo, which fetches the **official** challenges and grader from
`roonglit/rails_wars` and grades only their editable sections against
pristine tests. Editing tests in their copy does nothing. Untouched
challenges report "not started" and do not fail the run, so a fresh
repo is green.

## One-time setup (already done — recorded here for the future)

- `roonglit/rails_wars` is **public** (required: learner repos fetch the
  grader from it), is a **template repository**, default branch `main`.
- Reference solutions live in `solutions/`, which is gitignored — they
  exist only on the instructor machine. Keep a private backup.

## Onboarding a new junior

1. Send them the link: `github.com/roonglit/rails_wars`.
2. They click **Use this template → "Create a new repository"**.
   Warn them: NOT "Open in a codespace" — that creates no repository,
   just a throwaway cloud editor.
3. Name: anything (suggest `rails-wars-<name>`). Visibility: **Private**.
4. They add you as a collaborator: repo → Settings → Collaborators.
5. Add their `owner/repo` to your `repos.txt` (one per line).

That is the whole ceremony. Their first workflow run happens on repo
creation and should be green with five "not started".

## Checking progress

Per repo: the **Actions** tab → latest `grade` run → the run's summary
page shows a table, one row per challenge, plus failure output.

All repos at once (needs `gh auth login` once):

```bash
grader/status.sh -f repos.txt
```

Prints one line per junior: `green`, `RED`, or `no runs`.

## Grading locally (trust anchor / debugging)

```bash
git clone <their-repo> /tmp/junior && \
  ruby grader/grader.rb --learner /tmp/junior
```

Same grader, same result as CI. Useful when a junior says "it works on
my machine" — run it and read the failure output together.

## When a junior disputes a red

1. Run the grader locally on their clone (above).
2. Read the failing assertion message — they are written as guidance.
3. If the challenge itself is at fault: fix the challenge, never weaken
   the test. Follow the verification protocol in `CLAUDE.md` (red
   against stub, green against solution) before pushing the fix.
   Learner repos pick up the fix automatically on their next push,
   because the grader always comes from `main` of this repo.

## Changing or adding challenges

Follow `CLAUDE.md` — it is the maintainer manual (structure, writing
conventions, verification protocol). Two rules interact with grading:

- The grader finds Phase 1 challenges by filename (`grader/grader.rb`,
  `PHASE1` list). Each challenge is a runner `NN_topic.rb` plus the
  learner file `models/NN_topic.rb`; the grader copies only the
  learner's models file next to the official runner. Keep that pairing
  when adding a challenge, and add the filename to the list.
- Push to `main` only when verified: every learner's next push grades
  against whatever is on `main`.

## Answers, not just green

The auto-grader checks the code. The closing questions in each
challenge check the understanding — they are designed to be
unanswerable without having done the work. Ask each junior two or three
of them after each green, in person or in chat. That conversation is
where the teaching happens; the grader just frees you from checking
syntax.
