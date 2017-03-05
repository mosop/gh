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

    def html_url
      @json["html_url"].as_s
    end

    def title
      @json["title"].as_s
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

      def list!(org)
        Issue.list(org, self)
      end
    end

    def self.list(org : String, params = List.new)
      Gh::List(Int64, Issue).new("/orgs/#{org}/issues", params.to_h)
    end

    def self.list(owner : String, repo : String, params = List.new)
      Gh::List(Int64, Issue).new("/repos/#{owner}/#{repo}/issues", params.to_h)
    end

    class Search < Params
      params({
        q: String,
        sort: String,
        order: String
      })

      def search!
        Issue.search(self)
      end
    end

    def self.search(params = Search.new)
      Gh::List(Int64, Issue).new("/search/issues", params.to_h, key: "items")
    end

    def self.get(owner : String, repo : String, number : String | Int::Primitive)
      Request.get("/repos/#{owner}/#{repo}/issues/#{number}") do |req, res, json|
        Issue.new(json)
      end.not_nil!
    end
  end
end
