# ----------------------------------------------------------------------------
# Challenge 09 — N+1 queries and eager loading
# Time box: 30 minutes
# Run with:  ruby 09_n_plus_one.rb   (from the repo root)
# ----------------------------------------------------------------------------
#
# BRIEF
#
# The blog's front page shows every post, newest first, with its author's
# name and its comments. Written naively, that page runs one query for
# the posts, then one MORE query per post for its author, and one more
# for its comments. 50 posts = 101 queries. This is the N+1 problem, and
# it is the most common performance bug in every Rails app ever deployed.
#
# The tests in the runner COUNT your queries. The feed must load
# everything it needs up front, in a fixed number of queries, no matter
# how many posts exist.
#
# This is the ONLY file you edit. The schema and the tests live in
# 09_n_plus_one.rb — read them, they are the specification.
# There is nothing to install and nothing to set up. Just run the file.
#
# ----------------------------------------------------------------------------

class Author < ActiveRecord::Base
  # TODO: an author has many posts. (You have done this before — quick recap.)
end

class Post < ActiveRecord::Base
  # TODO: a post belongs to an author and has many comments.
  #
  # TODO: scope :feed — every post, newest first BY created_at (the tests
  #       plant a post whose id order disagrees with its date order, so
  #       ordering by id will not pass). The feed must bring authors and
  #       comments along in the same trip — that is the whole challenge.
  #
  # TODO: scope :by_author — takes a name, returns that author's posts.
  #       The DATABASE must do the filtering, in one query. Loading every
  #       post into Ruby and picking through them is the thing this
  #       challenge exists to stop.
end

class Comment < ActiveRecord::Base
  # TODO: a comment belongs to a post.
end

# ----------------------------------------------------------------------------
# When you are green, you should be able to answer:
#
# 1. Turn on the logger — add ActiveRecord::Base.logger = Logger.new($stdout)
#    at the top of THIS file — and run Post.feed.to_a. How many queries,
#    and what does each one load? Now delete your eager loading, run it
#    again, and watch the N+1 happen line by line. Put it back.
# 2. includes, preload, eager_load: run the feed with each one and read
#    the SQL. Which produced a JOIN, which produced separate queries, and
#    what does includes decide on its own?
# 3. Your by_author scope needs joins, and your feed needs includes. Swap
#    them — what breaks in each direction, and why? (One of them will
#    complain about a table; read that error slowly, it is famous.)
# 4. post.comments.size, .length, and .count look identical. After the
#    feed has eager-loaded comments, one of the three STILL fires a query.
#    Which one, and what is the rule for choosing between them?
#
# Stretch (optional): the front page also wants each post's comment COUNT
# without loading the comments themselves. Look up counter_cache, add it
# (you may pretend the schema has a comments_count column — say what the
# migration would be), and explain what write it saves and what write it
# adds.
# ----------------------------------------------------------------------------
