# ----------------------------------------------------------------------------
# Challenge 05 — Polymorphic associations
# Time box: 30 minutes
# Run with:  ruby 05_polymorphic.rb   (from the repo root)
# ----------------------------------------------------------------------------
#
# BRIEF
#
# The blog now has photos as well as posts, and readers comment on both.
# One Comment model serves them all. Look at the comments table in the
# runner: there is no post_id and no photo_id. Instead there are two
# columns — commentable_type and commentable_id — that together point at
# any record of any model. That pair is called a polymorphic association.
#
# Wire it up: a Comment belongs to its commentable; Posts and Photos each
# have many comments. Deleting a post or a photo must take its comments
# with it.
#
# This is the ONLY file you edit. The schema and the tests live in
# 05_polymorphic.rb — read them, they are the specification.
# There is nothing to install and nothing to set up. Just run the file.
#
# ----------------------------------------------------------------------------

class Post < ActiveRecord::Base
  # TODO: a post has many comments — but comments have no post_id.
  #       Tell the association which polymorphic name to use.
  # TODO: destroying a post destroys its comments.
end

class Photo < ActiveRecord::Base
  # TODO: same as Post. Notice how little changes.
end

class Comment < ActiveRecord::Base
  # TODO: a comment belongs to its commentable — which may be a Post
  #       today, a Photo tomorrow, and anything else next year.
end

# ----------------------------------------------------------------------------
# When you are green, you should be able to answer:
#
# 1. Turn on the logger — add ActiveRecord::Base.logger = Logger.new($stdout)
#    at the top of THIS file — and run post.comments. The WHERE clause has
#    two conditions. What are they, and what exactly is stored in
#    commentable_type?
# 2. In Phase 0 you added foreign keys to protect id columns. Why can the
#    database NOT put a foreign key on commentable_id? What kind of bad row
#    can therefore appear, and what stops it in practice?
# 3. Your team renames the Post class to Entry. Every old comment row still
#    says "Post" in commentable_type. What breaks, and when — at rename
#    time, or the first time someone loads an old comment?
# 4. Challenge 02 solved "one model attached to many others" with a join
#    table and has_many :through. When is polymorphic the better tool, and
#    when is the join table? (Hint: think about what a Comment is to a Post
#    versus what a Tag is to a Post.)
#
# Stretch (optional): add a Video model with a title, give it comments, and
# make a comment on it — without touching the Comment class or the schema.
# That is the whole point of polymorphic.
# ----------------------------------------------------------------------------
