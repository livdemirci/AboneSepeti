require 'rspec'
require_relative '../test_helper'

class ProfilPage
  include TestHelper

  # Locators
  PROFIL_BUTTON = { id: 'com.abonesepeti.app:id/imgProfile' }
  AYARLAR_BUTTON = { uiautomator: 'new UiSelector().text("Ayarlar")' }
  SIFRE_DEGISTIR_BUTTON = { uiautomator: 'new UiSelector().text("Şifremi Değiştir")' }
  MEVCUT_SIFRE_INPUT = { uiautomator: 'new UiSelector().text("Mevcut Şifre")' }
  YENI_SIFRE_INPUT = { uiautomator: 'new UiSelector().text("Yeni Şifre")' }
  YENI_SIFRE_DOGRULAMA_INPUT = { uiautomator: 'new UiSelector().text("Yeni Şifre Doğrulama")' }
  KAYDET_BUTTON = { uiautomator: 'new UiSelector().text("Kaydet")' }
  SURUM_UYARI_BUTTON = { id: 'com.abonesepeti.app:id/btndDismissDialog' }
  SNACKBAR_TEXT = { id: 'com.abonesepeti.app:id/snackbar_text' }
  CIKIS_YAP_BUTTON = { uiautomator: 'new UiSelector().text("Çıkış Yap")' }
  EVET_BUTTON = { uiautomator: 'new UiSelector().text("Evet")' }

  # Page Methods
  def profil_butonuna_tikla
    try_for(9, 3) do
      driver.find_element(PROFIL_BUTTON).click
    end
  end

  def ayarlar_butonuna_tikla
    element = nil
    try_for(9, 3) do
      element = driver.find_element(AYARLAR_BUTTON)
    end
    element.click
  end

  def sifremi_degistir_click
    element = nil
    try_for(9, 3) do
      element = driver.find_element(SIFRE_DEGISTIR_BUTTON)
    end
    element.click
  end

  def mevcut_sifre_gir(sifre)
    element = driver.find_element(MEVCUT_SIFRE_INPUT)
    element.send_keys(sifre)
  end

  def baslangic_sifresini_gir(yeni_sifre = '123456')
    driver.find_element(YENI_SIFRE_INPUT).send_keys(yeni_sifre)
  end

  def baslangic_sifre_dogrulama_gir(yeni_sifre = '123456')
    driver.find_element(YENI_SIFRE_DOGRULAMA_INPUT).send_keys(yeni_sifre)
  end

  def kaydet_butonuna_tikla
    try_for(9, 3) do
      driver.find_element(KAYDET_BUTTON).click
    end
  end

  def surum_yenilik_uyarisini_kapat
    begin
      try_for(3, 0.1) do
        button = driver.find_element(SURUM_UYARI_BUTTON)
        if button.displayed?
          button.click
          puts 'Sürüm yenilik uyarısı kapatıldı!'
        end
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError
      puts "Uyarı elementi bulunamadı, devam ediliyor..."
    rescue => e
      puts "Beklenmeyen bir hata oluştu: #{e.message}"
    end
  end

  def sifreniz_basarili_bir_sekilde_degistirildi_uyarisini_dogrular
    element = nil
    try_for(9, 0.1) do
      element = driver.find_element(SNACKBAR_TEXT)
    end

    raise 'Element not found within the specified time.' unless element
    element.text
  end

  def cikis_yap_click
    element = nil
    try_for(9, 3) do
      element = driver.find_element(CIKIS_YAP_BUTTON)
    end
    element.click
  end

  def evet_butonuna_tikla
    element = nil
    try_for(9, 3) do
      element = driver.find_element(EVET_BUTTON)
    end
    element.click
  end
end
