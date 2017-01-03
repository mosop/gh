module Gh
  class Issue
    def initialize(@json : JSON::Any)
    end

    def listing_key
      number
    end

    def number
      @json["number"].as_i64
    end

    def body
      @json["body"].as_s
    end

    struct ListParams < Params
      params({
        milestone: Int64 | String,
        state: String,
        assignee: String,
        creator: String,
        mentioned: String,
        labels: String,
        sort: String,
        direction: String,
        since: String,
      })
    end

    def self.list(owner, repo, params = ListParams.new)
      List(Int64, Issue).new("/repos/#{owner}/#{repo}/issues", params.to_h)
    end

    def self.get(owner, repo, number)
      Client.new.get("/repos/#{owner}/#{repo}/issues/#{number}") do |res, json|
        Issue.new(json)
      end
    end
  end
end
