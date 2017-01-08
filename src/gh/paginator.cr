module Gh
  class Paginator
    getter last_page = 0
    getter? end_of_pages = false
    @path : String
    @q : Hash(String, JSON::Type)?

    NEXT = /rel="next"/

    def initialize(@path, @q)
    end

    def fetch_next
      return if @end_of_pages
      q = if _q = @q
        _q.dup
      else
        {} of String => JSON::Type
      end
      q["page"] = (@last_page + 1).to_s
      Request.get(@path, q) do |req, res, json|
        if json.size > 0
          @last_page += 1
          yield req, res, json
          if link = res.headers["Link"]?
            @end_of_pages = true unless NEXT =~ link
          else
            @end_of_pages = true
          end
        else
          @end_of_pages = true
        end
      end
    end

    def each_page
      until @end_of_pages
        fetch_next do |req, res, json|
          yield req, res, json
        end
      end
    end
  end
end
