class FlightDatum < ApplicationRecord

  class << self
    def get_table()

      noc_url1 = Rails.application.credentials.noc[:url1]
      noc_url2 = Rails.application.credentials.noc[:url2]
      noc_id   = Rails.application.credentials.noc[:id]
      noc_pw   = Rails.application.credentials.noc[:pw]
      noc_js   = Rails.application.credentials.noc[:js]

      options  = Selenium::WebDriver::Chrome::Options.new
      #options.add_argument('--headless')
      driver   = Selenium::WebDriver.for :chrome, options: options

      #waitに60秒のタイマーを持たせる
      wait     = Selenium::WebDriver::Wait.new(timeout: 60)

      #siteを開く
      driver.navigate.to(noc_url1)

      input_id = driver.find_element(:id, 'txtUserName')
      input_pw = driver.find_element(:id, 'txtPassword')

      input_id.send_keys(noc_id)
      input_pw.send_keys(noc_pw)

      driver.find_element(:id, 'btnSub').click
      wait.until { driver.find_element(:id, 'menuToggle').displayed? }

      #運航データのsiteを開く
      driver.navigate.to(noc_url2)

      #selectタブを操作
      select_element = driver.find_element(:id, 'CPHcontent_ctl00_DP_ReportFilters')
      wait.until { driver.find_element(:xpath, '//*[@id="ReportViewerReportPanel"]/div/table').displayed? }
      sleep 10

      choose_element = Selenium::WebDriver::Support::Select.new(select_element)
      choose_element.select_by(:text, "SYSTEM DATA")
      wait.until { driver.find_element(:id, 'CPHcontent_ctl00_OptiosRow').displayed? }
      sleep 10

      #データ・シート表示
      driver.find_element(:id, 'CPHcontent_BtnRun').click

    end
  end
end
