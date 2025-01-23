require_relative '../test_helper'

class AboneliklerPage
  include TestHelper

  # Locators
  ABONELIKLER_BUTTON = { id: 'com.abonesepeti.app.test:id/home_fragment_container' }
  ABONELIK_EKLE_BUTTON = { id: 'com.abonesepeti.app.test:id/txt_header_button' }
  KURUM_ARA_INPUT = { uiautomator: 'new UiSelector().text("Kurum ara")' }
  ADANA_SU_TEXT = { uiautomator: 'new UiSelector().text("ADANA SU")' }
  ABONE_NUMARASI_INPUT = { id: 'com.abonesepeti.app.test:id/service_number' }
  ABONE_ADI_INPUT = { id: 'com.abonesepeti.app.test:id/edt_alias' }
  BASLANGIC_TARIHI_BUTTON = { id: 'com.abonesepeti.app.test:id/text_input_end_icon' }
  OK_BUTTON = { uiautomator: 'new UiSelector().text("OK")' }
  HANELERIM_BUTTON = { id: 'com.abonesepeti.app.test:id/txt_household_name' }
  KISI_CONTAINER = { id: 'com.abonesepeti.app.test:id/member_container' }
  DEVAM_ET_BUTTON = { id: 'com.abonesepeti.app.test:id/btn_subscribe_member_to_platform' }
  GERI_BUTTON = { uiautomator: 'new UiSelector().resourceId("com.abonesepeti.app.test:id/btn_back")' }
  SU_ABONELIKLERI_BUTTON = { uiautomator: 'new UiSelector().text("Su")' }
  EVIM_SU_TEXT = { uiautomator: 'new UiSelector().text("Evim_Su")' }
  ABONELIGI_SIL_BUTTON = { uiautomator: 'new UiSelector().text("Sil")' }
  NEGATIF_DIALOG_BUTTON = { id: 'com.abonesepeti.app.test:id/btn_negative_custom_dialog' }
  TOAST_MESSAGE = { xpath: "//*[contains(@text, 'Abonelik başarılı bir şekilde oluşturuldu.')]" }
  FIKIRLERINIZI_MERAK_EDIYORUZ_HAYIR_BUTTON = { id: 'com.abonesepeti.app.test:id/noThanksTextView' }
  SEC_BUTTON = { id: 'com.abonesepeti.app.test:id/btn_select' }

  # Page Methods
  def abonelikler_sayfasina_tikla
    element = nil
    try_for(9, 3) do
      element = driver.find_element(ABONELIKLER_BUTTON)
    end
    element.click
  end

  def abonelik_ekle_butonuna_tikla
    driver.find_element(ABONELIK_EKLE_BUTTON).click
  end

  def kurum_ara(kurum)
    element = driver.find_element(KURUM_ARA_INPUT)
    element.send_keys(kurum)
  end

  def kurumun_goruntulenmeesini_bekle
    try_for(9, 3) do
      driver.find_element(ADANA_SU_TEXT)
    end
  end

  def kurumun_goruntulendigini_dogrula; end

  def kurumu_sec_click
    driver.find_element(ADANA_SU_TEXT).click
  end

  def abone_numarasi_gir(numara)
    element = nil
    try_for(9, 3) do
      element = driver.find_element(ABONE_NUMARASI_INPUT)
    end
    element.send_keys(numara)
  end

  def abone_adi_gir
    driver.find_element(ABONE_ADI_INPUT).send_keys('Evim_Su')
  end

  def baslangic_tarihi_sec
    driver.find_element(BASLANGIC_TARIHI_BUTTON).click
  end

  def ok_button_click
    button = nil
    try_for(9, 3) do
      button = driver.find_element(OK_BUTTON)
    end
    button.click
  end

  def taahhüt_süresi_seç(taahhüt_süresi)
    driver.find_element(uiautomator: "new UiSelector().text(\"#{taahhüt_süresi}\")").click
  end

  def hanelerim_butonuna_tikla
    driver.find_element(HANELERIM_BUTTON).click
  end

  def sec_button_click
    sec_button = nil
    try_for(9, 3) do
      sec_button = driver.find_element(SEC_BUTTON)
    end
    sec_button.click
  end

  def kisi_sec_click
    driver.find_element(KISI_CONTAINER).click
    sleep 0.5

    sec_button = nil
   
    try_for(9, 3) do
      sec_button = driver.find_element(SEC_BUTTON)
    end
    sec_button.click
  end

  def devam_et_ve_baska_ekle_butonuna_tikla
    try_for(9, 3) do
      driver.find_element(DEVAM_ET_BUTTON).click
    end
  end

  def geri_butonuna_tikla
    try_for(9, 3) do
      driver.find_element(GERI_BUTTON)
    end

    geri_butonu = nil
    try_for(9, 3) do
      geri_butonu = driver.find_element(GERI_BUTTON)
    end
    geri_butonu.click
  end

  def su_aboneliklerine_tikla
    try_for(9, 3) do
      driver.find_element(SU_ABONELIKLERI_BUTTON).click
    end
  end

  def abonelige_tikla
    evim_su = nil
    try_for(9, 3) do
      evim_su = driver.find_element(EVIM_SU_TEXT)
    end
    evim_su.click
  end

  def aboneligi_sil_butonunu_görene_kadar_asagi_kaydir
    element = driver.find_element(ADANA_SU_TEXT)

    driver.execute_script('mobile: dragGesture', {
                            elementId: element.id,
                            endX: 100,
                            endY: 100
                          })

    sleep(1.5)
  end

  def aboneligi_sil_butonuna_tikla
    driver.find_element(ABONELIGI_SIL_BUTTON).click
  end

  def negatif_dialog_click
    try_for(9, 3) do
      driver.find_element(NEGATIF_DIALOG_BUTTON)
    end
    driver.find_element(NEGATIF_DIALOG_BUTTON).click
  end

  def toast_mesajini_bul(mesaj)
    toast_message = nil
    try_for(10, 0.01) do
      toast_message = @driver.find_elements(:xpath, "//android.widget.Toast[contains(@text, '#{mesaj}')]").first
    end
    toast_message
  end

  def abonelikler_click
    element = nil
    try_for(9, 3) do
      element = driver.find_element(ABONELIKLER_BUTTON)
    end
    element.click
  end

  def adana_suyu_bekle
    text = nil
    try_for(9, 0.1) do
      text = driver.find_element(ADANA_SU_TEXT).text
    end
    text
  end

  def abanolik_basarili_bir_sekilde_olusturuldugunu_bekle
    toast_mesajini_bul('Abonelik başarılı bir şekilde oluşturuldu.')
  end

  def evim_suyu_bekle
    text = nil
    try_for(5, 0.1) do
      text = driver.find_element(EVIM_SU_TEXT).text
    end
    text
  end

  def toast_mesajı_bekle
    text = nil
    try_for(10, 0.01) do
      text = driver.find_element(:xpath, "//*[contains(@text, 'Abonelik başarılı bir şekilde silindi.')]").text
    end
    text
  end

  def fikirlerinizi_merak_ediyoruz_hayır_tikla
    element = nil
    try_for(10, 0.1) do
      element = driver.find_element(FIKIRLERINIZI_MERAK_EDIYORUZ_HAYIR_BUTTON)
    end
    element.click
  end
end
