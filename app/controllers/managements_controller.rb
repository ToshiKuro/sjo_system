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
                                                                   'To'           => select_date.strftime('%Y-%m-%dT14:59:59')},
                                         'FlightRequestData'   => {'Airports'     => 'true',
                                                                   'Times'        => 'true',
                                                                   'Loads'        => 'true',
                                                                   'CrewOnBoards' => 'true'} })

    #flight dataがなければ抜ける
    flights_result = response.body[:get_flights_response][:get_flights_result]
    return if flights_result.nil?

    flights_result[:flight].each do |flight|

      unless flight[:times].nil?
        flight_times       = flight[:times][:time]
        block_off          = flight_times.find { |time| time[:type] == 'ActualBlockOff' }
        take_off           = flight_times.find { |time| time[:type] == 'ActualTakeOff' }
        estimated_time     = flight_times.find { |time| time[:type] == 'EstimatedBlockOn' }
        landing            = flight_times.find { |time| time[:type] == 'ActualTouchDown' }
        block_on           = flight_times.find { |time| time[:type] == 'ActualBlockOn' }
      end

      unless flight[:loads].nil?
        if ('5/1').to_date <= select_date && select_date <= ('10/31').to_date
          ad_coefficient   = 150
        elsif flight[:type] == 'S'
          ad_coefficient   = 153
        elsif flight[:type] == 'A'
          ad_coefficient   = 155
        end

        case flight[:type]
        when 'S'
          bag_coefficient  = 7.5
        when 'A'
          bag_coefficient  = 60
        end

        flight_loads       = flight[:loads][:booked_passenger_per_weight]
        adults_load        = flight_loads[:adults].to_i
        children_load      = flight_loads[:children].to_i
        infants_load       = flight_loads[:infants].to_i
        ad_and_ch_load     = adults_load + children_load
        total_pax          = ad_and_ch_load.to_s + ' + ' + infants_load.to_s
        payload            = (adults_load * ad_coefficient) + (children_load * 70) + (ad_and_ch_load * bag_coefficient)
      end

      unless flight[:crew_on_board].nil?
        flight_crew        = flight[:crew_on_board][:crew_on_board]
        pilot_in_command   = flight_crew.find { |crew| crew[:assigned_rank] == 'CP' }
        crew_configuration = flight_crew.find_all{|crew| crew[:crew][:type] == 'P'}.size.to_s + '/' +
                             flight_crew.find_all{|crew| crew[:crew][:type] == 'C'}.size.to_s
      end

      @table_data  << [ flight[:unique_id],
                        flight[:flight_date].strftime('%d%b%y'),
                        'SJO' + flight[:flight_number],
                        flight[:aircraft_registration],
                        pilot_in_command.present?   ? pilot_in_command[:crew][:nickname]          : '',
                        crew_configuration.present? ? crew_configuration                          : '',
                        flight[:departure_airport_code],
                        flight[:std].strftime('%H:%M'),
                        flight[:airports][:departure_airport][:stand],
                        flight[:arrival_airport_code],
                        flight[:sta].strftime('%H:%M'),
                        flight[:airports][:arrival_airport][:stand],
                        Time.at(flight[:sta].to_time - flight[:std].to_time).utc.strftime('%H:%M'),
                        adults_load.present?        ? adults_load                                 : '',
                        children_load.present?      ? children_load                               : '',
                        infants_load.present?       ? infants_load                                : '',
                        total_pax.present?          ? total_pax                                   : '',
                        payload.present?            ? payload.ceil                                : '',
                        block_off.present?          ? block_off[:date_time].strftime('%H%M')      : '',
                        take_off.present?           ? take_off[:date_time].strftime('%H%M')       : '',
                        estimated_time.present?     ? estimated_time[:date_time].strftime('%H%M') : '',
                        landing.present?            ? landing[:date_time].strftime('%H%M')        : '',
                        block_on.present?           ? block_on[:date_time].strftime('%H%M')       : '' ]
    end

  end

end
