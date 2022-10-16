# frozen_string_literal: true

require_relative 'benchmark_helper'

COUNT = 1000

def array_append
  ary = []
  COUNT.times { ary << _1 }
end

def list_append
  linked_list = LinkedList.new
  COUNT.times { linked_list << _1 }
end

Benchmark.ips do |x|
  x.report('Array#append     ') { array_append }
  x.report('LinkedList#append') { list_append }
  x.compare!
end

# Ruby 3.1.2
# Comparison:
#    Array#append     :    30031.2 i/s
#    LinkedList#append:       30.3 i/s - 989.63x  (± 0.00) slower
