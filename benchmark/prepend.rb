# frozen_string_literal: true

require_relative 'benchmark_helper'

COUNT = 100000

def array_prepend
  ary = []
  COUNT.times { ary.prepend _1 }
end

def list_prepend
  linked_list = LinkedList.new
  COUNT.times { linked_list.prepend _1 }
end

Benchmark.ips do |x|
  x.report('Array#prepend     ') { array_prepend }
  x.report('LinkedList#prepend') { list_prepend }
  x.compare!
end

# Ruby 3.1.2
# Comparison:
#   Array#prepend     :    23358.6 i/s
#   LinkedList#prepend:     4713.2 i/s - 4.96x  (± 0.00) slower
