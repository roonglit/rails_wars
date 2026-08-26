# Companion test for Phase 0, challenge 02.
# Copy into test/models/ and run:  bin/rails test test/models/migration_test.rb
#
# This file checks the schema. It cannot check that your development data
# survived — the test database never saw your seeds. The runner commands in
# the brief are the other half of the verification. Run both.

require "test_helper"

class MigrationTest < ActiveSupport::TestCase
  def conn
    ActiveRecord::Base.lease_connection
  end

  def column(table, name)
    conn.columns(table).find { |c| c.name == name.to_s }
  end

  test "1: articles has a slug string column" do
    col = column(:articles, :slug)
    assert col, "articles has no slug column — migration 1"
    assert_equal :string, col.type, "slug must be a string"
  end

  test "2: slug has a unique index" do
    idx = conn.indexes(:articles).find { |i| i.columns == ["slug"] }
    assert idx, "articles.slug has no index — migration 2"
    assert idx.unique,
      "the slug index must be UNIQUE — two articles at the same URL is a production incident"
  end

  test "3: comments.author_name was renamed to commenter_name" do
    assert column(:comments, :commenter_name),
      "comments has no commenter_name column — migration 3"
    refute column(:comments, :author_name),
      "author_name must be gone. Rename the column — do not add a new one " \
      "and drop the old one, that throws the data away"
  end

  test "4: views is NOT NULL with a default of 0" do
    col = column(:articles, :views)
    assert col, "articles has no views column — migration 4"
    refute col.null, "views must be NOT NULL — a null counter breaks every sum and sort"
    assert_equal 0, Article.new.views,
      "a brand new article must start with views = 0 — that is what the default is for"
  end

  test "5: the database itself rejects a null views" do
    assert column(:articles, :views), "articles has no views column — migration 4"
    assert_raises(ActiveRecord::NotNullViolation,
      "inserting views = nil must be stopped by the database, not by a model validation — " \
      "constraints protect you from every writer, not just this app") do
      Article.create!(title: "Sneaky", views: nil)
    end
  end
end
