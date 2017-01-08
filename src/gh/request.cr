module Gh
  class Request
    alias Body = String | Bytes | IO
    REDIRECT_CODES = [301, 302, 307]
    HOST = "api.github.com"

    getter http : HTTP::Request
    getter? params : Hash(String, JSON::Type)?

    def initialize(method, path, q : Hash(String, JSON::Type)? = nil, body : Body? = nil, @params : Hash(String, JSON::Type)? = nil)
      @http = HTTP::Request.new(method, path, Request.new_headers, body)
      params = @http.query_params
      if q
        q.each do |k, v|
          params.add k, v.to_s
        end
      end
    end

    def self.new_headers
      h = HTTP::Headers.new
      h["Host"] = HOST
      h["Accept"] = "application/vnd.github.v3+json"
      h["User-Agent"] = "mosop/gh"
      h["Authorization"] = "token #{Gh.access_token}"
      h
    end

    def exec
      HTTP::Client.new(HOST, tls: true).exec(@http)
    end

    def exec(&block)
      HTTP::Client.new(HOST, tls: true).exec(@http) do |res|
        return with_redirect(res) do |res|
          yield self, res
        end
      end
    end

    def json(&block)
      HTTP::Client.new(HOST, tls: true).exec(@http) do |res|
        return with_redirect(res) do |res|
          yield self, res, JSON.parse(res.body_io? || res.body)
        end
      end
    end

    def with_redirect(res)
      loop do
        if res.success?
          return yield res
        elsif REDIRECT_CODES.includes?(res.status_code)
          res = Request.get(res.headers["Location"])
        else
          raise HttpError.new(self, res)
        end
      end
    end

    def self.get(path, q : Hash(String, JSON::Type)? = nil)
      new("GET", path, q).exec
    end

    def self.get(path, q : Hash(String, JSON::Type)? = nil, &block)
      new("GET", path, q).json do |req, res, json|
        yield req, res, json
      end
    end

    def self.post(path, data : Hash(String, JSON::Type), &block)
      new("POST", path, nil, data.to_json, data).json do |req, res, json|
        yield req, res, json
      end
    end

    def self.patch(path, data : Hash(String, JSON::Type), &block)
      new("PATCH", path, nil, data.to_json, data).json do |req, res, json|
        yield req, res, json
      end
    end

    def self.delete(path)
      new("DELETE", path).exec
    end

    def self.delete(path, &block)
      new("DELETE", path).exec do |req, res|
        yield req, res
      end
    end
  end
end
