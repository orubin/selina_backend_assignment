require 'test_helper'

class OrderTest < ActiveSupport::TestCase
    test 'should not save order without location_id' do
        order = Order.new
        begin
            order.save
        rescue
        end
        assert Order.count == 0
    end
    test 'check that exception is thrown' do
        order = Order.new
        begin
            order.save
        rescue => e
            assert e.class == ActiveRecord::NotNullViolation
        end
    end
    test 'check that order.reserve_room works' do
        start_date = '2019-01-01'
        end_date = '2019-01-09'
        order = Order.new(location_id: 1, room_type: 1, 
                            guests_amount: 2, booking_start: '2019-01-01', 
                            booking_end: '2019-01-09', user_id: 5)
        order.save
        assert order.reserve_room(11, start_date, end_date)
        assert ReservedRoom.count == 8
    end
    test 'check that order.reserve_room does not double book rooms' do
        start_date = '2019-01-01'
        end_date = '2019-01-09'
        order = Order.new(location_id: 1, room_type: 1, 
                            guests_amount: 2, booking_start: '2019-01-01', 
                            booking_end: '2019-01-09', user_id: 5)
        order.save
        assert order.reserve_room(11, start_date, end_date)
        assert_not order.reserve_room(11, start_date, end_date)
        assert ReservedRoom.count == 8
    end
    test 'check that order.reserve_room does not double book rooms for different orders' do
        start_date1 = '2019-01-01'
        end_date1 = '2019-01-09'
        start_date2 = '2019-01-03'
        end_date2 = '2019-01-06'
        order1 = Order.new(location_id: 1, room_type: 1, 
                            guests_amount: 2, booking_start: start_date1, 
                            booking_end: end_date2, user_id: 5)
        order2 = Order.new(location_id: 1, room_type: 1, 
                            guests_amount: 2, booking_start: start_date2, 
                            booking_end: end_date2, user_id: 7)
        order1.save
        order2.save
        assert order1.reserve_room(11, start_date1, end_date1)
        assert_not order2.reserve_room(11, start_date2, end_date2)
        assert ReservedRoom.count == 8
    end
    test 'check that order.reserve_room does book rooms for different orders with different room_ids' do
        start_date1 = '2019-01-01'
        end_date1 = '2019-01-09'
        start_date2 = '2019-01-03'
        end_date2 = '2019-01-06'
        order1 = Order.new(location_id: 1, room_type: 1, 
                            guests_amount: 2, booking_start: start_date1, 
                            booking_end: end_date2, user_id: 5)
        order2 = Order.new(location_id: 1, room_type: 1, 
                            guests_amount: 2, booking_start: start_date2, 
                            booking_end: end_date2, user_id: 7)
        order1.save
        order2.save
        assert order1.reserve_room(11, start_date1, end_date1)
        assert order2.reserve_room(12, start_date2, end_date2)
        assert ReservedRoom.count == 11
    end
end