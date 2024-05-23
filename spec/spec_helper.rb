# frozen_string_literal: true

require 'rubocop-sqlfluff'
require 'rubocop/rspec/support'

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense

  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.raise_on_warning = true
  config.fail_if_no_examples = true

  config.order = :random
  Kernel.srand config.seed
end

sqlfluff_bin_available = system('which', 'sqlfluff')
if !sqlfluff_bin_available
  abort <<~STR
    sqlfluff not in the executable path!
    Maybe you need to run:
      . env/bin/activate
      pip install -r requirements.txt
  STR
end
