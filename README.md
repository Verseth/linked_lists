# LinkedLists

Adds the linked list structure to Ruby as a proper `Enumerable` class,
like `Set` or `Array`.

Has a similar set of methods to `Array` and `Set`.

There are situations in which a linked list would be faster than an array.
Shifting and unshifting elements for example.

This library, for now, is implemented in Ruby which dwindles any performance
benefits from using this data structure when compared to the native Ruby `Array`.

I will reimplement it as a C extension, with the same API in the future.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add linked_lists

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install linked_lists

## Usage

There is a new data structure called `LinkedList` which may be used
similarly to `Set` or `Array`.

It is a proper `Enumerable`.

```ruby
list = LinkedList[1, 2, 3]
list #=> #<LinkedList: {1, 2, 3}>
list.shift #=> 1
list #=> #<LinkedList: {2, 3}>
list.unshift(:new) #=> #<LinkedList: {:new, 2, 3}>

list.each do |value|
    p value
end
# :new
# 2
# 3

LinkedList[1, 2] + LinkedList[5,  'str'] #=> #<LinkedList: {1, 2, 5, 'str'}>

LinkedList[10, 20, 30].map { |a| a * 2 } #=> #<LinkedList: {20, 40, 60}>
list = LinkedList[10, 20, 30]
list.map!(&:to_s)
list #=> #<LinkedList: {"10", "20", "30"}>
list.to_a #=> ["10", "20", "30"]

LinkedList[:foo, nil, :bar, nil].compact #=> #<LinkedList: {:foo, :bar}>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Verseth/linked_lists.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
