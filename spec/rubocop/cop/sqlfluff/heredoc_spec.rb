# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sqlfluff::Heredoc, :config do
  let(:config) { RuboCop::Config.new(config_values) }
  let(:config_values) do
    {
      'Sqlfluff/Heredoc' => {
        'StringIds' => string_ids,
        'Dialect' => 'ansi',
      },
      'Layout/HeredocIndentation' => {
        'Enabled' => true,
      },
      'Layout/ClosingHeredocIndentation' => {
        'Enabled' => true,
      },
    }
  end
  let(:string_ids) { ['SQL'] }

  it 'registers an offense SQL inside heredocs breaks sqlfluff rules' do
    expect_offense(<<~RUBY)
      ActiveRecord::Base.connection.execute(<<~SQL)
                                            ^^^^^^ sqlfluff: lint failure (CP01) Line 1 Keywords must be upper case, (CP01) Line 2 Keywords must be upper case
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

  it 'fixes mismatched indentation' do
    expect_offense(<<~RUBY)
      ActiveRecord::Base.connection.execute(<<~SQL)
                                            ^^^^^^ sqlfluff: lint failure (CP01) Line 1 Keywords must be upper case, (LT02) Line 2 Line should not be indented, (CP01) Line 2 Keywords must be upper case
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
                                            ^^^^^^ sqlfluff: lint failure (CP01) Line 1 Keywords must be upper case
        select 1
      SQL
    RUBY

    expect_correction(<<~RUBY)
      ActiveRecord::Base.connection.execute(<<~SQL)
        SELECT 1
      SQL
    RUBY
  end

  context 'with templated variables' do
    around do |ex|
      config = <<~CONFIG
        [sqlfluff]
        templater = python

        [sqlfluff:rules:capitalisation.keywords]
        capitalisation_policy = upper

        [sqlfluff:templater:python:context]
        table = "AAA_my_table"
        from = "2023-01-01"
        to = "2024-01-01"
      CONFIG

      with_config_file(config) do
        ex.run
      end
    end

    it 'handles %{...} template in queries' do
      expect_no_offenses(<<~RUBY)
        ActiveRecord::Base.connection.execute(<<~SQL)
          SELECT 1
          FROM %{table}
          WHERE created_at BETWEEN %{from} AND %{to}
        SQL
      RUBY
    end

    it 'corrects %{...} template in queries' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.connection.execute(<<~SQL)
                                              ^^^^^^ sqlfluff: lint failure (CP01) Line 1 Keywords must be upper case, (CP01) Line 2 Keywords must be upper case, (CP01) Line 3 Keywords must be upper case, (CP01) Line 3 Keywords must be upper case, (CP01) Line 3 Keywords must be upper case
          select 1
          from %{table}
          where created_at between %{from} and %{to}
        SQL
      RUBY

      expect_correction(<<~RUBY)
        ActiveRecord::Base.connection.execute(<<~SQL)
          SELECT 1
          FROM %{table}
          WHERE created_at BETWEEN %{from} AND %{to}
        SQL
      RUBY
    end
  end

  context 'with custom StringIds' do
    let(:string_ids) { ['QUERY'] }

    it 'registers offenses in those heredoc tags' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.connection.execute(<<~QUERY)
                                              ^^^^^^^^ sqlfluff: lint failure (CP01) Line 1 Keywords must be upper case
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

  context 'with a custom config file' do
    around do |ex|
      config = <<~CONFIG
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

      with_config_file(config) do
        ex.run
      end
    end

    it 'uses the custom config file' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.connection.execute(<<~SQL)
                                              ^^^^^^ sqlfluff: lint failure (CP01) Line 1 Keywords must be lower case, (LT04) Line 2 Found trailing comma ','. Expected only leading near line breaks, (CP01) Line 4 Keywords must be lower case
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

  # Use inside an around block
  # @yieldparam ex
  def with_config_file(str)
    Tempfile.create('.sqlfluff') do |temp|
      File.open(temp.path, 'w') do |file|
        file.puts(str)
      end

      config_values['Sqlfluff/Heredoc']['ConfigFile'] = temp.path

      yield
    end
  end
end
