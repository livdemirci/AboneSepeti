# You need Ruby (Rake, RWebSpec, ci_reporter gems installed)
#   Simplest way on Windows is to install RubyShell (http://agileway.com.au/downloads)

require 'rubygems'
gem 'ci_reporter'
gem 'rspec'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec' # use this if you're using RSpec

load File.join(File.dirname(__FILE__), 'buildwise.rake')

## Settings: Customize here...
#
BUILDWISE_URL = ENV['BUILDWISE_MASTER'] || 'http://buildwise.dev'
# BUILDWISE_QUICK_PROJECT_ID = "agiletravel-quick-build-rspec"
# BUILDWISE_FULL_PROJECT_ID  = "agiletravel-full-build-rspec" # import to set for full build

FULL_BUILD_MAX_TIME = ENV['DISTRIBUTED_MAX_BUILD_TIME'].to_i || 60 * 60 # max build time, over this, time out
FULL_BUILD_CHECK_INTERVAL = ENV['DISTRIBUTED_BUILD_CHECK_INTERVAL'].to_i || 20 # check interval for build complete

$test_dir = File.expand_path(File.join(File.dirname(__FILE__), 'spec')) # change to aboslution path if invocation is not this directory
# rspec will create 'spec/reports' under check out dir

# List tests you want to exclude
#
def excluded_spec_files
  # NOTE, testing only for faster develping agent, remove a couple of test later
  ['debugging_spec.rb', '03_passenger_spec.rb']
end

def all_specs
  Dir.glob("#{$test_dir}/*_spec.rb").map { |file| File.basename(file) }
end

def specs_for_quick_build
  all_specs # Tüm _spec.rb dosyalarını döndür
end

desc 'run tests in this spec/ folder, option to use INTELLIGENT_ORDERING or/and DYNAMIC_FEEDBACK'
RSpec::Core::RakeTask.new('ui_tests:quick') do |t|
  specs_to_be_executed = buildwise_determine_specs_for_quick_build(specs_for_quick_build, excluded_spec_files,
                                                                   $test_dir)
  buildwise_formatter =  File.join(File.dirname(__FILE__), 'buildwise_rspec_formatter.rb')
  t.rspec_opts = "--pattern my_own_custom_order --require #{buildwise_formatter} #{specs_to_be_executed.join(' ')} --order defined"
end

desc 'run quick tests from BuildWise'
task 'ci:ui_tests:quick' => ['ci:setup:rspec'] do
  build_id = buildwise_start_build(working_dir: __dir__)
  buildwise_run_sequential_build_target(build_id, 'ui_tests:quick')
end

## Full Build
#
desc 'Running tests distributedly'
task 'ci:ui_tests:full' => ['ci:setup:rspec'] do
  build_id = buildwise_start_build(working_dir: __dir__,
                                   ui_test_dir: ['spec'],
                                   excluded: excluded_spec_files || [],
                                   distributed: true)
  buildwise_montior_parallel_execution(build_id, max_wait_time: FULL_BUILD_MAX_TIME,
                                                 check_interval: FULL_BUILD_CHECK_INTERVAL)
end

desc 'run all tests in this folder'
RSpec::Core::RakeTask.new('go') do |t|
  test_files = Dir.glob('*_spec.rb') + Dir.glob('*_test.rb') - excluded_test_files
  t.pattern = FileList[test_files]
  t.rspec_opts = '' # to enable warning: "-w"
end

