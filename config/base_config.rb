require 'yaml'

module BaseConfig
  class << self
    attr_accessor :wait_time, :moderate_wait_time, :short_wait_time

    def device_type=(type)
      @device_type = type.downcase
    end

    def device_type
      @device_type ||= (ENV['DEVICE_TYPE'] || ENV['device_type'] || 'emulator').downcase
    end

    def environment=(env)
      @environment = env.downcase
    end

    def environment
      @environment ||= begin
        config = load_config
        env = ENV['ENV'] || 'prod'  # Default to preprod if not set
        puts "Current environment: #{env}"
        puts "ENV['ENV']: #{ENV['ENV']}"
        env.downcase
      end
    end

    def load_config
      @config ||= YAML.load_file(File.join(File.dirname(__FILE__), 'appium.yml'), aliases: true)
    end

    def get_caps
      config = load_config
      port = ENV['APPIUM_PORT'] || '4723'

      puts "Using environment: #{environment}"
      puts "Using device type: #{device_type}"

      # Önce device type'a göre konfigürasyonu al
      device_config = config[device_type]
      raise "Configuration not found for device type: #{device_type}" unless device_config

      # Sonra environment'a göre konfigürasyonu al
      env_config = device_config[environment]
      raise "Configuration not found for environment: #{environment} in device type: #{device_type}" unless env_config

      puts "Device config for #{device_type} in #{environment}: #{env_config.inspect}"

      def transform_keys_recursive(hash)
        hash.transform_keys(&:to_sym).transform_values do |value|
          if value.is_a?(Hash)
            transform_keys_recursive(value)
          else
            value
          end
        end
      end

      caps = {
        caps: transform_keys_recursive(env_config['caps']),
        appium_lib: transform_keys_recursive(env_config['appium_lib'].merge({
                                                                            'server_url' => "http://0.0.0.0:#{port}"
                                                                          }))
      }
      puts "Final caps: #{caps.inspect}"
      caps
    end

    private

    def config
      @config ||= begin
        config = load_config
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
end
