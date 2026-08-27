# ----------------------------------------------------------------------------
# Challenge 02 — has_many :through
# Time box: 30 minutes
# Run with:  ruby 02_has_many_through.rb   (from the repo root)
# ----------------------------------------------------------------------------
#
# BRIEF
#
# The blog gets tags. A post can have many tags. A tag can sit on many posts.
# The join table `taggings` already exists — one row per (post, tag) pair.
# Wire the three models together so all tests pass.
#
# This is the ONLY file you edit. The schema and the tests live in
# 02_has_many_through.rb — read them, they are the specification.
# There is nothing to install and nothing to set up. Just run the file.
#
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
# When you are green, you should be able to answer:
#
# 1. Turn on the logger — add ActiveRecord::Base.logger = Logger.new($stdout)
#    at the top of THIS file — and run test 4. What SQL does `post.tags << tag`
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
