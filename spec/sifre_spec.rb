require 'bundler/setup'
Bundler.require(:default)
require 'rspec'
require 'selenium-webdriver'
require 'appium_lib'
require 'pry'
require 'pp'
require 'json'
require 'faker'
require 'chunky_png'
require 'base64'
require 'rspec'

# Proje kök dizinine göre yolları belirlemek için bir temel yol oluşturuyoruz
BASE_DIR = File.expand_path('..', __dir__)

# Yardımcı dosyaları yüklemek için dinamik yollar
load File.join(BASE_DIR, 'test_helper.rb')
require_relative File.join(BASE_DIR, 'pages', 'abstract_page.rb')
require_relative File.join(BASE_DIR, 'pages', 'login_page.rb')
require_relative File.join(BASE_DIR, 'pages', 'profil_page.rb')
require_relative File.join(BASE_DIR, 'spec', 'agileway_utils.rb')



describe 'Kullanici cep telefonunu girip şşşşşşkodu gönderdikten sonra gelen 4 haneli ködü girip yeni şifreyi onaylamalı ve kaydetmelidir.' do
  include TestHelper
  include AgilewayUtils
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

  it 'Kullanici telefon numarasini girerek sifresini sifirlar.' do
    sleep 5 # uygulama başlaması için

    login_page = LoginPage.new
    profil_page = ProfilPage.new
    login_page.giris_sayfasini_bekle

    login_page.giris_yap_click

    login_page.sifremi_unuttum_sayfasini_bekle

    login_page.sifremi_unuttum_click

    sleep 2 # ekranin gelmesi icin

    login_page.telefon_numarasini_gir

    sleep 2 # numaranin girilmesi icin

    login_page.kodu_gonder_click

    sleep 10 # kodun gelmesi icin

    otp_pattern = /Dogrulama kodunuz:\s*(\d{4})/

    verification_code = login_page.wait_for_otp(otp_pattern, TIMEOUT = 10)
    puts verification_code

    login_page.dogrulama_kodunu_gonder(verification_code)

    login_page.dogrulaya_tiklat

    sifre = login_page.rastgele_sifre_olustur

    sleep 1 # sifre olusturulmasi icin

    login_page.sifre_alanina_rastgele_sifre_gir(sifre)

    login_page.sifre_alanina_girdigin_ayni_sifreyi_gir(sifre)

    login_page.sifreyi_kaydet_butonuna_tikla

    sleep 3 # sifrenin kaydedilmesi icin

    login_page.telefon_numarasini_gir

    login_page.sifre_alanina_rastgele_sifre_gir(sifre)

    login_page.giris_yap_click



    profil_page.surum_yenilik_uyarisini_kapat



    profil_page.profil_butonuna_tikla

    profil_page.ayarlar_butonuna_tikla
    profil_page.sifremi_degistir_click
    profil_page.mevcut_sifre_gir(sifre)
    profil_page.baslangic_sifresini_gir
    profil_page.baslangic_sifre_dogrulama_gir
    profil_page.kaydet_butonuna_tikla

    profil_page.sifreniz_basarili_bir_sekilde_degistirildi_uyarisini_dogrular
    
    profil_page.cikis_yap_click
    profil_page.evet_butonuna_tikla
    driver.quit_driver
  end
end
