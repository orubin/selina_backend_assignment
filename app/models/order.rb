class Order < ActiveRecord::Base

    module Status
        CONFIRMED = 1
        CANCELLED = 2
        COMPLETED = 3
    end

    belongs_to :location
    has_many :reserved_rooms

    def reserve_room(room_id, start_date, end_date)
        reserved_dates = []
        
        # try and reserve the room for the dates
        (Date.parse(start_date)..Date.parse(end_date)-1).each do |date|
            
            reserved_room = ReservedRoom.new
            reserved_room.order_id = id
            reserved_room.location_id = location_id
            reserved_room.room_id = room_id
            reserved_room.room_type = room_type
            reserved_room.date = date
            reserved_dates << reserved_room

        end

        begin
            ReservedRoom.transaction do
                reserved_dates.each do |reserved_room|
                    reserved_room.save!
                end
            end
            return true
        rescue
            return false
        end
        false
    end
end