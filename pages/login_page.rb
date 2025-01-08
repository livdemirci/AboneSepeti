require_relative '../test_helper'

class LoginPage
  include TestHelper

  # Locators
  GIRIS_YAP_BUTTON = { id: 'com.abonesepeti.app:id/btnSkip' }
  LOGIN_BUTTON = { id: 'com.abonesepeti.app:id/btn_login' }
  GIRIS_YAP_TEXT = { uiautomator: 'new UiSelector().text("Giriş Yap")' }
  SIFREMI_UNUTTUM_TEXT = { uiautomator: 'new UiSelector().text("Şifremi Unuttum")' }
  TELEFON_INPUT = { uiautomator: 'new UiSelector().text("Cep Telefonu")' }
  EMAIL_TELEFON_INPUT = { uiautomator: 'new UiSelector().text("E-posta veya Telefon")' }
  SIFRE_INPUT = { uiautomator: 'new UiSelector().text("Şifre")' }
  KODU_GONDER_BUTTON = { uiautomator: 'new UiSelector().text("Kodu Gönder")' }
  VERIFICATION_CODE_INPUT = { class_name: 'android.widget.EditText' }
  DOGRULA_BUTTON = { uiautomator: 'new UiSelector().text("Doğrula")' }
  SIFRE_ONAY_INPUT = { uiautomator: 'new UiSelector().text("Şifreyi Onayla")' }
  SIFREYI_KAYDET_BUTTON = { uiautomator: 'new UiSelector().text("Şifreyi Kaydet")' }

  # Page Methods
  def giris_yap_click
    giris_yap = nil
    try_for(9, 3) do
      giris_yap = driver.find_element(GIRIS_YAP_BUTTON)
    end
    giris_yap.click
  end

  def giris_yap_login_click
    giris_yap = nil
    try_for(9, 3) do
      giris_yap = driver.find_element(LOGIN_BUTTON)
    end
    giris_yap.click
  end

  def giris_sayfasini_bekle
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    wait.until { driver.find_element(GIRIS_YAP_TEXT) }
  end

  def sifremi_unuttum_sayfasini_bekle
    wait = Selenium::WebDriver::Wait.new(timeout: 15)
    wait.until { driver.find_element(SIFREMI_UNUTTUM_TEXT) }
  end

  def sifremi_unuttum_click
    sifremi_unuttum = nil
    try_for(9, 3) do
      sifremi_unuttum = driver.find_element(SIFREMI_UNUTTUM_TEXT)
    end
    sifremi_unuttum.click
  end

  def telefon_numarasini_gir
    telefon = nil
    try_for(9, 3) do
      telefon = driver.find_element(TELEFON_INPUT)
    end
    telefon.send_keys('5419539727')
  end

  def e_posta_veya_telefon_numarasini_gir
    telefon = nil
    try_for(9, 3) do
      telefon = driver.find_element(EMAIL_TELEFON_INPUT)
    end
    telefon.send_keys('5419539727')
  end

  def varsayılan_sifreyi_gir
    sifre = nil
    try_for(9, 3) do
      sifre = driver.find_element(SIFRE_INPUT)
    end
    sifre.send_keys('123456')
  end

  def giris_yap_butonuna_tikla
    giris_yap = nil
    try_for(9, 3) do
      giris_yap = driver.find_element(LOGIN_BUTTON)
    end
    giris_yap.click
  end

  def kodu_gonder_click
    kodu_gonder = driver.find_element(KODU_GONDER_BUTTON)
    kodu_gonder.click
  end

  def dogrulama_kodunu_al(sms_body)
    return unless sms_body && sms_body =~ /(\d{4})/

    verification_code = Regexp.last_match(0)
    puts "Dogrulama kodu: #{verification_code}"
    @verification_code = verification_code
    verification_code
  end

  def dogrulama_kodunu_gonder(verification_code)
    driver.find_element(VERIFICATION_CODE_INPUT).send_keys(verification_code)
  end

  def dogrulaya_tiklat
    wait = Selenium::WebDriver::Wait.new(timeout: 15)
    wait.until { driver.find_element(DOGRULA_BUTTON) }
    dogrula = driver.find_element(DOGRULA_BUTTON)
    dogrula.click
  end

  def rastgele_sifre_olustur
    Faker::Internet.password(min_length: 8)
  end

  def sifre_alanina_rastgele_sifre_gir(sifre)
    sifre_alani = nil
    try_for(9, 3) do
      sifre_alani = driver.find_element(SIFRE_INPUT)
    end
    sifre_alani.send_keys(sifre)
  end

  def sifre_alanina_girdigin_ayni_sifreyi_gir(sifre)
    sifre_onay_input = driver.find_element(SIFRE_ONAY_INPUT)
    sifre_onay_input.send_keys(sifre)
  end

  def sifreyi_kaydet_butonuna_tikla
    sifreyi_kaydet_button = driver.find_element(SIFREYI_KAYDET_BUTTON)
    sifreyi_kaydet_button.click
  end

  def gelen_mesajlari_al
    sms_output = `adb shell am broadcast -a io.appium.settings.sms.read --es max 10`
    if sms_output.empty?
      puts 'No messages found.'
      return nil
    else
      sms_lines = sms_output.lines
      if sms_lines.any?
        first_line = sms_lines.last
        if first_line =~ /address=(.*?), body=(.*?), date=(.*)/
          sender = Regexp.last_match(1)
          body = Regexp.last_match(2)
          { sender: sender, body: body }
          puts "Sender: #{sender}, Message: #{body}"

          return body
        end
      end
    end

    nil
  end

  def wait_for_otp(otp_pattern, timeout)
    start_time = Time.now

    while Time.now - start_time <= timeout
      data = driver.execute_script('mobile: listSms', { max: 1 }).to_s

      matcher = Regexp.new(otp_pattern).match(data)

      if matcher
        return matcher[1]
      end

      sleep(1)
    end

    nil
  end

  def kullanici_sifresini_gir(sifre = '123456')
    sifre_input = driver.find_element(SIFRE_INPUT)
    sifre_input.send_keys(sifre)
  end

  def version_uyarisini_kapat
    begin
      try_for(3, 0.1) do
        button = driver.find_element({ uiautomator: 'new UiSelector().resourceId("com.abonesepeti.app:id/btn_positive_custom_dialog")' })
        button.click if button.displayed?
        puts 'Versiyon uyarısı kapatıldı!'
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError
      puts 'Versiyon uyarısı bulunamadı, devam ediliyor...'
    rescue => e
      puts "Beklenmeyen bir hata oluştu: #{e.message}"
    end
  end
end
