class ManagementsController < ApplicationController

  def index
    select_date = DateTime.now.strftime("%d%b%y")
    @table_data = FlightDatum.where(date: select_date).order(:date, :scheduled_time_of_departure)
  end

  def get_flight_data
    select_date = DateTime.now.strftime("%d%b%y")
    FlightDatum.get_table(select_date)
  end

  def forward_arrival_information
    ArrivalInformation.get_arrival_information
  end

end
