module Gh
  class List(K, V)
    @paginator : Paginator
    @all = {} of K => V
    @key : String?

    def initialize(path, q = nil, @key = nil)
      @paginator = Paginator.new(path, q)
    end

    def each(&block : V ->)
      return if @paginator.end_of_pages?
      @paginator.each_page do |req, res, json|
        list = if k = @key
          json[k]
        else
          json
        end
        list.each do |data|
          item = V.new(data)
          @all[item.listing_key] = item
          yield item
        end
      end
    end

    def all
      unless @paginator.end_of_pages?
        each do |*args|
        end
      end
      @all
    end
  end
end
