class CreateFlightData < ActiveRecord::Migration[6.0]
  def change
    create_table :flight_data do |t|

      t.integer :flight_datum_id
      t.string  :date
      t.string  :callsign
      t.string  :domestic
      t.string  :registration
      t.string  :departure
      t.string  :arrival
      t.string  :departure_spot
      t.string  :arrival_spot
      t.string  :scheduled_time_of_departure
      t.string  :scheduled_time_of_arrival
      t.string  :block_time
      t.integer :booked_adults
      t.integer :booked_children
      t.integer :booked_infants
      t.string  :crew_configuration
      t.string  :block_out
      t.string  :take_off
      t.string  :estimated_time_of_arrival
      t.string  :landing
      t.string  :block_in
      t.string  :pilot_in_command

      t.timestamps
    end
  end
end
