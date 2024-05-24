# frozen_string_literal: true

require_relative 'lib/rubocop/sqlfluff/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-sqlfluff'
  spec.version = RuboCop::Sqlfluff::VERSION
  spec.authors = ['Zach Margolis']
  spec.email = ['zachary.margolis@gsa.gov']

  spec.summary = 'sqlfluff Rubocop extension'
  spec.description = 'Run sqlfluff linting via Rubocop'

  spec.required_ruby_version = '>= 3.1'

  spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'pycall', '>= 1.5.2'
  spec.add_runtime_dependency 'rubocop'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
