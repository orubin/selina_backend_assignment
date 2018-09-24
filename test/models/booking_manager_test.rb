require 'test_helper'

class BookingManagerTest < ActiveSupport::TestCase

    test 'check that book dorm works - 2 nights reservation' do
        insert_locations
        insert_available_rooms
        first_location_id = Location.first.id
        total_rooms = AvailableRoom.where(location_id: first_location_id, room_type: 0)
        bm = BookingManager.new('2019-01-01', '2019-01-03', 0, 1, first_location_id)
        assert bm.book_dorm(total_rooms)
        assert ReservedRoom.count == 2
        assert ReservedDormRoom.count == 2
        assert ReservedDormRoom.first.order_id == Order.first.id
        assert ReservedDormRoom.first.reserved_room_id == ReservedRoom.first.id
    end
    
    test 'check that book dorm works - 2 nights reservation with one more man already reserved' do
        insert_locations
        insert_available_rooms
        first_location_id = Location.first.id
        total_rooms = AvailableRoom.where(location_id: first_location_id, room_type: 0)
        bm = BookingManager.new('2019-01-01', '2019-01-04', 0, 1, first_location_id)
        assert bm.book_dorm(total_rooms)
    
        bm = BookingManager.new('2019-01-01', '2019-01-03', 0, 1, first_location_id)
        assert bm.book_dorm(total_rooms)
        
        assert ReservedRoom.count == 3
        assert Order.count == 2
        assert ReservedRoom.first.guests_amount == 2
        assert ReservedRoom.last.guests_amount == 1
        assert ReservedDormRoom.count == 5
    end

    test 'check that book private works' do
        insert_locations
        insert_available_rooms
        first_location_id = Location.first.id
        total_rooms = AvailableRoom.where(location_id: first_location_id, room_type: 1)
        bm = BookingManager.new('2019-01-01', '2019-01-04', 1, 1, first_location_id)
        assert bm.book_private(total_rooms)
        assert ReservedRoom.count == 3
        assert ReservedRoom.all.map(&:order_id).uniq.first == Order.first.id
    end

    test 'check that book private works for two different orders in different dates' do
        insert_locations
        insert_available_rooms
        first_location_id = Location.first.id
        total_rooms = AvailableRoom.where(location_id: first_location_id, room_type: 2)
        bm = BookingManager.new('2019-01-01', '2019-01-04', 2, 2, first_location_id)
        assert bm.book_private(total_rooms)
        bm = BookingManager.new('2019-01-02', '2019-01-03', 2, 2, first_location_id)
        assert bm.book_private(total_rooms)
        assert ReservedRoom.count == 4
        assert Order.count == 2
        assert Order.first.reserved_rooms.size == 3
        assert Location.first.orders.size == 2
    end

    test 'check that book private works for two different orders in the same dates' do
        insert_locations
        insert_available_rooms
        first_location_id = Location.first.id
        total_rooms = AvailableRoom.where(location_id: first_location_id, room_type: 2)
        bm = BookingManager.new('2019-01-01', '2019-01-04', 2, 2, first_location_id)
        assert bm.book_private(total_rooms)
        bm = BookingManager.new('2019-01-01', '2019-01-04', 2, 1, first_location_id)
        assert bm.book_private(total_rooms)
        assert ReservedRoom.count == 6
        assert Order.count == 2
        assert Order.first.reserved_rooms.size == 3
    end

    test 'check that booking does not work when all of the rooms are full - private' do
        insert_locations
        insert_available_rooms
        first_location_id = Location.first.id
        total_rooms = AvailableRoom.where(location_id: first_location_id, room_type: 2)
        
        3.times do
            bm = BookingManager.new('2019-01-01', '2019-01-04', 2, 2, first_location_id)
            assert bm.book_private(total_rooms)
        end

        bm = BookingManager.new('2019-01-01', '2019-01-04', 2, 2, first_location_id)
        assert_not bm.book_private(total_rooms)
    end

    test 'check that booking does not work when one of the rooms is full - dorm' do
        insert_locations
        insert_available_rooms
        first_location_id = Location.first.id
        total_rooms = AvailableRoom.where(location_id: first_location_id, room_type: 0)

        ReservedRoom.new(room_id: total_rooms.first.room_id, location_id: first_location_id, 
                        order_id: 1, room_type: 0, date: '2019-01-02', guests_amount: 8).save!
        ReservedRoom.new(room_id: total_rooms.last.room_id, location_id: first_location_id, 
                        order_id: 1, room_type: 0, date: '2019-01-02', guests_amount: 8).save!

        bm = BookingManager.new('2019-01-01', '2019-01-03', 0, 1, first_location_id)
        assert_not bm.book_dorm(total_rooms)
    end

    test 'check that booking dorm room succeeds when there is only one spot left in one of the nights' do
        insert_locations
        insert_available_rooms
        first_location_id = Location.first.id
        total_rooms = AvailableRoom.where(location_id: first_location_id, room_type: 0)

        ReservedRoom.new(room_id: total_rooms.first.room_id, location_id: first_location_id, 
                        order_id: 0, room_type: 0, date: '2019-01-02', guests_amount: 8).save!
        ReservedRoom.new(room_id: total_rooms.last.room_id, location_id: first_location_id, 
                        order_id: 0, room_type: 0, date: '2019-01-02', guests_amount: 7).save!

        bm = BookingManager.new('2019-01-01', '2019-01-03', 0, 1, first_location_id)
        assert bm.book_dorm(total_rooms)
    end

end