class Location < ActiveRecord::Base

    has_many :available_rooms
    has_many :orders

    def self.get_top_locations
        # Get top 3 location that has most orders
        # this can be done in more than one way of course:
        # 1. straightforward query
        # 2. create resque / sidekiq task that will run every minute (maybe less/more) and will run this query
        #    and will save the results in cache or in a special new db table
        # 3. add cache right on top of this query
        # 4. create a new table / new column that will hold the orders count - every new order - increase it
        #    maybe will be better when dealing with million of rows
        # 5. run this query / logic on a different db than production db - somekind of replica

        # will produce an array of location_ids - the last one is with the most orders
        Order.group(:location_id).count.sort_by {|_key, value| value}.last(3).map {|v| v[0]}
    end

end