class KafkaInput < Fluent::Input
  Fluent::Plugin.register_input('kafka_input', self)

  # ruby-kafka plugin main options
  config_param :brokers, :string, :default => 'localhost:9092'
  config_param :topic, :string, :default => nil
  config_param :group, :string, :default => 'consumer001'

  # encryption and authentication options
  config_param :encryption, :bool, :default => false
  config_param :authentication, :bool, :default => false
  config_param :ca_cert_path, :string,:default => nil
  config_param :client_cert_path, :string, :default => nil
  config_param :client_cert_key_path, :string, :default => nil

  def initialize
    super
    require 'kafka'
    require 'active_support/notifications'
    require 'Yajl'
  end

  def start
    build_consumer
    @stop_consuming = false
    @consume_thread = Thread.new(&method(:consume))
  end

  def configure(conf)
    super
    @tag = conf['tag']

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

  def shutdown
    super
    @stop_consuming = true
    Thread.kill(@consume_thread)
  end

  def build_consumer
    kafka = Kafka.new(
      seed_brokers: @brokers.split(','),
      ssl_ca_cert:  @ca_cert,
      ssl_client_cert: @client_cert,
      ssl_client_cert_key: @client_cert_key
    )
    @consumer = kafka.consumer(group_id: @group)
    @consumer.subscribe(@topic)
  end

  def consume
    
    loop do
      @consumer.each_message do |msg|
        router.emit(@tag, Fluent::Engine.now, msg.value)
      end
    end
  end
end
