# ----------------------------------------------------------------------------
# Challenge 04 — Validations
# Time box: 30 minutes
# Run with:  ruby 04_validations.rb   (from the repo root)
# ----------------------------------------------------------------------------
#
# BRIEF
#
# The blog is opening signups. A User has a name, an email, a username, and
# an optional age. Bad data must never reach the database — that is what
# validations are for. All the rules live in the model, below.
#
# This is the ONLY file you edit. The schema and the tests live in
# 04_validations.rb — read them, they are the specification.
# There is nothing to install and nothing to set up. Just run the file.
#
# ----------------------------------------------------------------------------

class User < ActiveRecord::Base
  # TODO: name and email are required.
  #
  # TODO: email must look like an email address. Do not chase a perfect
  #       regex — "something, an @, something" is what the tests want.
  #
  # TODO: age must be 13 or more — but age is optional. A missing age is
  #       fine; a wrong age is not.
  #
  # TODO: username must be unique, and "SamDoe" and "samdoe" count as the
  #       same username.
  #
  # TODO: the usernames "admin" and "root" are reserved. Reject them, and
  #       attach the error to :username. ("administrator" is fine — the
  #       list is exact, not a substring match.)
end

# ----------------------------------------------------------------------------
# When you are green, you should be able to answer:
#
# 1. Turn on the logger — add ActiveRecord::Base.logger = Logger.new($stdout)
#    at the top of THIS file — and call User.new(...).valid?. Exactly one of
#    your validations runs a SQL query. Which one, and why can't it work
#    without the database?
# 2. Two requests create the same username at the same instant. Both call
#    valid?, both see "no such username yet", both save. What actually stops
#    this in a real app? (Hint: you built one in Phase 0, and it is not in
#    this file.)
# 3. What is the difference between save and save! when a record is invalid?
#    Which exception does create! raise, and what is in its message?
# 4. user.errors[:email] vs user.errors.full_messages — try both on a user
#    that fails two rules at once. When would a form need one over the other?
#
# Stretch (optional): make email case-insensitive too — but instead of
# validating, normalize it: every email should be stored downcased, no matter
# how it was typed. (Rails has a one-liner for this since 7.1.)
# ----------------------------------------------------------------------------
