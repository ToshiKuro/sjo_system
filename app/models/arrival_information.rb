class ArrivalInformation

  class << self
    def get_arrival_information()
      opcenter_url = Rails.application.credentials.opcenter[:url]
      opcenter_id  = Rails.application.credentials.opcenter[:id]
      opcenter_pw  = Rails.application.credentials.opcenter[:pw]

      options      = Selenium::WebDriver::Chrome::Options.new
      #options.add_argument('--headless')
      driver       = Selenium::WebDriver.for :chrome, options: options

      #waitに60秒のタイマーを持たせる
      wait         = Selenium::WebDriver::Wait.new(timeout: 60)

      #siteを開く
      driver.navigate.to(opcenter_url)

      input_id = driver.find_element(:id, 'id_username')
      input_pw = driver.find_element(:id, 'id_password')

      input_id.send_keys(opcenter_id)
      input_pw.send_keys(opcenter_pw)

      driver.find_element(:xpath, '//*[@id="login_block"]/div[3]/input').click
      wait.until { driver.find_element(:id, 'center_section').displayed? }
      sleep 5
    end
  end

end
