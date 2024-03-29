# frozen_string_literal: true

require_relative 'lib/spiderb/version'

Gem::Specification.new do |spec|
  spec.name          = 'spiderb'
  spec.version       = Spiderb::VERSION
  spec.authors       = ['Brad Feehan']
  spec.email         = ['git@bradfeehan.com']

  spec.summary       = 'A web crawler written in Ruby'
  spec.homepage      = 'https://github.com/bradfeehan/spiderb'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/bradfeehan/spiderb'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 1.0', '>= 1.0.1'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'faraday-cookie_jar'
  spec.add_dependency 'nokogiri', '~> 1.10', '>= 1.10.9'

  spec.add_development_dependency 'pry'
end
