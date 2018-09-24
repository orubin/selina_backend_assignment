class Api::V1::BookingsController < ApplicationController
    before_action :set_params

    def book_now
        render json: { status: "error", data: {'message':'Wrong Params'} }, status: 400 and return unless check_params
        
        # get total rooms in the property that match the request
        # can be cached in redis also
        total_rooms = AvailableRoom.where(location_id: @location_id, room_type: @room_type)

        bm = BookingManager.new(@start_date, @end_date, @room_type, @guests_amount, @location_id)
        
        # differentiate between dorm and private rooms request
        result = bm.book_dorm(total_rooms) if AvailableRoom::Type::DORM == @room_type
        result = bm.book_private(total_rooms) if AvailableRoom::Type::PRIVATE_ROOM == @room_type || AvailableRoom::Type::DELUXE_ROOM == @room_type

        if result
            render json: { status: "ok" , data: {'message':'Booking done'} }
        else
            render json: { status: "ok" , data: {'message':'Room no longer available'} }, status: 200
        end
    end

    private

    def check_params
        return false unless @location_id || @room_type || @guests_amount || @start_date || @end_date
        return false unless @room_type == AvailableRoom::Type::PRIVATE_ROOM || 
                            @room_type == AvailableRoom::Type::DELUXE_ROOM ||
                            @room_type == AvailableRoom::Type::DORM
        return false unless @guests_amount > 0
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
        @room_type = params[:room_type].to_i
        @guests_amount = params[:guests_amount].to_i
        @start_date = params[:start_date]
        @end_date = params[:end_date]
    end

end