class BookingManager

    def initialize(start_date, end_date, room_type, guests_amount, location_id)
        @start_date = start_date
        @end_date = end_date
        @room_type = room_type
        @guests_amount = guests_amount
        @location_id = location_id
    end

    def book_dorm(total_rooms)
        room_capacity = {}
        total_rooms.each {|room| room_capacity[room.room_id] = room.guests_amount}
        
        # when someone tries to book a dorm room - we check if there is enough space in one of the rooms
        return false unless AvailabilityHelper.search_for_vacant_dorm_rooms(@location_id, @start_date, @end_date)


        # create an order
        order = Order.new(room_type: @room_type, guests_amount: @guests_amount, 
                          location_id: @location_id, booking_start: @start_date, booking_end: @end_date, user_id: 5)
        order.save!
        
        reservation_needed = true
        # resreve one of the dorm rooms for each night
        (Date.parse(@start_date)..Date.parse(@end_date)-1).each do |date|
            room_capacity.each do |room_id, value|
                break unless reservation_needed
                room = ReservedRoom.where(location_id: @location_id, 
                                            room_id: room_id, 
                                            date: date,
                                            order_id: 0,
                                            room_type: AvailableRoom::Type::DORM).first_or_create!
                # can also be done with ReservedRoom.transaction (all saves in one transaction)
                # and another way to go is to add a callback inside ReservedRoom that will check the
                # guests_amount when a ReservedRoom is updated - we can raise ActiveRecord::RecordInvalid.new(self)
                # if we find a dorm room being saved with more people that it can hold
                room.with_lock do
                    if room.guests_amount < value
                        room.guests_amount += 1
                        room.save!
                        ReservedDormRoom.new(order_id: order.id, reserved_room_id: room.id).save!
                        reservation_needed = false
                        break
                    end
                end
            end
            reservation_needed = true
        end

        true
    end

    def book_private(total_rooms)
        # total_rooms will contain [10, 11] for rooms with room_id 10 and 11 in the property
        total_rooms = total_rooms.pluck(:room_id)
        
        # check that the rooms are still available in the requested dates
        # we search for all reservations for this kind of room type and get their room_ids
        reservations = ReservedRoom.where(location_id: @location_id, date: @start_date..@end_date, room_type: @room_type).pluck(:room_id)

        # check that at least one of the rooms is available
        # subtract the reservations array from the total_rooms array - and we will be left with available room_ids
        # because if the room has a reservation in one of the days of the dates range - it cannot be booked
        available_room_ids = total_rooms - reservations

        # if there are no rooms available - return 'error' to the client
        return false if available_room_ids.empty?
        
        # create an order
        order = Order.new(room_type: @room_type, guests_amount: @guests_amount, 
                        location_id: @location_id, booking_start: @start_date, booking_end: @end_date, user_id: 5)
        order.save!
        
        reservation_complete = false
        while !reservation_complete && !available_room_ids.empty? do
            # randomly picks a room_id from the list - reduces collisions / race conditions
            room_id = available_room_ids.delete(available_room_ids.sample)

            reservation_complete = order.reserve_room(room_id, @start_date, @end_date)       
        end

        reservation_complete  
    end


end