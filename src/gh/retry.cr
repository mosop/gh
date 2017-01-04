module Gh
  class Retry
    property! times : Int64?
    property wait : Int64 = 5000_i64
    property first_wait : Int64 = 0_i64

    macro int64(name, t, nilable = false)
      {%
        name = name.id
      %}
      def self.{{name}}(value : {{t}})
        o = new
        {% if nilable %}
          if value
            o.{{name}} = value.to_i64
          else
            o.{{name}} = nil
          end
        {% else %}
          o.{{name}} = value.to_i64
        {% end %}
        o
      end

      def {{name}}(value : {{t}})
        {% if nilable %}
          if value
            self.{{name}} = value.to_i64
          else
            self.{{name}} = nil
          end
        {% else %}
          self.{{name}} = value.to_i64
        {% end %}
        self
      end
    end

    int64 :times, Int::Primitive?, true
    int64 :wait, Int::Primitive
    int64 :first_wait, Int::Primitive

    def not_nil
      Processor.new(self).not_nil do |retry|
        yield retry
      end
    end

    def self.infinite
      Retry.new
    end

    class Processor
      getter times : Int64
      getter first_wait : Int64
      getter wait : Int64
      setter next_wait : Int64

      def initialize(retry : Retry)
        @times = if times = retry.times?
          times
        else
          -1_i64
        end
        @first_wait = retry.first_wait
        @wait = retry.wait
        @next_wait = retry.wait
      end

      def not_nil
        return nil if @times == 0
        sleep @first_wait if @first_wait > 0
        loop do
          result = yield self
          return result unless result.nil?
          @times -= 1 if @times > 0
          break if @times == 0
          sleep @next_wait
        end
      end

      def ends?
        @times == 1
      end
    end
  end
end
