require 'bundler/setup'
Bundler.require(:default)
require 'rspec'
require 'selenium-webdriver'
require 'appium_lib'
# require 'pry'
require 'pp'
require 'json'
require 'faker'
require 'chunky_png'
require 'base64'
require 'spec_helper'
require_relative '../screenshot_helper'
require 'rspec'


load File.dirname(__FILE__) + '/../test_helper.rb'

describe 'Kullanici cep telefonunu girip şşşşşşkodu gönderdikten sonra gelen 4 haneli ködü girip yeni şifreyi onaylamalı ve kaydetmelidir.' do
  include TestHelper
  include ScreenshotHelper
  before(:all) do
    # device_info = get_device_info
    # @device_name = device_info[:device_name] # Cihaz adını al
    # @wsl_ip = get_wsl_ip
    # puts @wsl_ip ? "WSL IP Address: #{@wsl_ip}" : 'WSL IP Address not found or incorrect format.'

    @caps = {
      caps: {
        platformName: 'Android',
        deviceName: 'c2a1b4cc',
        appPackage: 'com.abonesepeti.app',
        appActivity: 'com.abonesepeti.presentation.main.MainActivity',
        automationName: 'UiAutomator2'
      },
      appium_lib: {
        server_url: 'http://127.0.0.1:4723',
        wait_timeout: 30_000
      }
    }
    @driver = Appium::Driver.new(@caps, true).start_driver
    Appium.promote_appium_methods Object
  end

  after(:all) do
    # @driver.quit if @driver
  end

  it 'Kullanici cep telefonunu girip kodu gönderdikten sonra gelen 4 haneli kodu girip yeni şifreyi onaylamalı ve kaydetmeli.' do
    sleep 5 # uygulama başlaması için

    login_page = LoginPage.new

    login_page.giris_sayfasini_bekle
    path = 'C:\\AboneSepeti\\referance_image\\original.png'

    compare_screenshot_with_reference(path, 0.9)
    compare_screenshot_match_images(path)
    login_page.giris_yap_click

    login_page.sifremi_unuttum_sayfasini_bekle

    login_page.sifremi_unuttum_click

    login_page.telefon_numarasini_gir

    sleep 2 # ekranin gelmesi icin

    login_page.kodu_gonder_click

    sleep 12 # kodun gelmesi icin

    sms_body = login_page.gelen_mesajlari_al # son gelen smsleri al

    sleep 10 # mesajlarin yuklenmesi icin

    verification_code = login_page.dogrulama_kodunu_al(sms_body)

    sleep 4 # regexp islemi icin

    login_page.dogrulama_kodunu_gonder(verification_code)

    login_page.dogrulaya_tiklat

    sifre = login_page.rastgele_sifre_olustur

    sleep 1 # sifre olusturulmasi icin

    login_page.sifre_alanina_rastgele_sifre_gir(sifre)

    login_page.sifre_alanina_girdigin_ayni_sifreyi_gir(sifre)

    login_page.sifreyi_kaydet_butonuna_tikla
  end
end

# ////////////////////////////////////////////////////////////////////////////////////

# def get_wsl_ip
#   os = RbConfig::CONFIG['host_os']
#   command = if os =~ /mingw|mswin|cygwin/
#               'ipconfig'
#             else
#               '/mnt/c/Windows/System32/cmd.exe /c ipconfig'
#             end

#   ipconfig_output = `#{command}`
#   ip_line = ipconfig_output.lines.find { |line| line.include?('vEthernet (WSL (Hyper-V firewall))') }

#   if ip_line.nil?
#     puts 'WSL IP Address not found. Using default IP: http://127.0.0.1'
#     return '127.0.0.1'
#   end

#   ip_line_index = ipconfig_output.lines.index(ip_line)
#   if ip_line_index.nil? || ipconfig_output.lines[ip_line_index + 4].nil?
#     puts 'WSL IP Address not found. Using default IP: http://127.0.0.1'
#     return '127.0.0.1'
#   end

#   ip_address_line = ipconfig_output.lines[ip_line_index + 4]
#   ip_address = ip_address_line.split(':').last.strip

#   if ip_address.match(/\A\d{1,3}(\.\d{1,3}){3}\z/)
#     ip_address
#   else
#     puts 'WSL IP Address not found. Using default IP: http://127.0.0.1'
#     '127.0.0.1'
#   end
# end

# def get_device_info
#   device_name = nil
#   platform_version = nil

#   # ADB ile bağlı cihazları al
#   adb_devices_output = `adb devices` # ADB komutunu çalıştır
#   puts "ADB devices output:\n#{adb_devices_output}" # adb cihazlarının çıktısını yazdır

#   device_line = adb_devices_output.lines.find { |line| line.include?('device') && !line.include?('List of devices') }

#   if device_line
#     puts "Device Line: #{device_line}" # Burada device_line yazdırılıyor
#     device_name = device_line.split("\t").first
#     puts "Device Name: #{device_name}" # Cihaz adını yazdır

#     # Cihazın Android sürümünü bul
#     platform_version = `adb -s #{device_name} shell getprop ro.build.version.release`.strip
#     puts "Platform Version: #{platform_version}" # Android sürümünü yazdır
#   else
#     puts 'No devices found.'
#   end

#   { device_name: device_name, platform_version: platform_version }
# end

# def adb_command(command)
#   `adb #{command}`
# end

# def swipe_up(driver, start_x, start_y, end_x, end_y, _duration = 250)
#   driver.action
#         .move_to_location(start_x, start_y).pointer_down(:left)
#         .move_to_location(end_x, end_y)
#         .release.perform
# end

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
