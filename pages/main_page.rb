require_relative '../test_helper'

class MainPage
  include TestHelper

  # Locators
  PROFIL_BUTTON = { id: 'com.abonesepeti.app:id/imgProfile' }

  # Page Methods
  def profil_sayfasini_bekle
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    wait.until { driver.find_element(PROFIL_BUTTON) }
  end

  def profil_click
    profil = driver.find_element(PROFIL_BUTTON)
    profil.click
  end
end
