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


describe 'Kullanici Hanelerim sayfasında yeni hane ekleyip silebilmeli.' do
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

  it 'Kullanici Hanelerim sayfasında yeni hane ekleyip silebilmeli' do
    sleep 5 # uygulama başlaması için
    MainPage.new
    login_page = LoginPage.new
    profil_page = ProfilPage.new
    abonelikler_page = AboneliklerPage.new

    login_page.giris_sayfasini_bekle
    login_page.giris_yap_click
    login_page.sifremi_unuttum_sayfasini_bekle
    login_page.e_posta_veya_telefon_numarasini_gir
    login_page.varsayılan_sifreyi_gir
    login_page.giris_yap_butonuna_tikla

    profil_page.surum_yenilik_uyarisini_kapat

    login_page.version_uyarisini_kapat

    abonelikler_page.abonelikler_click

    haneler_page = HanelerPage.new
    haneler_page.hanelerime_tikla
    haneler_page.hane_ekleye_tikla
    haneler_page.hane_adı_yaz("test_hanesi")
    haneler_page.hane_ekle_butonuna_bas
    hane_dogrulama_yazisi = haneler_page.hane_basariyla_olusturuldu_yazisini_dogrula

    expect(hane_dogrulama_yazisi).to eq("Hane başarıyla oluşturuldu")

    haneler_page.yeni_haneye_tikla
    haneler_page.hane_il_secimine_tikla
    haneler_page.hane_ili_ara("kayseri")
    haneler_page.hane_ilini_sec_butonuna_bas
    haneler_page.hane_ilcesini_sec_butonuna_tikla
    haneler_page.hane_ilcesi_ara("melikgazi")
    haneler_page.hane_ilcesini_sec_butonuna_bas
    haneler_page.hane_adresini_gir
    haneler_page.haneyi_kaydet_butonuna_tikla
    hane_bilgileri_dogrulama_yazisi = haneler_page.hane_bilgileriniz_basariyla_olusturuldu_yazisini_dogrula

    expect(hane_bilgileri_dogrulama_yazisi).to eq("Hane bilgileriniz başarıyla güncellendi")

    haneler_page.haneneyi_sil_butonuna_tikla
    haneler_page.evet_haneyi_sil_dialog_butonuna_bas
    hane = haneler_page.hane_adinin_gorunmedigi_dogrula
    expect(hane.empty?).to be true
  end
end
