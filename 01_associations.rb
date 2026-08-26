# ----------------------------------------------------------------------------
# Challenge 01 — Associations: belongs_to and has_many
# Time box: 30 minutes
# Run with:  ruby 01_associations.rb
# ----------------------------------------------------------------------------
#
# BRIEF
#
# A tiny blog. Authors write posts. Readers leave comments on posts.
# The tables already exist. The models below are empty.
# Wire the models together so all tests pass.
#
# Edit ONLY the MODELS section. The schema and the tests are off-limits.
#
# ----------------------------------------------------------------------------

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"
  gem "activerecord", "~> 8.1"
  gem "sqlite3", "~> 2.9"
end

require "active_record"
require "minitest/autorun"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.belongs_to_required_by_default = true # same default as a real Rails app
ActiveRecord::Migration.verbose = false

# ----------------------------------------------------------------------------
# SCHEMA — do not edit
# ----------------------------------------------------------------------------

ActiveRecord::Schema.define do
  create_table :authors do |t|
    t.string :name, null: false
  end

  create_table :posts do |t|
    t.string :title, null: false
    t.integer :author_id
  end

  create_table :comments do |t|
    t.text :body, null: false
    t.integer :post_id
  end
end

# ----------------------------------------------------------------------------
# MODELS — the only section you may edit
# ----------------------------------------------------------------------------

class Author < ActiveRecord::Base
  # TODO: an author has many posts.
  # TODO: when an author is destroyed, their posts must go too.
end

class Post < ActiveRecord::Base
  # TODO: a post belongs to an author.
  # TODO: a post has many comments.
  # TODO: when a post is destroyed, its comments must go too.
end

class Comment < ActiveRecord::Base
  # TODO: a comment belongs to a post.
end

# ----------------------------------------------------------------------------
# TESTS — do not edit. Ordered easy to hard.
# ----------------------------------------------------------------------------

class AssociationsTest < Minitest::Test
  def self.test_order = :alpha

  def setup
    Comment.delete_all
    Post.delete_all
    Author.delete_all

    @arya  = Author.create!(name: "Arya")
    @brin  = Author.create!(name: "Brin")
    @post  = Post.create!(title: "Hello", author_id: @arya.id)
    @other = Post.create!(title: "Bye", author_id: @brin.id)
  end

  def test_1_author_has_many_posts
    assert_equal ["Hello"], @arya.posts.map(&:title),
      "Author#posts must return only that author's posts"
  end

  def test_2_post_belongs_to_author
    assert_equal "Arya", @post.author.name,
      "Post#author must return the Author the post belongs to"
  end

  def test_3_creating_through_the_association_sets_the_foreign_key
    post = @arya.posts.create!(title: "Second")
    assert_equal @arya.id, post.author_id,
      "author.posts.create! must fill in author_id by itself — that is the point of the association"
  end

  def test_4_a_post_without_an_author_is_invalid
    post = Post.new(title: "Orphan")
    refute post.valid?,
      "belongs_to validates presence by default in Rails — a post with no author must not save"
  end

  def test_5_destroying_a_post_destroys_its_comments
    Comment.create!(body: "First!", post_id: @post.id)
    Comment.create!(body: "Nice.",  post_id: @post.id)
    Comment.create!(body: "Other",  post_id: @other.id)

    @post.destroy

    assert_equal 0, Comment.where(post_id: @post.id).count,
      "destroying a post must destroy its comments — orphaned rows pile up silently in production"
    assert_equal 1, Comment.count,
      "only the destroyed post's comments may disappear — do not touch other posts' comments"
  end

  def test_6_destroying_an_author_cascades_to_comments
    Comment.create!(body: "First!", post_id: @post.id)

    @arya.destroy

    assert_equal 0, Post.where(author_id: @arya.id).count,
      "destroying an author must destroy their posts"
    assert_equal 0, Comment.count,
      "the cascade must go all the way down: author -> posts -> comments. " \
      "One dependent: :destroy is not enough — each level declares its own."
  end
end

# ----------------------------------------------------------------------------
# When you are green, you should be able to answer:
#
# 1. Turn on the logger (ActiveRecord::Base.logger = Logger.new($stdout)) and
#    run again. How many DELETE statements does test 6 produce? Why that many?
# 2. Change dependent: :destroy to dependent: :delete_all on Post#comments.
#    Which test still passes, and what stopped happening under the hood?
# 3. Why does test 4 pass without you writing any `validates` line?
# 4. What happens to test 5 if you remove `dependent: :destroy` but the
#    database had `ON DELETE CASCADE` on the foreign key instead?
#
# Stretch (optional): add a `Post#comment_count` that does NOT load the
# comments into memory, and prove it with the logger.
# ----------------------------------------------------------------------------
