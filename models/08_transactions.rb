# ----------------------------------------------------------------------------
# Challenge 08 — Transactions
# Time box: 30 minutes
# Run with:  ruby 08_transactions.rb   (from the repo root)
# ----------------------------------------------------------------------------
#
# BRIEF
#
# The blog lets readers tip authors. Every Account has a balance in cents.
# A tip moves money from one account to another — and moving money is TWO
# writes: subtract here, add there. If anything fails between the two,
# you have either destroyed money or invented it. Both are career events.
#
# Write Account#transfer_to!(other, amount). The two writes must succeed
# together or fail together — that is what a database transaction is for.
# The tests will deliberately break each half of the transfer and check
# that the other half is undone.
#
# This is the ONLY file you edit. The schema and the tests live in
# 08_transactions.rb — read them, they are the specification.
# There is nothing to install and nothing to set up. Just run the file.
#
# ----------------------------------------------------------------------------

class Account < ActiveRecord::Base
  # TODO: define Account::InsufficientFunds — an error class of your own.
  #       (An error class is one line. Look at how Ruby errors inherit.)
  #
  # TODO: transfer_to!(other, amount)
  #       - amount must be positive: raise ArgumentError otherwise.
  #       - raise InsufficientFunds when the balance cannot cover it.
  #       - subtract from this account, add to the other — atomically.
  #         If either write fails FOR ANY REASON, the database must end
  #         up exactly as it started.
  #       - the bang in the name is a promise: on failure this method
  #         raises. It never quietly returns false.
end

# ----------------------------------------------------------------------------
# When you are green, you should be able to answer:
#
# 1. Turn on the logger — add ActiveRecord::Base.logger = Logger.new($stdout)
#    at the top of THIS file — and run one successful transfer and one
#    failed one. Find the BEGIN, the COMMIT, and the ROLLBACK. What
#    exactly sits between BEGIN and COMMIT?
# 2. The tests reload every account before checking its balance. Comment
#    out one reload (in your head): after a rollback, what does the
#    in-memory object say the balance is? Which one is lying — the object
#    or the database?
# 3. raise ActiveRecord::Rollback inside your transaction instead of
#    InsufficientFunds. The rollback still happens — but what does the
#    CALLER see now? Why is this exception dangerous in a method whose
#    name ends in !?
# 4. The schema puts a CHECK (balance_cents >= 0) constraint on the table,
#    and your code checks the balance too. Two requests transfer the last
#    100 cents out at the same instant — which check actually saves you,
#    and why can't the Ruby one?
#
# Stretch (optional): two transfers between the same two accounts can
# still deadlock or double-spend under real concurrency. Look up
# with_lock, wrap the debit side, and explain in one sentence what the
# database does differently now.
# ----------------------------------------------------------------------------
