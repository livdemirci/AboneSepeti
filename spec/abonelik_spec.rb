# frozen_string_literal: true

BASE_DIR = File.expand_path('..', __dir__)

Dir["#{BASE_DIR}/pages/*_page.rb"].each do |file|
  puts "Loading file: #{file}"
  load file
end
require_relative '../test_helper'
require_relative '../agileway_utils'
require_relative 'my_utils'
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
    MainPage.new
    login_page = LoginPage.new
    profil_page = ProfilPage.new
    abonelikler_page = AboneliklerPage.new

    login_page.giris_sayfasini_bekle
    login_page.giris_yap_click
    login_page.sifremi_unuttum_sayfasini_bekle
    login_page.telefon_numarasini_gir
    login_page.kullanici_sifresini_gir
    login_page.giris_yap_click
    profil_page.surum_yenilik_uyarisini_kapat
    abonelikler_page.abonelikler_click
    abonelikler_page.abonelik_ekle_butonuna_tikla
    abonelikler_page.kurum_ara
    abonelikler_page.kurumun_goruntulenmeesini_bekle
    abonelikler_page.kurumun_goruntulendigini_dogrula
    abonelikler_page.adana_suyu_bekle
    

    try_for(9, 3) do
      expect(text).to include('ADANA SU') 
    end

    abonelikler_page.kurumu_sec_click
    abonelikler_page.abone_numarasi_gir
    abonelikler_page.abone_adi_gir
    abonelikler_page.baslangic_tarihi_sec
    abonelikler_page.ok_button_click
    abonelikler_page.taahhüt_süresi_seç('6 Ay')
    abonelikler_page.hanelerim_butonuna_tikla

    abonelikler_page.sec_button_click
    sleep 0.5 # hane seçimi için
    abonelikler_page.kisi_sec_click
    abonelikler_page.devam_et_ve_baska_ekle_butonuna_tikla
    abonelikler_page.abanolik_basarili_bir_sekilde_silindigini_bekle

    try_for(9, 3) do
      expect(toast_message).not_to be_nil, 'Toast mesajı bulunamadı.'
    end

    abonelikler_page.geri_butonuna_tikla

    abonelikler_page.su_aboneliklerine_tikla
    abonelikler_page.abonelige_tikla
    abonelikler_page.evim_suyu_bekle

    try_for(9, 3) do
      expect(evim_su).to include('Evim_Su')
    end

    abonelikler_page.aboneligi_sil_butonunu_görene_kadar_asagi_kaydir
    abonelikler_page.aboneligi_sil_butonuna_tikla
    abonelikler_page.negatif_dialog_click
    abonelikler_page.toast_mesajı_bekle
    
    try_for(9, 3) do
      expect(toast_message).not_to be_nil, 'Toast mesajı bulunamadı!'
    end

    driver.quit_driver
  end
end
