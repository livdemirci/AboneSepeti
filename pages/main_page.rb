require_relative '../test_helper'

class MainPage

  include TestHelper

  def profil_sayfasini_bekle
    wait = Selenium::WebDriver::Wait.new(timeout: 10) # 10 saniye
    wait.until { driver.find_element(:id, 'com.abonesepeti.app:id/imgProfile') }
  end

  def profil_click
    profil = driver.find_element(:id, 'com.abonesepeti.app:id/imgProfile')
    profil.click
  end

  
end
