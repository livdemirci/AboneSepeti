# frozen_string_literal: true

BASE_DIR = File.expand_path('..', __dir__)

Dir["#{BASE_DIR}/pages/*_page.rb"].each do |file|
  puts "Loading file: #{file}"
  load file
end
require_relative '../test_helper'
require_relative '../agileway_utils'
require 'bundler/setup'
require 'rspec'
require 'selenium-webdriver'
require 'appium_lib'
require 'pry'
require 'pp'
require 'json'
require 'faker'
require 'chunky_png'
require 'base64'

describe 'Kullanici cep telefonunu girip kodu gönderdikten sonra gelen 4 haneli ködü girip yeni şifreyi onaylamalı ve kaydetmelidir.' do
  include TestHelper
  include AgilewayUtils
  before(:all) do
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
    # @driver.manage.timeouts.implicit_wait = 10 # saniye cinsinden
    Appium.promote_appium_methods Object
  end

  after(:all) do
    # @driver.quit if @driver
  end

  it 'Kullanici Aboneliklerim sayfasında abonelikler görüntülenebilmeli,hane ve kişi filtrelemesi yapılabilmeli.' do
    sleep 5 # uygulama başlaması için

    login_page = LoginPage.new
    profil_page = ProfilPage.new
    login_page.giris_sayfasini_bekle

    login_page.giris_yap_click

    login_page.sifremi_unuttum_sayfasini_bekle

    login_page.telefon_numarasini_gir

    sifre = '123456'
    sifre_input = driver.find_element(:uiautomator, 'new UiSelector().text("Şifre")')
    sifre_input.send_keys(sifre)

    login_page.giris_yap_click

    profil_page.surum_yenilik_uyarisini_kapat

    element = nil
    try_for(9, 3) do
      element = driver.find_element(:id, 'com.abonesepeti.app:id/home_fragment_container') # abonelikler
    end
    element.click

    driver.find_element(:id, 'com.abonesepeti.app:id/txt_header_button').click # Abonelik ekle butonuna tıkla

    driver.find_element(:uiautomator, 'new UiSelector().text("Kurum ara")').send_keys('adana') # Kurum ara adana

    try_for(9, 3) do
      driver.find_element(:uiautomator, 'new UiSelector().text("ADANA SU")') # Adana suyu bekle
    end
    text = driver.find_element(:uiautomator, 'new UiSelector().text("ADANA SU")').text # Adana suyu bekle

    try_for(9, 3) do
      expect(text).to include('ADANA SU') # 'include' matcher'ı kullanılıyor
    end
    driver.find_element(:uiautomator, 'new UiSelector().text("ADANA SU")').click # Adana suyu seç

    try_for(9, 3) do
      driver.find_element(:id, 'com.abonesepeti.app:id/service_number') # Abone numarası gir
    end

    driver.find_element(:id, 'com.abonesepeti.app:id/service_number').send_keys('1234567890')

    driver.find_element(:id, 'com.abonesepeti.app:id/edt_alias').send_keys('Evim_Su') # Abone adı gir

    driver.find_element(:id, 'com.abonesepeti.app:id/text_input_end_icon').click # baslangic tarihi seç

    button = nil
    try_for(9, 3) do
      button = driver.find_element(:uiautomator, 'new UiSelector().text("OK")')
    end
    button.click # OK butonuna tıkla

    taahhüt_süresi = '6 Ay'
    driver.find_element(:uiautomator, "new UiSelector().text(\"#{taahhüt_süresi}\")").click # taahhüt süresi seç

    driver.find_element(:id, 'com.abonesepeti.app:id/txt_household_name').click

    sec_button = nil

    try_for(9, 3) do
      sec_button = driver.find_element(:id, 'com.abonesepeti.app:id/btn_select')
    end
    sec_button.click # haneyi seç

    driver.find_element(:id, 'com.abonesepeti.app:id/member_container').click
    sleep 0.5

    sec_button = nil

    try_for(9, 3) do
      sec_button = driver.find_element(:id, 'com.abonesepeti.app:id/btn_select')
    end
    sec_button.click # kisiyi seç

    driver.find_element(:id, 'com.abonesepeti.app:id/btn_subscribe_member_to_platform').click # Devam et ve baska ekle butonuna tıkla

    try_for(9, 3) do
      # Toast mesajlarını bul
      toast_messages = @driver.find_elements(:class_name, 'android.widget.Toast')

      # Eğer herhangi bir toast mesajı bulunursa, mesajı kontrol et
      if toast_messages.any?
        expect(toast_messages.any? { |toast| toast.text == 'Abonelik başarılı bir şekilde silindi.' }).to be true, 'Toast mesajı bulunamadı.'
        break # Eğer mesaj bulunduysa döngüyü sonlandır
      end
    end

    try_for(9, 3) do
      driver.find_element(:id, 'com.abonesepeti.app:id/btn_back').click # geri butonuna tıkla
    end

    element = nil
    try_for(9, 3) do
      element = driver.find_element(:id, 'com.abonesepeti.app:id/home_fragment_container') # abonelikler
    end
    element.click

    driver.find_element(:uiautomator, 'new UiSelector().text("Su")').click # su aboneliklerine tikla

    try_for(9, 3) do
      driver.find_element(:uiautomator, 'new UiSelector().text("Evim_Su")') # Evim suyu bekle
    end

    evim_su = driver.find_element(:uiautomator, 'new UiSelector().text("Evim_Su")').text
    expect(evim_su).to include('Evim_Su')

    driver.find_element(:uiautomator, 'new UiSelector().text("Evim_Su")').click # Evim suyu görüntülemek icin tikla

    try_for(9, 3) do
      driver.find_element(:uiautomator, 'new UiSelector().text("Evim_Su")')
    end

    expect(evim_su).to include('Evim_Su') # evim su görüntülendigini dogrula

    # Öğeyi bul
    element = driver.find_element(:uiautomator, 'new UiSelector().text("Aylık")')

    # DragGesture işlemini gerçekleştir
    driver.execute_script('mobile: dragGesture', {
                            elementId: element.id,
                            endX: 100,
                            endY: 100
                          })

    sleep(1.5) # Kaymasini bekle

    driver.find_element(:uiautomator, 'new UiSelector().text("Sil")').click

    

    try_for(9, 3) do
      driver.find_element(:id, 'com.abonesepeti.app:id/btn_negative_custom_dialog')
    end
    driver.find_element(:id, 'com.abonesepeti.app:id/btn_negative_custom_dialog').click

    elements = @driver.find_elements(:xpath, "//*[contains(@text, 'Evim_Su')]")
    expect(elements).to be_empty, 'Metin bulundu ama bulunmamalıydı.'

    driver.quit_driver
  end
end
