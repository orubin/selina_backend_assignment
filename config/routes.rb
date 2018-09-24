Rails.application.routes.draw do
  namespace :api, constraints: { format: :json } do
    namespace :v1 do

      get 'locations/get_location', to: 'locations#get_location'
      get 'locations/get_locations', to: 'locations#get_locations'

      post 'get_available_rooms', to: 'available_rooms#get_available_rooms'

      get 'locations/get_top_locations', to: 'locations#get_top_locations'

      post 'bookings/book_now', to: 'bookings#book_now'

    end
  end
end
