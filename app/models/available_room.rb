class AvailableRoom < ActiveRecord::Base
    
    belongs_to :location

    module Type
        DORM = 0
        PRIVATE_ROOM = 1
        DELUXE_ROOM = 2
    end

    def display
        { 'name': name, 'price': price_per_night }
    end

end