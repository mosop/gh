require "../spec_helper"

module GhCodeExampleCreatingPullRequests
  include Gh::SpecHelper

  it name do
    gh_auth1 do
      Gh::Repo.delete "mosop1", "gh-test"
      Gh::Repo::Create.name("gh-test").create!
      Dir.tmp do |tmpdir|
        Dir.cd(tmpdir) do
          git_init1
          `git remote add origin https://github.com/mosop1/gh-test.git`
          `git commit --allow-empty -m "initial"`
          `git push origin master#{TO_DEV_NULL}`
        end
      end
    end
    gh_auth2 do
      Gh::Repo.delete "mosop2", "gh-test"
      Gh::Fork.create "mosop1", "gh-test"
      Gh::Repo.get? "mosop1", "gh-test", Gh::Retry.times(5)
      Dir.tmp do |tmpdir|
        Dir.cd(tmpdir) do
          git_init2
          `git remote add origin https://github.com/mosop2/gh-test.git`
          `git pull origin master#{TO_DEV_NULL}`
          `git checkout -b create_pull_requests origin/master#{TO_DEV_NULL}`
          `touch test`
          `git add .`
          `git commit -m "test"`
          `git push origin create_pull_requests#{TO_DEV_NULL}`
        end
      end
      params = Gh::Pull::Create
        .title("Creating Pull Requests")
        .head("mosop2:create_pull_requests")
        .base("master")
        .body(<<-EOS
        Hi @mosop1,

        I added the Gh::Pull class for creating pull requests.

        Thanks.
        EOS
        )
      pr = params.create!("mosop1", "gh-test")
      pr.head_owner_login.should eq "mosop2"
      pr.head_repo_name.should eq "gh-test"
      pr.body.should eq params.body
      got = Gh::Pull.get("mosop1", "gh-test", 1)
      got.head_owner_login.should eq pr.head_owner_login
      got.head_repo_name.should eq pr.head_repo_name
      got.body.should eq pr.body
    end
  end
end
