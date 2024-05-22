# frozen_string_literal: true

require 'open3'

module RuboCop
  module Cop
    module Sqlfluff
      class Heredoc < Base
        include RuboCop::Cop::Heredoc
        extend AutoCorrector

        MSG = 'sqlfluff: lint failure'

        def matching_id_heredoc?(node)
          cop_config.fetch('StringIds').any? do |string_id|
            node.location.expression.source.end_with?(string_id)
          end
        end

        def on_heredoc(node)
          return unless matching_id_heredoc?(node)

          sql = node.location.heredoc_body.source

          passed, errors = sqlfluff_lint(sql)

          return if passed

          add_offense(node, message: MSG) do |corrector|
            corrector.replace(
              node.location.heredoc_body,
              sqlfluff_fix(sql),
              # Need to figure out how to replace with indentation!
              # indent(
              #   str,
              #   to: config.for_cop('Layout/IndentationWidth').fetch('Width', 2),
              # ),
            )
          end
        end

        # @return [Boolean, String]
        def sqlfluff_lint(sql)
          out, _err, status = Open3.capture3(
            sqlfluff_executable,
            'lint',
            '--dialect',
            cop_config.fetch('Dialect'),
            '-',
            stdin_data: sql
          )

          [status.success?, out]
        end

        # @return [String]
        def sqlfluff_fix(sql)
          out, _err, status = Open3.capture3(
            sqlfluff_executable,
            'fix',
            '--dialect',
            cop_config.fetch('Dialect'),
            '-',
            stdin_data: sql
          )

          if status.success?
            out
          else
            sql
          end
        end

        def sqlfluff_executable
          File.expand_path('../../../../../bin/pip-sqlfluff-wrapper', __FILE__)
        end

        def indent(str, to:)
          str.split("\n", -1).map { |line| (" " * to) + line }.join("\n").tap do |after|
            puts "BEFORE:\n#{str}\nAFTER:\n#{after}"
          end
        end
      end
    end
  end
end
