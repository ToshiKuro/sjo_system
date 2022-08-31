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

      table    = []
      table_tr = []

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
      sleep 5

      choose_element = Selenium::WebDriver::Support::Select.new(select_element)
      choose_element.select_by(:text, "SYSTEM DATA")
      wait.until { driver.find_element(:id, 'CPHcontent_ctl00_OptiosRow').displayed? }
      sleep 5

      #データ・シート表示
      #日付選択
      select_date = DateTime.now.strftime("%d%b%y")
      driver.find_element(:id, 'CPHcontent_ctl00_UC_DateSpan_dpValidFrom').clear
      driver.find_element(:id, 'CPHcontent_ctl00_UC_DateSpan_dpValidFrom').send_keys(select_date)
      driver.find_element(:id, 'CPHcontent_ctl00_UC_DateSpan_dpValidTo').clear
      driver.find_element(:id, 'CPHcontent_ctl00_UC_DateSpan_dpValidTo').send_keys(select_date)
      sleep 3

      #シート表示
      driver.find_element(:id, 'CPHcontent_BtnRun').click
      wait.until { driver.find_element(:xpath, '//*[@id="ReportViewerReportPanel"]/div/table/tbody/tr[10]').displayed? }
      sleep 5

      #全ページ表示
      driver.find_element(:xpath, '//td[contains(text(), "Single Page")]').click
      sleep 1
      driver.find_element(:xpath, '//td[contains(text(), "Continuous")]').click
      wait.until { driver.find_element(:xpath, '//*[@id="ReportViewerReportPanel"]/div/table/tbody/tr[10]').displayed? }
      sleep 5

      #データ・シートから運航データを抽出
      doc = Nokogiri::HTML(driver.page_source)

      doc.xpath('//*[@id="ReportViewerReportPanel"]/div').each do |sheet|
        sheet.xpath('table/tbody/tr').each_with_index do |tr, i|

          if i > 8 && tr.css('td').text == '' then
            break
          elsif i > 8 then
            tr.css('td').each do |td|
              table_tr << td.text
            end
            table << table_tr
            table_tr = []
          end

        end
      end

      table

    end
  end

end
