require_relative '../test_helper'
class LoginPage
  include TestHelper

  def giris_yap_click
    giris_yap = nil
    try_for(9, 3) do
      giris_yap = driver.find_element(:id, 'com.abonesepeti.app:id/btnSkip')
    end
    giris_yap.click
  end

  def giris_yap_login_click
    giris_yap = nil
    try_for(9, 3) do
      giris_yap = driver.find_element(:id, 'com.abonesepeti.app:id/btn_login')
    end
    giris_yap.click
  end

  def giris_sayfasini_bekle
    wait = Selenium::WebDriver::Wait.new(timeout: 10) # 10 saniye
    wait.until { driver.find_element(:uiautomator, 'new UiSelector().text("Giriş Yap")') }
  end

  def sifremi_unuttum_sayfasini_bekle
    wait = Selenium::WebDriver::Wait.new(timeout: 15) # 10 saniye
    wait.until { driver.find_element(:uiautomator, 'new UiSelector().text("Şifremi Unuttum")') }
  end

  def sifremi_unuttum_click
    sifremi_unuttum = nil
    try_for(9, 3) do
      sifremi_unuttum = driver.find_element(:uiautomator, 'new UiSelector().text("Şifremi Unuttum")')
    end
    sifremi_unuttum.click
  end

  def telefon_numarasini_gir
    telefon = nil
    try_for(9, 3) do
      telefon = driver.find_element(:uiautomator, 'new UiSelector().text("Cep Telefonu")')
    end
    telefon.send_keys('5419539727')
  end

  def e_posta_veya_telefon_numarasini_gir
    telefon = nil
    try_for(9, 3) do
      telefon = driver.find_element(:uiautomator, 'new UiSelector().text("E-posta veya Telefon")')
    end
    telefon.send_keys('5419539727')
  end

  def varsayılan_sifreyi_gir
    sifre = nil
    try_for(9, 3) do
      sifre = driver.find_element(:uiautomator, 'new UiSelector().text("Şifre")')
    end
    sifre.send_keys('123456')
  end

  def giris_yap_butonuna_tikla
    giris_yap = nil
    try_for(9, 3) do
      giris_yap = driver.find_element(:id, 'com.abonesepeti.app:id/btn_login')
    end
    giris_yap.click
  end

  def kodu_gonder_click
    kodu_gonder = driver.find_element(:uiautomator, 'new UiSelector().text("Kodu Gönder")')
    kodu_gonder.click
  end

  def dogrulama_kodunu_al(sms_body)
    return unless sms_body && sms_body =~ /(\d{4})/

    verification_code = Regexp.last_match(0)
    puts "Dogrulama kodu: #{verification_code}"
    @verification_code = verification_code # Sınıf değişkenine atama
    verification_code # Fonksiyonun geri döndürdüğü değer
  end

  def dogrulama_kodunu_gonder(verification_code)
    driver.find_element(:class_name, 'android.widget.EditText').send_keys(verification_code)
  end

  def dogrulaya_tiklat
    wait = Selenium::WebDriver::Wait.new(timeout: 15) # 10 saniye
    wait.until { driver.find_element(:uiautomator, 'new UiSelector().text("Doğrula")') }
    dogrula = driver.find_element(:uiautomator, 'new UiSelector().text("Doğrula")')
    dogrula.click
  end

  def rastgele_sifre_olustur
    Faker::Internet.password(min_length: 8)
  end

  def sifre_alanina_rastgele_sifre_gir(sifre)
    # Şifre alanına rastgele oluşturulan şifreyi gönder
    sifre_input = driver.find_element(:uiautomator, 'new UiSelector().text("Şifre")')
    sifre_input.send_keys(sifre)
  end

  def sifre_alanina_girdigin_ayni_sifreyi_gir(sifre)
    # Şifreyi onaylamak için aynı şifreyi gönder
    sifre_onay_input = driver.find_element(:uiautomator, 'new UiSelector().text("Şifreyi Onayla")')
    sifre_onay_input.send_keys(sifre)
  end

  def sifreyi_kaydet_butonuna_tikla
    # Şifreyi kaydet butonuna tıkla
    sifreyi_kaydet_button = driver.find_element(:uiautomator, 'new UiSelector().text("Şifreyi Kaydet")')
    sifreyi_kaydet_button.click
  end

  def gelen_mesajlari_al
    sms_output = `adb shell am broadcast -a io.appium.settings.sms.read --es max 10`
    # sms_output = `adb shell content query --uri content://sms/inbox --projection address,body,date --sort "date" --where "1=1"`
    # puts "Latest SMS Output:\n#{sms_output}"

    if sms_output.empty?
      puts 'No messages found.'
      return nil
    else
      sms_lines = sms_output.lines
      if sms_lines.any?
        # Son satırı al ve ayrıştır
        first_line = sms_lines.last
        if first_line =~ /address=(.*?), body=(.*?), date=(.*)/
          sender = Regexp.last_match(1)
          body = Regexp.last_match(2)
          { sender: sender, body: body }
          puts "Sender: #{sender}, Message: #{body}"

          return body # Body değerini döndür
        end
      end
    end

    nil
  end

  def wait_for_otp(otp_pattern, timeout)
    start_time = Time.now

    while Time.now - start_time <= timeout
      # SMS verilerini çek
      data = driver.execute_script('mobile: listSms', { max: 1 }).to_s

      # OTP desenini regex ile eşleştir
      matcher = Regexp.new(otp_pattern).match(data)

      if matcher
        return matcher[1] # Eşleşen ilk grup (1. grup)
      end

      # Belirli bir süre bekle (polling)
      sleep(1)
    end

    nil # OTP bulunamazsa
  end

  def kullanici_sifresini_gir(sifre = '123456')
    sifre_input = driver.find_element(:uiautomator, 'new UiSelector().text("Şifre")')
    sifre_input.send_keys(sifre)
  end

  def version_uyarisini_kapat
    try_for(5, 0.1) do
      # Uyarı elementi çıkarsa bulur ve işlem yaparız
      if driver.find_element(:uiautomator,
                             'new UiSelector().resourceId("com.abonesepeti.app:id/btn_positive_custom_dialog")').displayed?
        driver.find_element(:uiautomator,
                            'new UiSelector().resourceId("com.abonesepeti.app:id/btn_positive_custom_dialog")').click
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError
      # Element bulunamadığında hata atmadan devam eder
      puts 'Uyarı elementi bulunamadı, devam ediliyor...'
    end
  end
end
