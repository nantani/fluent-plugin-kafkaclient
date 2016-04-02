require 'helper'
require 'yajl'
require 'msgpack'

class KafkaOutBufferedTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def default_config
    %[
      client_id           producer01
      brokers             localhost:9092
      topic               test_topic
      partition_key       partition_key
      output_data_type    json
      output_include_tag  true
      output_include_time true
      producer_type       sync
      required_acks       -1
    ]
  end

  def create_driver(conf = default_config, tag='test')
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::KafkaOutBuffered, tag).configure(conf)
  end


  def test_configure
    d = create_driver()
    assert_equal 'producer01', d.instance.client_id
    assert_equal 'localhost:9092', d.instance.brokers
    assert_equal 'test_topic', d.instance.topic
    assert_equal 'partition_key', d.instance.partition_key
    assert_equal 'json', d.instance.output_data_type
    assert_equal true, d.instance.output_include_tag
    assert_equal true, d.instance.output_include_time
    assert_equal 'sync', d.instance.producer_type
    assert_equal -1, d.instance.required_acks
    assert_equal 5, d.instance.ack_timeout
    assert_equal nil, d.instance.compression_codec
    assert_equal 1, d.instance.compression_threshold
    assert_equal 2, d.instance.max_retries
    assert_equal 1000, d.instance.max_buffer_size
    assert_equal 1000, d.instance.max_queue_size
    assert_equal 0, d.instance.delivery_threshold
    assert_equal 0, d.instance.delivery_interval
    assert_equal false, d.instance.encryption
    assert_equal false, d.instance.authentication
    assert_equal nil, d.instance.ca_cert_path
    assert_equal nil, d.instance.client_cert_path
    assert_equal nil, d.instance.client_cert_key_path

  end

  def test_format
    d = create_driver()

  end

  def test_build_producer()
    d = create_driver()

  end

  def test_encode()
    d = create_driver()

  end

  def test_write
    d = create_driver()

  end
end
