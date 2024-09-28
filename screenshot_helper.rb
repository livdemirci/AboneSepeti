require 'rspec'
require 'selenium-webdriver'
require 'appium_lib'

# RSpec.configure do |config|
#   config.include ScreenshotHelper
# appium --use-plugins=images
  module ScreenshotHelper
    def compare_screenshot_match_images(reference_image_path)
      # Similar implementation as compare_screenshot_with_reference
      # Read the reference image as Base64 encoded string
      image1 = File.read(reference_image_path, mode: 'rb')
  
      # Capture screenshot and save it as Base64 encoded string
      image2_path = "screenshot.png"
      @driver.save_screenshot(image2_path)
      image2 = File.read(image2_path, mode: 'rb')
  
      # Compare images using Appium's get_images_similarity method
      get_images_result = @driver.get_images_similarity(first_image: image1, second_image: image2, visualize: true)
  
      # Save the visualized result
      File.open('unmatch_result_visual.png', 'wb') do |file|
        file.write(Base64.decode64(get_images_result['visualization']))
      end
  
      # Get the actual similarity score
      actual_score = get_images_result['score']
    end
  
    
  
    def compare_screenshot_with_reference(reference_image_path, expected_threshold = 0.9)
      # Read the reference image as Base64 encoded string
      image1 = File.read(reference_image_path, mode: 'rb')
  
      # Capture screenshot and save it as Base64 encoded string
      image2_path = "screenshot.png"
      @driver.save_screenshot(image2_path)
      image2 = File.read(image2_path, mode: 'rb')
  
      # Compare images using Appium's get_images_similarity method
      get_images_result = @driver.get_images_similarity(first_image: image1, second_image: image2, visualize: true)
  
      # Save the visualized result
      File.open('unmatch_result_visual.png', 'wb') do |file|
        file.write(Base64.decode64(get_images_result['visualization']))
      end
  
      # Get the actual similarity score
      actual_score = get_images_result['score']
    end
  
    def click_button_if_found(button_image_path)
      # Ekran görüntüsünü al
      screenshot_path = "screenshot.png"
      driver.save_screenshot(screenshot_path)
    
      # Buton resmini tam ekran görüntüsünde bul
      result = driver.find_image_occurrence(screenshot_path, button_image_path)
    
      # Eğer bir eşleşme bulunduysa
      if result && result['score'] > 0.9 # Eşleşme skoru
        rect = result['rect']
        if rect
          # Dikdörtgenin ortasına tıklamak için
          center_x = rect['x'] + (rect['width'] / 2)
          center_y = rect['y'] + (rect['height'] / 2)
    
          # Dokunma hareketini tanımla ve tıkla
          finger = Selenium::WebDriver::Interactions.pointer(:touch, name: 'finger')
          tap = Selenium::WebDriver::Interactions::Sequence.new(finger, 1)
          tap.create_pointer_move(duration: 0, x: center_x, y: center_y, origin: :viewport)
          tap.create_pointer_down(:left) # Sol fare butonuna bas
          tap.create_pointer_up(:left) # Sol fare butonunu bırak
    
          # Eylemi gerçekleştir
          driver.perform([tap])
    
          puts "Butona tıklandı!"
        else
          puts "Butonun koordinatları bulunamadı."
        end
      else
        puts "Buton bulunamadı."
      end
    end
    def get_images_similarity(first_image:, second_image:, visualize: false)
      # Implementation of get_images_similarity method
    end
  end
  # Diğer RSpec yapılandırmaları buraya eklenebilir
