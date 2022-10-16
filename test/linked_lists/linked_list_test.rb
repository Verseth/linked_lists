# frozen_string_literal: true

require 'test_helper'

class LinkedListTest < ::Minitest::Test
  def test_s_array_literal
    l = LinkedList[]
    assert_equal 0, l.size
    assert_equal [], l.to_a

    l = LinkedList[1, 2]
    assert_equal 2, l.size
    assert_equal [1, 2], l.to_a

    l = LinkedList[:foo, 'bar', 2, 10.15, nil]
    assert_equal 5, l.size
    assert_equal [:foo, 'bar', 2, 10.15, nil], l.to_a
  end

  def test_s_new
    l = LinkedList.new([1, 2, 3])
    assert_equal 3, l.size
    assert_equal [1, 2, 3], l.to_a

    l = LinkedList.new(::Set[1, 2, 3])
    assert_equal 3, l.size
    assert_equal [1, 2, 3], l.to_a

    l = LinkedList.new(1..5)
    assert_equal 5, l.size
    assert_equal [1, 2, 3, 4, 5], l.to_a

    l = LinkedList.new(nil)
    assert_equal 0, l.size
    assert_equal [], l.to_a

    assert_raises(::ArgumentError) { LinkedList.new(true) }
    assert_raises(::ArgumentError) { LinkedList.new(false) }
    assert_raises(::ArgumentError) { LinkedList.new('string') }
    assert_raises(::ArgumentError) { LinkedList.new(3) }
  end

  def test_dup
    l1 = LinkedList[1, 2, 3]
    l2 = l1.dup

    assert !l1.equal?(l2)
    assert l1.eql?(l2)

    l1.size.times do |i|
      assert l1.node_at(i) != l2.node_at(i)
    end

    l1 << :new
    assert_equal 4, l1.length
    assert_equal 3, l2.length

    l2 << :new2
    assert_equal 4, l1.length
    assert_equal 4, l2.length

    assert_equal :new, l1.last
    assert_equal :new2, l2.last
  end

  def test_clone
    l1 = LinkedList[1, 2, 3]
    l2 = l1.clone

    assert !l1.equal?(l2)
    assert l1.eql?(l2)

    l1.size.times do |i|
      assert l1.node_at(i) != l2.node_at(i)
    end

    l1 << :new
    assert_equal 4, l1.length
    assert_equal 3, l2.length

    l2 << :new2
    assert_equal 4, l1.length
    assert_equal 4, l2.length

    assert_equal :new, l1.last
    assert_equal :new2, l2.last
  end

  def test_head
    l = LinkedList[1, 2]
    assert l.head.is_a?(LinkedList::Node)
    assert_equal 1, l.head.value
    assert l.head.next.is_a?(LinkedList::Node)
    assert_equal 2, l.head.next.value
    assert_nil l.head.next.next
  end

  def test_tail
    l = LinkedList[1, 2]
    tail = l.tail
    assert tail.is_a?(LinkedList::Node)
    assert_equal 2, tail.value
    assert_nil tail.next

    assert_equal 1, l.head.value
    assert l.head.next.is_a?(LinkedList::Node)
    assert tail.equal? l.head.next
    assert_equal 2, l.head.next.value
    assert_nil l.head.next.next

    l = LinkedList[:foo, :bar, 'baz']
    assert_equal 'baz', l.tail.value
  end

  def test_freeze
    l = LinkedList[:foo, :bar, 'baz']
    l.freeze
    assert l.frozen?
    assert_raises(::FrozenError) { l << 1 }
    assert_raises(::FrozenError) { l >> 1 }
    assert_raises(::FrozenError) { l.delete :bar }
    assert_raises(::FrozenError) { l.clear }
    assert_raises(::FrozenError) { l.head.next = nil }

    l.each_node { |n| assert n.frozen? }
  end

  def test_clear
    l = LinkedList[:foo, :bar, 'baz']
    assert_equal [:foo, :bar, 'baz'], l.to_a
    assert l.head
    assert_equal 3, l.size
    l.clear
    assert_nil l.head
    assert_equal 0, l.size
    assert_equal [], l.to_a
  end

  def test_empty
    assert !LinkedList[:foo, :bar, 'baz'].empty?
    assert !LinkedList[nil].empty?
    assert LinkedList[].empty?
    assert LinkedList.new.empty?
  end

  def test_size
    assert_equal 3, LinkedList[:foo, :bar, 'baz'].size
    assert_equal 1, LinkedList[nil].size
    assert_equal 2, LinkedList[1, 5].size
    assert_equal 0, LinkedList[].size
    assert_equal 0, LinkedList.new.size

    l = LinkedList.new
    10.times do |i|
      l << i
      assert_equal i + 1, l.size
    end

    l = LinkedList.new(0...20)
    initial_length = l.size
    assert_equal 20, initial_length
    (0...20).reverse_each.with_index do |val, i|
      l.delete(val)
      assert_equal initial_length - i - 1, l.size
    end
  end

  def test_last
    l = LinkedList[:foo, :bar, 'baz']
    assert_equal 'baz', l.last
    assert_equal [], l.last(0)
    assert_equal ['baz'], l.last(1)
    assert_equal [:bar, 'baz'], l.last(2)
    assert_equal [:foo, :bar, 'baz'], l.last(3)
    assert_equal [:foo, :bar, 'baz'], l.last(4)
    assert_equal [:foo, :bar, 'baz'], l.last(20)

    l = LinkedList[1, 2, 3, 4, 5, 6, 7, 8]
    assert_equal 8, l.last
    assert_equal [], l.last(0)
    assert_equal [8], l.last(1)
    assert_equal [7, 8], l.last(2)
    assert_equal [6, 7, 8], l.last(3)
    assert_equal [5, 6, 7, 8], l.last(4)
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8], l.last(20)

    l = LinkedList[]
    assert_nil l.last
    assert_equal [], l.last(0)
    assert_equal [], l.last(1)
    assert_equal [], l.last(15)

    assert_raises(::ArgumentError) { l.last(-2) }
    assert_raises(::TypeError) { l.last('str') }
    assert_raises(::TypeError) { l.last(::Object.new) }
    assert_raises(::TypeError) { l.last(::Object) }
    assert_raises(::TypeError) { l.last([1]) }
    assert_raises(::TypeError) { l.last({}) }
  end

  def test_index
    l = LinkedList[1, 2, 3, 4, 5, 6, 7, 8]
    assert_equal 0, l.index(1)
    assert_equal 7, l.index(8)
    assert_equal 3, l.index(4)
    assert_nil l.index(:elo)
    assert_nil l.index(20)
    assert_equal(4, l.index { |o| o > 4 })
    assert_nil(l.index { |o| o < -2 })

    l = LinkedList[:foo, :bar, 'baz']
    assert_equal 0, l.index(:foo)
    assert_equal 2, l.index('baz')
    assert_equal 1, l.index(:bar)
    assert_nil l.index(10)
    assert_nil l.index(Object)
    assert_equal(1, l.index { |o| %i[bar baz].include? o })
    assert_nil(l.index { false })
    assert_equal(0, l.index { true })
  end

  def test_node_at
    l = LinkedList[:foo, :bar, 'baz']
    assert l.node_at(0).is_a?(LinkedList::Node)
    assert_equal :foo, l.node_at(0).value
    assert_equal :foo, l.node_at(0.2).value
    assert_equal l.node_at(1), l.node_at(0).next
    assert_equal 'baz', l.node_at(2).value
    assert_nil l.node_at(2).next
    assert_nil l.node_at(15)
    assert_nil l.node_at(-20)
    assert_nil l.node_at(-20)

    assert_raises(::NoMethodError) { l.node_at('str') }
    assert_raises(::NoMethodError) { l.node_at(nil) }
    assert_raises(::NoMethodError) { l.node_at(1..2) }
    assert_raises(::NoMethodError) { l.node_at([1]) }
    assert_raises(::NoMethodError) { l.node_at({}) }
    assert_raises(::NoMethodError) { l.node_at(::Object) }
    assert_raises(::NoMethodError) { l.node_at(::Object.new) }
  end

  def test_at
    l = LinkedList[:foo, :bar, 'baz']
    assert !l.at(0).is_a?(LinkedList::Node)
    assert_equal :foo, l.at(0)
    assert_equal :foo, l.at(0.2)
    assert_equal 'baz', l.at(2)
    assert_equal 'baz', l.at(-1)
    assert_equal :bar, l.at(-2)
    assert_equal :foo, l.at(-3)
    assert_nil l.at(3)
    assert_nil l.at(15)
    assert_nil l.at(-20)
    assert_nil l.at(-20)

    assert_raises(::NoMethodError) { l.at('str') }
    assert_raises(::NoMethodError) { l.at(nil) }
    assert_raises(::NoMethodError) { l.at(1..2) }
    assert_raises(::NoMethodError) { l.at([1]) }
    assert_raises(::NoMethodError) { l.at({}) }
    assert_raises(::NoMethodError) { l.at(::Object) }
    assert_raises(::NoMethodError) { l.at(::Object.new) }
  end

  def test_square_brackets
    l = LinkedList[:foo, :bar, 'baz', 20, 30, 40, 50, 60]
    assert_equal :foo, l[0]
    assert_equal :bar, l[1]
    assert_equal 'baz', l[2]
    assert_equal 60, l[-1]
    assert_equal 50, l[-2]
    assert_equal 40, l[-3]
    assert_nil l[-20]
    assert_nil l[30]

    assert_equal [], l[0, 0]
    assert_equal [], l[1, 0]
    assert_equal [:foo], l[0, 1]
    assert_equal [:bar], l[1, 1]
    assert_equal [20, 30], l[3, 2]
    assert_equal [20, 30, 40, 50, 60], l[3, 40]
    assert_equal [30, 40, 50], l[-4, 3]

    assert_equal ['baz', 20, 30, 40], l[2..5]
    assert_equal ['baz', 20, 30], l[2...5]
    assert_equal [30, 40, 50], l[-4..-2]
    assert_equal [30, 40], l[-4...-2]
  end

  def test_slice
    l = LinkedList[:foo, :bar, 'baz', 20, 30, 40, 50, 60]
    assert_equal :foo, l.slice(0)
    assert_equal :bar, l.slice(1)
    assert_equal 'baz', l.slice(2)
    assert_equal 60, l.slice(-1)
    assert_equal 50, l.slice(-2)
    assert_equal 40, l.slice(-3)
    assert_nil l.slice(-20)
    assert_nil l.slice(30)

    assert_equal LinkedList[], l.slice(0, 0)
    assert_equal LinkedList[], l.slice(1, 0)
    assert_equal LinkedList[:foo], l.slice(0, 1)
    assert_equal LinkedList[:bar], l.slice(1, 1)
    assert_equal LinkedList[20, 30], l.slice(3, 2)
    assert_equal LinkedList[20, 30, 40, 50, 60], l.slice(3, 40)
    assert_equal LinkedList[30, 40, 50], l.slice(-4, 3)

    assert_equal LinkedList['baz', 20, 30, 40], l.slice(2..5)
    assert_equal LinkedList['baz', 20, 30], l.slice(2...5)
    assert_equal LinkedList[30, 40, 50], l.slice(-4..-2)
    assert_equal LinkedList[30, 40], l.slice(-4...-2)
  end

  def test_each
    ary = [0, 1, 2, 3, 4]
    l = LinkedList.new(ary)
    assert_equal 5, l.size
    assert l.each.instance_of?(::Enumerator)

    new_ary = []
    l.each do |val|
      new_ary << val
    end
    assert_equal ary, new_ary
  end

  def test_each_node
    ary = [0, 1, 2, 3, 4]
    l = LinkedList.new(ary)
    assert_equal 5, l.size
    assert l.each_node.instance_of?(::Enumerator)

    new_ary = []
    l.each_node do |node|
      assert node.is_a?(LinkedList::Node)
      new_ary << node.value
    end
    assert_equal ary, new_ary
  end

  def test_reverse
    l = LinkedList[20, 30, 40, 50, 60]
    assert l.reverse.is_a?(LinkedList)
    assert_equal LinkedList[60, 50, 40, 30, 20], l.reverse
    assert !l.equal?(l.reverse)
  end

  def test_map
    l = LinkedList[20, 30, 40, 50, 60]
    assert l.map.instance_of?(::Enumerator)

    new_l = l.map { |o| o * 2 }
    assert !l.equal?(new_l)
    assert_equal LinkedList[20, 30, 40, 50, 60], l
    assert_equal LinkedList[40, 60, 80, 100, 120], new_l
  end

  def test_filter_map
    l = LinkedList[20, 30, 40, 50, 60]
    assert l.filter_map.instance_of?(::Enumerator)

    new_l = l.filter_map { |o| o * 2 }
    assert !l.equal?(new_l)
    assert_equal LinkedList[20, 30, 40, 50, 60], l
    assert_equal LinkedList[40, 60, 80, 100, 120], new_l

    l = LinkedList[1, 2, 3, false, 'string', nil, 10, nil, nil]
    assert l.filter_map.instance_of?(::Enumerator)

    new_l = l.filter_map { |o| o * 2 if o }
    assert !l.equal?(new_l)
    assert_equal LinkedList[1, 2, 3, false, 'string', nil, 10, nil, nil], l
    assert_equal LinkedList[2, 4, 6, 'stringstring', 20], new_l
  end

  def test_map!
    l = LinkedList[20, 30, 40, 50, 60]
    assert l.map!.instance_of?(::Enumerator)

    new_l = l.map! { |o| o * 2 }
    assert l.equal?(new_l)
    assert_equal LinkedList[40, 60, 80, 100, 120], l
  end

  def test_reject
    l = LinkedList[5, 8, 12, 50]
    assert l.reject.instance_of?(::Enumerator)

    new_l = l.reject { |o| o > 10 }
    assert !l.equal?(new_l)
    assert_equal LinkedList[5, 8, 12, 50], l
    assert_equal LinkedList[5, 8], new_l
  end

  def test_reject!
    l = LinkedList[5, 8, 12, 50]
    assert l.reject!.instance_of?(::Enumerator)

    new_l = l.reject! { |o| o > 10 }
    assert l.equal?(new_l)
    assert_equal LinkedList[5, 8], l

    assert_nil(l.reject! { |o| o > ::Float::INFINITY })
    assert_equal LinkedList[5, 8], l
  end

  def test_select
    l = LinkedList['regular', 'premium', 'sale', 'gone']
    assert l.select.instance_of?(::Enumerator)

    new_l = l.select { |o| o.length < 7 }
    assert !l.equal?(new_l)
    assert_equal LinkedList['regular', 'premium', 'sale', 'gone'], l
    assert_equal LinkedList['sale', 'gone'], new_l
  end

  def test_select!
    l = LinkedList['regular', 'premium', 'sale', 'gone']
    assert l.select!.instance_of?(::Enumerator)

    new_l = l.select! { |o| o.length < 7 }
    assert l.equal?(new_l)
    assert_equal LinkedList['sale', 'gone'], l

    assert_nil(l.select! { |o| o.length < ::Float::INFINITY })
    assert_equal LinkedList['sale', 'gone'], l
  end

  def test_keep_if
    l = LinkedList[5, 8, 12, 50]
    assert l.keep_if.instance_of?(::Enumerator)

    new_l = l.keep_if { |o| o <= 10 }
    assert l.equal?(new_l)
    assert_equal LinkedList[5, 8], l

    assert_equal(l, l.keep_if { |o| o < ::Float::INFINITY })
    assert_equal LinkedList[5, 8], l
  end

  def test_delete_if
    l = LinkedList[5, 8, 12, 50]
    assert l.delete_if.instance_of?(::Enumerator)

    new_l = l.delete_if { |o| o > 10 }
    assert l.equal?(new_l)
    assert_equal LinkedList[5, 8], l

    assert_equal(l, l.delete_if { |o| o > ::Float::INFINITY })
    assert_equal LinkedList[5, 8], l
  end

  def test_delete
    l = LinkedList[74, :foo, 74, :other]
    assert_equal 4, l.size
    assert_equal 74, l.delete(74)
    assert_equal 3, l.size
    assert_equal LinkedList[:foo, 74, :other], l

    assert_equal :other, l.delete(:other)
    assert_equal 2, l.size
    assert_equal LinkedList[:foo, 74], l

    assert_nil l.delete(:nonexistent)
    assert_equal 2, l.size
    assert_equal LinkedList[:foo, 74], l
  end

  def test_delete_all
    l = LinkedList[74, :foo, 74, :other]
    assert_equal 4, l.size
    assert_equal 74, l.delete_all(74)
    assert_equal 2, l.size
    assert_equal LinkedList[:foo, :other], l

    assert_equal :other, l.delete_all(:other)
    assert_equal 1, l.size
    assert_equal LinkedList[:foo], l

    assert_nil l.delete_all(:nonexistent)
    assert_equal 1, l.size
    assert_equal LinkedList[:foo], l
  end

  def test_delete_node
    l = LinkedList[74, :foo, 74, :other]
    assert_equal 4, l.size
    node = l.node_at(2)
    assert_equal node, l.delete_node(node)
    assert_equal 3, l.size, l.inspect
    assert_equal LinkedList[74, :foo, :other], l

    assert_nil l.delete_node(LinkedList::Node.new)

    assert_raises(::ArgumentError) { l.delete_node 2 }
    assert_raises(::ArgumentError) { l.delete_node 74 }
    assert_raises(::ArgumentError) { l.delete_node :foo }
  end

  def test_delete_at
    l = LinkedList[80, 70, 40, 135, 2.2]
    assert_equal 5, l.size
    assert_equal 70, l.delete_at(1)
    assert_equal 4, l.size
    assert_equal LinkedList[80, 40, 135, 2.2], l

    assert_equal 2.2, l.delete_at(3)
    assert_equal 3, l.size
    assert_equal LinkedList[80, 40, 135], l

    assert_equal 80, l.delete_at(0)
    assert_equal 2, l.size
    assert_equal LinkedList[40, 135], l

    assert_nil l.delete_at(10)
    assert_equal 2, l.size
    assert_equal LinkedList[40, 135], l
  end

  def test_shift
    l = LinkedList[80, 70, 40, 135, 2.2]
    assert_equal 5, l.size
    assert_equal 80, l.shift
    assert_equal 4, l.size
    assert_equal LinkedList[70, 40, 135, 2.2], l

    assert_equal 70, l.shift
    assert_equal 3, l.size

    assert_equal 40, l.shift
    assert_equal 2, l.size

    assert_equal 135, l.shift
    assert_equal 1, l.size

    assert_equal 2.2, l.shift
    assert_equal 0, l.size

    assert_nil l.shift
    assert_equal 0, l.size
    assert_nil l.shift
    assert_equal 0, l.size

    l = LinkedList.new(0...20)
    assert_equal 20, l.size
    assert_equal [0, 1], l.shift(2)
    assert_equal 18, l.size
    assert_equal 2, l.first

    assert_equal [2], l.shift(1)
    assert_equal 17, l.size

    assert_equal (3..12).to_a, l.shift(10)
    assert_equal 7, l.size

    assert_equal (13..19).to_a, l.shift(25)
    assert_equal 0, l.size

    assert_nil l.shift(3)
    assert_equal 0, l.size

    assert_raises(::ArgumentError) { l.shift(-1) }
    assert_raises(::ArgumentError) { l.shift(-20) }
    assert_raises(::TypeError) { l.shift('str') }
    assert_raises(::TypeError) { l.shift({}) }
    assert_raises(::TypeError) { l.shift([]) }
  end

  def test_pop
    l = LinkedList[80, 70, 40, 135, 2.2]
    assert_equal 5, l.size
    assert_equal 2.2, l.pop
    assert_equal 4, l.size
    assert_equal LinkedList[80, 70, 40, 135], l

    assert_equal 135, l.pop
    assert_equal 3, l.size

    assert_equal 40, l.pop
    assert_equal 2, l.size

    assert_equal 70, l.pop
    assert_equal 1, l.size

    assert_equal 80, l.pop
    assert_equal 0, l.size

    assert_nil l.pop
    assert_equal 0, l.size
    assert_nil l.pop
    assert_equal 0, l.size

    l = LinkedList.new(0...20)
    assert_equal 20, l.size
    assert_equal [18, 19], l.pop(2)
    assert_equal 18, l.size
    assert_equal 17, l.last

    assert_equal [17], l.pop(1)
    assert_equal 17, l.size

    assert_equal (7..16).to_a, l.pop(10)
    assert_equal 7, l.size

    assert_equal (0..6).to_a, l.pop(25)
    assert_equal 0, l.size

    assert_equal [], l.pop(3)
    assert_equal 0, l.size

    assert_raises(::ArgumentError) { l.pop(-1) }
    assert_raises(::ArgumentError) { l.pop(-20) }
    assert_raises(::TypeError) { l.pop('str') }
    assert_raises(::TypeError) { l.pop({}) }
    assert_raises(::TypeError) { l.pop([]) }
  end

  def test_join
    l = LinkedList[1, :symbol, 'string', 2.5]
    assert_equal '1symbolstring2.5', l.join
    assert_equal '1 -> symbol -> string -> 2.5', l.join(' -> ')
    assert_equal('1:symbol"string"2.5', l.join(&:inspect))
    assert_equal('1, :symbol, "string", 2.5', l.join(', ', &:inspect))
  end

  def test_push
    l = LinkedList[1]
    assert_equal 1, l.size

    assert_equal l, l.push(2)
    assert_equal 2, l.size
    assert_equal LinkedList[1, 2], l

    l = LinkedList.new
    assert_equal 0, l.size

    l.push 25
    assert_equal 1, l.size
    assert_equal LinkedList[25], l
  end

  def test_unshift
    l = LinkedList.new
    assert_equal 0, l.size

    assert_equal l, l.unshift(31)
    assert_equal 1, l.size
    assert_equal LinkedList[31], l

    assert_equal l, l.unshift(:new)
    assert_equal 2, l.size
    assert_equal LinkedList[:new, 31], l
  end

  def test_insert
    l = LinkedList.new
    assert_equal 0, l.size

    assert_equal l, l.insert(0, :new)
    assert_equal 1, l.size
    assert_equal LinkedList[:new], l

    assert_equal l, l.insert(0, 1, 2, 3)
    assert_equal 4, l.size
    assert_equal LinkedList[1, 2, 3, :new], l

    assert_equal l, l.insert(2, :elo)
    assert_equal 5, l.size
    assert_equal LinkedList[1, 2, :elo, 3, :new], l

    assert_equal l, l.insert(3, 'string', 'and', 'things')
    assert_equal 8, l.size
    assert_equal LinkedList[1, 2, :elo, 'string', 'and', 'things', 3, :new], l

    l = LinkedList.new
    assert_equal 0, l.size

    l.insert(5, :foo)
    assert_equal 6, l.size
    assert_equal LinkedList[nil, nil, nil, nil, nil, :foo], l

    l.insert(7, 10)
    assert_equal 8, l.size
    assert_equal LinkedList[nil, nil, nil, nil, nil, :foo, nil, 10], l

    l.insert(8, :last)
    assert_equal 9, l.size
    assert_equal LinkedList[nil, nil, nil, nil, nil, :foo, nil, 10, :last], l
  end

  def test_concat
    l = LinkedList.new
    assert_equal l, l.concat(LinkedList.new)
    assert_equal LinkedList.new, l
    assert_equal l, l.concat(LinkedList[1, 2, 3])
    assert_equal LinkedList[1, 2, 3], l
    assert_equal l, l.concat(LinkedList[:foo])
    assert_equal LinkedList[1, 2, 3, :foo], l
    assert_equal l, l.concat(LinkedList.new)
    assert_equal LinkedList[1, 2, 3, :foo], l

    l = LinkedList.new
    assert_equal l, l.concat([1, 2, 3])
    assert_equal LinkedList[1, 2, 3], l
    assert_equal l, l.concat([:foo])
    assert_equal LinkedList[1, 2, 3, :foo], l

    l = LinkedList.new
    assert_equal l, l.concat(::Set[1, 2, 3])
    assert_equal LinkedList[1, 2, 3], l
    assert_equal l, l.concat(::Set[:foo])
    assert_equal LinkedList[1, 2, 3, :foo], l

    l = LinkedList.new
    assert_equal l, l.concat({ bar: :baz, some: 1 })
    assert_equal LinkedList[[:bar, :baz], [:some, 1]], l
    assert_equal l, l.concat({ 'other' => 2 })
    assert_equal LinkedList[[:bar, :baz], [:some, 1], ['other', 2]], l

    assert_raises(::ArgumentError) { l.concat('str') }
    assert_raises(::ArgumentError) { l.concat(1) }
    assert_raises(::ArgumentError) { l.concat(::Object) }
    assert_raises(::ArgumentError) { l.concat(::Object.new) }
  end

  def test_concat!
    l = LinkedList[:first]
    l2 = LinkedList[1, 2, 3]
    assert_equal l, l.concat!(l2)
    assert_equal LinkedList[:first, 1, 2, 3], l
    l2 << :awesome
    assert_equal LinkedList[1, 2, 3, :awesome], l2
    assert_equal LinkedList[:first, 1, 2, 3, :awesome], l

    l3 = LinkedList[:foo]
    assert_equal l, l.concat!(l3)
    assert_equal LinkedList[:first, 1, 2, 3, :awesome, :foo], l
    l3 << 'l3 value'
    assert_equal LinkedList[:foo, 'l3 value'], l3
    assert_equal LinkedList[:first, 1, 2, 3, :awesome, :foo, 'l3 value'], l

    assert_raises(::ArgumentError) { l.concat!(::Set['2', 1]) }
    assert_raises(::ArgumentError) { l.concat!({ some: :hash }) }
    assert_raises(::ArgumentError) { l.concat!([1, 2]) }
    assert_raises(::ArgumentError) { l.concat!('str') }
    assert_raises(::ArgumentError) { l.concat!(1) }
    assert_raises(::ArgumentError) { l.concat!(::Object) }
    assert_raises(::ArgumentError) { l.concat!(::Object.new) }
  end

  def test_compact
    l = LinkedList.new
    new_l = l.compact
    assert !l.equal?(new_l)
    assert_equal l, new_l
    assert_equal LinkedList[], new_l

    l = LinkedList[nil, nil, nil, nil]
    new_l = l.compact
    assert !l.equal?(new_l)
    assert_equal LinkedList[nil, nil, nil, nil], l
    assert_equal LinkedList[], new_l

    l = LinkedList[1, 2, 0, '', 'str', :sym, [], {}]
    new_l = l.compact
    assert !l.equal?(new_l)
    assert_equal l, new_l
    assert_equal LinkedList[1, 2, 0, '', 'str', :sym, [], {}], new_l

    l = LinkedList[nil, 1, 2, nil, nil, 0, '', 'str', :sym, [], {}, nil]
    new_l = l.compact
    assert !l.equal?(new_l)
    assert_equal LinkedList[nil, 1, 2, nil, nil, 0, '', 'str', :sym, [], {}, nil], l
    assert_equal LinkedList[1, 2, 0, '', 'str', :sym, [], {}], new_l
  end

  def test_compact!
    l = LinkedList.new
    assert_nil l.compact!
    assert_equal LinkedList[], l

    l = LinkedList[nil, nil, nil, nil]
    new_l = l.compact!
    assert l.equal?(new_l)
    assert_equal LinkedList[], l

    l = LinkedList[1, 2, 0, '', 'str', :sym, [], {}]
    assert_nil l.compact!
    assert_equal LinkedList[1, 2, 0, '', 'str', :sym, [], {}], l

    l = LinkedList[nil, 1, 2, nil, nil, nil, 0, '', 'str', :sym, [], {}, nil]
    new_l = l.compact!
    assert l.equal?(new_l)
    assert_equal LinkedList[1, 2, 0, '', 'str', :sym, [], {}], l
  end

  def test_superlist?
    assert LinkedList.new.superlist?(LinkedList.new)
    assert LinkedList[1].superlist?(LinkedList.new)
    assert LinkedList[nil].superlist?(LinkedList.new)
    assert LinkedList[1, 2, 3, :foo].superlist?(LinkedList.new)

    assert !LinkedList.new.superlist?(LinkedList[1])
    assert !LinkedList.new.superlist?(LinkedList[nil])
    assert !LinkedList.new.superlist?(LinkedList[1, 2, 3])
    assert !LinkedList.new.superlist?(LinkedList[:foo, :bar])

    l = LinkedList[1, 2, 3, :foo, :bar, 'something']
    assert l.superlist?(LinkedList[1])
    assert l.superlist?(LinkedList[1, 2, 3])
    assert l.superlist?(LinkedList[2, 3, :foo])
    assert l.superlist?(LinkedList[:bar])
    assert l.superlist?(LinkedList[:bar, 'something'])
    assert l.superlist?(LinkedList['something'])

    assert !l.superlist?(LinkedList[2, :foo])
    assert !l.superlist?(LinkedList[1, 'something'])
    assert !l.superlist?(LinkedList['something', nil])
  end

  def test_sublist?
    assert LinkedList.new.sublist?(LinkedList.new)
    assert LinkedList.new.sublist?(LinkedList[1])
    assert LinkedList.new.sublist?(LinkedList[nil])
    assert LinkedList.new.sublist?(LinkedList[1, 2, 3, :foo])

    assert !LinkedList[1].sublist?(LinkedList.new)
    assert !LinkedList[nil].sublist?(LinkedList.new)
    assert !LinkedList[1, 2, 3].sublist?(LinkedList.new)
    assert !LinkedList[:foo, :bar].sublist?(LinkedList.new)

    l = LinkedList[1, 2, 3, :foo, :bar, 'something']
    assert LinkedList[1].sublist?(l)
    assert LinkedList[1, 2, 3].sublist?(l)
    assert LinkedList[2, 3, :foo].sublist?(l)
    assert LinkedList[:bar].sublist?(l)
    assert LinkedList[:bar, 'something'].sublist?(l)
    assert LinkedList['something'].sublist?(l)

    assert !LinkedList[2, :foo].sublist?(l)
    assert !LinkedList[1, 'something'].sublist?(l)
    assert !LinkedList['something', nil].sublist?(l)
  end

  def test_plus
    assert_equal LinkedList[], LinkedList.new + LinkedList.new
    assert_equal LinkedList[1, 2, 3], LinkedList.new + LinkedList[1, 2, 3]
    assert_equal LinkedList[1, 2, 3, :foo], LinkedList[1, 2, 3] + LinkedList[:foo]
    assert_equal LinkedList[1, 2, 3, :foo], LinkedList[1, 2, 3, :foo] + LinkedList.new

    assert_equal LinkedList[1, 2, 3], LinkedList.new + [1, 2, 3]
    assert_equal LinkedList[1, 2, 3, :foo], LinkedList[1, 2, 3] + [:foo]

    assert_equal LinkedList[1, 2, 3], LinkedList.new + ::Set[1, 2, 3]
    assert_equal LinkedList[1, 2, 3, :foo], LinkedList[1, 2, 3] + ::Set[:foo]

    assert_equal LinkedList[[:bar, :baz], [:some, 1]], LinkedList.new + { bar: :baz, some: 1 }
    assert_equal LinkedList['hello', 1, ['other', 2]], LinkedList['hello', 1] + { 'other' => 2 }

    l = LinkedList[1, 2, 3]
    assert_raises(::ArgumentError) { l + 'str' }
    assert_raises(::ArgumentError) { l + 1 }
    assert_raises(::ArgumentError) { l + ::Object }
    assert_raises(::ArgumentError) { l + ::Object.new }
  end

  def test_eql?
    assert !LinkedList.new.eql?(::Set[])
    assert !LinkedList.new.eql?([])
    assert LinkedList.new.eql?(LinkedList.new)
    assert !LinkedList[nil].eql?(LinkedList.new)
    assert !LinkedList.new.eql?(LinkedList[nil])
    assert LinkedList[nil].eql?(LinkedList[nil])
    assert LinkedList[1, 2, 3].eql?(LinkedList[1, 2, 3])
    assert !LinkedList[1, 2, 3, 4].eql?(LinkedList[1, 2, 3])
    assert !LinkedList[:foo, 'bar', 5.2].eql?(LinkedList[:foo, 'bar', 5.3])
    assert !LinkedList[:foo, 'bar', 5.3].eql?(LinkedList[:foo, 'bar', 5.2])
    assert LinkedList[1, 2, { foo: :bar }].eql?(LinkedList[1, 2, { foo: :bar }])
    assert !LinkedList[1, 2, { foo: :lol }].eql?(LinkedList[1, 2, { foo: :bar }])
    assert !LinkedList[1, 2, { foo: :bar }].eql?(LinkedList[1, 2, { foo: :lol }])
  end

  def test_include?
    l = LinkedList.new
    assert !l.include?(1)
    assert !l.include?(nil)
    assert !l.include?('str')

    l = LinkedList[1, 2, 3]
    assert l.include?(1)
    assert l.include?(3)
    assert l.include?(2)
    assert !l.include?(5)
    assert !l.include?(-1)
    assert !l.include?(nil)

    l = LinkedList['foo', 'bar', :lol, 1, :lol]
    assert l.include?('foo')
    assert l.include?('bar')
    assert l.include?(:lol)
    assert !l.include?(:lolo)
    assert !l.include?('foor')
    assert !l.include?(nil)

    l = LinkedList[nil, nil]
    assert l.include?(nil)
    assert !l.include?(1)
  end

  def test_to_set
    assert_equal ::Set[1, 2, 3], LinkedList[1, 2, 3].to_set
    assert_equal ::Set['foo', 'bar'], LinkedList['foo', 'bar'].to_set
    assert_equal ::Set[:sym, :other, 2], LinkedList[:sym, :other, :sym, 2, :sym, :other].to_set
  end

  def test_inspect
    assert_equal '#<LinkedList: {}>', LinkedList.new.inspect
    assert_equal '#<LinkedList: {nil, nil, nil}>', LinkedList[nil, nil, nil].inspect
    assert_equal '#<LinkedList: {1, 2, nil, 3}>', LinkedList[1, 2, nil, 3].inspect
    assert_equal '#<LinkedList: {:foo, :bar}>', LinkedList[:foo, :bar].inspect
    assert_equal '#<LinkedList: {"string", 2.0, String}>', LinkedList['string', 2.0, ::String].inspect
  end
end
