module Gh
  class Pull
    getter json : JSON::Any

    def initialize(@json)
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

    def base_repo_owner_login
      @json["base"]["repo"]["owner"]["login"].as_s
    end

    def base_repo_name
      @json["base"]["repo"]["name"].as_s
    end

    def head_repo_owner_login
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
      Pull.close base_repo_owner_login, base_repo_name, number
    end

    class List < Params
      params({
        state: String,
        head: String,
        base: String,
        sort: String,
        direction: String
      })

      def list!(owner, repo)
        Pull.list(owner, repo, self)
      end
    end

    def self.list(owner : String, repo : String, params = List.new)
      Gh::List(Int64, Pull).new("/repos/#{owner}/#{repo}/pulls", params.to_h)
    end

    def self.get?(owner : String, repo : String, number : Int::Primitive)
      get(owner, repo, number)
    rescue ex : HttpError
      raise ex unless ex.not_found?
      nil
    end

    def self.get(owner : String, repo : String, number : Int::Primitive)
      Request.get("/repos/#{owner}/#{repo}/pulls/#{number}") do |req, res, json|
        Pull.new(json)
      end.not_nil!
    end

    class Create < Params
      params({
        title: String,
        head: String,
        base: String,
        body: String,
        maintainer_can_modify: Bool,
        issue: String
      })

      def create!(owner, repo)
        Pull.create(owner, repo, self)
      end
    end

    def self.create(owner : String, repo : String, params : Create)
      Request.post("/repos/#{owner}/#{repo}/pulls", params.to_h) do |req, res, json|
        return Pull.new(json)
      end.not_nil!
    end

    class Update < Params
      params({
        title: String,
        body: String,
        state: String,
        base: String,
        maintainer_can_modify: Bool,
      })

      def update!(owner, repo, number)
        Pull.update(owner, repo, number, self)
      end
    end

    def self.update(owner : String, repo : String, number : Int::Primitive, params : Update)
      Request.patch("/repos/#{owner}/#{repo}/pulls/#{number}", params.to_h) do |req, res, json|
        Pull.new(json)
      end.not_nil!
    end

    def self.close(owner : String, repo : String, number : Int::Primitive)
      Update.state("close").update!(owner, repo, number)
    end

    def self.close_all(owner : String, repo : String)
      List.state("open").list!(owner, repo).all.each do |pr|
        pr[1].close
      end
    end
  end
end
