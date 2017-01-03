module Gh
  class Repository
    def initialize(@json : JSON::Any)
    end

    def name
      @json["name"].as_s
    end

    def full_name
      @json["full_name"].as_s
    end

    struct CreateParams < Params
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
    end

    def self.create(params : CreateParams)
      create nil, params
    end

    def self.create(org : String?, params : CreateParams)
      path = if org
        "/orgs/#{org}/repos"
      else
        "/user/repos"
      end
      Client.new.post path, params.to_h
    end

    def self.delete(owner, repo)
      begin
        Client.new.delete "/repos/#{owner}/#{repo}"
      rescue ex : HttpError
        raise ex unless ex.status_code == 404
      end
    end
  end
end
