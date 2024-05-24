# frozen_string_literal: true

require 'pycall'

module RuboCop
  module Cop
    module Sqlfluff
      # Lint cop that checks for SQL queries inside of heredoc blocks
      # and lints them with python sqlfluff
      class Heredoc < Base
        include RuboCop::Cop::Heredoc
        extend AutoCorrector

        MSG = 'sqlfluff: lint failure'
        DEFAULT_STRING_IDS = %w[SQL].freeze
        DEFAULT_DIALECT = 'ansi'
        DEFAULT_CONFIG_FILE = '.sqlfluff'
        DEFAULT_VIRTUALENV = 'env'

        def matching_id_heredoc?(node)
          cop_config.fetch('StringIds', DEFAULT_STRING_IDS).any? do |string_id|
            node.location.expression.source.end_with?(string_id)
          end
        end

        def on_heredoc(node)
          return unless matching_id_heredoc?(node)

          sql = node.location.heredoc_body.source

          passed, errors = sqlfluff_lint(sql)

          return if passed

          add_offense(node, message: "#{MSG} #{format_errors(errors)}") do |corrector|
            corrector.replace(
              node.location.heredoc_body,
              sqlfluff_fix(sql),
            )
          end
        end

        def sqlfluff
          @sqlfluff ||= begin
            sys = PyCall.import_module('sys')
            env_path = ENV.fetch('VENV_PATH', cop_config.fetch('VirtualEnvPath', DEFAULT_VIRTUALENV))

            Dir["#{env_path}/**/site-packages"].each do |packages_path|
              sys.path.append(packages_path)
            end

            PyCall.import_module('sqlfluff')
          end
        end

        # @return [Boolean, Array<Hash>]
        def sqlfluff_lint(sql)
          errors = sqlfluff.lint(
            sql: dedent(template_in(sql)).first,
            dialect: cop_config.fetch('Dialect', DEFAULT_DIALECT),
            config_path: cop_config.fetch('ConfigFile', DEFAULT_CONFIG_FILE),
          )

          # rubocop:disable Style/ZeroLengthPredicate
          # errors is a PyCall::List, not a native Ruby array
          [errors.length.zero?, errors]
          # rubocop:enable Style/ZeroLengthPredicate
        end

        # @return [String]
        def sqlfluff_fix(sql)
          dedented, indent_amount = dedent(sql)

          indent(
            template_out(
              sqlfluff.fix(
                sql: template_in(dedented),
                dialect: cop_config.fetch('Dialect', DEFAULT_DIALECT),
                config_path: cop_config.fetch('ConfigFile', DEFAULT_CONFIG_FILE),
              ),
            ),
            to: indent_amount,
          ).gsub(/ +\Z/, '')
        end

        # Converts %{} to {}
        def template_in(sql)
          sql.gsub(/%\{([^\}]+)\}/, '{\1}')
        end

        # Converts {} back to %{}
        def template_out(sql)
          sql.gsub(/\{([^\}]+)\}/, '%{\1}')
        end

        # @return [String, Integer] (dedented string, number of spaces removed)
        def dedent(str)
          indent_amount = str.lines.map { |line| line.size - line.lstrip.size }.min
          dedented = str.lines.map do |line|
            line[indent_amount..]
          end.join
          [dedented, indent_amount]
        end

        def indent(str, to:)
          str.split("\n", -1).map { |line| (' ' * to) + line }.join("\n")
        end

        # @param errors [PyCall::List]
        # @return [String]
        def format_errors(errors)
          errors.map do |error|
            "(#{error['code']}) Line #{error['start_line_no']} #{error['description']}".chomp('.')
          end.join(', ')
        end
      end
    end
  end
end
