module Gh
  class Fork
    struct CreateParams < Params
      params({
        organization: String,
      })
    end

    def self.create(owner : String, repo : String, params = CreateParams.new)
      Client.new.post "/repos/#{owner}/#{repo}/forks", params.to_h
    end
  end
end
