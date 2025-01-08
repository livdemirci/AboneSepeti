require 'yaml'

module BaseConfig
  class << self
    attr_accessor :device_type, :app_name, :app_activity, :wait_time, :moderate_wait_time, :short_wait_time

    def setup
      @device_type = ENV['device_type'] || 'xiaomi'
      @app_name = 'com.abonesepeti.app'
      @app_activity = 'com.abonesepeti.presentation.main.MainActivity'
      @wait_time = 15
      @moderate_wait_time = 10
      @short_wait_time = 5
    end

    def config
      @config ||= begin
        config = YAML.load_file(File.join(File.dirname(__FILE__), 'appium.yml'), aliases: true)
        symbolize_keys(config)
      end
    end

    def get_caps
      device_config = config[device_type.to_sym] || config[:default]
      {
        caps: device_config[:caps],
        appium_lib: device_config[:appium_lib]
      }
    end

    private

    def symbolize_keys(hash)
      hash.transform_keys!(&:to_sym)
      hash.each_value do |value|
        case value
        when Hash
          symbolize_keys(value)
        end
      end
      hash
    end
  end

  setup
end
