class FlightDatum < ApplicationRecord

  class << self
    def get_table()

      url = Rails.application.credentials.noc[:url]
      id  = Rails.application.credentials.noc[:id]
      pw  = Rails.application.credentials.noc[:pw]

    end
  end
end
