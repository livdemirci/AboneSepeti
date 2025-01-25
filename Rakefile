require 'rubygems'
gem 'ci_reporter'
gem 'rspec'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec' # RSpec için CI raporları
require 'parallel'
require 'yaml'
require 'appium_lib'
require 'nokogiri'
require 'fileutils'

# BuildWise ayarları (isteğe bağlı)
BUILDWISE_URL = ENV['BUILDWISE_MASTER'] || 'http://buildwise.dev'
FULL_BUILD_MAX_TIME = ENV['DISTRIBUTED_MAX_BUILD_TIME'].to_i || 60 * 60 # maksimum build süresi
FULL_BUILD_CHECK_INTERVAL = ENV['DISTRIBUTED_BUILD_CHECK_INTERVAL'].to_i || 20 # kontrol aralığı

# Test dizini
$test_dir = File.expand_path(File.join(File.dirname(__FILE__), 'spec'))

# Hariç tutulacak test dosyaları
def excluded_spec_files
  ['debugging_spec.rb', '03_passenger_spec.rb'] # Örnek hariç tutulan dosyalar
end

# Tüm test dosyalarını bul
def all_specs
  Dir.glob("#{$test_dir}/*_spec.rb").map { |file| File.basename(file) }
end

# Hızlı build için test dosyaları
def specs_for_quick_build
  all_specs - excluded_spec_files
end

# UI testlerini çalıştır (hızlı build)
RSpec::Core::RakeTask.new('ui_tests:quick') do |t|
  specs_to_be_executed = specs_for_quick_build
  t.rspec_opts = "--pattern #{specs_to_be_executed.join(' ')} --order defined"
end

