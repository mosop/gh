module Gh
  class Fork
    getter json : JSON::Any

    def initialize(@json)
    end

    class Create < Params
      params({
        organization: String,
      })

      def create!(owner, repo)
        Fork.create(owner, repo, self)
      end
    end

    def self.create(owner : String, repo : String, params = Create.new)
      Client.new.post("/repos/#{owner}/#{repo}/forks", params.to_h) do |res, json|
        Fork.new(json)
      end
    end
  end
end
