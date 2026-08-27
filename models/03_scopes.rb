# ----------------------------------------------------------------------------
# Challenge 03 — Scopes
# Time box: 30 minutes
# Run with:  ruby 03_scopes.rb   (from the repo root)
# ----------------------------------------------------------------------------
#
# BRIEF
#
# The blog's front page needs reusable queries: published articles, recent
# articles, popular articles, and a title search. Each one is a scope on
# Article. Scopes return relations, so they chain: Article.published.recent.
#
# This is the ONLY file you edit. The schema and the tests live in
# 03_scopes.rb — read them, they are the specification.
# There is nothing to install and nothing to set up. Just run the file.
#
# ----------------------------------------------------------------------------

class Article < ActiveRecord::Base
  # TODO: scope :published — published_at is set AND is not in the future.
  #       (A scheduled article is not published yet.)
  #
  # TODO: scope :recent — takes a number of days, default 7. Articles whose
  #       published_at falls inside the last N days. The future never counts
  #       as recent.
  #
  # TODO: scope :popular — 100 views or more, most viewed first.
  #
  # TODO: scope :search — takes a term, matches it anywhere in the title.
  #       A blank or nil term returns everything — and the result must still
  #       chain with the other scopes.
end

# ----------------------------------------------------------------------------
# When you are green, you should be able to answer:
#
# 1. Turn on the logger — add ActiveRecord::Base.logger = Logger.new($stdout)
#    at the top of THIS file — and run Article.published.recent(30).popular.
#    How many SQL queries is that? Where did the three WHEREs go?
# 2. Rewrite :popular as a class method (def self.popular). Which tests still
#    pass? Now make it return nil when there are no popular articles — what
#    breaks, and why does the scope version not break?
# 3. Comment out the two active_support requires at the top of 03_scopes.rb
#    (the runner) and run the file. What is the exact error, and which line of
#    YOUR code triggers it? Put them back after.
# 4. Your recent scope computes N.days.ago in Ruby. When is that value frozen —
#    when the scope is defined, or every time it is called? Why does a lambda
#    matter here? (Hint: this bug ships to production constantly, in the form
#    `scope :recent, where("published_at > ?", 7.days.ago)` in old Rails.)
#
# Stretch (optional): add a scope :trending that combines recent(7) and
# popular without repeating their SQL.
# ----------------------------------------------------------------------------