desc 'Generate stats for UI tests'
task 'test:stats' do
  ui_test_dir = File.dirname(__FILE__)
  STATS_SOURCES = {
    'Tests' => "#{ui_test_dir}/spec",
    'Pages' => "#{ui_test_dir}/pages",
    'Helpers' => "#{ui_test_dir}/*_helper.rb"
  }

  test_stats = { 'lines' => 0, 'test_suites' => 0, 'test_cases' => 0, 'test_lines' => 0 }
  page_stats = { 'lines' => 0, 'classes' => 0, 'methods' => 0, 'code_lines' => 0 }
  helper_stats = { 'lines' => 0, 'helpers' => 0, 'methods' => 0, 'code_lines' => 0 }

  # Tests
  directory = STATS_SOURCES['Tests']
  Dir.foreach(directory) do |file_name|
    next if ['.', '..', 'debugging_spec.rb'].include?(file_name)
    next if File.directory?(File.join(directory, file_name))

    f = File.open(directory + '/' + file_name)
    test_stats['test_suites'] += 1
    while line = f.gets
      test_stats['lines'] += 1
      if line =~ /^\s*it\s+['"]/ || line =~ /^\s*story\s+['"]/ || line =~ /^\s*test_case\s+['"]/
        test_stats['test_cases'] += 1
      end
      test_stats['test_lines'] += 1 unless line =~ /^\s*$/ || line =~ /^\s*#/
    end
    f.close
  end
  # puts test_stats.inspect

  # Pages
  directory = STATS_SOURCES['Pages']
  Dir.foreach(directory) do |file_name|
    next if ['.', '..'].include?(file_name)

    f = File.open(directory + '/' + file_name)
    while line = f.gets
      page_stats['lines'] += 1
      page_stats['classes'] += 1 if line =~ /class [A-Z]/
      page_stats['methods'] += 1 if line =~ /def [a-z]/
      page_stats['code_lines'] += 1 unless line =~ /^\s*$/ || line =~ /^\s*#/
    end
    f.close
  end

  # Helpers
  # directory = File.dirname( STATS_SOURCES["Helpers"])
  # helper_wildcard = File.basename( STATS_SOURCES["Helpers"])
  # puts directory
  # puts helper_wildcard
  Dir.glob(STATS_SOURCES['Helpers']).each do |helper_file|
    f = File.open(helper_file)
    helper_stats['helpers'] += 1
    while line = f.gets
      helper_stats['lines'] += 1
      helper_stats['methods'] += 1 if line =~ /def [a-z]/
      helper_stats['code_lines'] += 1 unless line =~ /^\s*$/ || line =~ /^\s*#/
    end
    f.close
  end

  total_lines = helper_stats['lines'] + page_stats['lines'] + test_stats['lines']
  total_code_lines = helper_stats['code_lines'] + page_stats['code_lines'] + test_stats['test_lines']

  puts '+------------+---------+---------+---------+--------+'
  puts '| TEST       |   LINES |  SUITES |   CASES |    LOC |'
  puts "|            | #{test_stats['lines'].to_s.rjust(7)} " + "| #{test_stats['test_suites'].to_s.rjust(7)} " + "| #{test_stats['test_cases'].to_s.rjust(7)} " + "| #{test_stats['test_lines'].to_s.rjust(6)} " + '|'
  puts '+------------+---------+---------+---------+--------+'
  puts '| PAGE       |   LINES | CLASSES | METHODS |    LOC |'
  puts "|            | #{page_stats['lines'].to_s.rjust(7)} " + "| #{page_stats['classes'].to_s.rjust(7)} " + "| #{page_stats['methods'].to_s.rjust(7)} " + "| #{page_stats['code_lines'].to_s.rjust(6)} " + '|'
  puts '+------------+---------+---------+---------+--------+'
  puts '| HELPER     |   LINES |   COUNT | METHODS |    LOC |'
  puts "|            | #{helper_stats['lines'].to_s.rjust(7)} " + "| #{helper_stats['helpers'].to_s.rjust(7)} " + "| #{helper_stats['methods'].to_s.rjust(7)} " + "| #{helper_stats['code_lines'].to_s.rjust(6)} " + '|'
  puts '+------------+---------+---------+---------+--------+'
  puts '| TOTAL      | ' + total_lines.to_s.rjust(7) + ' |         |         |' + total_code_lines.to_s.rjust(7) + ' |'
  puts '+------------+---------+---------+---------+--------+'
end

