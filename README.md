# Rubocop::Sqlfluff

A gem that wraps the Python [sqlfluff](https://sqlfluff.com/)

## Installation

Not published to rubygems yet! Install via GitHub:

```ruby
gem 'rubocop-sqlfluff', github: 'zachmargolis/rubocop-sqlfluff'
```

## Usage

The `sqlfluff` executable needs to be on the load path so that this plugin can work.

Currently recommended workflow with python virtualenvs is to load Ruby from inside the python env

```bash
. env/bin/activate
bundle exec rubocop
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zachmargolis/rubocop-sqlfluff.
