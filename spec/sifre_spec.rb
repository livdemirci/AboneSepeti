require 'rspec'
require 'selenium-webdriver'
require 'appium_lib'
# require 'pry'
require 'pp'
require 'json'
require 'faker'

load File.dirname(__FILE__) + '/../test_helper.rb'

describe 'Kullanici cep telefonunu girip şşşşşşkodu gönderdikten sonra gelen 4 haneli ködü girip yeni şifreyi onaylamalı ve kaydetmelidir.' do
  include TestHelper

  before(:all) do
    device_info = get_device_info
    @device_name = device_info[:device_name] # Cihaz adını al
    @wsl_ip = get_wsl_ip
    puts @wsl_ip ? "WSL IP Address: #{@wsl_ip}" : 'WSL IP Address not found or incorrect format.'

    @caps = {
      caps: {
        platformName: 'Android',
        deviceName: @device_name, # Cihaz adını buraya ekliyoruz
        appPackage: 'com.abonesepeti.app',
        appActivity: 'com.abonesepeti.presentation.main.MainActivity',
        automationName: 'UiAutomator2'
      },
      appium_lib: {
        server_url: "http://#{@wsl_ip}:4723",
        wait_timeout: 30_000
      }
    }
    @driver = Appium::Driver.new(@caps, true).start_driver
    Appium.promote_appium_methods Object
  end

  after(:all) do
    @driver.quit if @driver
  end

  it 'Kullanici cep telefonunu girip kodu gönderdiktenşşşşşşş sonra gelen 4 haneli kodu girip yeni şifreyi onaylamalı ve kaydetmeli.' do
    sleep 5 # uygulama başlaması için

    wait = Selenium::WebDriver::Wait.new(timeout: 10) # 10 saniye
    wait.until { driver.find_element(:uiautomator, 'new UiSelector().text("Giriş Yap")') }

    login_page = LoginPage.new
    login_page.giris_yap_click

    sleep 6 # giris ekrani yuklenmesi icin

    sifremi_unuttum = driver.find_element(:uiautomator, 'new UiSelector().text("Şifremi Unuttum")')
    sifremi_unuttum.click

    telefon = driver.find_element(:uiautomator, 'new UiSelector().text("Cep Telefonu")')
    telefon.send_keys('5419539727')

    sleep 1 # ekranin gelmesi icin

    kodu_gonder = driver.find_element(:uiautomator, 'new UiSelector().text("Kodu Gönder")')
    kodu_gonder.click

    sleep 9 # kodun gelmesi icin

    sms_body = get_latest_sms

    sleep 12 # mesajlarin yuklenmesi icin

    if sms_body && sms_body =~ /(\d{4})/
      verification_code = Regexp.last_match(0)
      puts "Dogrulama kodu: #{verification_code}"
    end

    sleep 1 # regexp islemi icin

    driver.find_element(:class_name, 'android.widget.EditText').send_keys(verification_code)

    dogrula = driver.find_element(:uiautomator, 'new UiSelector().text("Doğrula")')
    dogrula.click

    # Faker ile rastgele bir şifre oluştur
    sifre = Faker::Internet.password(min_length: 8)
    sleep 0.5
    # Şifre alanına rastgele oluşturulan şifreyi gönder
    sifre_input = driver.find_element(:uiautomator, 'new UiSelector().text("Şifre")')
    sifre_input.send_keys(sifre)

    # Şifreyi onaylamak için aynı şifreyi gönder
    sifre_onay_input = driver.find_element(:uiautomator, 'new UiSelector().text("Şifreyi Onayla")')
    sifre_onay_input.send_keys(sifre)

    # Şifreyi kaydet butonuna tıkla
    sifreyi_kaydet_button = driver.find_element(:uiautomator, 'new UiSelector().text("Şifreyi Kaydet")')
    sifreyi_kaydet_button.click
  end

  def get_wsl_ip
  os = RbConfig::CONFIG["host_os"]
  command = if os =~ /mingw|mswin|cygwin/
      "ipconfig"
    else
      "/mnt/c/Windows/System32/cmd.exe /c ipconfig"
    end

  ipconfig_output = `#{command}`
  ip_line = ipconfig_output.lines.find { |line| line.include?("vEthernet (WSL (Hyper-V firewall))") }

  if ip_line.nil?
    puts "WSL IP Address not found. Using default IP: http://127.0.0.1"
    return "127.0.0.1"
  end

  ip_line_index = ipconfig_output.lines.index(ip_line)
  if ip_line_index.nil? || ipconfig_output.lines[ip_line_index + 4].nil?
    puts "WSL IP Address not found. Using default IP: http://127.0.0.1"
    return "127.0.0.1"
  end

  ip_address_line = ipconfig_output.lines[ip_line_index + 4]
  ip_address = ip_address_line.split(":").last.strip

  if ip_address.match(/\A\d{1,3}(\.\d{1,3}){3}\z/)
    ip_address
  else
    puts "WSL IP Address not found. Using default IP: http://127.0.0.1"
    "127.0.0.1"
  end
