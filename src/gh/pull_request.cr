module Gh
  class PullRequest
    def initialize(@json : JSON::Any)
    end

    def listing_key
      number
    end

    def number
      @json["number"].as_i64
    end

    def issue_url
      @json["issue_url"].as_s
    end

    def owner_login
      @json["base"]["repo"]["owner"]["login"].as_s
    end

    def repo_name
      @json["base"]["repo"]["name"].as_s
    end

    def head_owner_login
      @json["head"]["repo"]["owner"]["login"].as_s
    end

    def head_repo_name
      @json["head"]["repo"]["name"].as_s
    end

    def title
      @json["title"].as_s
    end

    def body
      @json["body"].as_s
    end

    @issue_number : Int64?
    def issue_number
      @issue_number ||= issue_url.split("/").last.to_i64
    end

    @issue : Issue?
    def issue
      @issue ||= Issue.get(owner_login, repo_name, issue_number)
    end

    def close
      PullRequest.close owner_login, repo_name, number
    end

    struct ListParams < Params
      params({
        state: String,
        head: String,
        base: String,
        sort: String,
        direction: String
      })
    end

    def self.list(owner, repo, params = ListParams.new)
      List(Int64, PullRequest).new("/repos/#{owner}/#{repo}/pulls", params.to_h)
    end

    def self.get(owner, repo, number)
      Client.new.get("/repos/#{owner}/#{repo}/pulls/#{number}") do |res, json|
        PullRequest.new(json)
      end
    end

    struct CreateParams < Params
      params({
        title: String,
        head: String,
        base: String,
        body: String,
        maintainer_can_modify: Bool,
        issue: String
      })
    end

    def self.create(owner, repo, params : CreateParams)
      Client.new.post "/repos/#{owner}/#{repo}/pulls", params.to_h
    end

    struct UpdateParams < Params
      params({
        title: String,
        body: String,
        state: String,
        base: String,
        maintainer_can_modify: Bool,
      })
    end

    def self.update(owner, repo, number, params : UpdateParams)
      Client.new.patch "/repos/#{owner}/#{repo}/pulls/#{number}", params.to_h
    end

    def self.close(owner, repo, number)
      update owner, repo, number, UpdateParams.new.state("close")
    end

    def self.close_all(owner, repo)
      PullRequest.list(owner, repo, ListParams.new.state("open")).all.each do |pr|
        pr[1].close
      end
    end
  end
end
