require 'test_helper'

class LocationsControllerTest < ActionDispatch::IntegrationTest

    get_locations_url = '/api/v1/locations/get_locations'
    get_top_locations_url = '/api/v1/locations/get_top_locations'

    def save_location(name, country)
        location = Location.new(name: name, country: country, latitude: 32.000, longitude: 34.000)
        location.save!
    end

    test "should get locations success" do
        get get_locations_url
        assert_response :success
    end
    test "should get locations empty data right" do
        get get_locations_url
        assert JSON.parse(response.body)['data'] == []
    end
    test "should get locations data right" do
        save_location('Test', 'Test')
        get get_locations_url
        assert JSON.parse(response.body)['data'].size == 1
        assert JSON.parse(response.body)['data'].first['name'] == 'Test'
    end
    test "should get two locations data right" do
        save_location('Test', 'Test')
        save_location('Test2', 'Test2')
        get get_locations_url
        assert JSON.parse(response.body)['data'].size == 2
        assert JSON.parse(response.body)['data'].first['name'] == 'Test'
        assert JSON.parse(response.body)['data'].last['name'] == 'Test2'
    end
    test 'get top locations is empty when no orders' do
        insert_locations
        get get_top_locations_url
        assert_response :success
        assert JSON.parse(response.body)['data'] == []
    end
    test 'get top locations for one location' do
        insert_locations
        first_location_id = Location.first.id
        Order.new(location_id: first_location_id, room_type: 1, 
                    guests_amount: 2, booking_start: '2019-01-01', 
                    booking_end: '2019-01-09', user_id: 5).save!
        get get_top_locations_url
        assert_response :success
        assert JSON.parse(response.body)['data'].size == 1
    end
    test 'get top locations for two locations' do
        insert_locations
        Order.new(location_id: Location.first.id, room_type: 1, 
                    guests_amount: 2, booking_start: '2019-01-01', 
                    booking_end: '2019-01-09', user_id: 5).save!
        Order.new(location_id: Location.last.id, room_type: 1, 
                    guests_amount: 2, booking_start: '2019-01-01', 
                    booking_end: '2019-01-09', user_id: 5).save!
        get get_top_locations_url
        assert_response :success
        assert JSON.parse(response.body)['data'].size == 2
    end
    test 'get top locations for two locations - last one has the most' do
        insert_locations
        last_location_id = Location.last.id
        Order.new(location_id: Location.first.id, room_type: 1, 
                    guests_amount: 2, booking_start: '2019-01-01', 
                    booking_end: '2019-01-09', user_id: 5).save!
        Order.new(location_id: last_location_id, room_type: 1, 
                    guests_amount: 2, booking_start: '2019-01-01', 
                    booking_end: '2019-01-09', user_id: 5).save!
        Order.new(location_id: last_location_id, room_type: 1, 
                    guests_amount: 2, booking_start: '2019-01-01', 
                    booking_end: '2019-01-02', user_id: 7).save!
        get get_top_locations_url
        assert_response :success
        assert JSON.parse(response.body)['data'].size == 2
        assert JSON.parse(response.body)['data'].last == last_location_id
    end
    test 'get locations - order by country name' do
        insert_locations
        get get_locations_url, params: { 'order_by_country': true }
        assert_response :success
        assert JSON.parse(response.body)['data'].size == Location.all.size
        JSON.parse(response.body)['data'].first['country'] == Location.all.map(&:country).sort.first
    end
    
end