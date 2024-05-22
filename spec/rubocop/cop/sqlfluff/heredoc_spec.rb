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

  it 'does not register an offense when using a different string ID' do
    expect_no_offenses(<<~RUBY)
      good_method
    RUBY
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
