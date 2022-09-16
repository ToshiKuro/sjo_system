class FlightDatum < ApplicationRecord

  class << self

    def get_table(select_date)
      options        = Selenium::WebDriver::Chrome::Options.new
      options.binary = '/app/.apt/usr/bin/google-chrome'
      options.add_argument('--headless')
      driver         = Selenium::WebDriver.for :chrome, options: options
      #waitに60秒のタイマーを持たせる
      wait           = Selenium::WebDriver::Wait.new(timeout: 120)

      #siteを開く
      login_to_noc(driver)
      wait.until { driver.find_element(:id, 'menuToggle').displayed? }

      #データ・シート表示
      open_flight_data(select_date, driver, wait)

      #データ・シートから運航データを抽出し、保存する
      doc         = Nokogiri::HTML(driver.page_source)
      flight_data = get_flight_data(doc)

      save_flight_data(flight_data)
      driver.quit
    end

    def login_to_noc(driver)
      noc_url1 = Rails.application.credentials.noc[:url1]
      noc_id   = Rails.application.credentials.noc[:id]
      noc_pw   = Rails.application.credentials.noc[:pw]

      driver.navigate.to(noc_url1)

      input_id = driver.find_element(:id, 'txtUserName')
      input_pw = driver.find_element(:id, 'txtPassword')

      input_id.send_keys(noc_id)
      input_pw.send_keys(noc_pw)

      driver.find_element(:id, 'btnSub').click
    end

    def open_flight_data(select_date, driver, wait)
      noc_url2 = Rails.application.credentials.noc[:url2]
      driver.navigate.to(noc_url2)
      wait.until { driver.find_element(:xpath, '//*[@id="ReportViewerReportPanel"]/div').displayed? }
      sleep 3

      #selectタブを操作
      select_element = driver.find_element(:id, 'CPHcontent_ctl00_DP_ReportFilters')
      choose_element = Selenium::WebDriver::Support::Select.new(select_element)
      choose_element.select_by(:text, "SYSTEM DATA")
      wait.until { driver.find_element(:id, 'CPHcontent_ctl00_LB_Extras2_LBDestination').displayed? }
      sleep 3

      #データ・シート表示
      #日付選択
      driver.find_element(:id, 'CPHcontent_ctl00_UC_DateSpan_dpValidFrom').clear
      driver.find_element(:id, 'CPHcontent_ctl00_UC_DateSpan_dpValidFrom').send_keys(select_date)
      driver.find_element(:id, 'CPHcontent_ctl00_UC_DateSpan_dpValidTo').clear
      driver.find_element(:id, 'CPHcontent_ctl00_UC_DateSpan_dpValidTo').send_keys(select_date)

      #シート表示
      driver.find_element(:id, 'CPHcontent_BtnRun').click
      wait.until { driver.find_element(:xpath, '//*[@id="ReportViewerReportPanel"]/div/table/tbody/tr[10]').displayed? }
      sleep 3

      #全ページ表示
      driver.find_element(:xpath, '//td[contains(text(), "Single Page")]').click
      sleep 1
      driver.find_element(:xpath, '//td[contains(text(), "Continuous")]').click
      wait.until { driver.find_element(:xpath, '//*[@id="ReportViewerReportPanel"]/div/table/tbody/tr[10]').displayed? }
      sleep 3
    end

    def get_flight_data(doc)
      flight_data  = []
      flight_datum = []

      doc.xpath('//*[@id="ReportViewerReportPanel"]/div').each do |sheet|
        sheet.xpath('table/tbody/tr').each_with_index do |tr, i|

          #9行目から、先頭が空白でないデータを抽出
          if i > 8 && tr.css('td').text == ''
            break
          elsif i > 8
            tr.css('td').each do |td|
              flight_datum << td.text
            end

            flight_data << flight_datum
            flight_datum = []
          end

        end
      end

      flight_data
    end

    def save_flight_data(flight_data)
      key      = [:flight_datum_id, :date, :callsign, :domestic, :registration, :departure, :arrival, :scheduled_time_of_departure,
                 :scheduled_time_of_arrival, :block_time, :booked_adults, :booked_children, :booked_infants, :crew_configuration,
                 :arrival_spot, :departure_spot, :block_out, :estimated_time_of_arrival, :take_off, :landing, :block_in, :pilot_in_command]

      flight_data.each do |flight_datum|
        unless flight_datum[4].blank?

          #余分な空白を削除し、データ数を調整する
          if flight_datum[14].blank?
            flight_datum.delete('')
            flight_datum.insert(14, '')

            (22 - flight_datum.size).times do
              flight_datum.insert(-2, '')
            end
          elsif flight_datum.size > 22
            (flight_datum.size - 22).times do
              flight_datum.delete_at(-2)
            end
          end

          flight_datum[1].slice!(7..-1)
          flight_datum = [key, flight_datum].transpose.to_h
          FlightDatum.find_or_initialize_by(flight_datum_id: flight_datum[:flight_datum_id]).update_attributes(flight_datum)
        end
      end
    end

  end

end