desc 'Testleri paralel çalıştır'
task :parallel_tests do
  require 'parallel'
  require 'yaml'
  require_relative 'config/base_config'
  require 'appium_lib'
  require 'rspec/core'
  require 'ci/reporter/rspec'
  require 'nokogiri'

  # Ortam seçimini al (varsayılan: preprod)
  environment = ENV['ENV'] || 'preprod'
  BaseConfig.environment = environment
  
  puts "Test ortamı: #{environment}"

  timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
  report_dir = "reports/#{timestamp}"
  FileUtils.mkdir_p(report_dir)

  # Configure RSpec formatters for extended reporting
  ENV['CI_REPORTS'] = report_dir
  ENV['SPEC_OPTS'] = "--format html --out #{report_dir}/test_report_%{spec_name}.html"

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
        # Bu device type için mevcut cihazlardan birini seç
        available_devices = device_type_mapping[device_type]
        device = available_devices.first

        device_test_groups[device] ||= {
          device_type: device_type,
          tests: []
        }
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

  # Her cihaz için bir Appium server başlat
  begin
    device_servers = {}

    device_test_groups.each_with_index do |(device, group), index|
      port = 4723 + index
      puts "\n[Device: #{device} (#{group[:device_type]})] Appium server başlatılıyor (Port: #{port})"

      # Appium server'ı başlat
      server_cmd = "appium -p #{port} --allow-insecure chromedriver_autodownload > appium_#{port}.log 2>&1 &"
      system(server_cmd)
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

        # RSpec komutunu çalıştır
        rspec_cmd = <<~RUBY
          bundle exec ruby -e '
            require "rspec"
            require "appium_lib"
          #{'  '}
            ENV["SPEC_OPTS"] = "--format html --out #{report_dir}/test_report_#{spec_name}.html"
          #{'  '}
            # RSpec çalıştır
            RSpec::Core::Runner.run(["#{spec_file}"], $stderr, $stdout)
          '
        RUBY

        system(rspec_cmd)
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
    Rake::Task["merge_reports"].invoke
  end

  # Paralel testler tamamlandıktan sonra raporları birleştir
end

desc 'Merge test reports'
task :merge_reports do
  require 'nokogiri'
  
  # En son çalışan testlerin dizinini bul
  latest_report_dir = Dir.glob("spec/reports/*").max_by { |f| File.mtime(f) }
  
  if !latest_report_dir || !File.directory?(latest_report_dir)
    puts "Rapor dizini bulunamadı"
    next
  end
  
  puts "En son rapor dizini: #{latest_report_dir}"
  
  # En son dizindeki HTML dosyalarını bul
  html_files = Dir.glob("#{latest_report_dir}/test_report_*_spec.html")
  
  if html_files.empty?
    puts "Birleştirilecek HTML rapor bulunamadı"
    next
  end
  
  # İlk dosyayı temel olarak al
  base_html = File.read(html_files.first)
  merged_doc = Nokogiri::HTML(base_html)
  
  # Test gruplarını toplayacağımız div
  main_div = merged_doc.at_css('#div_group_1')
  return unless main_div
  
  total_examples = 0
  total_failures = 0
  failed_examples = []
  passed_examples = []
  
  # Her HTML dosyasını işle
  html_files.each do |file|
    spec_name = File.basename(file, '.html').sub('test_report_', '')
    puts "Rapor birleştiriliyor: #{spec_name}"
    
    doc = Nokogiri::HTML(File.read(file))
    
    # Test gruplarını topla
    doc.css('.example_group').each do |group|
      # Başarısız testleri bul
      if group['class'].include?('failed')
        # Ekran görüntüsünü kontrol et
        example_div = group.at_css('.example.failed')
        if example_div
          screenshot_path = example_div['data-screenshot']
          if screenshot_path && File.exist?(screenshot_path)
            # Ekran görüntüsünü rapora ekle
            img_tag = doc.create_element('img', 
              src: "data:image/png;base64,#{Base64.strict_encode64(File.read(screenshot_path))}", 
              class: 'failure-screenshot',
              style: 'max-width: 800px; border: 2px solid red; margin: 10px 0;'
            )
            example_div.add_child(img_tag)
          end
        end
        
        failed_examples << group
        total_failures += 1
      else
        passed_examples << group
      end
      total_examples += 1
    end
  end
  
  # Test sonuçlarını birleştir
  main_div.inner_html = ''
  
  # Önce başarısız testleri ekle
  failed_examples.each do |example|
    main_div.add_child(example)
  end
  
  # Sonra başarılı testleri ekle
  passed_examples.each do |example|
    main_div.add_child(example)
  end
  
  # Başlık ve durum bilgisini güncelle
  if total_failures > 0
    merged_doc.at_css('#rspec-header')['class'] = 'failed'
    merged_doc.at_css('#div_group_1')['class'] = 'example_group failed'
  else
    merged_doc.at_css('#rspec-header')['class'] = 'passed'
    merged_doc.at_css('#div_group_1')['class'] = 'example_group passed'
  end
  
  # Birleştirilmiş raporu kaydet
  output_file = "#{latest_report_dir}/merged_report.html"
  File.write(output_file, merged_doc.to_html)
  
  puts "\nBirleştirme tamamlandı!"
  puts "Toplam test sayısı: #{total_examples}"
  puts "Başarısız test sayısı: #{total_failures}"
  puts "Başarılı test sayısı: #{total_examples - total_failures}"
  puts "Birleştirilmiş rapor: #{output_file}"