end


  def get_device_info
    device_name = nil
    platform_version = nil

    # ADB ile bağlı cihazları al
    adb_devices_output = `adb devices` # ADB komutunu çalıştır
    puts "ADB devices output:\n#{adb_devices_output}" # adb cihazlarının çıktısını yazdır

    device_line = adb_devices_output.lines.find { |line| line.include?('device') && !line.include?('List of devices') }

    if device_line
      puts "Device Line: #{device_line}" # Burada device_line yazdırılıyor
      device_name = device_line.split("\t").first
      puts "Device Name: #{device_name}" # Cihaz adını yazdır

      # Cihazın Android sürümünü bul
      platform_version = `adb -s #{device_name} shell getprop ro.build.version.release`.strip
      puts "Platform Version: #{platform_version}" # Android sürümünü yazdır
    else
      puts 'No devices found.'
    end

    { device_name: device_name, platform_version: platform_version }
  end

  def adb_command(command)
    `adb #{command}`
  end

  def get_latest_sms
    sms_output = `adb shell content query --uri content://sms/inbox --projection address,body,date --sort "date" --where "1=1"`
    # puts "Latest SMS Output:\n#{sms_output}"

    latest_sms = nil

    if sms_output.empty?
      puts 'No messages found.'
      return nil
    else
      sms_lines = sms_output.lines
      if sms_lines.any?
        # Son satırı al ve ayrıştır
        first_line = sms_lines.last
        if first_line =~ /address=(.*?), body=(.*?), date=(.*)/
          sender = Regexp.last_match(1)
          body = Regexp.last_match(2)
          latest_sms = { sender: sender, body: body }
          puts "Sender: #{sender}, Message: #{body}"

          return body # Body değerini döndür
        end
      end
    end

    nil
  end

  # def swipe_up(driver, start_x, start_y, end_x, end_y, _duration = 250)
  #   driver.action
  #         .move_to_location(start_x, start_y).pointer_down(:left)
  #         .move_to_location(end_x, end_y)
  #         .release.perform
  # end
end
# # Bildirimleri aç
# driver.execute_script('mobile: openNotifications')

# sleep 1

# # Bildirim öğelerini al
# notifications = driver.find_elements(:id, 'android:id/status_bar_latest_event_content')

# # Son bildirim öğesini al
# last_notification = notifications.last

# # Son bildirimin metin içeriğini al
# notification_text_element = last_notification.find_element(:id, 'android:id/message_text')

# notification_text = notification_text_element.text
# puts "Son gelen bildirimin metni: #{notification_text}"

# if notification_text =~ /(\d{4})/
#   verification_code = Regexp.last_match(1)
#   puts "4 haneli doğrulama kodu: #{verification_code}"
# end

# driver.navigate.back
# sleep 2
# driver.find_element(:class_name, 'android.widget.EditText').send_keys(verification_code)

# dogrula = driver.find_element(:uiautomator, 'new UiSelector().text("Doğrula")')
# dogrula.click
# sleep 4
