class ManagementsController < ApplicationController

  def index
    #検索する日にちを選択
    if params[:date].present?
      select_date = params[:date].to_date
    else
      select_date = Date.today
    end

    @select_date = select_date.strftime('%Y-%m-%d')
    @table_data  = []
    get_table_data(select_date)
  end

  def get_table_data(select_date)
    #N-OC APIからデータを取り込む
    client    = Savon.client(:wsdl => Rails.application.credentials.soap_ui[:wsdl])
    response  = client.call(:get_flights,
                            :message => {'Username'            => Rails.application.credentials.noc[:id],
                                         'Password'            => Rails.application.credentials.noc[:pw],
                                         'FlightRequestFilter' => {'From'         => select_date.strftime('%Y-%m-%dT00:00:00'),
                                                                   'To'           => select_date.strftime('%Y-%m-%dT23:59:59')},
                                         'FlightRequestData'   => {'Airports'     => 'true',
                                                                   'Times'        => 'true',
                                                                   'Loads'        => 'true',
                                                                   'CrewOnBoards' => 'true'} })
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
                        block_off      == nil ? '' : block_off[:date_time].strftime('%H%M'),
                        take_off       == nil ? '' : take_off[:date_time].strftime('%H%M'),
                        estimated_time == nil ? '' : estimated_time[:date_time].strftime('%H%M'),
                        landing        == nil ? '' : landing[:date_time].strftime('%H%M'),
                        block_on       == nil ? '' : block_on[:date_time].strftime('%H%M') ]
    end
  end

end
