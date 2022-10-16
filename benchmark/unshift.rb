# frozen_string_literal: true

require_relative 'benchmark_helper'

COUNT = 1000

def array_unshift
  ary = []
  COUNT.times { ary.unshift _1 }
end

def list_unshift
  linked_list = LinkedList.new
  COUNT.times { linked_list.unshift _1 }
end

Benchmark.ips do |x|
  x.report('Array#unshift     ') { array_unshift }
  x.report('LinkedList#unshift') { list_unshift }
  x.compare!
end

# Ruby 3.1.2
# Comparison:
#   Array#unshift     :    23358.6 i/s
#   LinkedList#unshift:     4713.2 i/s - 4.96x  (± 0.00) slower
