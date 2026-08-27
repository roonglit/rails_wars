#!/usr/bin/env ruby
# frozen_string_literal: true

# Rails Wars auto-grader.
#
# Grades a learner's working copy against the OFFICIAL challenge files, so
# editing the tests or the schema in the learner's copy changes nothing:
# only the learner's editable sections are read from their repo, and they
# are grafted into pristine copies before the tests run.
#
#   Phase 1: the MODELS section of each NN_topic.rb is extracted from the
#            learner's file and injected into the official file, which then
#            runs in a temp dir with the official schema and tests.
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

# The editable region: everything between the MODELS banner and the TESTS
# banner. Both banners live in the do-not-edit region, so they are taken
# from the official file, never trusted from the learner's.
MODELS_SECTION = /^(# -+\n# MODELS[^\n]*\n# -+\n)(.*?)(^# -+\n# TESTS)/m

Result = Struct.new(:name, :status, :detail) # status: :pass, :fail, :not_started, :missing
results = []

def models_of(content)
  content[MODELS_SECTION, 2]
end

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
  official = File.join(SOURCE, file)
  learner  = File.join(LEARNER, file)
  name     = file.sub(".rb", "")

  unless File.exist?(learner)
    results << Result.new(name, :missing, "#{file} is missing from the repo")
    next
  end

  official_src = File.read(official)
  learner_src  = File.read(learner)
  stub_models    = models_of(official_src)
  learner_models = models_of(learner_src)

  if learner_models.nil?
    results << Result.new(name, :fail, "the MODELS section markers were removed — restore the file's structure")
    next
  end

  if normalized(learner_models) == normalized(stub_models)
    results << Result.new(name, :not_started, nil)
    next
  end

  # Anti-tamper: everything outside MODELS comes from the official file.
  grafted = official_src.sub(MODELS_SECTION) { "#{$1}#{learner_models}#{$3}" }
  tampered = normalized(learner_src.sub(MODELS_SECTION) { "#{$1}#{stub_models}#{$3}" }) !=
             normalized(official_src)

  Dir.mktmpdir("rails-wars-#{name}-") do |dir|
    path = File.join(dir, file)
    File.write(path, grafted)
    out, ok = run(["ruby", path], chdir: dir)
    detail = tampered ? "note: changes outside the MODELS section were ignored" : nil
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
