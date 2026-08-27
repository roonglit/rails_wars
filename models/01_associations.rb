# ----------------------------------------------------------------------------
# Challenge 01 — Associations: belongs_to and has_many
# Time box: 30 minutes
# Run with:  ruby 01_associations.rb   (from the repo root)
# ----------------------------------------------------------------------------
#
# BRIEF
#
# A tiny blog. Authors write posts. Readers leave comments on posts.
# The tables already exist. The models below are empty.
# Wire the models together so all tests pass.
#
# This is the ONLY file you edit. The schema and the tests live in
# 01_associations.rb — read them, they are the specification.
# There is nothing to install and nothing to set up. Just run the file.
#
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
# When you are green, you should be able to answer:
#
# 1. Turn on the logger — add ActiveRecord::Base.logger = Logger.new($stdout)
#    at the top of THIS file — and run again. How many DELETE statements does
#    test 6 produce? Why that many?
# 2. Change dependent: :destroy to dependent: :delete_all on Post#comments.
#    Which test still passes, and what stopped happening under the hood?
# 3. Why does test 4 pass without you writing any `validates` line?
# 4. What happens to test 5 if you remove `dependent: :destroy` but the
#    database had `ON DELETE CASCADE` on the foreign key instead?
# 5. You never told `belongs_to :author` which table or which column to use.
#    Imagine the column were named `writer_id` instead of `author_id` — what
#    would break, and which option would you have to add? This "it just knows"
#    is called convention over configuration. It is the biggest idea in Rails.
#
# Stretch (optional): add a `Post#comment_count` that does NOT load the
# comments into memory, and prove it with the logger.
# ----------------------------------------------------------------------------