end

desc 'Merge CI Reporter test reports'
task :merge_ci_reports do
  require 'nokogiri'

  report_dir = Dir.glob("spec/reports/*").max_by { |f| File.mtime(f) }
  if report_dir && File.directory?(report_dir)
    puts "En son rapor dizini: #{report_dir}"

    # XML dosyalarını bul (hem SPEC-*.xml hem de birlesik_rapor.xml)
    xml_files = Dir.glob("#{report_dir}/*.xml")

    if xml_files.empty?
      puts "Birleştirilecek XML rapor bulunamadı"
      next
    end

    # Birleştirilmiş rapor için yeni bir XML belgesi oluştur
    merged_doc = Nokogiri::XML('<testsuite></testsuite>')
    merged_suite = merged_doc.at_css('testsuite')

    total_tests = 0
    total_failures = 0
    total_errors = 0
    total_time = 0.0

    # Her XML dosyasını işle
    xml_files.each do |file|
      puts "Rapor birleştiriliyor: #{File.basename(file)}"
      doc = Nokogiri::XML(File.read(file))
      suite = doc.at_css('testsuite')

      next unless suite

      # İstatistikleri topla
      total_tests += suite['tests'].to_i
      total_failures += suite['failures'].to_i
      total_errors += (suite['errors'] || '0').to_i
      total_time += (suite['time'] || '0').to_f

      # Test durumlarını birleştirilmiş rapora ekle
      suite.css('testcase').each do |testcase|
        merged_suite.add_child(testcase.dup)
      end
    end

    # Birleştirilmiş istatistikleri ayarla
    merged_suite['tests'] = total_tests.to_s
    merged_suite['failures'] = total_failures.to_s
    merged_suite['errors'] = total_errors.to_s
    merged_suite['time'] = total_time.to_s
    merged_suite['name'] = 'Birleştirilmiş Test Sonuçları'

    # Birleştirilmiş raporu kaydet
    output_file = "#{report_dir}/merged_ci_report.xml"
    File.write(output_file, merged_doc.to_xml(indent: 2))

    puts "\nBirleştirme tamamlandı!"
    puts "Toplam test sayısı: #{total_tests}"
    puts "Toplam hata sayısı: #{total_failures}"
    puts "Toplam error sayısı: #{total_errors}"
    puts "Toplam süre: #{total_time.round(2)} saniye"
    puts "Birleştirilmiş rapor: #{output_file}"
  else
    puts "Rapor klasörü bulunamadı"
  end
end

require 'json'
require 'erb'
require 'parallel_tests'
require 'fileutils'