# Paralel testleri çalıştır
desc 'Testleri paralel çalıştır'
task :parallel_tests do
  # Ortam seçimi (varsayılan: preprod)
  environment = ENV['ENV'] || 'preprod'
  puts "Test ortamı: #{environment}"

  # Rapor dizini oluştur
  timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
  report_dir = "reports/#{timestamp}"
  FileUtils.rm_rf(report_dir) if File.directory?(report_dir)
  FileUtils.mkdir_p(report_dir)

  # RSpec formatter'ları ayarla
  ENV['CI_REPORTS'] = report_dir

  # Appium yapılandırmasını yükle
  appium_config = YAML.load_file(File.join(File.dirname(__FILE__), 'config/appium.yml'), aliases: true)
  device_configs = appium_config.select { |k, v| k != 'default' }

  # Bağlı cihazları al
  connected_devices = `adb devices`.split("\n")[1..-1]&.map { |line| line.split[0] }&.compact || []
  if connected_devices.empty?
    puts "Hata: Bağlı cihaz bulunamadı!"
    exit 1
  end

  # Cihazları tipine göre ayır
  emulator_devices = connected_devices.select { |device| device.start_with?('emulator-') }
  real_devices = connected_devices - emulator_devices

  puts "Bağlı cihazlar:"
  puts "- Emülatörler: #{emulator_devices.join(', ')}"
  puts "- Fiziksel cihazlar: #{real_devices.join(', ')}"

  # Test dosyalarını bul
  spec_files = Dir.glob("#{$test_dir}/**/*_spec.rb") - excluded_spec_files.map { |f| File.join($test_dir, f) }

  # Device type'lara göre uygun cihazları eşle
  device_type_mapping = {}
  device_configs.each do |config_name, config|
    if config_name == 'emulator'
      device_type_mapping[config_name] = emulator_devices
    else
      device_type_mapping[config_name] = real_devices
    end
  end

  puts "\nDevice type eşleşmeleri:"
  device_type_mapping.each do |type, devices|
    puts "- #{type}: #{devices.join(', ')}"
  end

  # Test-cihaz çiftlerini oluştur
  device_test_groups = {}
  spec_files.each do |spec_file|
    content = File.read(spec_file)
    if match = content.match(/BaseConfig\.device_type\s*=\s*['"]([^'"]+)['"]/)
      device_type = match[1]
      if device_type_mapping[device_type]&.any?
        device = device_type_mapping[device_type].first
        device_test_groups[device] ||= { device_type: device_type, tests: [] }
        device_test_groups[device][:tests] << spec_file
      else
        puts "Uyarı: '#{device_type}' tipi için uygun cihaz bulunamadı: #{File.basename(spec_file)}"
      end
    else
      puts "Uyarı: Device type bulunamadı: #{File.basename(spec_file)}"
    end
  end

  if device_test_groups.empty?
    puts "Hata: Çalıştırılacak test bulunamadı!"
    exit 1
  end

  puts "\nTest dağılımı:"
  device_test_groups.each do |device, group|
    puts "- #{device} (#{group[:device_type]}):"
    group[:tests].each do |test|
      puts "  - #{File.basename(test)}"
    end
  end

  # Test sonuçlarını toplamak için bir hash oluştur
  test_results = {
    total_tests: 0,
    passed_tests: 0,
    failed_tests: 0,
    screenshots: []
  }

  # Her cihaz için bir Appium server başlat
  begin
    device_servers = {}
    device_test_groups.each_with_index do |(device, group), index|
      port = 4723 + index
      puts "\n[Device: #{device} (#{group[:device_type]})] Appium server başlatılıyor (Port: #{port})"
      system("appium -p #{port} --allow-insecure chromedriver_autodownload > appium_#{port}.log 2>&1 &")
      sleep 15 # Server'ın başlaması için bekle
      device_servers[device] = port
      puts "[Device: #{device} (#{group[:device_type]})] Appium server hazır"
    end

    # Her cihaz için testleri paralel çalıştır
    Parallel.each(device_test_groups) do |device, group|
      port = device_servers[device]
      system_port = 8200 + device_servers.keys.index(device)

      # Test için gerekli ortam değişkenlerini ayarla
      ENV['APPIUM_PORT'] = port.to_s
      ENV['SYSTEM_PORT'] = system_port.to_s
      ENV['UDID'] = device
      ENV['DEVICE_TYPE'] = group[:device_type]

      group[:tests].each do |spec_file|
        spec_name = File.basename(spec_file, '.rb')
        puts "\n[Device: #{device} (#{group[:device_type]})] #{spec_name} çalıştırılıyor"

        # Uygulama süreçlerini temizle
        system("adb -s #{device} shell pm clear com.abonesepeti.app")
        sleep 2

        # Rapor dosyasını her test çalıştırması için benzersiz hale getirmek
        group_name = "#{spec_name}_#{ENV['UDID']}_#{timestamp}"
        ENV['SPEC_OPTS'] = "--format RspecJunitFormatter --out #{report_dir}/test_report_#{group_name}.xml"

        # RSpec komutunu çalıştır
        begin
          system("bundle exec rspec #{spec_file}")
          test_results[:total_tests] += 1
          test_results[:passed_tests] += 1
          puts "[Başarılı] #{spec_name}"
        rescue => e
          puts "Hata oluştu: #{e.message}"
          test_results[:total_tests] += 1
          test_results[:failed_tests] += 1
          puts "[Başarısız] #{spec_name}"

          # Ekran görüntüsü al
          screenshot_path = File.join(report_dir, "screenshot_#{group_name}.png")
          driver = Appium::Driver.new(
            { caps: appium_config[group[:device_type]],
              appium_lib: { server_url: "http://localhost:#{port}/wd/hub" } }, true
          )
          driver.start_driver
          driver.save_screenshot(screenshot_path)
          puts "Ekran görüntüsü kaydedildi: #{screenshot_path}"
          driver.driver_quit

          test_results[:screenshots] << screenshot_path
        end
      end
    end
  ensure
    # Tüm Appium server'ları kapat
    device_servers.each do |device, port|
      puts "\n[Device: #{device}] Appium server kapatılıyor (Port: #{port})"
      system("pkill -f 'appium.*#{port}'")
      system("rm -f appium_#{port}.log")
    end

    # Raporları birleştir
    puts "\nRaporlar birleştiriliyor..."
    Rake::Task["merge_reports"].invoke(report_dir)

    # Test sonuçlarını özetle
    puts "\nTest Sonuçları Özeti:"
    puts "- Toplam Test: #{test_results[:total_tests]}"
    puts "- Geçen Testler: #{test_results[:passed_tests]}"
    puts "- Başarısız Testler: #{test_results[:failed_tests]}"
    puts "- Ekran Görüntüleri:"
    test_results[:screenshots].each do |screenshot|
      puts "  - #{screenshot}"
    end
  end
end

# JUnit raporlarını birleştir
desc 'JUnit raporlarını birleştir'
task :merge_reports, [:report_dir] do |t, args|
  require 'nokogiri'

  report_dir = args[:report_dir]
  merged_report_path = File.join(report_dir, 'merged_report.xml')

  # Tüm rapor dosyalarını bul
  report_files = Dir.glob("#{report_dir}/test_report_*.xml")

  if report_files.empty?
    puts "Uyarı: Birleştirilecek rapor dosyası bulunamadı!"
    return
  end

  # Birleştirilmiş raporu oluştur
  merged_report = Nokogiri::XML::Builder.new do |xml|
    xml.testsuites do
      report_files.each do |report_file|
        doc = Nokogiri::XML(File.open(report_file))
        doc.xpath('//testsuite').each do |testsuite|
          xml.testsuite(name: testsuite['name'], tests: testsuite['tests'], failures: testsuite['failures'], errors: testsuite['errors'], time: testsuite['time']) do
            testsuite.xpath('.//testcase').each do |testcase|
              xml.testcase(name: testcase['name'], classname: testcase['classname'], time: testcase['time']) do
                testcase.xpath('.//failure').each do |failure|
                  xml.failure(failure['message'], type: failure['type']) do
                    xml.text(failure.text)
                  end
                end
                testcase.xpath('.//error').each do |error|
                  xml.error(error['message'], type: error['type']) do
                    xml.text(error.text)
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  # Birleştirilmiş raporu kaydet
  File.write(merged_report_path, merged_report.to_xml)
  puts "Raporlar birleştirildi: #{merged_report_path}"
end