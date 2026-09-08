# ----------------------------------------------------------------------------
# Challenge 06 — Single Table Inheritance
# Time box: 30 minutes
# Run with:  ruby 06_sti.rb   (from the repo root)
# ----------------------------------------------------------------------------
#
# BRIEF
#
# The blog outgrew plain posts. It now publishes two kinds of content:
# Articles (which have a body) and Videos (which have a duration). They
# share almost everything — a title, a published flag, the same table.
#
# Look at the schema in the runner: ONE table, `contents`, with a `type`
# column. That column is magic to Rails: it stores the class name, and it
# turns one table into a family of models. This is Single Table
# Inheritance (STI).
#
# Your job: a Content base class and two subclasses, Article and Video.
# Shared rules live on the parent, written once. Each subclass adds only
# what is its own.
#
# This is the ONLY file you edit. The schema and the tests live in
# 06_sti.rb — read them, they are the specification. (Yes, the tests use
# classes that do not exist yet. Creating them is the challenge.)
# There is nothing to install and nothing to set up. Just run the file.
#
# ----------------------------------------------------------------------------

class Content < ActiveRecord::Base
  # TODO: every content needs a title. Write this rule ONCE, here —
  #       the tests check that it is not copy-pasted into the subclasses.
  #
  # TODO: scope :published — contents whose published flag is true.
  #       You write it once, here. Watch what happens when a subclass
  #       calls it.
end

# TODO: class Article — an article needs a body.
#       Careful with what it inherits from. `< ActiveRecord::Base` will
#       send Rails looking for an `articles` table that does not exist.

# TODO: class Video — a video needs a duration_seconds.

# ----------------------------------------------------------------------------
# When you are green, you should be able to answer:
#
# 1. Turn on the logger — add ActiveRecord::Base.logger = Logger.new($stdout)
#    at the top of THIS file — and run Video.all. There is a WHERE clause
#    you never wrote. What is it, and who added it?
# 2. Add class Tutorial < Article (two lines, try it). Create a Tutorial,
#    then run Article.all. Is the tutorial in it? Look at the SQL — what
#    did the type filter become?
# 3. The contents table has a duration_seconds column that every Article
#    leaves NULL, and a body column that every Video leaves NULL. That is
#    the price of STI. At what point — how many subclasses, how many
#    one-kind-only columns — would you stop using STI, and what would you
#    use instead?
# 4. Someone edits the database by hand and sets a row's type to "Essay".
#    What happens the next time Content.all loads that row? Try it:
#    Content.first.update_column(:type, "Essay") and then Content.all.
#    (update_column skips validations — that is how bad data sneaks in.)
#
# Stretch (optional): give Content a `teaser` method that returns
# "#{title} (article)" for articles and "#{title} (video, Ns)" for videos —
# WITHOUT a single is_a? or case statement anywhere. Subclasses overriding
# one method is the other half of what STI buys you.
# ----------------------------------------------------------------------------
