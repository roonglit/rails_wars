# ----------------------------------------------------------------------------
# Challenge 03 — Scopes
# Time box: 30 minutes
# Run with:  ruby 03_scopes.rb
# ----------------------------------------------------------------------------
#
# BRIEF
#
# The blog's front page needs reusable queries: published articles, recent
# articles, popular articles, and a title search. Each one is a scope on
# Article. Scopes return relations, so they chain: Article.published.recent.
#
# Edit ONLY the MODELS section. The schema and the tests are off-limits.
#
# Note: outside a Rails app, `10.days.ago` needs ActiveSupport loaded by
# hand — that is what the two active_support requires below are for.
#
# ----------------------------------------------------------------------------

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"
  gem "activerecord", "~> 8.1"
  gem "sqlite3", "~> 2.9"
end

require "active_record"
require "active_support"
require "active_support/time" # Integer#days, Duration#ago, Time.current
require "minitest/autorun"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Migration.verbose = false

# ----------------------------------------------------------------------------
# SCHEMA — do not edit
# ----------------------------------------------------------------------------

ActiveRecord::Schema.define do
  create_table :articles do |t|
    t.string   :title, null: false
    t.datetime :published_at            # nil means draft
    t.integer  :views, null: false, default: 0
  end
end

# ----------------------------------------------------------------------------
# MODELS — the only section you may edit
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
# TESTS — do not edit. Ordered easy to hard.
# ----------------------------------------------------------------------------

class ScopesTest < Minitest::Test
  def self.test_order = :alpha

  def setup
    Article.delete_all

    @draft     = Article.create!(title: "Draft: untitled thoughts")
    @scheduled = Article.create!(title: "Big launch teaser",   published_at: 2.days.from_now)
    @old       = Article.create!(title: "Old Rails guide",     published_at: 40.days.ago, views: 500)
    @fresh     = Article.create!(title: "Fresh Ruby news",     published_at: 2.days.ago,  views: 10)
    @mid       = Article.create!(title: "Nine days of Rails",  published_at: 9.days.ago,  views: 100)
  end

  def test_1_published_excludes_drafts
    titles = Article.published.map(&:title)

    refute_includes titles, "Draft: untitled thoughts",
      "an article with no published_at is a draft — never show it"
    assert_includes titles, "Old Rails guide",
      "published articles must be in the published scope"
  end

  def test_2_published_excludes_scheduled_articles
    refute_includes Article.published.map(&:title), "Big launch teaser",
      "published_at in the future means scheduled, not published — " \
      "this is the one everybody forgets until a launch leaks early"
  end

  def test_3_recent_takes_a_window_in_days
    assert_equal ["Fresh Ruby news", "Nine days of Rails"], Article.recent(10).map(&:title).sort,
      "recent(10) means published_at inside the last 10 days"
    assert_equal ["Fresh Ruby news"], Article.recent.map(&:title),
      "with no argument, recent defaults to 7 days"
    refute_includes Article.recent(10).map(&:title), "Big launch teaser",
      "the future is not recent"
  end

  def test_4_popular_filters_and_orders
    assert_equal ["Old Rails guide", "Nine days of Rails"], Article.popular.map(&:title),
      "popular means 100 views or more, most viewed first — filter AND order"
  end

  def test_5_scopes_chain
    assert_equal ["Old Rails guide", "Nine days of Rails"],
      Article.published.recent(60).popular.map(&:title),
      "scopes must chain: each one returns a relation, so the next can refine it"
  end

  def test_6_search_with_a_blank_term_still_chains
    assert_equal ["Nine days of Rails", "Old Rails guide"], Article.search("rails").map(&:title).sort,
      "search matches the term anywhere in the title"
    assert_equal 5, Article.search(nil).count,
      "a nil term must return everything, not nothing"
    assert_equal 3, Article.search("").published.count,
      "search with a blank term must still chain — if this line raises " \
      "NoMethodError on nil, you wrote a class method that returns nil. " \
      "A scope never returns nil; that difference takes pages down in production."
  end
end

# ----------------------------------------------------------------------------
# When you are green, you should be able to answer:
#
# 1. Turn on the logger and run Article.published.recent(30).popular.
#    How many SQL queries is that? Where did the three WHEREs go?
# 2. Rewrite :popular as a class method (def self.popular). Which tests still
#    pass? Now make it return nil when there are no popular articles — what
#    breaks, and why does the scope version not break?
# 3. Delete the two active_support requires at the top and run the file.
#    What is the exact error, and which line of YOUR code triggers it?
# 4. Your recent scope computes N.days.ago in Ruby. When is that value frozen —
#    when the scope is defined, or every time it is called? Why does a lambda
#    matter here? (Hint: this bug ships to production constantly, in the form
#    `scope :recent, where("published_at > ?", 7.days.ago)` in old Rails.)
#
# Stretch (optional): add a scope :trending that combines recent(7) and
# popular without repeating their SQL.
# ----------------------------------------------------------------------------
