# frozen_string_literal: true

require_relative 'benchmark_helper'

COUNT = 10_000
ARRAY = Array(0...COUNT)
LIST = LinkedList.new(0...COUNT)

def array_shift
  while ARRAY.shift; end
end

def list_shift
  while LIST.shift; end
end

Benchmark.bm do |x|
  x.report('Array#shift     ') { array_shift }
  x.report('LinkedList#shift') { list_shift }
end

# Ruby 3.1.2
# user     system      total        real
# Array#shift       0.000198   0.000002   0.000200 (  0.000198)
# LinkedList#shift  0.000909   0.000005   0.000914 (  0.000910)
