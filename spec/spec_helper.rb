require 'rspec_junit_formatter'

RSpec.configure do |config|
  # Eğer BuildWise Agent ortamında çalışıyorsa stdout ve stderr'yi yakala
  if ENV["RUN_IN_BUILDWISE_AGENT"] == "true"
    config.around(:each) do |example|
      stdout, stderr = StringIO.new, StringIO.new
      $stdout, $stderr = stdout, stderr

      example.run

      example.metadata[:stdout] = $stdout.string
      example.metadata[:stderr] = $stderr.string

      $stdout = STDOUT
      $stderr = STDERR

  
     
    end

    # Test başarısız olduğunda ekran görüntüsü al
    config.after(:each) do |example|
      if example.exception
        timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
        screenshot_name = "screenshot_#{example.description.gsub(/\s+/, '_')}_#{timestamp}.png"
        screenshot_path = File.join('reports', screenshot_name)

        # Ekran görüntüsünü al
        $driver.save_screenshot(screenshot_path)

        # HTML rapora ekran görüntüsünü ekle
        example.metadata[:screenshot] = screenshot_path
      end
    end

    config.before(:all) do
      # Environment ve device type ayarlarını yap
      BaseConfig.environment = ENV['ENV'] || 'preprod'
      BaseConfig.device_type = ENV['DEVICE_TYPE'] || 'emulator'
      puts "Test environment: #{BaseConfig.environment}"
      puts "Device type: #{BaseConfig.device_type}"
    end

    # Allure raporu oluşturmak için formatter ekle
    config.add_formatter AllureRubyRSpec::Formatter, "allure-results"
  end

  
end
