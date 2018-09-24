require 'test_helper'

class AvailableRoomsControllerTest < ActionDispatch::IntegrationTest
    url = '/api/v1/get_available_rooms'

    test 'should get missing params - 400' do
        post url
        assert_response 400
    end
    test 'should get missing params - 400 - part of the params' do
        post url, params: { 'location_id': 1, 'start_date': '2019-01-01' }
        assert_response 400
    end
    test 'should get missing params - 400 - Illegal Date' do
        post url, params: { 'location_id': 1, 'start_date': '2019-01-01', 'end_date': '2019-01-xx' }
        assert_response 400
    end
    test 'should get OK response - 200 - all rooms available' do
        insert_locations
        insert_available_rooms
        post url, params: { 'location_id': Location.first.id, 'start_date': '2019-01-01', 'end_date': '2019-01-03' }
        assert JSON.parse(JSON.parse(response.body)['data']).size == 3
        assert_response 200
    end
    test 'should get OK response - 200 - only part of the rooms are available' do
        insert_locations
        insert_available_rooms
        first_location_id = Location.first.id
        available_rooms = AvailableRoom.where(location_id: first_location_id, room_type: 2).pluck(:room_id)
        
        # reserve all the rooms for this night
        available_rooms.each do |room_id|
            ReservedRoom.new(room_id: room_id, location_id: first_location_id, 
                            order_id: 1, room_type: 2, date: '2019-01-01').save!
        end

        post url, params: { 'location_id': Location.first.id, 'start_date': '2019-01-01', 'end_date': '2019-01-02' }
        parsed_response = JSON.parse(JSON.parse(response.body)['data'])
        assert parsed_response.size == 2
        assert parsed_response.first['name'] == 'Dorm'
        assert parsed_response.last['name'] == 'Private'
        assert_response 200
    end

end