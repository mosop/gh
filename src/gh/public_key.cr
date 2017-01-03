module Gh
  class PublicKey
    def initialize(@json : JSON::Any)
    end

    def listing_key
      id
    end

    def id
      @json["id"].as_i64
    end

    def delete
      PublicKey.delete id
    end

    def self.list
      List(Int64, PublicKey).new("/user/keys")
    end

    struct CreateParams < Params
      params({
        title: String,
        key: String,
      })
    end

    def self.create(params : CreateParams)
      Client.new.post "/user/keys", params.to_h
    end

    def self.delete(id : Int64)
      Client.new.delete "/user/keys/#{id}"
    end

    def self.delete_all
      list.all.each do |pk|
        pk[1].delete
      end
    end
  end
end
