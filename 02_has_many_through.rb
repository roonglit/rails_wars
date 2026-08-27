# ----------------------------------------------------------------------------
# Challenge 02 — has_many :through
# Time box: 30 minutes
# Run with:  ruby 02_has_many_through.rb
# ----------------------------------------------------------------------------
#
# BRIEF
#
# The blog gets tags. A post can have many tags. A tag can sit on many posts.
# The join table `taggings` already exists — one row per (post, tag) pair.
# Wire the three models together so all tests pass.
#
# There is nothing to install and nothing to set up. This file is not part
# of a Rails app. Just run it — it installs its own gems on the first run.
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
  create_table :posts do |t|
    t.string :title, null: false
  end

  create_table :tags do |t|
    t.string :name, null: false
  end

  create_table :taggings do |t|
    t.integer :post_id, null: false
    t.integer :tag_id,  null: false
  end
end

# ----------------------------------------------------------------------------
# MODELS — the only section you may edit
# ----------------------------------------------------------------------------

class Post < ActiveRecord::Base
  # TODO: a post has many taggings.
  # TODO: a post has many tags, through its taggings.
  # TODO: a post must never list the same tag twice, even if the join table
  #       holds a duplicate pair.
  # TODO: destroying a post removes its taggings — but never the tags.
end

class Tag < ActiveRecord::Base
  # TODO: a tag has many taggings.
  # TODO: a tag has many posts, through its taggings.
end

class Tagging < ActiveRecord::Base
  # TODO: a tagging belongs to a post and to a tag.
end

# ----------------------------------------------------------------------------
# TESTS — do not edit. Ordered easy to hard.
# ----------------------------------------------------------------------------

class HasManyThroughTest < Minitest::Test
  def self.test_order = :alpha

  def setup
    Tagging.delete_all
    Post.delete_all
    Tag.delete_all

    @post  = Post.create!(title: "Rails tips")
    @other = Post.create!(title: "Ruby tricks")
    @ruby  = Tag.create!(name: "ruby")
    @rails = Tag.create!(name: "rails")

    Tagging.create!(post_id: @post.id,  tag_id: @ruby.id)
    Tagging.create!(post_id: @post.id,  tag_id: @rails.id)
    Tagging.create!(post_id: @other.id, tag_id: @ruby.id)
  end

  def test_1_post_has_many_taggings
    assert_equal 2, @post.taggings.count,
      "Post#taggings must return the join rows for this post"
  end

  def test_2_post_reaches_tags_through_taggings
    assert_equal %w[rails ruby], @post.tags.map(&:name).sort,
      "Post#tags must go through the taggings join table"
  end

  def test_3_tag_reaches_posts_through_taggings
    assert_equal ["Rails tips", "Ruby tricks"], @ruby.posts.map(&:title).sort,
      "the association works in both directions: Tag#posts through taggings"
  end

  def test_4_shovel_writes_the_join_row_for_you
    tag = Tag.create!(name: "testing")
    @post.tags << tag

    assert_equal 1, Tagging.where(post_id: @post.id, tag_id: tag.id).count,
      "post.tags << tag must create the Tagging row itself — you never build it by hand"
  end

  def test_5_destroying_a_post_removes_taggings_but_keeps_tags
    @post.destroy

    assert_equal 0, Tagging.where(post_id: @post.id).count,
      "a destroyed post must not leave join rows behind"
    assert_equal 2, Tag.count,
      "tags are shared — destroying one post must never destroy a tag"
  end

  def test_6_duplicate_join_rows_do_not_duplicate_tags
    Tagging.create!(post_id: @post.id, tag_id: @ruby.id) # duplicate pair

    assert_equal %w[rails ruby], @post.reload.tags.map(&:name).sort,
      "a duplicate row in the join table must not make the tag appear twice — " \
      "in production these duplicates arrive sooner or later"
  end

  def test_7_removing_a_tag_from_a_post_only_deletes_the_join_row
    @post.tags.destroy(@ruby)

    assert_equal 0, Tagging.where(post_id: @post.id, tag_id: @ruby.id).count,
      "post.tags.destroy(tag) must remove the join row"
    assert Tag.exists?(@ruby.id),
      "…but the tag itself must survive — other posts still use it. " \
      "This is the part of has_many :through people get wrong in production."
  end
end

# ----------------------------------------------------------------------------
# When you are green, you should be able to answer:
#
# 1. Turn on the logger and run test 4. What SQL does `post.tags << tag`
#    produce? How many INSERTs?
# 2. In test 7, `post.tags.destroy(@ruby)` destroys something — what exactly?
#    Confirm with the logger.
# 3. Remove `dependent: :destroy` from Post#taggings and run again. Which
#    test breaks, and what is now sitting in the taggings table?
# 4. What is the difference between `has_many :tags, through: :taggings` and
#    `has_and_belongs_to_many :tags`? Why does almost everyone pick :through?
#
# Stretch (optional): add `Post.tagged_with("ruby")` returning all posts
# carrying that tag name, in one query.
# ----------------------------------------------------------------------------
