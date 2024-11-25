module MyUtils
  
  def scroll_to_element(driver, max_attempts)
    attempt = 0

    loop do
      # Hedef elementi kontrol edin ve döngüyü sonlandırın
      element = yield # Block çağrısı
      puts 'Hedef öğe bulundu!'
      return element
    rescue Selenium::WebDriver::Error::NoSuchElementError
      # Maksimum deneme sayısına ulaşıldıysa işlemi sonlandırın
      if attempt >= max_attempts
        puts 'Hedef öğe bulunamadı. Maksimum kaydırma denemesine ulaşıldı.'
        return nil
      end

      # Kaydırma hareketini tanımlayın
      finger = ::Selenium::WebDriver::Interactions.pointer(:touch, name: 'finger1')
      finger.create_pointer_move(duration: 0.5, x: 200, y: 800,
                                 origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
      finger.create_pointer_down(:left)
      finger.create_pointer_move(duration: 0.5, x: 200, y: 300,
                                 origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
      finger.create_pointer_up(:left)

      # Hareketi gerçekleştirin
      driver.perform_actions([finger])
      sleep 1 # Hareketin tamamlanmasını bekleyin

      # Kaydırma deneme sayısını artırın
      attempt += 1
      puts "Kaydırma denemesi: #{attempt}"
    end
  end
end
