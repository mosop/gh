module Gh
  class PublicKey
    getter json : JSON::Any

    def initialize(@json)
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
      Gh::List(Int64, PublicKey).new("/user/keys")
    end

    class Create < Params
      params({
        title: String,
        key: String,
      })

      def create!
        PublicKey.create self
      end
    end

    def self.create(params : CreateParams)
      Client.new.post("/user/keys", params.to_h) do |res, json|
        PublicKey.new(json)
      end
    end

    def self.delete(id : Int::Primitive)
      Client.new.delete "/user/keys/#{id}"
    end

    def self.delete_all
      list.all.each do |pk|
        pk[1].delete
      end
    end
  end
end
