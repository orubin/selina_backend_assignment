require 'test_helper'

class BookingsControllerTest < ActionDispatch::IntegrationTest

    url = '/api/v1/bookings/book_now'
    no_longer_available = 'Room no longer available'
    booking_done = 'Booking done'

    test 'should get missing params - 400' do
        post url
        assert_response 400
    end
    test 'should get missing params - 400 - part of the params are missing 1' do
        post url, params: { 'location_id': 1, 'room_type': 1 }
        assert_response 400
    end
    test 'should get missing params - 400 - part of the params are missing 2' do
        post url, params: { 'location_id': 1, 'room_type': 1, 'guests_amount': 2 }
        assert_response 400
    end
    test 'should get missing params - 400 - part of the params are missing 3' do
        post url, params: { 'location_id': 1, 'room_type': 1, 'guests_amount': 2, 'start_date': '2019-01-01' }
        assert_response 400
    end
    test 'should get 200 - but no rooms are available' do
        post url, params: { 'location_id': 1, 'room_type': 1, 'guests_amount': 2, 'start_date': '2019-01-01', 'end_date': '2019-01-02' }
        assert_response :success
        assert JSON.parse(response.body)['data']['message'] == no_longer_available
    end
    test 'should get 200 - booking done' do
        insert_locations
        insert_available_rooms
        first_location_id = Location.first.id
        post url, params: { 'location_id': first_location_id, 'room_type': 1, 'guests_amount': 2, 'start_date': '2019-01-01', 'end_date': '2019-01-02' }
        assert_response :success
        assert ReservedRoom.count == 1
        assert JSON.parse(response.body)['data']['message'] == booking_done
    end
    test 'should get 200 - No available rooms' do
        insert_locations
        insert_available_rooms
        first_location_id = Location.first.id
        available_rooms = AvailableRoom.where(location_id: first_location_id, room_type: 2).pluck(:room_id)
        
        # reserve all the rooms for this night
        available_rooms.each do |room_id|
            ReservedRoom.new(room_id: room_id, location_id: first_location_id, 
                            order_id: 1, room_type: 2, date: '2019-01-01').save!
        end

        post url, params: { 'location_id': first_location_id, 'room_type': 2, 'guests_amount': 2, 'start_date': '2019-01-01', 'end_date': '2019-01-02' }
        assert_response :success
        assert ReservedRoom.count == 3
        assert JSON.parse(response.body)['data']['message'] == no_longer_available
    end
    test 'should get 200 - Last room booking done' do
        insert_locations
        insert_available_rooms
        first_location_id = Location.first.id
        available_rooms = AvailableRoom.where(location_id: first_location_id, room_type: 2).pluck(:room_id)
        
        # save a last room
        available_rooms.pop
        # reserve all the rooms for this night
        available_rooms.each do |room_id|
            ReservedRoom.new(room_id: room_id, location_id: first_location_id, 
                            order_id: 1, room_type: 2, date: '2019-01-01').save!
        end

        post url, params: { 'location_id': first_location_id, 'room_type': 2, 'guests_amount': 2, 'start_date': '2019-01-01', 'end_date': '2019-01-02' }
        assert_response :success
        assert ReservedRoom.count == 3
        assert JSON.parse(response.body)['data']['message'] == booking_done
    end
   
end