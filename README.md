# AboneSepeti Mobile Test Framework

Parallel Appium test framework for AboneSepeti mobile application. This framework supports running tests on multiple devices simultaneously, including both emulators and physical devices.

## 🚀 Features

- **Parallel Test Execution**: Run tests simultaneously on multiple devices
- **Device Management**: Support for different device types (local, emulator, xiaomi, samsung, cloud)
- **Resource Optimization**: Single Appium server per device
- **Performance**: 61% faster test execution compared to serial execution
- **Dynamic Port Assignment**: Automatic port management to avoid conflicts
- **Page Object Model**: Organized test structure using page objects
- **Custom Utilities**: Helper methods for common mobile testing operations

## 📋 Prerequisites

- Ruby 3.2.3+
- Android SDK and Platform Tools
- Appium 2.0+
- Connected Android devices or running emulators
- Node.js and npm (for Appium)

## 🛠️ Installation

1. Clone the repository:
```bash
git clone https://github.com/livdemirci/AboneSepeti.git
cd AboneSepeti
```

2. Install dependencies:
```bash
bundle install
```

3. Install Appium:
```bash
npm install -g appium
appium driver install uiautomator2
```

## ⚙️ Configuration

### Device Configuration (appium.yml)
The `config/appium.yml` file contains device-specific configurations. You can define different capabilities for various device types:

```yaml
default:
  appium_lib:
    server_url: "http://0.0.0.0:4723"

local:
  caps:
    platformName: "Android"
    automationName: "UiAutomator2"
    appPackage: "com.abonesepeti.app"
    appActivity: "com.abonesepeti.presentation.main.MainActivity"
    noReset: true
    fullReset: false
    autoGrantPermissions: true

emulator:
  caps:
    platformName: "Android"
    automationName: "UiAutomator2"
    appPackage: "com.abonesepeti.app"
    appActivity: "com.abonesepeti.presentation.main.MainActivity"
    avd: "Pixel_4_API_30"  # Your emulator name
    noReset: true
```

### Environment Variables

The framework uses several environment variables that can be set before running tests:

- `DEVICE_TYPE`: Type of device to run tests on (local/emulator/xiaomi/samsung/cloud)
- `APPIUM_PORT`: Port for Appium server (default: 4723)
- `SYSTEM_PORT`: System port for UiAutomator2 (default: 8200)
- `UDID`: Device UDID (automatically set by framework)

Example:
```bash
DEVICE_TYPE=emulator APPIUM_PORT=4723 bundle exec rspec spec/sifre_spec.rb
```

## 🏃‍♂️ Running Tests

### Run All Tests in Parallel
```bash
bundle exec rake parallel_tests
```

This will:
1. Detect all connected devices
2. Distribute tests across available devices
3. Start Appium servers with unique ports
4. Execute tests in parallel
5. Clean up servers after completion

### Run a Single Test
```bash
bundle exec rspec spec/sifre_spec.rb
```

### Run Tests on Specific Device Type
```bash
DEVICE_TYPE=xiaomi bundle exec rspec spec/sifre_spec.rb
```

## 📁 Project Structure

```
AboneSepeti/
├── config/
│   ├── appium.yml       # Device configurations
│   └── base_config.rb   # Base configuration module
├── pages/
│   ├── abstract_page.rb # Base page object with common methods
│   ├── login_page.rb    # Login page interactions
│   ├── main_page.rb     # Main page interactions
│   └── ...             # Other page objects
├── spec/
│   ├── abonelik_spec.rb # Subscription tests
│   ├── hane_spec.rb     # Household tests
│   └── sifre_spec.rb    # Password reset tests
├── Gemfile             # Ruby dependencies
├── Rakefile           # Rake tasks including parallel execution
└── README.md          # This documentation
```

## 📝 Writing Tests

### Page Objects
Create page objects in the `pages` directory:

```ruby
class LoginPage < AbstractPage
  def login(phone, password)
    find_element(:id, 'phone_input').send_keys(phone)
    find_element(:id, 'password_input').send_keys(password)
    find_element(:id, 'login_button').click
  end
end
```

### Test Specs
Write tests using RSpec in the `spec` directory:

```ruby
RSpec.describe 'Login functionality' do
  before(:each) do
    @driver = Appium::Driver.new(BaseConfig.get_caps, true).start_driver
    @login_page = LoginPage.new(@driver)
  end

  it 'should login successfully' do
    @login_page.login('5551234567', 'password123')
    expect(@login_page.success_message).to be_displayed
  end
end
```

## 🔧 Utilities and Helpers

### AbstractPage Methods
Common methods available in `abstract_page.rb`:

```ruby
def wait_for_element(locator, timeout = 15)
def scroll_to_element(text)
def verify_toast_message(message)
def take_screenshot(name)
```

### BaseConfig Methods
Configuration methods in `base_config.rb`:

```ruby
BaseConfig.device_type     # Get current device type
BaseConfig.get_caps        # Get device capabilities
```

## ⚡ Performance Optimization

The framework includes several optimizations:

1. **Single Appium Server per Device**:
   - Each device uses one Appium server throughout the test run
   - Servers are reused for multiple tests
   - ~60% reduction in server startup/shutdown overhead

2. **Parallel Test Distribution**:
   - Tests are distributed based on device availability
   - Each device runs tests suited for its type
   - Automatic load balancing across devices

3. **Resource Management**:
   - Dynamic port allocation to avoid conflicts
   - Automatic cleanup of Appium servers
   - Efficient process management

## 🔍 Troubleshooting

### Common Issues

1. **Connection Refused**
```
ERROR: Unable to connect to Appium. Is the server running on http://0.0.0.0:4723?
```
Solution: Start Appium server manually or use rake task

2. **Device Not Found**
```
No devices found for type: xiaomi
```
Solution: Check device connection and `adb devices` output

3. **Element Not Found**
```
Timeout after X seconds with error: An element could not be located
```
Solution: Increase wait time or check element locator

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **Liv Demirci** - *Initial work* - [livdemirci](https://github.com/livdemirci)

## 🙏 Acknowledgments

- Appium community for the excellent mobile testing tool
- Ruby and RSpec communities for the robust testing framework
- All contributors who helped improve this framework
