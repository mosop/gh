module Gh
  class HttpError < Exception
    getter request : Request
    getter response : HTTP::Client::Response

    def initialize(@request, @response)
      body = JSON.parse(@response.body_io? || @response.body).raw.to_pretty_json.split("\n").map{|i| "  #{i}"}.join("\n").rstrip
      message = String.build do |sb|
        sb << "HTTP Error ("
        sb << @response.status_code.to_s
        sb << "): "
        sb << @request.http.method
        sb << " "
        sb << @request.http.path
        if params = @request.params?
          sb << "\n  parameters:\n"
          sb << params.to_pretty_json.split("\n").map{|i| "  #{i}"}.join("\n").rstrip
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
