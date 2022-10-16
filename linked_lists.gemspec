# frozen_string_literal: true

require_relative 'lib/linked_lists/version'

Gem::Specification.new do |spec|
  spec.name = 'linked_lists'
  spec.version = LinkedLists::VERSION
  spec.authors = ['Mateusz Drewniak']
  spec.email = ['matmg24@gmail.com']

  spec.summary = 'Adds linked lists and doubly linked lists to Ruby.'
  spec.description = <<~DESC
    Adds the linked list structure to Ruby as a proper `Enumerable` class,
    like `Set` or `Array`.

    Has a similar set of methods to `Array` and `Set`.
  DESC
  spec.homepage = 'https://github.com/Verseth/linked_lists'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  # spec.extensions = ['ext/linked_lists/extconf.rb']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
