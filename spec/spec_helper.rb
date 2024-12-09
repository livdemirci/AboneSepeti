require 'rspec_junit_formatter'

RSpec.configure do |config|
  # Eğer BuildWise Agent ortamında çalışıyorsa stdout ve stderr'yi yakala
  if ENV["RUN_IN_BUILDWISE_AGENT"] == "true"
    config.around(:each) do |example|
      stdout, stderr = StringIO.new, StringIO.new
      $stdout, $stderr = stdout, stderr

      example.run

      example.metadata[:stdout] = $stdout.string
      example.metadata[:stderr] = $stderr.string

      $stdout = STDOUT
      $stderr = STDERR
    end

    # Allure raporu oluşturmak için formatter ekle
    config.add_formatter AllureRubyRSpec::Formatter, "allure-results"
  end
end

