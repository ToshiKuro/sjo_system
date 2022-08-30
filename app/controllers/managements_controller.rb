class ManagementsController < ApplicationController
  def index
    @test_data = FlightDatum.get_table()
  end
end
