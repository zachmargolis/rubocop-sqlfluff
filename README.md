# Rubocop::Sqlfluff

A Rubocop extension that wraps the Python [sqlfluff](https://sqlfluff.com/)

> [!IMPORTANT]
> This project is in its early days and probably shouldn't be considered stable yet

It lets you run sqlfluff lints on queries inside Ruby heredocs:

```ruby
sql = <<~SQL
SQL
```


## Installation

Not published to rubygems yet! Install via GitHub:

```ruby
gem 'rubocop-sqlfluff', github: 'zachmargolis/rubocop-sqlfluff'
```

## Usage

1. Update your Gemfile

    ```ruby
    gem 'rubocop-sqlfluff', require: false
    ```

1. Update your Rubocop config:

    ```ruby
    require:
    - rubocop-sqlfluff

    Sqlfluff/Heredoc:
      Enabled: true
      StringIds:
        - SQL
      Dialect: postgres
      ConfigFile: '.sqlfluff'
      VirtualEnvPath: 'env'
    ```

1. Make sure `sqlfluff` is installed via Python and activated

    ```bash
    python3 -m venv env
    . env/bin/activate
    pip install -r requirements.txt
    ```

1. Run rubocop!

    ```bash
    bundle exec rubocop
    ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zachmargolis/rubocop-sqlfluff.
