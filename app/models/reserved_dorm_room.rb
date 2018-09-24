class ReservedDormRoom < ActiveRecord::Base

    belongs_to :reserved_room
    belongs_to :order

end