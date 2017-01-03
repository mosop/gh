module Gh
  class List(K, V)
    @paginator : Paginator
    @all = {} of K => V

    def initialize(path, q = nil)
      @paginator = Paginator.new(path, q)
    end

    def each(&block : V ->)
      return if @paginator.end_of_pages?
      @paginator.each_page do |res, json|
        json.each do |data|
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
