class ManagementsController < ApplicationController

  def index
    #検索する日にちを選択
    if params[:date].present?
      select_date = params[:date].to_date
      jst_data    = get_jst_data(select_date)
    else
      select_date = Date.today
    end

    #当日よりも古いデータはDBから、当日以降はWebから取り込む
    if select_date < Date.today && jst_data.present?
      @table_data = jst_data.map { |datum| datum.attributes.values}
    else
      @table_data = FlightDatum.get_table(select_date.strftime('%d%b%y'))
    end

    @select_date = select_date.strftime('%Y-%m-%d')
  end

  def forward_arrival_information
    ArrivalInformation.get_arrival_information
  end

  def get_jst_data(select_date)
    jst_data = FlightDatum.where(date: (select_date - 1).strftime('%d%b%y'),
                                 scheduled_time_of_departure: ['15:00'..'23:59'])
             + FlightDatum.where(date: select_date.strftime('%d%b%y'),
                                 scheduled_time_of_departure: ['00:00'..'14:59'])
  end

end
