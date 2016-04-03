# Fluent::Plugin::Kafkaclient
Fluentd plugin for Apache Kafka.
This plugin uses [ruby-kafka](https://github.com/zendesk/ruby-kafka) as ruby client library.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-kafkaclient'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-kafkaclient

## Usage

### Producing Messages to Kafka (Buffered Output Plugin)
This is basic configuration.

```
<match *.**>
  @type               kafka_out_buffered
  client_id           <client id> :default => producer_000
  brokers             <broker1_host>:<broker1_port>,<broker2_host>:<broker2_port>
  topic               <kafka topic>
  producer_type       (sync|async) :default => sync
  partition_key       (string)     :default => nil
  buffer_type         (file|memory)
  output_data_type    (text|json|msgpack) :default => text
  output_include_tag  (true|false) :default => false
  output_include_time (true|false) :default => false
</match>
```

#### Sync Producer

These Parameters are used for Sync Producer.

```
  required_acks, :integer, :default => 1
  ack_timeout, :integer, :default => 2
  compression_codec, (snappy|gzip|nil), :default => nil
  compression_threshold, :integer, :default => 1
  max_retries, :string, :integer, :default => 2
  retry_backoff, :string, :integer, :default => 1
  max_buffer_size, :integer, :default => 1000
```
- ```required_acks``` The number of acknowledgments the producer requires the leader to have received before considering a request complete.
- ```ack_timeout``` a timeout executed by a broker when the client is sending messages to it
- ```compression_codec``` you can choose snappy or gzip to compress.
- ```compression_threshold``` the number of messages to compress one time.
- ```max_retries``` the maximum number of retries to attempt
- ```retry_backoff``` the number of seconds to wait after a failed attempt to send messages to a Kafka broker before retrying.
- ```max_buffer_size``` the maximum size of the producer buffer.

#### Async Producer
These Parameters can be used for Async Producer.

```
  max_queue_size, :integer, :default => 1000
  delivery_threshold, :integer, :default => 0
  delivery_interval, :integer, :default => 0
```
- ```deliver_threshold``` Trigger a delivery once 'deliver_threshold' messages have been buffered
- ```delivery_interval``` Trigger a delivery every 'delivery_interval' seconds.

### Encryption and Authentication using TSL

```
  encryption           :bool, :default => false
  authentication       :bool, :default => false
  ca_cert_path         <path to ca_cert>:default => nil
  client_cert_path     <path to client cert> :default => nil
  client_cert_key_path <path to client cert key> :default => nil
```

In order to encrypt messages, you just need to
1. make param of encryption true
2. set a valid CA certificate path to param of ca_cert_path

In order to authenticate the client to the cluster, 
1. make param of authentication true
2. set each path of a certificate and key created for the client and trusted by the brokers.

For details, Please see document about [ruby-kafka](https://github.com/zendesk/ruby-kafka) and [Apache Kafka](http://kafka.apache.org)

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

## License
Copyright 2015 Kazuki Minamiya

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

