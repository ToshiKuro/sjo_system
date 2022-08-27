class CreateFlightData < ActiveRecord::Migration[6.0]
  def change
    create_table :flight_data do |t|

      t.timestamps
    end
  end
end
