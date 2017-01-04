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
        Repo.create org, self
      end
    end

    def self.create(org : String?, params : Create)
      path = if org
        "/orgs/#{org}/repos"
      else
        "/user/repos"
      end
      Client.new.post path, params.to_h
    end

    def self.delete(owner : String, repo : String)
      begin
        Client.new.delete "/repos/#{owner}/#{repo}"
      rescue ex : HttpError
        raise ex unless ex.status_code == 404
      end
    end
  end
end
