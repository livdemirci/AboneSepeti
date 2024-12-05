require 'rspec'
require_relative '../test_helper'

class ProfilPage
  include TestHelper

  def profil_butonuna_tikla
    try_for(9, 3) do
      @driver.find_element(:id, 'com.abonesepeti.app:id/imgProfile').click
    end
  end

  def ayarlar_butonuna_tikla
    element = nil
    try_for(9, 3) do
      element = driver.find_element(:uiautomator, 'new UiSelector().text("Ayarlar")')
    end
    element.click
  end

  def sifremi_degistir_click
    element = nil
    try_for(9, 3) do
      element = driver.find_element(:uiautomator, 'new UiSelector().text("Şifremi Değiştir")')
    end
    element.click
  end

  def mevcut_sifre_gir(sifre)
    element = driver.find_element(:uiautomator, 'new UiSelector().text("Mevcut Şifre")')
    element.send_keys(sifre)
  end

  def baslangic_sifresini_gir(yeni_sifre = '123456')
    driver.find_element(:uiautomator, 'new UiSelector().text("Yeni Şifre")').send_keys(yeni_sifre)
  end

  def baslangic_sifre_dogrulama_gir(yeni_sifre = '123456')
    driver.find_element(:uiautomator, 'new UiSelector().text("Yeni Şifre Doğrulama")').send_keys(yeni_sifre)
  end

  def kaydet_butonuna_tikla
    try_for(9, 3) do
      driver.find_element(:uiautomator, 'new UiSelector().text("Kaydet")').click
    end
  end

  def surum_yenilik_uyarisini_kapat
    begin
      try_for(3, 0.1) do
        # Uyarı elementi çıkarsa bulur ve işlem yaparız
        button = driver.find_element(:id, 'com.abonesepeti.app:id/btndDismissDialog')
        if button.displayed?
          button.click
          puts 'Sürüm yenilik uyarısı kapatıldı!'
        end
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError
      # Element bulunamadığında hata atmadan devam eder
      puts "Uyarı elementi bulunamadı, devam ediliyor..."
    rescue => e
      # Diğer olası hatalar loglanır
      puts "Beklenmeyen bir hata oluştu: #{e.message}"
    end
  end
  

  def sifreniz_basarili_bir_sekilde_degistirildi_uyarisini_dogrular
    element = nil
    # Elementin bulunması için denemeleri başlat
    try_for(9, 0.1) do
      element = driver.find_element(:id, 'com.abonesepeti.app:id/snackbar_text')
    end

    # Eğer element bulunmadıysa hata fırlat
    raise 'Element not found within the specified time.' unless element

    # Elementin metnini döndür
    element.text
  end

  def cikis_yap_click
    element = nil
    try_for(9, 3) do
      element = driver.find_element(:uiautomator, 'new UiSelector().text("Çıkış Yap")')
    end
    element.click
  end

  def evet_butonuna_tikla
    element = nil
    try_for(9, 3) do
      element = driver.find_element(:uiautomator, 'new UiSelector().text("Evet")')
    end
    element.click
  end
end
