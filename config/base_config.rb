require 'yaml'

module BaseConfig
  class << self
    attr_accessor :app_name, :app_activity, :wait_time, :moderate_wait_time, :short_wait_time

    def setup
      @app_name = 'com.abonesepeti.app'
      @app_activity = 'com.abonesepeti.presentation.main.MainActivity'
      @wait_time = 15
      @moderate_wait_time = 10
      @short_wait_time = 5
    end

    def device_type=(type)
      @device_type = type
    end

    def device_type
      @device_type ||= ENV['device_type'] || 'xiaomi'
    end

    def get_caps
      config = YAML.load_file(File.join(File.dirname(__FILE__), 'appium.yml'), aliases: true)
      device_type = ENV['DEVICE_TYPE'] || 'local'
      port = ENV['APPIUM_PORT'] || '4723'
      
      device_config = config[device_type]
      
      def transform_keys_recursive(hash)
        hash.transform_keys(&:to_sym).transform_values do |value|
          if value.is_a?(Hash)
            transform_keys_recursive(value)
          else
            value
          end
        end
      end
      
      {
        caps: transform_keys_recursive(device_config['caps']),
        appium_lib: transform_keys_recursive(device_config['appium_lib'].merge({
          'server_url' => "http://0.0.0.0:#{port}"
        }))
      }
    end

    private

    def config
      @config ||= begin
        config = YAML.load_file(File.join(File.dirname(__FILE__), 'appium.yml'), aliases: true)
        config['default']['appium_lib']['server_url'] = "http://0.0.0.0:#{ENV['APPIUM_PORT'] || 4723}"
        symbolize_keys(config)
      end
    end

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
