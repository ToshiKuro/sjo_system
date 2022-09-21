class ManagementsController < ApplicationController

  def index
    #検索する日にちを選択
    if params[:date].present?
      select_date = params[:date].to_date
    else
      select_date = DateTime.now
    end

    #当日よりも古いデータはDBから、当日以降はWebから取り込む
    if select_date.strftime('%Y-%m-%d') < DateTime.now.strftime('%Y-%m-%d')
      @table_data = FlightDatum.where(select_date.strftime('%d%b%y'))
    else
      @table_data = FlightDatum.get_table(select_date.strftime('%d%b%y'))
    end

    @select_date = select_date.strftime('%Y-%m-%d')
  end

  def forward_arrival_information
    ArrivalInformation.get_arrival_information
  end

end
