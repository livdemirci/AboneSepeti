require_relative '../test_helper'

class AboneliklerPage
  include TestHelper

  def abonelikler_sayfasina_tikla
    element = nil
    try_for(9, 3) do
      element = driver.find_element(:id, 'com.abonesepeti.app:id/home_fragment_container') # abonelikler
    end
    element.click
  end

  def abonelik_ekle_butonuna_tikla
    driver.find_element(:id, 'com.abonesepeti.app:id/txt_header_button').click # Abonelik ekle butonuna tıkla
    
  end

  def kurum_ara
    driver.find_element(:uiautomator, 'new UiSelector().text("Kurum ara")').send_keys('adana') # Kurum ara adana
  end

  def kurumun_goruntulenmeesini_bekle
    try_for(9, 3) do
      driver.find_element(:uiautomator, 'new UiSelector().text("ADANA SU")') # Adana suyu bekle
    end
  end

  def kurumun_goruntulendigini_dogrula; end

  def kurumu_sec_click
    driver.find_element(:uiautomator, 'new UiSelector().text("ADANA SU")').click # Adana suyu seç
  end

  def abone_numarasi_gir
    try_for(9, 3) do
      driver.find_element(:id, 'com.abonesepeti.app:id/service_number') # Abone numarası gir
    end

    driver.find_element(:id, 'com.abonesepeti.app:id/service_number').send_keys('1234567890')
  end

  def abone_adi_gir
    driver.find_element(:id, 'com.abonesepeti.app:id/edt_alias').send_keys('Evim_Su') # Abone adı gir
  end

  def baslangic_tarihi_sec
    driver.find_element(:id, 'com.abonesepeti.app:id/text_input_end_icon').click # baslangic tarihi seç
  end

  def ok_button_click
    button = nil
    try_for(9, 3) do
      button = driver.find_element(:uiautomator, 'new UiSelector().text("OK")')
    end
    button.click # OK butonuna tıkla
  end

  def taahhüt_süresi_seç(taahhüt_süresi)
    driver.find_element(:uiautomator, "new UiSelector().text(\"#{taahhüt_süresi}\")").click # taahhüt süresi seç
  end

  def hanelerim_butonuna_tikla
    driver.find_element(:id, 'com.abonesepeti.app:id/txt_household_name').click
  end

  def sec_button_click
    sec_button = nil

    try_for(9, 3) do
      sec_button = driver.find_element(:id, 'com.abonesepeti.app:id/btn_select')
    end
    sec_button.click # haneyi seç
  end

  def kisi_sec_click
    driver.find_element(:id, 'com.abonesepeti.app:id/member_container').click
    sleep 0.5

    sec_button = nil

    try_for(9, 3) do
      sec_button = driver.find_element(:id, 'com.abonesepeti.app:id/btn_select')
    end
    sec_button.click # kisiyi seç
  end

  def devam_et_ve_baska_ekle_butonuna_tikla
    driver.find_element(:id, 'com.abonesepeti.app:id/btn_subscribe_member_to_platform').click # Devam et ve baska ekle butonuna tıkla
  end

  def geri_butonuna_tikla
    try_for(9, 3) do
      driver.find_element(:uiautomator, 'new UiSelector().resourceId("com.abonesepeti.app:id/btn_back")') # Geri butonu bekle
    end

    geri_butonu = nil
    try_for(9, 3) do
      geri_butonu = driver.find_element(:uiautomator,
                                        'new UiSelector().resourceId("com.abonesepeti.app:id/btn_back")')
    end
    sleep 0.5
    try_for(9, 3) do
      geri_butonu.click if geri_butonu && geri_butonu.displayed?
    end
  end

  def su_aboneliklerine_tikla
    driver.find_element(:uiautomator, 'new UiSelector().text("Su")').click # su aboneliklerine tikla
  end

  def abonelige_tikla
    try_for(9, 3) do
      driver.find_element(:uiautomator, 'new UiSelector().text("Evim_Su")') # Evim suyu bekle
    end
    driver.find_element(:uiautomator, 'new UiSelector().text("Evim_Su")').text
    driver.find_element(:uiautomator, 'new UiSelector().text("Evim_Su")').click # Evim suyu görüntülemek icin tikla
  end

  def aboneligi_sil_butonunu_görene_kadar_asagi_kaydir
    # Öğeyi bul
    element = driver.find_element(:uiautomator, 'new UiSelector().text("Aylık")')

    # DragGesture işlemini gerçekleştir
    driver.execute_script('mobile: dragGesture', {
                            elementId: element.id,
                            endX: 100,
                            endY: 100
                          })

    sleep(1.5) # Kaymasini bekle
  end

  def aboneligi_sil_butonuna_tikla
    driver.find_element(:uiautomator, 'new UiSelector().text("Sil")').click
  end

  def negatif_dialog_click
    try_for(9, 3) do
      driver.find_element(:id, 'com.abonesepeti.app:id/btn_negative_custom_dialog')
    end
    driver.find_element(:id, 'com.abonesepeti.app:id/btn_negative_custom_dialog').click
  end

  def toast_mesajini_bul(mesaj)
    # Belirtilen toast mesajını bulmak için xpath kullanıyoruz
    toast_message = @driver.find_elements(:xpath, "//android.widget.Toast[contains(@text, '#{mesaj}')]")

    # Eğer bulunursa ilk öğeyi döner, bulunamazsa boş bir dizi döner
    toast_message.first
  end

  def abonelikler_click
    element = nil
    try_for(9, 3) do
      element = driver.find_element(:id, 'com.abonesepeti.app:id/home_fragment_container') # abonelikler
    end
    element.click
  end
end
