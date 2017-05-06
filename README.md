# AW Datapipe
[![Gem Version](https://badge.fury.io/rb/aw_datapipe.png)](https://badge.fury.io/rb/aw_datapipe)
[![Build Status](https://travis-ci.org/varyonic/aw_datapipe.png?branch=master)](https://travis-ci.org/varyonic/aw_datapipe)

AW Datapipe is an unofficial domain specific ruby wrapper for the 
[AWS SDK](http://www.rubydoc.info/github/aws/aws-sdk-ruby) Data Pipeline API.

The primary goal is to support ruby scripts for creating and updating 
pipeline definitions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aw_datapipe'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aw_datapipe

## Usage

Configure credentials for AWS SDK.

```sh
export AWS_ACCESS_KEY_ID=AKIA****************
export AWS_SECRET_ACCESS_KEY=********************************
```
Use a ruby console (e.g. irb) to download a pipeline definition as ruby instead of JSON.
```ruby
require 'aw_datapipe'
pipelines = AwDatapipe::Session.new
pipelines.download_definition 'df-***************', 'tmp/pipeline-definition.rb'
```

The generated script can be checked into version control, modified and executed
to update the pipeline definition.
```sh
bundle exec ruby tmp/pipeline-definition.rb
```
## Development

A live AWS account with a sample pipeline is required to run the remote tests.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/varyonic/aw_datapipe.

## Releasing

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
