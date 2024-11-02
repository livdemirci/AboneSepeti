module ErrorHandling
  def error_handling
    yield
  rescue => e
    puts "Hata oluştu: #{e.message}"
    puts "Dosya: #{e.backtrace_locations[0].path}, Satır: #{e.backtrace_locations[0].lineno}" if e.backtrace_locations
    binding.pry  # Hata durumunda dur
  end
end
