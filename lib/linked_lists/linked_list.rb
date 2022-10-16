# frozen_string_literal: true

require_relative 'linked_list/node'

# An `Enumerable` data structure
# which implements a singly linked list.
# It's a proper `Enumerable` object like `Array`, `Hash` or `Set`.
#
# Its API has been heavily inspired by `Set` and `Array`.
#
#   list = LinkedList[1, 2, 3, :foo]
#
# Prepending and shifting items is very fast and happens in *O(1)*.
#
#   list = LinkedList[:foo]
#   list.unshift :bar
#   list.prepend :baz
#   list >> 'foobar'
#   list #=> LinkedList["foobar", :baz, :bar, :foo]
#
# Appending is possible but requires the entire list to be traversed, which gives
# a time complexity of *O(n)*.
#
#   list = LinkedList[:foo]
#   list.push :bar
#   list.append :baz
#   list << 'foobar'
#   list #=> LinkedList[:foo, :bar, :baz, 'foobar']
#
# Optimal traversing is only possible in one direction, from head (first element)
# to tail (last element).
#
# To get the length of a linked list, the entire list has to be traversed
# which happens in *O(n)*.
#
#   LinkedList[].size #=> 0
#   LinkedList[:foo].length #=> 1
#   LinkedList[:foo, 1, 2, 3].count #=> 4
#
# Getting items by index is possible, but the list needs to be
# traversed from head to the index, which gives a time complexity of *O(n)*.
#
#   list = LinkedList["foobar", :baz, :bar, :foo]
#   list[0] #=> "foobar"
#   list.slice(0) #=> "foobar"
#   list[2] #=> :bar
#   list[-1] #=> :foo
#   list[1, 2] #=> [:baz, :bar]
#   list.slice(1, 2) #=> LinkedList[:baz, :bar]
#   list[1..3] #=> [:baz, :bar, :foo]
#
class LinkedList
  include ::Enumerable

  class << self
    # Create a new `LinkedList` with these elements
    # inserted.
    #
    # @param elements [Array]
    def [](*elements)
      new(elements)
    end
  end

  # The first element of the linked list.
  # Time complexity: *O(1)*
  #
  # @return [Node, nil]
  attr_accessor :head

  # @param enum [Object] Enumerable object that will be converted.
  def initialize(enum = nil)
    @head = nil
    return if enum.nil?

    concat(enum)
  end

  # The last element of the linked list.
  #
  # Keep in mind that in order to retrieve it the entire
  # list needs to be traversed.
  #
  # Time complexity is *O(n)*.
  #
  # @return [Node, nil]
  def tail
    each_node { |node| return node if node.next.nil? }
  end

  # Freezes the list and its every node.
  #
  # Time complexity is *O(n)*.
  #
  # @return [self]
  def freeze
    super
    each_node(&:freeze)

    self
  end

  # Removes all elements from `self`.
  # Sets the `head` to `nil`.
  #
  # Time complexity: *O(1)*.
  #
  # @return [self]
  def clear
    @head = nil
    self
  end

  # Checks if `head` is `nil`.
  #
  # Time complexity: *O(1)*.
  #
  # @return [Boolean]
  def empty?
    @head.nil?
  end

  # The number of elements in the list.
  # Keep in mind that the entire list needs to be traversed in order
  # to find out it's length.
  #
  # Time complexity is *O(n)*.
  #
  # @return [Integer]
  def size
    return 0 if empty?

    length = 0
    each_with_index { |_, i| length = i }

    length + 1
  end
  alias length size

  # Returns the last element, or the last `length` elements, of the linked list.
  # If the list is empty, the first form returns `nil`, and the second form returns an empty list.
  #
  # Keep in mind that it's only possible to traverse this list in one direction
  # from head to tail. So the entire list has to be traversed in order
  # to retrieve the last elements.
  #
  # Time complexity is *O(2n)*.
  #
  # @param length [Integer]
  # @return [Object, Array]
  def last(*args)
    to_a.last(*args)
  end

  # Returns the index of the first object in the linked list such that the object is `==` to `obj`.
  # Time complexity: *O(n)*
  #
  # If a block is given instead of an argument, returns the index
  # of the first object for which the block returns `true`. Returns `nil` if no match is found.
  #
  # Time complexity: *O(n)*
  #
  # @param obj [Object] Value that will be compared with the nodes of this list.
  # @return [Object, nil]
  def index(obj = nil)
    if block_given?
      each_with_index do |element, i|
        return i if yield(element)
      end

      return
    end

    each_with_index do |element, i|
      return i if obj == element
    end

    nil
  end

  # Returns the node at the provided index.
  # This list in not indexed so the entire list will have to
  # be traversed in the worst case.
  # Time complexity: *O(n)*
  #
  # @param index [Integer]
  # @return [Node, nil]
  def node_at(index)
    index = index.to_int
    return each_node.to_a.at(index) if index.negative?

    each_node.with_index do |node, i|
      return node if i == index
    end

    nil
  end

  # Returns the item at the provided index.
  # This list in not indexed so the entire list will have to
  # be traversed in the worst case.
  # Time complexity: *O(n)*
  #
  # @param index [Integer]
  # @return [Object, nil]
  def at(index)
    node_at(index)&.value
  end

  # Get the elements at the specified index. Head of the list is `0`.
  #
  # This list in not indexed so the entire list will have to
  # be traversed in the worst case.
  # Time complexity: *O(n)*
  #
  # @param index [Integer]
  # @param length [Integer, nil]
  # @return [Object, Array]
  def [](index, length = nil)
    slice_with_enum(::Array, index, length)
  end

  # Get the elements at the specified index. Head of the list is `0`.
  #
  # This list in not indexed so the entire list will have to
  # be traversed in the worst case.
  # Time complexity: *O(n)*
  #
  # @param index [Integer]
  # @param length [Integer, nil]
  # @return [Object, self]
  def slice(index, length = nil)
    slice_with_enum(self.class, index, length)
  end

  # Calls the given block once for each element in linked list, passing
  # the element as a parameter. Returns an enumerator if no block is
  # given.
  #
  # Time complexity: *O(n)*
  #
  # @yieldparam [Object] An element of the list.
  # @return [self, Enumerator]
  def each
    return enum_for(__method__) unless block_given?

    each_node { |node| yield node.value }
  end

  alias each_value each

  # Calls the given block once for each node in the linked list, passing
  # the node as a parameter. Returns an enumerator if no block is
  # given.
  #
  # Time complexity: *O(n)*
  #
  # @yieldparam [Node] A node of the list.
  # @return [self, Enumerator]
  def each_node
    return enum_for(__method__) unless block_given?
    return unless @head

    element = @head
    loop do
      yield element
      break if (element = element.next).nil?
    end

    self
  end

  # Returns a new `LinkedList` with the elements of `self` in reverse order.
  # Time complexity: *O(2n)*
  #
  # @return [self]
  def reverse
    result = self.class.new
    reverse_each do |obj|
      result << obj
    end

    result
  end

  # Returns a new `LinkedList` which consists of the values returned by the block.
  # Returns an enumerator if no block is given.
  #
  # Time complexity: *O(n)*
  #
  # @yieldparam [Object] An element of the list.
  # @return [self, Enumerator]
  def map
    return enum_for(__method__) unless block_given?

    result = self.class.new
    each_node do |node|
      result << yield(node.value)
    end

    result
  end
  alias collect map

  # Returns a list containing truthy elements returned by the block.
  #
  # With a block given, calls the block with successive elements;
  # returns a list containing each truthy value returned by the block.
  #
  # Time complexity: *O(n)*
  #
  # @yieldparam [Object] An element of the list.
  # @return [self, Enumerator]
  def filter_map
    return enum_for(__method__) unless block_given?

    result = self.class.new
    each_node do |node|
      next unless (block_result = yield(node.value))

      result << block_result
    end

    result
  end

  # Replaces the elements with ones returned by the block.
  # Returns an enumerator if no block is given.
  #
  # Time complexity: *O(n)*
  #
  # @yieldparam [Object] An element of the list.
  # @return [self, Enumerator]
  def map!
    return enum_for(__method__) unless block_given?

    each_node do |node|
      node.value = yield(node.value)
    end

    self
  end
  alias collect! map!

  # Returns a new `LinkedList` object whose entries are those for which the block returns a falsey value.
  # Or a new `Enumerator` if no block given.
  #
  # Time complexity: *O(n)*
  #
  # @yieldparam [Object] An element of the list.
  # @return [self, Enumerator]
  def reject
    return enum_for(__method__) unless block_given?

    select { |o| !yield(o) }
  end

  # Returns a new `LinkedList` object whose entries are those for which the block returns a truthy value.
  # Or a new Enumerator if no block given.
  #
  # Time complexity: *O(n)*
  #
  # @yieldparam [Object] An element of the list.
  # @return [self, Enumerator]
  def select
    return enum_for(__method__) unless block_given?

    result = self.class.new
    each do |value|
      result << value if yield(value)
    end

    result
  end
  alias filter select

  # Returns self whose entries are those for which the block returns a truthy value.
  # Or a new `Enumerator` if no block given.
  #
  # Time complexity: *O(n)*
  #
  # @yieldparam [Object] An element of the list.
  # @return [self, Enumerator, nil]
  def delete_if(&block)
    reject!(&block) || self
  end

  # Deletes the first item from `self` that is equal to `obj`.
  # Returns the deleted item, or `nil` if no matching item is found.
  #
  # Time complexity: *O(n)*
  #
  # @param obj [Object] object to be deleted
  # @return [Object]
  def delete(obj)
    removed = nil
    prev_node = nil
    each_node do |n|
      next (prev_node = n) unless n.value == obj

      delete_node_with_prev(prev_node, n.next)
      return n.value
    end

    removed
  end

  # Deletes all items from `self` that are equal to `obj`.
  # Returns the last deleted item, or `nil` if no matching item is found.
  #
  # Time complexity: *O(n)*
  #
  # @param obj [Object] object to be deleted
  # @return [Object]
  def delete_all(obj)
    removed = nil
    delete_if do |element|
      removed = element if element == obj
    end

    removed
  end

  # Deletes a node from `self` that is the same object as the given `node`.
  # Returns the deleted node, or `nil` if no matching item is found.
  #
  # Time complexity: *O(n)*
  #
  # @param node [Node] node to be deleted
  # @return [Node, nil]
  def delete_node(node)
    raise ::ArgumentError, 'value should be a node' unless node.is_a?(Node)

    removed = nil
    prev_node = nil
    each_node do |n|
      next (prev_node = n) unless n == node

      delete_node_with_prev(prev_node, n.next)
      return n
    end

    removed
  end

  # Deletes the element at the specified index
  # returning that element, or `nil` if the `index` is out of range.
  #
  # This list in not indexed so the entire list will have to
  # be traversed in the worst case.
  # Time complexity: *O(n)*
  #
  # @param index [Integer]
  # @return [Object, nil]
  def delete_at(index)
    prev_node = nil
    each_node.with_index do |node, i|
      return node.value if i == index && delete_node_with_prev(prev_node, node.next)

      prev_node = node
    end

    nil
  end

  # Removes and returns leading elements.
  # When no argument is given, removes and returns the first element.
  # When positive Integer argument `length` is given, removes the first `length` elements
  # and returns those elements in a new `Array`.
  #
  # Time complexity is *O(1)* when no `length` is given.
  # Otherwise it's *O(min(m, n))*, where *m* is the given `length` of elements to be shifted
  # and *n* is the length of `self`.
  #
  # @param length [Integer, nil]
  # @return [Object, Array]
  def shift(length = nil)
    raise ::TypeError, "no implicit conversion of #{length.class} into Integer" unless length.nil? || length.respond_to?(:to_int)
    raise ::ArgumentError, 'negative linked list size' if length&.negative?
    return if empty?

    unless length
      prev_head = @head
      @head = @head.next
      return prev_head.value
    end

    length = length.to_int
    removed = []
    each_node.with_index do |node, i|
      break if i == length

      removed << @head.value
      @head = node.next
    end

    removed
  end

  # Removes and returns trailing elements.
  #
  # When no argument is given and self is not empty, removes and returns the last element
  #
  # Keep in mind that the entire list has to be traversed
  # in the worst case to pop an item.
  #
  # Time complexity: *O(n)*.
  #
  # @param length [Integer, nil]
  # @return [Object, Array]
  def pop(length = nil)
    raise ::TypeError, "no implicit conversion of #{length.class} into Integer" unless length.nil? || length.respond_to?(:to_int)
    return [] if length&.zero?
    raise ::ArgumentError, 'negative linked list size' if length&.negative?

    index = length ? -length : -1
    ary = each_node.to_a
    node = ary[index] || @head
    prev_node = ary[index - 1]

    if prev_node.nil?
      @head = nil
    else
      prev_node.next = nil
    end

    return node&.value unless length

    node&.to_list.to_a
  end

  # Returns self whose entries are those for which the block returns a falsey value.
  # A new `Enumerator` if no block given.
  # Or `nil` if no entries were removed.
  #
  # Time complexity: *O(n)*
  #
  # @yieldparam [Object] An element of the list.
  # @return [self, Enumerator, nil]
  def reject!
    return enum_for(__method__) unless block_given?

    select! { |o| !yield(o) }
  end

  # Returns self whose entries are those for which the block returns a truthy value.
  # Or a new `Enumerator` if no block given.
  #
  # Time complexity: *O(n)*
  #
  # @yieldparam [Object] An element of the list.
  # @return [self, Enumerator, nil]
  def keep_if(&block)
    select!(&block) || self
  end

  # Returns self whose entries are those for which the block returns a truthy value.
  # A new `Enumerator` if no block given.
  # Or `nil` if no entries were removed.
  #
  # Time complexity: *O(n)*
  #
  # @yieldparam [Object] An element of the list.
  # @return [self, Enumerator, nil]
  def select!
    return enum_for(__method__) unless block_given?
    return if empty?

    removed = false
    prev_node = nil
    node = @head
    next_node = node.next
    loop do
      keep = yield(node.value)
      if keep
        prev_node = node
        node = prev_node.next
        next_node = node&.next
      else
        removed = true
        prev_node, node, next_node = delete_node_with_prev(prev_node, next_node)
      end

      break if node.nil?
    end

    return unless removed

    self
  end
  alias filter! select!

  # Time complexity: *O(n)*
  #
  # @param separator [String, nil]
  # @yieldparam [Object]
  # @return [String]
  def join(separator = nil)
    result = ::String.new
    each_node do |node|
      string_value = block_given? ? yield(node.value) : node.value
      result << string_value.to_s
      result << separator if separator && node.next
    end

    result
  end

  # Appends the given `objects` to `self`.
  #
  # Time complexity: *O(n)*.
  #
  # @param objects [Object]
  # @return [self]
  def push(*objects)
    return self if objects.empty?

    @head  = Node.new objects.shift if empty?
    tail.insert_after(*objects)

    self
  end
  alias << push
  alias add push
  alias append push

  # Prepends the given `objects` to `self`.
  #
  # Time complexity is *O(1)* if one item is given.
  # Otherwise it's *O(m)*, where *m* is the length of given `objects`.
  #
  # @param objects [Array]
  # @return [self]
  def unshift(*objects)
    objects.reverse_each do |obj|
      new_node = Node.new obj
      new_node.next = @head
      @head = new_node
    end

    self
  end
  alias >> unshift
  alias prepend unshift

  # Inserts given objects before or after the element at `Integer` index offset; returns `self`.
  #
  # Inserts all given objects before the element at offset index:
  #
  #   a = LinkedList[:foo, 'bar', 2]
  #   a.insert(1, :bat, :bam) # => LinkedList[:foo, :bat, :bam, "bar", 2]
  #
  # Extends the list if `index` is beyond the list (`index` >= `self.size`):
  #
  #   a = LinkedList[:foo, 'bar', 2]
  #   a.insert(5, :bat, :bam)
  #   a # => LinkedList[:foo, "bar", 2, nil, nil, :bat, :bam]
  #
  # Does nothing if no objects given:
  #
  #   a = LinkedList[:foo, 'bar', 2]
  #   a.insert(1)
  #   a.insert(50)
  #   a.insert(-50)
  #   a # => LinkedList[:foo, "bar", 2]
  #
  # @param index [Integer]
  # @param objects [Array]
  # @return [self]
  def insert(index, *objects)
    index = index.to_int

    raise ::ArgumentError, 'negative list index' if index.negative?
    return unshift(*objects) if index.zero?
    return self if objects.empty?

    last_node = nil
    prev_node = nil
    found_index = false
    last_index = 0
    each_node.with_index do |node, i|
      last_index = i
      last_node = node
      next (prev_node = node) unless i >= index

      found_index = true
      prev_node.insert_after(*objects)
      break
    end

    return self if found_index

    @head = last_node = Node.new if empty?

    loop do
      last_index += 1
      break if last_index >= index

      new_node = Node.new
      last_node.next = new_node
      last_node = new_node
    end
    last_node.insert_after(*objects)

    self
  end

  # Concatenates this linked list with another linked list or `Enumerable`.
  #
  # Time complexity is *O(m)*, where *m* is the length of given `enum`.
  #
  # @param enum [Object]
  # @return [self]
  def concat(enum)
    do_with_enum(enum) { |o| self << o }

    self
  end

  # Concatenates this linked list with another linked list.
  #
  # This version is faster for two linked lists but more unsafe
  # because concatenating them happens in place
  # by just linking the tail of the first list to the head of the second one.
  # This means that modifying the second list after concatenating it
  # will change the concatenated list as well!
  #
  # Time complexity is *O(n)*, where *n* is the length of `self`.
  #
  # @param list [self]
  # @return [self]
  def concat!(list)
    raise ::ArgumentError, 'value must be a linked list' unless list.instance_of?(self.class)

    tail.next = list.head

    self
  end

  # Returns a new `LinkedList` containing all non-nil elements from `self`
  #
  # Time complexity: *O(n)*
  #
  # @return [self]
  def compact
    result = self.class.new

    each do |value|
      next if value.nil?

      result << value
    end

    result
  end

  # Removes all `nil` elements from `self`.
  #
  # Returns `self` if any elements removed, otherwise `nil`.
  #
  # Time complexity: *O(n)*
  #
  # @return [self, nil]
  def compact!
    removed = nil
    prev_node = nil
    each_node do |node|
      if node.value.nil?
        removed = true
        prev_node, = delete_node_with_prev(prev_node, node.next)
        next
      end

      prev_node = node
    end
    return self if removed

    nil
  end

  # Checks whether `self` is a superlist of the provided list `other`
  # (if the `other` list is a sublist of `self`).
  # Time complexity is *O(n)*, where *n* is the length of `self`.
  #
  # @param other [self]
  # @return [Boolean]
  def superlist?(other)
    raise ::ArgumentError, 'value must be a linked list' unless other.is_a?(self.class)

    other.sublist?(self)
  end

  # Checks whether `self` is a sublist of the provided list `other`.
  # Time complexity is *O(m)*, where *m* is the length of `other`.
  #
  # @param other [self]
  # @return [Boolean]
  def sublist?(other)
    return true if equal?(other)
    raise ::ArgumentError, 'value must be a linked list' unless other.is_a?(self.class)
    return true if (empty? && !other.empty?) || (empty? && other.empty?)
    return false if !empty? && other.empty?

    self_node = @head
    other_node = other.head

    at_least_one_equal = false
    loop do
      return true if self_node.equal?(other_node)
      return true if self_node.nil?
      return false if other_node.nil?

      if self_node.value == other_node.value
        at_least_one_equal = true
        self_node = self_node.next
        other_node = other_node.next
        next
      end

      return false if at_least_one_equal

      other_node = other_node.next
    end

    true
  end

  # Returns a new LinkedList which is the result of
  # concatenating this linked list with another linked list or `Enumerable`.
  #
  # Time complexity is *O(n + m)*, where *n* is the length of `self` and *m* is the length of `other`.
  #
  # @param enum [Object]
  # @return [self]
  def +(other)
    dup.concat(other)
  end

  # Returns true if two linked lists are equal. The equality of each couple
  # of elements is defined according to `#==`.
  #
  # Time complexity is *O(min(n, m))*, where *n* is the length of `self`
  # and *m* is the length of `other`.
  #
  #     LinkedList[1, 2] == LinkedList[1, 2]                   #=> true
  #     LinkedList[1, 2] == LinkedList[1, 2.0]                 #=> true
  #     LinkedList[1, 3, 5] == LinkedList[1, 5]                #=> false
  #     LinkedList[1, 3, 5] == LinkedList[1, 3]                #=> false
  #     LinkedList['a', 'b', 'c'] == LinkedList['a', 'c', 'b'] #=> true
  #     LinkedList['a', 'b', 'c'] == ['a', 'c', 'b']           #=> false
  #
  # @return [Boolean]
  def eql?(other)
    return true if equal?(other)
    return false unless other.is_a?(self.class)

    self_node = @head
    other_node = other.head
    loop do
      break if self_node.nil? && other_node.nil?
      return false if self_node.nil? || other_node.nil?
      return false if self_node.value != other_node.value

      self_node = self_node.next
      other_node = other_node.next
    end

    true
  end
  alias == eql?

  # Returns `true` if the given object is a member of the list,
  # and `false` otherwise.
  #
  # Keep in mind that checking for inclusion will
  # will require the list to be traversed in its entirety
  # in the worst case.
  # Time complexity: *O(n)*.
  #
  # Used in case statements:
  #
  #     case :apple
  #     when LinkedList[:potato, :carrot]
  #       "vegetable"
  #     when LinkedList[:apple, :banana]
  #       "fruit"
  #     end
  #     # => "fruit"
  #
  # Or by itself:
  #
  #     LinkedList[1, 2, 3] === 2   #=> true
  #     LinkedList[1, 2, 3] === 4   #=> false
  #
  alias === include?

  # @return [Set]
  def to_set
    set = ::Set.new
    each do |value|
      set << value
    end

    set
  end

  # @return [String]
  def inspect
    "#<#{self.class}: {#{join(', ', &:inspect)}}>"
  end

  private

  def slice_with_enum(klass, index, length = nil)
    return klass.new if length&.zero?
    return at(index) if length.nil? && index.is_a?(::Numeric)
    return if length&.negative?

    range = if index.is_a?(::Range)
              index
            elsif length
              index..(index + length - 1)
            else
              index..index
            end

    if range.begin&.negative? || range.end&.negative?
      result = to_a[range]
      return result unless result.is_a?(::Array)

      return klass[*result]
    end

    result = klass.new
    added = nil
    each_with_index do |val, i|
      includes = range.include? i
      break if added && !includes
      next unless includes

      added ||= true
      result << val
    end
    return result unless result.empty?

    nil
  end

  def delete_node_with_prev(prev_node, next_node)
    if prev_node.nil?
      node = @head = next_node
      next_node = node&.next

      return [prev_node, node, next_node]
    end

    prev_node.next = next_node
    node = next_node
    next_node = node&.next

    [prev_node, node, next_node]
  end

  def initialize_dup(orig)
    super
    @head = nil
    orig.each { |o| self << o }
  end

  def initialize_clone(orig)
    super
    @head = nil
    orig.each { |o| self << o }
  end

  # @param enum [Object]
  # @return [void]
  def do_with_enum(enum, &block)
    return unless block
    return enum.each_entry(&block) if enum.respond_to?(:each_entry)
    return enum.each(&block) if enum.respond_to?(:each)

    raise ::ArgumentError, 'value must be enumerable'
  end
end
