module Gh
  class Retry
    property! times : Int64?
    property wait : Float64 = 5_f64
    property first_wait : Float64 = 0_f64

    macro prop(name, t, t2, nilable = false)
      {%
        name = name.id
        t2 = t2.id
      %}
      def self.{{name}}(value : {{t}})
        o = new
        {% if nilable %}
          if value
            o.{{name}} = value.to_{{t2}}
          else
            o.{{name}} = nil
          end
        {% else %}
          o.{{name}} = value.to_{{t2}}
        {% end %}
        o
      end

      def {{name}}(value : {{t}})
        {% if nilable %}
          if value
            self.{{name}} = value.to_{{t2}}
          else
            self.{{name}} = nil
          end
        {% else %}
          self.{{name}} = value.to_{{t2}}
        {% end %}
        self
      end
    end

    prop :times, Int::Primitive?, :i64, true
    prop :wait, Int::Primitive, :f64
    prop :first_wait, Int::Primitive, :f64

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
      getter first_wait : Float64
      getter wait : Float64
      setter next_wait : Float64

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
