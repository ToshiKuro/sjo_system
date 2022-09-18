class ManagementsController < ApplicationController

  def index
    if params[:date].blank?
      select_date = DateTime.now
    else
      select_date = params[:date].to_date
      FlightDatum.get_table(select_date.strftime("%d%b%y"))
    end

    @table_data  = FlightDatum.where(date: select_date.strftime("%d%b%y"))
                              .order(:date, :scheduled_time_of_departure)
    @select_date = select_date.strftime('%Y-%m-%d')
  end

  def get_flight_data
    select_date =params[:select_date].to_date.strftime('%Y-%m-%d')
    FlightDatum.get_table(select_date)
  end

  def forward_arrival_information
    ArrivalInformation.get_arrival_information
  end

end
