class ManagementsController < ApplicationController

  def index
    #検索する日にちを選択
    if params[:date].present?
      select_date = params[:date].to_date
    else
      select_date = Date.today
    end

    #N-OC APIからデータを取り込む
    client   = Savon.client(:wsdl => Rails.application.credentials.soap_ui[:wsdl])
    response = client.call(:get_flights,
                           :message => {'Username'            => Rails.application.credentials.noc[:id],
                                        'Password'            => Rails.application.credentials.noc[:pw],
                                        'FlightRequestFilter' => {'From'         => '2022-10-12T00:00:00',
                                                                  'To'           => '2022-10-12T23:00:00'},
                                        'FlightRequestData'   => {'Airports'     => 'true',
                                                                  'Times'        => 'true',
                                                                  'Loads'        => 'true',
                                                                  'CrewOnBoards' => 'true'} })

    @table_data  = []

    response.body[:get_flights_response][:get_flights_result][:flight].each do |flight|
      next if flight[:times] == nil
      flight_times     = flight[:times][:time]
      flight_loads     = flight[:loads][:booked_passenger_per_weight]
      pilot_in_command = flight[:crew_on_board][:crew_on_board].find { |crew| crew[:assigned_rank] == 'CP' }
      block_off        = flight_times.find { |time| time[:type] == 'ActualBlockOff' }
      take_off         = flight_times.find { |time| time[:type] == 'ActualTakeOff' }
      estimated_time   = flight_times.find { |time| time[:type] == 'EstimatedBlockOn' }
      landing          = flight_times.find { |time| time[:type] == 'ActualTouchDown' }
      block_on         = flight_times.find { |time| time[:type] == 'ActualBlockOn' }

      @table_data  << [ flight[:unique_id],
                        flight[:flight_date].strftime('%d%b%y'),
                        'SJO' + flight[:flight_number],
                        flight[:aircraft_registration],
                        pilot_in_command[:crew][:nickname],
                        #crew_configuration
                        flight[:departure_airport_code],
                        flight[:std].strftime('%H:%M'),
                        flight[:airports][:departure_airport][:stand],
                        flight[:arrival_airport_code],
                        flight[:sta].strftime('%H:%M'),
                        flight[:airports][:arrival_airport][:stand],
                        Time.at(flight[:sta].to_time - flight[:std].to_time).utc.strftime('%H:%M'),
                        flight_loads[:adults],
                        flight_loads[:children],
                        flight_loads[:infants],
                        block_off[:date_time].strftime('%H%M'),
                        take_off[:date_time].strftime('%H%M'),
                        estimated_time == nil ? '' : estimated_time[:date_time].strftime('%H%M'),
                        landing[:date_time].strftime('%H%M'),
                        block_on[:date_time].strftime('%H%M') ]
    end

    @select_date = select_date.strftime('%Y-%m-%d')
  end

  def get_excel_data(select_date)
    xlsx        = Roo::Excelx.new("#{Dir.home}/Desktop/SEND_ARR_INFO.xlsx")
    max_row_num = xlsx.last_row
    excel_data  = []

    max_row_num.times do |i|
      excel_data << xlsx.sheet('schedule').row(i + 1)
    end

    next_day_index = excel_data.find_index { |row| row[1] == Date.today.strftime('%d%b%y') && row[7] >= "15:00"}

    if select_date == Date.today
      excel_data[0..(next_day_index - 1)]
    else
      excel_data[next_day_index..-1]
    end
  end

  def forward_arrival_information
    ArrivalInformation.get_arrival_information
  end

  def get_jst_data(select_date)
    jst_data = FlightDatum.where(date: (select_date - 1).strftime('%d%b%y'),
                                 scheduled_time_of_departure: ['15:00'..'23:59']) +
               FlightDatum.where(date: select_date.strftime('%d%b%y'),
                                 scheduled_time_of_departure: ['00:00'..'14:59'])
  end

end
