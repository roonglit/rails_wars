# ----------------------------------------------------------------------------
# Challenge 07 — Callbacks
# Time box: 30 minutes
# Run with:  ruby 07_callbacks.rb   (from the repo root)
# ----------------------------------------------------------------------------
#
# BRIEF
#
# Articles need housekeeping that must happen EVERY time, no matter which
# controller or console session touches them. That is what callbacks are
# for: code that runs at fixed points in a record's life — before
# validation, before save, before destroy.
#
# Four jobs: clean the title, build a slug, stamp the publish time, and
# protect locked articles from deletion.
#
# This is the ONLY file you edit. The schema and the tests live in
# 07_callbacks.rb — read them, they are the specification.
# There is nothing to install and nothing to set up. Just run the file.
#
# ----------------------------------------------------------------------------

class Article < ActiveRecord::Base
  # TODO: a title is required.
  #
  # TODO: strip the spaces off the ends of the title — and do it EARLY
  #       enough that a title of only spaces fails the required check.
  #       (There are two before_ callbacks that could hold this code.
  #       Only one of them passes test 2. Understanding why is the lesson.)
  #
  # TODO: on every save, build the slug from the title: downcase it, turn
  #       every run of characters that are not letters or digits into one
  #       "-", and leave no "-" at either end.
  #       "Hello, World!" -> "hello-world"
  #
  # TODO: when an article is saved as published, stamp published_at with
  #       the current time — but only if it has never been stamped.
  #       A publish date is a historical fact; editing the title next
  #       week must not move it.
  #
  # TODO: a locked article must refuse to be destroyed. Halting a
  #       callback chain has a special mechanism — returning false is
  #       not it (that stopped working in Rails 5).
end

# ----------------------------------------------------------------------------
# When you are green, you should be able to answer:
#
# 1. Put a puts in each of your callbacks and create one article. Write
#    down the exact order they fire in, together with validation. Now you
#    know the real lifecycle — most people only think they do.
# 2. Why does the title-stripping code pass test 2 in before_validation
#    but fail it in before_save? Move it and watch.
# 3. Change a title with update_column instead of update. Which of your
#    callbacks ran? What does the slug say now? So what kind of bug does
#    update_column invite, and why does it exist anyway?
# 4. What does destroy RETURN when your before_destroy halts it — false,
#    nil, or an exception? What does destroy! do instead? Which one does
#    a controller want?
#
# Stretch (optional): the slug of a published article should never change,
# even when the title does — links to it are already out in the world.
# Make it so, without breaking test 3. (Look up saved_change_to_ /
# will_save_change_to_ dirty helpers.)
# ----------------------------------------------------------------------------
