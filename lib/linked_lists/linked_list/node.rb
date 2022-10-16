# frozen_string_literal: true

class LinkedList
  # Represents a node of a singly linked list.
  class Node
    class << self
      # @param value [Object] Value to be wrapped in a node.
      # @return [self]
      def wrap(value)
        return value if value.is_a?(self)

        new(value)
      end

      alias [] wrap
    end

    # @return [self, nil] Next node of the linked list.
    attr_accessor :next
    # @return [Object] The value stored by this node.
    attr_accessor :value

    # @param value [Object]
    # @param next_node [self, nil]
    def initialize(value = nil, next_node = nil)
      @value = value
      @next = next_node
    end

    # @return [String]
    def inspect
      "#<#{self.class} #{value.inspect}>"
    end

    # Inserts the given `objects` after `self`.
    #
    # Time complexity is *O(m)* where *m* is the length of given `objects`.
    #
    # @param objects [Object]
    # @return [self]
    def insert_after(*objects)
      prev_node = self
      objects.each do |obj|
        new_node = self.class.new obj
        new_node.next = prev_node.next
        prev_node.next = new_node
        prev_node = new_node
      end

      self
    end

    # Set this node as the head of
    # a new linked list.
    #
    # @return [LinkedList]
    def to_list
      list = LinkedList.new
      list.head = self
      list
    end
  end
end
