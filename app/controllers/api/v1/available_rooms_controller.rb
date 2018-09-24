class Api::V1::AvailableRoomsController < ApplicationController
    before_action :set_params

    def get_available_rooms
        render json: { status: "error", data: {'message':'Wrong Params'} }, status: 400 and return unless check_params
        # cache for total rooms count in every location
        total_rooms = Rails.cache.fetch("total_rooms_location_id_#{@location_id}", expires_in: 3600.seconds) do
            AvailableRoom.where(location_id: @location_id)
        end

        rooms_count = {'private': 0, 'dorm': 0, 'deluxe': 0}

        available_room_ids = AvailabilityHelper.search_for_vacant_rooms(@location_id, [1,2], @start_date, @end_date)
        
        dorms_available = AvailabilityHelper.search_for_vacant_dorm_rooms(@location_id, @start_date, @end_date)
        
        # run over all of the rooms - count how many are available
        total_rooms.each do |room| 
            rooms_count[room.name.downcase.to_sym] +=1 if available_room_ids.include? room.room_id
        end

        rooms_count[:dorm] = dorms_available ? 1 : 0
        result = []
        # rooms_count will now contain the number of rooms available - if zero - we will not return it
        total_rooms.uniq{|ar| ar.name}.each do |room|
            result << room.display if rooms_count[room.name.downcase.to_sym] > 0
        end

        render json: { status: "ok" , data: result.to_json }
    end

    private

    def check_params
        return false unless @location_id || @start_date || @end_date
        begin
            Date.parse(@start_date)
            Date.parse(@end_date)
        rescue
            return false
        end
        true
    end

    def set_params
        @location_id = params[:location_id].to_i
        @start_date = params[:start_date]
        @end_date = params[:end_date]
    end

end