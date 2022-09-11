class ArrivalInformation

  class << self

    def get_arrival_information
      opcenter_url = Rails.application.credentials.opcenter[:url]
      opcenter_id  = Rails.application.credentials.opcenter[:id]
      opcenter_pw  = Rails.application.credentials.opcenter[:pw]

      options      = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless')
      driver       = Selenium::WebDriver.for :chrome, options: options

      #waitに60秒のタイマーを持たせる
      wait         = Selenium::WebDriver::Wait.new(timeout: 60)

      #siteを開く
      driver.navigate.to(opcenter_url)
      wait.until { driver.find_element(:id, 'id_username').displayed? }
      sleep 3

      input_id     = driver.find_element(:id, 'id_username')
      input_pw     = driver.find_element(:id, 'id_password')

      input_id.send_keys(opcenter_id)
      input_pw.send_keys(opcenter_pw)

      driver.find_element(:xpath, '//*[@id="login_block"]/div[3]/input').click
      wait.until { driver.find_element(:id, 'center_section').displayed? }
      sleep 3

      ##arrival informationの抽出
      #ページ情報の取得
      doc = Nokogiri::HTML(driver.page_source)

      #arrival informationをclickしてmsgを表示させる
      doc.css('.message_row').each_with_index do |msg_row, i|
        @first_msg_id = msg_row[:id] if i == 0

        if @last_msg_id.present? && @last_msg_id == msg_row[:id]
          break
        elsif msg_row.xpath('td[3]').text.include?('ARR')
          msg_id = msg_row.get_attribute('id')
          driver.find_element(:id, msg_id).click
        end
      end

      @last_msg_id = @first_msg_id
      sleep 3

      #ページ情報を再取得し、siteを閉じる
      doc = Nokogiri::HTML(driver.page_source)
      driver.quit

      #メール用のarrival informationを抽出
      select_msg = doc.css('pre').select { |value| value.text.include?('QU ANPOCIJ') }
      self.get_mail_msg(select_msg)
    end

    def get_mail_msg(select_msg)
      select_msg.each do |msg|
        text_msg              = msg.text
        date                  = [(DateTime.now - 1).strftime("%d%b%y"), DateTime.now.strftime("%d%b%y")]
        callsign              = text_msg.slice(34..39)

        reference_point       = text_msg.index('/AD')
        arrival_start_point   = reference_point + 4
        arrival_end_point     = reference_point + 7
        departure_start_point = reference_point - 4
        departure_end_point   = reference_point - 1

        arrival               = text_msg.slice(arrival_start_point..arrival_end_point)
        departure             = text_msg.slice(departure_start_point..departure_end_point)

        #メール用にcallsignを修正
        if callsign.include?('/')
          callsign            = callsign.insert(2, '0').delete('/')
          text_msg            = text_msg.insert(39, callsign).slice!(34..38)
        end

        #該当flight_datum検索用にcallsignを修正
        callsign.slice!(0..2)
        callsign_for_search   = 'SJO' + callsign
        flight_datum          = FlightDatum.where(date: date, callsign: callsign_for_search, arrival: arrival, block_in: '')
                                           .where.not(block_out: '')

        #flight_datumがない、または既にblock inしている場合はループを抜ける
        break if flight_datum[0].nil?

        #メール用に不要な文字列を削除し、departureを修正
        text_msg.slice!(0..26)
        fix_msg = text_msg.sub(departure, flight_datum[0].departure)

        ArrivalMailer.forward_mail(fix_msg).deliver_now
      end
    end

  end

end
