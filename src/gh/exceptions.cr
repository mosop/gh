module Gh
  class HttpError < Exception
    getter method : String
    getter path : String
    getter params : Hash(String, JSON::Type)?
    getter response : HTTP::Client::Response

    def initialize(@method, @path, @params, @response)
      body = @response.body_io.gets_to_end
      body = JSON.parse(body).raw.to_pretty_json.split("\n").map{|i| "  #{i}"}.join("\n").rstrip
      message = String.build do |sb|
        sb << "HTTP Error ("
        sb << @response.status_code.to_s
        sb << "): "
        sb << @method.upcase
        sb << " "
        sb << @path
        if _params = @params
          sb << "\n  parameters:\n"
          sb << _params.to_pretty_json.split("\n").map{|i| "  #{i}"}.join("\n").rstrip
        end
        sb << "\n  response:\n"
        sb << body
      end
      super message
    end

    def status_code
      @response.status_code
    end

    def not_found?
      status_code == 404
    end
  end
end
