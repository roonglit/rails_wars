# Companion test for Phase 0, challenge 01.
# Copy into test/models/ and run:  bin/rails test test/models/schema_test.rb
#
# It reads the real database schema — columns, indexes, foreign keys.
# You cannot make it green by editing db/schema.rb by hand.

require "test_helper"

class SchemaTest < ActiveSupport::TestCase
  def conn
    ActiveRecord::Base.lease_connection
  end

  def column(table, name)
    conn.columns(table).find { |c| c.name == name.to_s }
  end

  test "1: the articles table exists" do
    assert conn.table_exists?(:articles),
      "no articles table yet — generate the Article model and migrate"
  end

  test "2: articles.title is a string and required at the database level" do
    assert conn.table_exists?(:articles), "generate the Article model first"
    col = column(:articles, :title)
    assert col, "articles has no title column"
    assert_equal :string, col.type, "title must be a string"
    refute col.null,
      "title must be NOT NULL — the generator does not add this, you edit the migration"
  end

  test "3: articles.body is text and articles.published_at is a nullable datetime" do
    assert conn.table_exists?(:articles), "generate the Article model first"
    body = column(:articles, :body)
    assert body, "articles has no body column"
    assert_equal :text, body.type, "body must be text, not string — it holds long content"

    published_at = column(:articles, :published_at)
    assert published_at, "articles has no published_at column"
    assert_equal :datetime, published_at.type, "published_at must be a datetime"
    assert published_at.null, "published_at must allow null — drafts have no date"
  end

  test "4: articles has timestamps" do
    assert conn.table_exists?(:articles), "generate the Article model first"
    assert column(:articles, :created_at), "articles has no created_at — did you remove t.timestamps?"
    assert column(:articles, :updated_at), "articles has no updated_at — did you remove t.timestamps?"
  end

  test "5: comments.article_id exists and is required" do
    assert conn.table_exists?(:comments),
      "no comments table yet — generate the Comment model and migrate"
    col = column(:comments, :article_id)
    assert col, "comments has no article_id — a comment must point at its article"
    refute col.null, "article_id must be NOT NULL — a comment without an article is an orphan"
  end

  test "6: comments.article_id is indexed" do
    assert conn.table_exists?(:comments), "generate the Comment model first"
    assert conn.indexes(:comments).any? { |i| i.columns == ["article_id"] },
      "comments.article_id needs an index — every belongs_to column does, " \
      "or listing an article's comments gets slower with every row"
  end

  test "7: comments has a real foreign key to articles" do
    assert conn.table_exists?(:comments), "generate the Comment model first"
    assert conn.foreign_keys(:comments).any? { |fk| fk.to_table == "articles" },
      "comments needs a database foreign key to articles — " \
      "the database is the last line of defense against orphaned rows"
  end
end
