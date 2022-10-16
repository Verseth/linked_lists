# frozen_string_literal: true

require_relative 'benchmark_helper'

COUNT = 10_000
ARRAY = Array(0...COUNT)
LIST = LinkedList.new(0...COUNT)


def array_pop
  while ARRAY.pop; end
end

def list_pop
  while LIST.pop; end
end

Benchmark.bm do |x|
  x.report('Array#pop     ') { array_pop }
  x.report('LinkedList#pop') { list_pop }
end

# Ruby 3.1.2
# user     system      total        real
# Array#pop       0.000188   0.000022   0.000210 (  0.000207)
# LinkedList#pop  2.771274   0.046929   2.818203 (  2.818997)
