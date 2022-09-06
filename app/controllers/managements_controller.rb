class ManagementsController < ApplicationController

  def index
    select_date = DateTime.now.strftime("%d%b%y")
    FlightDatum.get_table(select_date)
    @table_data = FlightDatum.where(date: select_date)
  end

  def test
    @mail_msg = ArrivalInformation.get_arrival_information
  end

end
