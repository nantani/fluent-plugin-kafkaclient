# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-kafkaclient"
  spec.version       = "0.0.1"
  spec.authors       = ["Kazuki Minamiya"]
  spec.email         = ["minami.ind@gmail.com"]

  spec.summary       = %q{Fluentd plugin for Apache Kafka, which supports version 0.9 of kafka.}
  spec.description   = %q{Fluentd plugin for Apache Kafka, which supports version 0.9 of kafka.}
  spec.homepage      = "https://github.com/nantani/fluent-plugin-kafkaclient"
  spec.license       = "APLv2"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.2.0'
  spec.add_dependency "fluentd"
  spec.add_dependency "ruby-kafka"
  spec.add_dependency "yajl"
  spec.add_dependency "msgpack"
  spec.add_dependency "activesupport", ">= 4.2.0", "< 5.1"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
end
