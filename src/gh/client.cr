module Gh
  class Client
    def initialize
    end

    REDIRECT_CODES = [301, 302, 307]

    def join_url(path)
      path.starts_with?("/") ? "https://api.github.com#{path}" : path
    end

    @headers : HTTP::Headers?
    def headers
      @headers ||= HTTP::Headers.new.tap do |h|
        h["Accept"] = "application/vnd.github.v3+json"
        h["User-Agent"] = "mosop/gh"
        h["Authorization"] = "token #{Gh.access_token}"
      end
    end

    def get(path, q = nil)
      get(path, q) do |res, json|
        res
      end
    end

    def get(path, q : Hash(String, JSON::Type)? = nil, &block : (HTTP::Client::Response, JSON::Any) ->)
      url = join_url(path)
      if q
        url = String.build do |sb|
          sb << url
          sb << "?"
          q.each_with_index do |kv, i|
            sb << "&" if i != 0
            sb << URI.escape(kv[0])
            sb << "="
            sb << URI.escape(kv[1].to_s)
          end
        end
      end
      HTTP::Client.get(url, headers) do |response|
        loop do
          if response.success?
            return yield response, JSON.parse(response.body_io.gets_to_end)
          elsif REDIRECT_CODES.includes?(response.status_code)
            response = HTTP::Client.get(url, headers)
          else
            raise HttpError.new("get", path, q, response)
          end
        end
      end
    end

    def post(path, data : Hash(String, JSON::Type))
      post(path, data) do |res, json|
        res
      end
    end

    def post(path, data : Hash(String, JSON::Type), &block : (HTTP::Client::Response, JSON::Any) ->)
      url = join_url(path)
      HTTP::Client.post(url, headers, body: data.to_json) do |response|
        loop do
          if response.success?
            return yield response, JSON.parse(response.body_io.gets_to_end)
          elsif REDIRECT_CODES.includes?(response.status_code)
            response = HTTP::Client.get(response.headers["Location"], headers)
          else
            raise HttpError.new("post", path, data, response)
          end
        end
      end
    end

    def patch(path, data : Hash(String, JSON::Type))
      patch(path, data) do |res, json|
        res
      end
    end

    def patch(path, data : Hash(String, JSON::Type), &block : (HTTP::Client::Response, JSON::Any) ->)
      url = join_url(path)
      HTTP::Client.patch(url, headers, body: data.to_json) do |response|
        loop do
          if response.success?
            return yield response, JSON.parse(response.body_io.gets_to_end)
          elsif REDIRECT_CODES.includes?(response.status_code)
            response = HTTP::Client.get(response.headers["Location"], headers)
          else
            raise HttpError.new("patch", path, data, response)
          end
        end
      end
    end

    def delete(path)
      delete(path) do |res|
        return res
      end
    end

    def delete(path, &block : HTTP::Client::Response ->)
      url = join_url(path)
      HTTP::Client.delete(url, headers) do |response|
        if response.success?
          return yield response
        elsif REDIRECT_CODES.includes?(response.status_code)
          response = HTTP::Client.get(response.headers["Location"], headers)
        else
          raise HttpError.new("delete", path, nil, response)
        end
      end
    end
  end
end
