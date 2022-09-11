Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'managements#index'

  get  'get_flight_data'             => 'managements#get_flight_data'
  get  'forward_arrival_information' => 'managements#forward_arrival_information'
end
