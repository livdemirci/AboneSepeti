
class ProfilPage


include TestHelper


  def profil_butonuna_tikla
    try_for(9, 3) do
    element = @driver.find_element(:id, 'com.abonesepeti.app:id/imgProfile').click

    end
  end

  def ayarlar_butonuna_tikla
    try_for(9, 3) do
    element =  driver.find_element(:uiautomator, 'new UiSelector().text("Ayarlar")')
    element.click
    end
  end

  def sifremi_degistir_click
    element = driver.find_element(:uiautomator, 'new UiSelector().text("Şifremi Değiştir")')
    element.click
  end

  def mevcut_sifre_gir(sifre)
    element = driver.find_element(:uiautomator, 'new UiSelector().text("Mevcut Şifre")')
    element.send_keys(sifre)
  end


  def baslangic_sifresini_gir(yeni_sifre='123456')
    element = driver.find_element(:uiautomator, 'new UiSelector().text("Yeni Şifre")').send_keys(yeni_sifre)
  end


  def baslangic_sifre_dogrulama_gir(yeni_sifre='123456')
    driver.find_element(:uiautomator, 'new UiSelector().text("Yeni Şifre Doğrulama")').send_keys(yeni_sifre)
  end

  def kaydet_butonuna_tikla
    driver.find_element(:uiautomator, 'new UiSelector().text("Kaydet")').click
  end

  def surum_yenilik_uyarisini_kapat
    try_for(9, 3) do
      # Uyarı elementi çıkarsa bulur ve işlem yaparız
      if driver.find_element(:id, 'com.abonesepeti.app:id/btndDismissDialog').displayed?
        driver.find_element(:id, 'com.abonesepeti.app:id/btndDismissDialog').click
      end
    end
  end

  def sifreniz_basarili_bir_sekilde_degistirildi_uyarisini_dogrular
    try_for(9, 3) do
      text = driver.find_element(:id, 'com.abonesepeti.app:id/snackbar_text').text
   expect(text).to eq('Şifreniz başarıyla değiştirilmiştir.')
   end
  end

  def cikis_yap_click
    driver.find_element(:uiautomator, 'new UiSelector().text("Çıkış Yap")').click
  end

  def evet_butonuna_tikla
    driver.find_element(:uiautomator, 'new UiSelector().text("Evet")').click
  end
end
