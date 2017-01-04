module Gh
  class Issue
    getter json : JSON::Any

    def initialize(@json)
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

    class List < Params
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

      def list!(owner, repo)
        Issue.list(owner, repo, self)
      end
    end

    def self.list(owner : String, repo : String, params = List.new)
      Gh::List(Int64, Issue).new("/repos/#{owner}/#{repo}/issues", params.to_h)
    end

    def self.get(owner : String, repo : String, number : String | Int::Primitive)
      Client.new.get("/repos/#{owner}/#{repo}/issues/#{number}") do |res, json|
        Issue.new(json)
      end
    end
  end
end
