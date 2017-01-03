require "spec"
require "crystal_plus/dir/.tmp"
require "../src/gh"

module Gh::SpecHelper
  macro included
    extend ::Gh::SpecHelper
  end

  TMP = File.expand_path("../tmp", __DIR__)
  TO_DEV_NULL = " >/dev/null 2>&1"

  def gh_auth1
    Gh.auth(ENV["GH_TEST_ACCESS_TOKEN1"]) do
      yield
    end
  end

  def gh_auth2
    Gh.auth(ENV["GH_TEST_ACCESS_TOKEN2"]) do
      yield
    end
  end

  def git_init1
    git_init 1
  end

  def git_init2
    git_init 2
  end

  def git_init(n)
    cred_path = File.join(TMP, ".git-credentials#{n}")
    `git init`
    `git config --add --local user.name mosop`
    `git config --add --local user.email mosop@users.noreply.github.com`
    `git config --local credential.helper 'store --file #{cred_path}'`
  end

  def self.tmp
    "#{__DIR__}/"
  end

  def self.init
    init_tmp
    init_git_credential 1
    init_git_credential 2
  end

  def self.init_tmp
    `mkdir -p #{TMP}`
  end

  def self.init_git_credential(n)
    path = File.join(TMP, ".git-credentials#{n}")
    token = ENV["GH_TEST_ACCESS_TOKEN#{n}"]
    `touch #{path}`
    `chmod 600 #{path}`
    File.write path, "https://mosop#{n}:#{token}@github.com\n"
  end

  init
end
