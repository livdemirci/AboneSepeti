# frozen_string_literal: true

BASE_DIR = File.expand_path('..', __dir__)

Dir["#{BASE_DIR}/pages/*_page.rb"].each do |file|
  puts "Loading file: #{file}"
  load file
end
require_relative '../test_helper'
require_relative '../agileway_utils'
require_relative '../my_utils'
require_relative '../config/base_config'
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
  include MyUtils
  include TestHelper
  include AgilewayUtils

  before(:all) do
   
    BaseConfig.device_type = 'xiaomi'
    BaseConfig.environment = 'preprod'
    @driver = Appium::Driver.new(BaseConfig.get_caps, true).start_driver
    Appium.promote_appium_methods Object
  end

  after(:all) do
    
    @driver.quit if @driver
  end

  it 'Kullanici telefon numarasini girerek sifresini sifirlar.' do
    sleep 5 # uygulama başlaması için

    login_page = LoginPage.new
    profil_page = ProfilPage.new
    login_page.giris_sayfasini_bekle

    login_page.giris_yap_click

    login_page.sifremi_unuttum_sayfasini_bekle

    login_page.sifremi_unuttum_click

    login_page.telefon_numarasini_gir

    login_page.kodu_gonder_click

    sleep 10 # kodun gelmesi icin

    otp_pattern = /Dogrulama kodunuz:\s*(\d{4})/

    verification_code = login_page.wait_for_otp(otp_pattern, TIMEOUT = 10)
    puts verification_code

    login_page.dogrulama_kodunu_gonder(verification_code)

    login_page.dogrulaya_tiklat

    sifre = login_page.rastgele_sifre_olustur

    sleep 2 # sifre olusturulmasi icin

    login_page.sifre_alanina_rastgele_sifre_gir(sifre)

    login_page.sifre_alanina_girdigin_ayni_sifreyi_gir(sifre)

    login_page.sifreyi_kaydet_butonuna_tikla

    sleep 3 # sifrenin kaydedilmesi icin

    login_page.e_posta_veya_telefon_numarasini_gir

    login_page.sifre_alanina_rastgele_sifre_gir(sifre)

    login_page.giris_yap_login_click

    profil_page.surum_yenilik_uyarisini_kapat

    login_page.version_uyarisini_kapat

    profil_page.profil_butonuna_tikla

    scroll_to_element(@driver, 10) do
      driver.find_element(:uiautomator, 'new UiSelector().text("Ayarlar")')
    end

    profil_page.ayarlar_butonuna_tikla
    profil_page.sifremi_degistir_click

    profil_page.mevcut_sifre_gir(sifre)
    profil_page.baslangic_sifresini_gir
    profil_page.baslangic_sifre_dogrulama_gir
    profil_page.kaydet_butonuna_tikla

    profil_page.sifreniz_basarili_bir_sekilde_degistirildi_uyarisini_dogrular
    expect(profil_page.sifreniz_basarili_bir_sekilde_degistirildi_uyarisini_dogrular).to eq('Şifreniz başarıyla değiştirilmiştir.')
    sleep 0.5
    profil_page.cikis_yap_click
    profil_page.evet_butonuna_tikla
    sleep 2
  end
end
