require 'sinatra'
require 'nokogiri'

set :public_folder, 'public'  # Bu satırı ekleyin

get '/' do
  # XML dosyasını oku
  xml_file = File.read('/home/livde/AboneSepeti/spec/reports/merged_report.xml')
  doc = Nokogiri::XML(xml_file)

  # Test sonuçlarını al
  tests = doc.xpath('//testcase')
  passed_tests = tests.select { |test| test.xpath('failure').empty? }
  failed_tests = tests.select { |test| !test.xpath('failure').empty? }

  # HTML içeriği oluştur
html_content = '<h1>Test Raporu</h1>'
html_content += '<link rel="stylesheet" type="text/css" href="style.css">'
html_content += '<h2>Tüm Testler</h2>'
html_content += '<table border="1" style="width: 100%; border-collapse: collapse;">'
html_content += '<tr><th>Test Dosyası</th><th>Çalışma Süresi (saniye)</th><th>Sonuç</th></tr>'

tests.each do |test|
  duration = test['time'] || 'N/A'
  error_message = test.xpath('failure').text.strip
  test_name = test['name'] # Test dosyasının adı
  result = error_message.empty? ? 'Geçti' : "Başarısız - Hata: #{error_message}"
  
  # Koşullu stil belirleme
  row_color = error_message.empty? ? 'style="background-color: #d4edda;"' : 'style="background-color: #f8d7da;"'

  html_content += "<tr #{row_color}>"
  html_content += "<td>#{test_name}</td>"
  html_content += "<td>#{duration}</td>"
  html_content += "<td>#{result}</td>"
  html_content += "</tr>"
end

html_content += '</table>'

# Genel özet
total_tests = tests.size
passed_count = passed_tests.size
failed_count = failed_tests.size
html_content += "<h2>Özet</h2>"
html_content += "<p>Toplam Test: #{total_tests}</p>"
html_content += "<p>Geçen Testler: #{passed_count}</p>"
html_content += "<p>Başarısız Testler: #{failed_count}</p>"

# HTML çıktısını döndür
html_content
end
