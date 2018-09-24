class Api::V1::LocationsController < ApplicationController
    before_action :set_params

    def get_location
        available_rooms = AvailableRoom.where(location_id: @location_id)
        render json: { status: "ok", data: available_rooms.to_json }
    end

    def get_locations
        @locations = Rails.cache.fetch('locations', expires_in: 60.seconds) do
            Location.all
        end

        @locations = @locations.sort_by{|loc| loc[:country]} if @order_by_country

        @locations = @locations.select{|loc| loc[:country] == @filter_by_country} if @filter_by_country

        result = []

        if @locations
            @locations.each do |loc|
                result << loc.as_json
            end
        end

        render json: { status: "ok" , data: result }
    end

    def get_top_locations
        result = Location.get_top_locations

        render json: { status: "ok" , data: result }
    end

    private

    def set_params
        @location_id = params[:location_id].to_i
        @order_by_country = true if params[:order_by_country].to_s == "true"
        @filter_by_country = params[:filter_by_country]
    end
end