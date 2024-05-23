# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sqlfluff::Heredoc, :config do
  let(:config) { RuboCop::Config.new(config_values) }
  let(:config_values) do
    {
      'Sqlfluff/Heredoc' => {
        'StringIds' => string_ids,
        'Dialect' => 'ansi',
      },
    }
  end
  let(:string_ids) { ['SQL'] }

  it 'registers an offense SQL inside heredocs breaks sqlfluff rules' do
    expect_offense(<<~RUBY)
      ActiveRecord::Base.connection.execute(<<~SQL)
                                            ^^^^^^ sqlfluff: lint failure
      select 1
      from mytable
      SQL
    RUBY

    expect_correction(<<~RUBY)
      ActiveRecord::Base.connection.execute(<<~SQL)
      SELECT 1
      FROM mytable
      SQL
    RUBY
  end

  it 'registers an offense SQL inside one-line heredocs that break sqlfluff rules' do
    expect_offense(<<~RUBY)
      ActiveRecord::Base.connection.execute(<<~SQL)
                                            ^^^^^^ sqlfluff: lint failure
      select 1
      SQL
    RUBY

    expect_correction(<<~RUBY)
      ActiveRecord::Base.connection.execute(<<~SQL)
      SELECT 1
      SQL
    RUBY
  end

  context 'custom StringIds' do
    let(:string_ids) { ['QUERY'] }

    it 'registers offenses in those heredoc tags' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.connection.execute(<<~QUERY)
                                              ^^^^^^^^ sqlfluff: lint failure
        select 1
        QUERY
      RUBY

      expect_correction(<<~RUBY)
        ActiveRecord::Base.connection.execute(<<~QUERY)
        SELECT 1
        QUERY
      RUBY
    end
  end

  it 'does not register an offense when using a different string ID' do
    expect_no_offenses(<<~RUBY)
      good_method
    RUBY
  end

  context 'custom config file' do
    around do |ex|
      Tempfile.create('.sqlfluff') do |temp|
        File.open(temp.path, 'w') do |file|
          file.puts <<~CONFIG
            [sqlfluff]
            exclude_rules = layout.end_of_file

            [sqlfluff:indentation]
            tab_space_size = 2

            [sqlfluff:layout:type:comma]
            line_position = leading
            spacing_before = touch

            [sqlfluff:rules:capitalisation.keywords]
            capitalisation_policy = lower
          CONFIG
        end

        config_values['Sqlfluff/Heredoc']['ConfigFile'] = temp.path

        ex.run
      end
    end

    it 'uses the custom config file' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.connection.execute(<<~SQL)
                                              ^^^^^^ sqlfluff: lint failure
        SELECT
          foo,
          bar
        FROM mytable
        SQL
      RUBY

      expect_correction(<<~RUBY)
        ActiveRecord::Base.connection.execute(<<~SQL)
        select
          foo
          , bar
        from mytable
        SQL
      RUBY
    end
  end

  context 'indentation width' do
    let(:config_values) do
      super().merge(
        'Layout/IndentationWidth' => {
          'Width' => 4,
        },
      )
    end

    pending 'takes indentation width into account for corrections' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.connection.execute(<<~SQL)
                                              ^^^^^^ sqlfluff: lint failure
          select 1
        SQL
      RUBY

      expect_correction(<<~RUBY)
          ActiveRecord::Base.connection.execute(<<~SQL)
              SELECT 1
          SQL
      RUBY
    end
  end
end
