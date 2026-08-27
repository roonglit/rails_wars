#!/usr/bin/env ruby
# frozen_string_literal: true

# Rails Wars auto-grader.
#
# Grades a learner's working copy against the OFFICIAL challenge files, so
# editing the tests or the schema in the learner's copy changes nothing:
# only the learner's editable sections are read from their repo, and they
# are grafted into pristine copies before the tests run.
#
#   Phase 1: the learner edits only models/NN_topic.rb. That one file is
#            copied into a temp dir next to the OFFICIAL runner (schema +
#            tests), and the runner is executed there.
#   Phase 0: the official schema_test.rb / migration_test.rb are copied
#            over whatever is in blog_practice/test/models/, then run.
#
# Usage:
#   ruby grader.rb --learner PATH_TO_LEARNER_REPO [--source PATH_TO_OFFICIAL_REPO]
#
# --source defaults to the repo this script lives in. Exit code is 0 when
# no attempted challenge fails (untouched challenges are "not started" and
# do not fail the run), 1 otherwise.

require "optparse"
require "tmpdir"
require "fileutils"
require "open3"

options = { source: File.expand_path("..", __dir__), learner: nil }
OptionParser.new do |o|
  o.on("--learner PATH") { |v| options[:learner] = File.expand_path(v) }
  o.on("--source PATH")  { |v| options[:source] = File.expand_path(v) }
end.parse!
abort "grader: --learner PATH is required" unless options[:learner]

SOURCE  = options[:source]
LEARNER = options[:learner]

PHASE1 = ["01_associations.rb", "02_has_many_through.rb", "03_scopes.rb"].freeze
PHASE0 = [
  { name: "phase0/01 generators", test: "schema_test.rb" },
  { name: "phase0/02 migrations", test: "migration_test.rb" },
].freeze

Result = Struct.new(:name, :status, :detail) # status: :pass, :fail, :not_started, :missing
results = []

def normalized(code)
  code.lines.map(&:strip).reject(&:empty?).join("\n")
end

def run(cmd, chdir:, timeout: 300)
  out, status = Open3.capture2e(*cmd, chdir: chdir)
  [out, status.success?]
rescue Errno::ENOENT => e
  [e.message, false]
end

# ---- Phase 1 ---------------------------------------------------------------

PHASE1.each do |file|
  official_runner = File.join(SOURCE, file)
  official_stub   = File.join(SOURCE, "models", file)
  learner_models  = File.join(LEARNER, "models", file)
  learner_runner  = File.join(LEARNER, file)
  name            = file.sub(".rb", "")

  unless File.exist?(learner_models)
    results << Result.new(name, :missing, "models/#{file} is missing from the repo")
    next
  end

  if normalized(File.read(learner_models)) == normalized(File.read(official_stub))
    results << Result.new(name, :not_started, nil)
    next
  end

  # Anti-tamper: only the learner's models file enters the temp tree; the
  # runner (schema + tests) always comes from the official repo.
  tampered = !File.exist?(learner_runner) ||
             normalized(File.read(learner_runner)) != normalized(File.read(official_runner))

  Dir.mktmpdir("rails-wars-#{name}-") do |dir|
    FileUtils.cp(official_runner, File.join(dir, file))
    FileUtils.mkdir_p(File.join(dir, "models"))
    FileUtils.cp(learner_models, File.join(dir, "models", file))
    out, ok = run(["ruby", file], chdir: dir)
    detail = tampered ? "note: changes to #{file} (the runner) were ignored" : nil
    if ok
      results << Result.new(name, :pass, detail)
    else
      tail = out.lines.last(15).join
      results << Result.new(name, :fail, [detail, tail].compact.join("\n"))
    end
  end
end

# ---- Phase 0 ---------------------------------------------------------------

app = File.join(LEARNER, "blog_practice")
if File.exist?(File.join(app, "bin", "rails"))
  # Anti-tamper: always test with the official copies.
  FileUtils.mkdir_p(File.join(app, "test", "models"))
  PHASE0.each do |ch|
    FileUtils.cp(File.join(SOURCE, "phase0", ch[:test]), File.join(app, "test", "models", ch[:test]))
  end

  PHASE0.each do |ch|
    out, ok = run(["bin/rails", "test", "test/models/#{ch[:test]}"], chdir: app)
    if ok
      results << Result.new(ch[:name], :pass, nil)
    else
      results << Result.new(ch[:name], :fail, out.lines.last(15).join)
    end
  end
else
  PHASE0.each { |ch| results << Result.new(ch[:name], :not_started, "no blog_practice app committed yet") }
end

# ---- Report ----------------------------------------------------------------

ICON = { pass: "PASS", fail: "FAIL", not_started: "not started", missing: "MISSING" }.freeze

puts "\n== Rails Wars grade =="
results.each do |r|
  puts format("  %-28s %s", r.name, ICON[r.status])
  next unless r.detail
  r.detail.lines.each { |l| puts "      #{l}" }
end

failed = results.count { |r| [:fail, :missing].include?(r.status) }
passed = results.count { |r| r.status == :pass }
puts "\n  #{passed} passed, #{failed} failed, #{results.count { |r| r.status == :not_started }} not started"

if ENV["GITHUB_STEP_SUMMARY"]
  emoji = { pass: ":green_circle: pass", fail: ":red_circle: FAIL",
            not_started: ":white_circle: not started", missing: ":red_circle: missing" }
  File.open(ENV["GITHUB_STEP_SUMMARY"], "a") do |f|
    f.puts "## Rails Wars grade\n\n| Challenge | Result |\n|---|---|"
    results.each { |r| f.puts "| #{r.name} | #{emoji[r.status]} |" }
    notes = results.select(&:detail)
    unless notes.empty?
      f.puts "\n"
      notes.each { |r| f.puts "<details><summary>#{r.name}</summary>\n\n```\n#{r.detail}\n```\n</details>" }
    end
  end
end

exit(failed.zero? ? 0 : 1)
