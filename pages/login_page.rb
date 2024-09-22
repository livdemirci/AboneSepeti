class LoginPage

  def giris_yap_click 
    giris_yap=driver.find_element(:uiautomator, 'new UiSelector().text("Giriş Yap")')
    giris_yap.click
  end
end
