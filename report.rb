require 'sinatra'
require 'nokogiri'
require 'fileutils'

set :public_folder, 'public'

# Dinamik dosya yolu için temel dizin
BASE_DIR = ENV['REPORT_BASE_DIR'] || __dir__

get '/' do
  # Reports dizinindeki en son oluşturulan alt dizini bul
  reports_dir = File.join(BASE_DIR, 'reports')
  latest_report_dir = Dir.glob(File.join(reports_dir, '*')).max_by { |f| File.mtime(f) }

  unless latest_report_dir && File.directory?(latest_report_dir)
    return "Rapor dizini bulunamadı: #{reports_dir}. Lütfen raporların doğru dizinde olduğundan emin olun."
  end

  # XML dosyasının dinamik yolu
  xml_file_path = File.join(latest_report_dir, 'merged_report.xml')

  # XML dosyasını oku
  unless File.exist?(xml_file_path)
    return "XML dosyası bulunamadı: #{xml_file_path}. Lütfen raporların doğru dizinde olduğundan emin olun."
  end

  xml_file = File.read(xml_file_path)
  doc = Nokogiri::XML(xml_file)

  # Test sonuçlarını al
  tests = doc.xpath('//testcase')
  passed_tests = tests.select { |test| test.xpath('failure').empty? }
  failed_tests = tests.select { |test| !test.xpath('failure').empty? }

  # Test başlama tarihi ve diğer bilgiler
  test_start_time = doc.at_xpath('//testsuite/@timestamp')&.value || 'N/A'

  # HTML içeriği oluştur
  html_content = '<h1>Test Raporu</h1>'
  html_content += '<link rel="stylesheet" type="text/css" href="style.css">'
  html_content += "<p><strong>Test Başlama Tarihi:</strong> #{test_start_time}</p>"
  html_content += '<h2>Tüm Testler</h2>'
  html_content += '<table>'
  html_content += '<tr><th>Test Dosyası</th><th>Çalışma Süresi (saniye)</th><th>Sonuç</th><th>Ekran Görüntüsü</th></tr>'

  tests.each do |test|
    duration = test['time'] || 'N/A'
    error_message = test.xpath('failure').text.strip
    test_name = test['name']
    result = error_message.empty? ? 'Geçti' : "Başarısız - Hata: #{error_message}"
    row_class = error_message.empty? ? 'passed' : 'failed'

    # Ekran görüntüsü dosya yolu (dinamik olarak oluşturuluyor)
    screenshot_path = if error_message.empty?
                       ''
                     else
                       screenshot_file = File.join(latest_report_dir, 'screenshots', "#{test_name}.png")
                       File.exist?(screenshot_file) ? "/screenshots/#{test_name}.png" : ''
                     end

    html_content += "<tr class='#{row_class}'>"
    html_content += "<td>#{test_name}</td>"
    html_content += "<td>#{duration}</td>"
    html_content += "<td>#{result}</td>"
    html_content += "<td>#{screenshot_path.empty? ? '' : "<img src='#{screenshot_path}' alt='Ekran Görüntüsü' style='width:100px;'>"}</td>"
    html_content += "</tr>"
  end

  html_content += '</table>'

  # Genel özet
  total_tests = tests.size
  passed_count = passed_tests.size
  failed_count = failed_tests.size
  html_content += "<div class='summary'>"
  html_content += "<h2>Özet</h2>"
  html_content += "<p>Toplam Test: #{total_tests}</p>"
  html_content += "<p>Geçen Testler: #{passed_count}</p>"
  html_content += "<p>Başarısız Testler: #{failed_count}</p>"
  html_content += "</div>"

  # HTML çıktısını döndür
  html_content
end