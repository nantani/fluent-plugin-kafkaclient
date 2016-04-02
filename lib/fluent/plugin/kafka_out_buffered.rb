# encode: utf-8
class Fluent::KafkaOutBuffered < Fluent::BufferedOutput
  Fluent::Plugin.register_output('kafka_out_buffered', self)

  # ruby-kafka plugin main options
  config_param :client_id, :string, :default => 'producer_000'
  config_param :brokers, :string, :default => 'localhost:9092'
  config_param :topic, :string, :default => nil
  config_param :partition_key, :string, :default => nil
  config_param :output_data_type, :string, :default => nil
  config_param :output_include_tag, :bool, :default => false
  config_param :output_include_time, :bool, :default => false
  config_param :producer_type, :string, :default => 'sync'

  # Sync Producer options
  config_param :required_acks, :integer, :default => 1
  config_param :ack_timeout, :integer, :default => 5
  config_param :compression_codec, :string, :default => nil
  config_param :compression_threshold, :integer, :default => 1
  config_param :max_retries, :string, :integer, :default => 2
  config_param :retry_backoff, :string, :integer, :default => 1
  config_param :max_buffer_size, :integer, :default => 1000

  # Async Producer options
  config_param :max_queue_size, :integer, :default => 1000
  config_param :delivery_threshold, :integer, :default => 0
  config_param :delivery_interval, :integer, :default => 0

  # encryption and authentication options
  config_param :encryption, :bool, :default => false
  config_param :authentication, :bool, :default => false
  config_param :ca_cert_path, :string,:default => nil
  config_param :client_cert_path, :string, :default => nil
  config_param :client_cert_key_path, :string, :default => nil

  def initialize
    super
    require 'kafka'
    require "active_support/notifications"
    require 'Yajl'
  end

  def configure(conf)
    super

    if @encryption
      raise Fluent::ConfigError, "CA cert file is not found or invalid" unless File.readable?(@ca_cert_path)
      @ca_cert = File.read(@ca_cert_path)
      $log.info "ca_cert is valid"
    end

    if @authentication
      raise Fluent::ConfigError, "Client cert file is not found or invalid" unless File.readable?(@client_cert_path)
      raise Fluent::ConfigError, "Client cert key is not found or invalid" unless File.readable?(@client_cert_key_path)
      @client_cert = File.read(@client_cert_path)
      @client_cert_key = File.read(@client_cert_key_path)
      $log.info "client cert and client cert key is valid"
    end

  end

  def  build_producer()
    @kafka = Kafka.new(
      seed_brokers: @brokers.split(','),
      ssl_ca_cert:  @ca_cert,
      ssl_client_cert: @client_cert,
      ssl_client_cert_key: @client_cert_key
    )

    if @producer_type == 'sync'
      @producer = @kafka.producer(
        required_acks: @required_acks,
        ack_timeout: @ack_timeout,
        compression_codec: @compression_codec,
        compression_threshold: @compression_threshold,
        max_retries: @max_retries,
        retry_backoff: @retry_backoff,
        max_buffer_size: @max_buffer_size
      )

    elsif @producer_type == 'async'
      @producer = @kafka.async_producer(
        max_queue_size: @max_queue_size,
        delivery_threshold: @delivery_threshold,
        delivery_interval: @delivery_interval
      )
    else
      raise Fluent::ConfigError, "Producer type parameter, #{@producer_type}, is invalid"

    $log.info "produer type is #{@producer_type}"
    end
  end

  def start
    super
    build_producer()
  end

  def shutdown
    super
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def encode(record)
    if @output_data_type == 'msgpack'
      record.to_msgpack
    elsif @output_data_type == 'json'
      Yajl::Encoder.encode(record)
    elsif none
      record
    end
  end

  def write(chunk)

    chunk.msgpack_each { |(tag, time, record)|

      record['tag'] = tag if @output_include_tag
      record['time'] = time if @output_include_time
      encoded_record=encode(record)

      @producer.produce(
        encoded_record,
        topic: @topic,
        partition_key: @partition_key
      )

      @producer.deliver_messages
    }

  end

end
