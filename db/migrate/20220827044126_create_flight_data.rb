class CreateFlightData < ActiveRecord::Migration[6.0]
  def change
    create_table :flight_data do |t|

      t.integer :flight_data_id
      t.string  :date
      t.string  :callsign
      t.string  :registration
      t.string  :departure
      t.time    :scheduled_time_of_departure
      t.string  :departure_spot
      t.string  :arrival
      t.time    :scheduled_time_of_arrival
      t.string  :arrival_spot
      t.time    :block_time
      t.integer :booked_adults
      t.integer :booked_children
      t.integer :booked_infants
      t.string  :crew_configuration
      t.time    :block_out
      t.time    :take_off
      t.time    :estimated_time_of_arrival
      t.time    :landing
      t.time    :block_in
      t.string  :pilot_in_command

      t.timestamps
    end
  end
end
