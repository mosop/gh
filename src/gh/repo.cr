module Gh
  class Repo
    getter json : JSON::Any

    def initialize(@json)
    end

    def name
      @json["name"].as_s
    end

    def full_name
      @json["full_name"].as_s
    end

    class Create < Params
      params({
        name: String,
        description: String,
        homepage: String,
        _private: Bool,
        has_issues: Bool,
        has_wiki: Bool,
        has_downloads: Bool,
        team_id: Int64,
        auto_init: Bool,
        gitignore_template: String,
        license_template: String,
      })

      def create!(org = nil)
        Repo.create(org, self)
      end
    end

    def self.create(org : String?, params : Create)
      path = if org
        "/orgs/#{org}/repos"
      else
        "/user/repos"
      end
      Request.post(path, params.to_h) do |req, res, json|
        Repo.new(json)
      end
    end

    def self.delete(owner : String, repo : String)
      begin
        Request.delete("/repos/#{owner}/#{repo}")
      rescue ex : HttpError
        raise ex unless ex.status_code == 404
      end
    end

    def self.get?(owner : String, repo : String, retry : Retry = nil)
      retry ||= Retry.times(1)
      retry.not_nil do |retry|
        begin
          get(owner, repo)
        rescue ex : HttpError
          raise ex if retry.ends? || !ex.not_found?
          nil
        end
      end
    end

    def self.get(owner : String, repo : String)
      Request.get("/repos/#{owner}/#{repo}") do |req, res, json|
        Repo.new(json)
      end
    end
  end
end
