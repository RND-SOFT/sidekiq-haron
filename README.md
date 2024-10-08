# Sidekiq::Haron

Transfer some metadata to sidekiq job, can tag sidekiq logs and add logging job args. Example request_id or other request info.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-haron'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-haron

## Usage

Аdd to project class inheriting from `Sidekiq::Haron::Transmitter` like this:

```ruby
class HaronTransmitter < Sidekiq::Haron::Transmitter

  def saved_data *args
    {
      request_id: Current.request_id,
      parent_request_id: Current.parent_request_id
    }
  end

  def load_data hash
    Current.request_id = hash['request_id'].presence || SecureRandom.hex
    Current.parent_request_id = hash['parent_request_id']
  end

  def tags
    [Current.parent_request_id]
  end

end
```

Аdd to `config/initializers/sidekiq.rb`:

```ruby
Sidekiq::Haron.install(HaronTransmitter)
```

Now all your sidekiq log have `Current.parent_request_id` value as tag and log job args too:

```
2020-01-14T14:22:09.035Z class=TestWorker jid=940645f14b345b3b4031d1cc I: [4f445354] with args [1, {"q"=>2}]
2020-01-14T14:22:09.035Z class=TestWorker jid=940645f14b345b3b4031d1cc I: [4f445354] start
2020-01-14T14:22:09.041Z class=TestWorker jid=940645f14b345b3b4031d1cc elapsed=0.006 I: [4f445354] done
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Rnd-Soft/sidekiq-haron.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