namespace :test do
  desc "Run tests in parallel and create separate reports"
  task :parallel do
    # Rapor dizinlerini oluştur
    FileUtils.mkdir_p('test-output/reports')
    FileUtils.mkdir_p('test-output/html')

    # Paralel testleri çalıştır
    system("parallel_rspec --serialize-stdout --group-by runtime spec/")
  end
end

namespace :reports do
  desc "Merge multiple JSON reports into one"
  task :merge do
    report_dir = 'test-output/reports'
    merged_report_path = 'test-output/merged_report.json'

    merged_report = { tests: [] }

    Dir["#{report_dir}/*.json"].each do |file|
      report_data = JSON.parse(File.read(file))
      merged_report[:tests].concat(report_data['tests'])
    end

    File.open(merged_report_path, 'w') do |file|
      file.write(JSON.pretty_generate(merged_report))
    end

    puts "Merged report created at #{merged_report_path}"
  end

  desc "Generate an HTML report from the merged JSON report"
  task :generate_html do
    merged_report_path = 'test-output/merged_report.json'
    html_report_path = 'test-output/html/index.html'

    report_data = JSON.parse(File.read(merged_report_path))
    template = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>Test Report</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 20px; }
          table { border-collapse: collapse; width: 100%; }
          th, td { padding: 8px; text-align: left; border: 1px solid #ddd; }
          th { background-color: #f2f2f2; }
          .pass { color: green; }
          .fail { color: red; }
        </style>
      </head>
      <body>
        <h1>Test Report</h1>
        <table>
          <tr>
            <th>Test Name</th>
            <th>Status</th>
            <th>Duration</th>
            <th>Details</th>
          </tr>
          <% report_data['tests'].each do |test| %>
            <tr>
              <td><%= test['name'] %></td>
              <td class="<%= test['status'].downcase %>"><%= test['status'] %></td>
              <td><%= test['duration'] %>s</td>
              <td><%= test['details'] %></td>
            </tr>
          <% end %>
        </table>
      </body>
      </html>
    HTML

    renderer = ERB.new(template)
    result = renderer.result(binding)

    File.open(html_report_path, 'w') do |file|
      file.write(result)
    end

    puts "HTML report created at #{html_report_path}"
  end
end

desc "Run all tests and generate reports"
task :test_with_reports => ["test:parallel", "reports:merge", "reports:generate_html"]

desc 'Run tests in parallel in preprod environment'
task :parallel_preprod, [:processes] do |t, args|
  ENV['ENV'] = 'preprod'
  processes = args[:processes] ? "-n #{args[:processes]}" : ""
  system("parallel_rspec #{processes} spec/")
end

desc 'Run specific tests in parallel in preprod environment'
task :parallel_preprod_spec, [:spec_path, :processes] do |t, args|
  ENV['ENV'] = 'preprod'
  spec_path = args[:spec_path] || 'spec/'
  processes = args[:processes] ? "-n #{args[:processes]}" : ""
  system("parallel_rspec #{processes} #{spec_path}")
end
require 'nokogiri'

desc 'XML raporlarını birleştirir'
task :merge_xml_reports do
  reports_dir = '/home/livde/AboneSepeti/spec/reports'
  output_file = "#{reports_dir}/merged_report.xml"

  # Tüm XML dosyalarını oku
  xml_files = Dir.glob("#{reports_dir}/*.xml")
  abort("XML dosyası bulunamadı: #{reports_dir}") if xml_files.empty?

  puts "Birleştirilecek XML dosyaları:"
  xml_files.each { |file| puts " - #{file}" }

  # İlk XML dosyasını ana belge olarak kullan
  main_doc = Nokogiri::XML(File.read(xml_files.shift))

  # Diğer XML dosyalarının içeriğini ana belgeye ekle
  xml_files.each do |file|
    doc = Nokogiri::XML(File.read(file))
    test_suites = doc.xpath('//testsuite') # 'testsuite' düğümlerini bul
    test_suites.each { |suite| main_doc.root.add_child(suite) }
  end

  # Birleşik XML raporunu kaydet
  File.write(output_file, main_doc.to_xml)
  puts "Birleşik XML raporu oluşturuldu: #{output_file}"
end
