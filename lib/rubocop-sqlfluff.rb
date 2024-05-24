# frozen_string_literal: true

require 'rubocop'

require_relative 'rubocop/sqlfluff'
require_relative 'rubocop/sqlfluff/version'
require_relative 'rubocop/sqlfluff/inject'

RuboCop::Sqlfluff::Inject.defaults!

require_relative 'rubocop/cop/sqlfluff_cops'
