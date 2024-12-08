require_relative '../test_helper'

class HanelerPage
  include TestHelper

  def hanelerime_tikla
    element = nil
    # Elementin bulunması için denemeleri başlat
    try_for(5, 0.1) do
      element = driver.find_element(:id, 'com.abonesepeti.app:id/ll_my_homes')
    end
    element.click
  end

  def hane_ekleye_tikla
    element = nil
    # Elementin bulunması için denemeleri başlat
    try_for(5, 0.1) do
      element = driver.find_element(:uiautomator, 'new UiSelector().text("Hane Ekle")')
    end
    element.click
  end

  def hane_adı_yaz(hane_adi_gir)
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:uiautomator, 'new UiSelector().text("Hane Adı")')
    end
    # element nil değilse, send_keys işlemini gerçekleştir
    element.send_keys(hane_adi_gir) if element
  end

  def hane_ekle_butonuna_bas
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:id, 'com.abonesepeti.app:id/btn_create_household_dialog_add_new_house_hold')
    end
    element.click
  end

  def hane_basariyla_olusturuldu_yazisini_dogrula
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:xpath, '//android.widget.Toast[@text="Hane başarıyla oluşturuldu"]')
    end
    element.text
  end

  def hane_bilgileriniz_basariyla_olusturuldu_yazisini_dogrula
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:xpath, '//android.widget.Toast[@text="Hane bilgileriniz başarıyla güncellendi"]')
    end
    element.text
  end

  def yeni_haneye_tikla
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:uiautomator, 'new UiSelector().text("test_hanesi")')
    end
    element.click
  end

  def hane_il_secimine_tikla
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:id, 'com.abonesepeti.app:id/edt_selected_city')
    end
    element.click
  end

  def hane_ili_ara(il = kayseri)
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:id, 'com.abonesepeti.app:id/et_search')
    end
    element.send_keys(il)
  end

  def hane_ilini_sec_butonuna_bas
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:uiautomator, 'new UiSelector().resourceId("com.abonesepeti.app:id/btn_select")')
    end
    element.click
  end

  def hane_ilcesini_sec_butonuna_tikla
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:id, 'com.abonesepeti.app:id/edt_selected_county')
    end
    element.click
  end

  def hane_ilcesi_ara(ilce = melikgazi)
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:id, 'com.abonesepeti.app:id/et_search')
    end
    element.send_keys(ilce)
  end

  def hane_ilcesini_sec_butonuna_bas
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:id, 'com.abonesepeti.app:id/btn_select')
    end
    element.click
  end

  def hane_adresini_gir
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:id, 'com.abonesepeti.app:id/addressEditText')
    end
    # Faker ile rastgele bir adres oluşturuyoruz
    text = Faker::Address.street_address
    element.send_keys(text)
  end

  def haneyi_kaydet_butonuna_tikla
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:uiautomator, 'new UiSelector().text("Kaydet")')
    end
    element.click
  end

  def haneneyi_sil_butonuna_tikla
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:uiautomator, 'new UiSelector().text("Haneyi sil")')
    end
    element.click
  end

  def evet_haneyi_sil_dialog_butonuna_bas
    element = nil
    try_for(5, 0.1) do
      element = driver.find_element(:uiautomator, 'new UiSelector().text("Evet, Haneyi Sil")')
    end
    element.click
  end

  def hane_adinin_gorunmedigi_dogrula
    element = nil
    try_for(5, 0.1) do
      element = driver.find_elements(:uiautomator, 'new UiSelector().text("test_hanesi")')
    end
    element
  end

  
end
