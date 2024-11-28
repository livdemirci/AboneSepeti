# frozen_string_literal: true

BASE_DIR = File.expand_path('..', __dir__)

Dir["#{BASE_DIR}/pages/*_page.rb"].each do |file|
  puts "Loading file: #{file}"
  load file
end
require_relative '../test_helper'
require_relative '../agileway_utils'
require_relative '../my_utils'
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
    Appium::Driver.new(android_caps, true).start_driver
    Appium.promote_appium_methods Object
    # @driver.manage.timeouts.implicit_wait = 10 # saniye cinsinden
    
  end

  after(:all) do
     @driver.quit if @driver
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
    text_adana_su = abonelikler_page.adana_suyu_bekle

    expect(text_adana_su).to include('ADANA SU')

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
    toast_message = abonelikler_page.abanolik_basarili_bir_sekilde_olusturuldugunu_bekle

    expect(toast_message).not_to be_nil, 'Toast mesajı bulunamadı.'

    abonelikler_page.geri_butonuna_tikla

    abonelikler_page.su_aboneliklerine_tikla
    abonelikler_page.abonelige_tikla

    evim_su = abonelikler_page.evim_suyu_bekle

    expect(evim_su).to include('Evim_Su')

    abonelikler_page.aboneligi_sil_butonunu_görene_kadar_asagi_kaydir
    abonelikler_page.aboneligi_sil_butonuna_tikla
    abonelikler_page.negatif_dialog_click
    toast_message = abonelikler_page.toast_mesajı_bekle

    expect(toast_message).not_to be_nil, 'Toast mesajı bulunamadı!'

  end
end
