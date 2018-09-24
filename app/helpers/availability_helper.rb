module AvailabilityHelper
    # returns the room_ids that are available in the time period and the location and room_type
    def self.search_for_vacant_rooms(location_id, room_type, start_date, end_date)
        # total_rooms will contain [10, 11] for rooms with room_id 10 and 11 in the property
        total_rooms = AvailableRoom.where(location_id: location_id, room_type: room_type).pluck(:room_id)

        # search for all reservations for this kind of room type and get their room_ids
        reservations = ReservedRoom.where(date: start_date..end_date, room_type: room_type).pluck(:room_id)

        # check that at least one of the rooms is available
        # subtract the reservations array from the total_rooms array - and we will be left with available room_ids
        # because if the room has a reservation in one of the days of the dates range - it cannot be booked
        available_room_ids = total_rooms - reservations
        available_room_ids
    end

    def self.search_for_vacant_dorm_rooms(location_id, start_date, end_date)
        total_dorm_rooms = AvailableRoom.where(location_id: location_id, room_type: AvailableRoom::Type::DORM)
        reservations = ReservedRoom.where(date: start_date..end_date, room_type: AvailableRoom::Type::DORM)

        total_quantity_per_night = total_dorm_rooms.size * total_dorm_rooms.first.guests_amount
        
        dates = {}
        
        (Date.parse(start_date)..Date.parse(end_date)-1).each do |date|
            dates[date.strftime("%Y-%m-%d")] = 0
        end
        
        # count how many guests are staying every night in all of the dorm rooms
        reservations.each do |res|
            if dates.key?(res.date.strftime("%Y-%m-%d"))
                dates[res.date.strftime("%Y-%m-%d")] += res.guests_amount
            end
        end

        # go over the people staying every night - see if there is room for one more
        dates.each do |key,value|
            return false if value == total_quantity_per_night
        end

        true
    end
end