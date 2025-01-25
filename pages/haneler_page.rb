require_relative '../test_helper'

class HanelerPage
  include TestHelper

  # Locators
  MY_HOMES_BUTTON = { id: 'com.abonesepeti.app.test:id/ll_my_homes' }
  HANE_EKLE_BUTTON = { uiautomator: 'new UiSelector().text("Yeni Hane Ekle")' }
  HANE_ADI_INPUT = { uiautomator: 'new UiSelector().text("Hane Adı")' }
  HANE_EKLE_BUTON = { id: 'com.abonesepeti.app.test:id/btn_create_household_dialog_add_new_house_hold' }
  HANE_BASARIYLA_OLUSTURULDU_TOAST = { xpath: '//android.widget.Toast[@text="Hane başarıyla oluşturuldu"]' }
  HANE_BILGILER_BASARIYLA_OLUSTURULDU_TOAST = { xpath: '//android.widget.Toast[@text="Hane bilgileriniz başarıyla güncellendi"]' }
  YENI_HANE_BUTTON = { uiautomator: 'new UiSelector().text("test_hanesi")' }
  HANE_IL_SECIMI_BUTTON = { id: 'com.abonesepeti.app.test:id/edt_selected_city' }
  HANE_IL_ARAMA_INPUT = { id: 'com.abonesepeti.app.test:id/et_search' }
  HANE_IL_SEC_BUTTON = { uiautomator: 'new UiSelector().resourceId("com.abonesepeti.app.test:id/btn_select")' }
  HANE_ILCE_SECIMI_BUTTON = { id: 'com.abonesepeti.app.test:id/edt_selected_county' }
  HANE_ILCE_ARAMA_INPUT = { id: 'com.abonesepeti.app.test:id/et_search' }
  HANE_ILCE_SEC_BUTTON = { id: 'com.abonesepeti.app.test:id/btn_select' }
  HANE_ADRESI_INPUT = { id: 'com.abonesepeti.app.test:id/addressEditText' }
  HANE_KAYDET_BUTTON = { id: 'com.abonesepeti.app.test:id/btn_change_household_info' }
  HANE_SIL_BUTTON = { id: 'com.abonesepeti.app.test:id/llAddMember' }
  HANE_SIL_EVET_BUTTON = { uiautomator: 'new UiSelector().text("Evet, Haneyi Sil")' }
  HANE_ADI_GORUNMUYOR = { uiautomator: 'new UiSelector().text("test_hanesi")' }

  def hanelerime_tikla
    try_for(9, 0.1) do
      element = driver.find_element(MY_HOMES_BUTTON)
      element.click if element
    end
  end

  def hane_ekleye_tikla
    try_for(9, 0.1) do
      element = driver.find_element(HANE_EKLE_BUTTON)
      element.click if element
    end
  end

  def hane_adı_yaz(hane_adi_gir)
    try_for(9, 0.1) do
      element = driver.find_element(HANE_ADI_INPUT)
      element.send_keys(hane_adi_gir) if element
    end
  end

  def hane_ekle_butonuna_bas
    try_for(9, 0.1) do
      element = driver.find_element(HANE_EKLE_BUTON)
      element.click if element
    end
  end

  def hane_basariyla_olusturuldu_yazisini_dogrula
    element = nil
    try_for(9, 0.1) do
      element = driver.find_element(HANE_BASARIYLA_OLUSTURULDU_TOAST)
    end
    element.text
  end

  def hane_bilgileriniz_basariyla_olusturuldu_yazisini_dogrula
    element = nil
    try_for(9, 0.1) do
      element = driver.find_element(HANE_BILGILER_BASARIYLA_OLUSTURULDU_TOAST)
    end
    element.text
  end

  def yeni_haneye_tikla
    try_for(9, 0.1) do
      element = driver.find_element(YENI_HANE_BUTTON)
      element.click if element
    end
  end

  def hane_il_secimine_tikla
    try_for(9, 0.1) do
      element = driver.find_element(HANE_IL_SECIMI_BUTTON)
      element.click if element
    end
  end

  def hane_ili_ara(il = 'kayseri')
    try_for(9, 0.1) do
      element = driver.find_element(HANE_IL_ARAMA_INPUT)
      element.send_keys(il)
    end
  end

  def hane_ilini_sec_butonuna_bas
    try_for(9, 0.1) do
      element = driver.find_element(HANE_IL_SEC_BUTTON)
      element.click if element
    end
  end

  def hane_ilcesini_sec_butonuna_tikla
    try_for(9, 0.1) do
      element = driver.find_element(HANE_ILCE_SECIMI_BUTTON)
      element.click if element
    end
  end

  def hane_ilcesi_ara(ilce = 'melikgazi')
    try_for(9, 0.1) do
      element = driver.find_element(HANE_ILCE_ARAMA_INPUT)
      element.send_keys(ilce)
    end
  end

  def hane_ilcesini_sec_butonuna_bas
    try_for(9, 0.1) do
      element = driver.find_element(HANE_ILCE_SEC_BUTTON)
      element.click
    end
  end

  def hane_adresini_gir
    try_for(9, 0.1) do
      element = driver.find_element(HANE_ADRESI_INPUT)
      text = Faker::Address.street_address
      element.send_keys(text)
    end
  end

  def haneyi_kaydet_butonuna_tikla
    try_for(9, 0.1) do
      element = driver.find_element(HANE_KAYDET_BUTTON)
      element.click
    end
  end

  def haneneyi_sil_butonuna_tikla
    try_for(9, 0.1) do
      element = driver.find_element(HANE_SIL_BUTTON)
      element.click
    end
  end

  def evet_haneyi_sil_dialog_butonuna_bas
    try_for(9, 0.1) do
      element = driver.find_element(HANE_SIL_EVET_BUTTON)
      element.click
    end
  end

  def hane_adinin_gorunmedigi_dogrula
    try_for(9, 0.1) do
      elements = driver.find_elements(HANE_ADI_GORUNMUYOR)
      elements.empty?
    end
  end
end
