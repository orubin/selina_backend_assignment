ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def insert_locations
    locations = [{'name':'Antigua', 'country':'Guatemala', 'latitude': 14.5591851, 'longitude': -90.7513298},
    {'name':'Bocas Del Toro', 'country':'Panama', 'latitude': 14.5591851, 'longitude': -90.7513298},
    {'name':'Cancun', 'country':'Mexico', 'latitude': 14.5591851, 'longitude': -90.7513298},
    {'name':'Cartagena', 'country':'Colombia', 'latitude': 14.5591851, 'longitude': -90.7513298},
    {'name':'Granada', 'country':'Nicaragua', 'latitude': 14.5591851, 'longitude': -90.7513298}]

    locations.each do |loc|
        location = Location.new
        location.name = loc[:name]
        location.country = loc[:country]
        location.latitude = loc[:latitude]
        location.longitude = loc[:longitude]
        location.save!
    end
  end

  def insert_available_rooms
    rooms = [{'name':'Dorm', 'room_type': 0, 'guests_amount': 8, 'price_per_night': 10},
    {'name':'Dorm', 'room_type': 0, 'guests_amount': 8, 'price_per_night': 10},
    {'name':'Private', 'room_type': 1, 'guests_amount': 2, 'price_per_night': 20},
    {'name':'Private', 'room_type': 1, 'guests_amount': 2, 'price_per_night': 20},
    {'name':'Private', 'room_type': 1, 'guests_amount': 2, 'price_per_night': 20},
    {'name':'Deluxe', 'room_type': 2, 'guests_amount': 2, 'price_per_night': 30},
    {'name':'Deluxe', 'room_type': 2, 'guests_amount': 2, 'price_per_night': 30},
    {'name':'Deluxe', 'room_type': 2, 'guests_amount': 2, 'price_per_night': 30}]

    Location.all.each do |loc|
      rooms.each_with_index do |ro,index|
          room = AvailableRoom.new
          room.location_id = loc.id
          room.name = ro[:name]
          room.room_id = (loc.id.to_s + index.to_s).to_i
          room.room_type = ro[:room_type]
          room.guests_amount = ro[:guests_amount]
          room.price_per_night = ro[:price_per_night]
          room.save!
      end
    end
  end

end
