class AddInitialData < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.integer  :location_id, null: false
      t.integer  :room_type
      t.integer  :guests_amount, null: false
      t.integer  :user_id, null: false
      t.string   :status
      t.datetime :booking_start
      t.datetime :booking_end
      t.jsonb    :special_requests, null: false, default: '{}'

      t.timestamps null: false
    end

    execute 'create index user_id_idx on orders (user_id);'

    create_table :locations do |t|
      t.string   :name, null: false
      t.string   :country, null: false
      t.float    :latitude, null: false
      t.float    :longitude, null: false

      t.timestamps null: false
    end

    create_table :available_rooms do |t|
      t.integer  :location_id, null: false
      t.string   :name, null: false
      t.integer  :room_type, null: false
      t.integer  :room_id, null: false
      t.integer  :guests_amount, null: false
      t.float    :price_per_night, null: false
      t.boolean  :occupied, null: false, default: false

      t.timestamps null: false
    end

    add_index :available_rooms, [:location_id, :room_type]

    create_table :reserved_rooms do |t|
      t.integer  :location_id, null: false
      t.integer  :order_id, null: false
      t.integer  :room_id, null: false
      t.integer  :room_type, null: false
      t.datetime :date, null: false
      t.integer  :guests_amount, default: 0

      t.timestamps null: false
    end

    add_index :reserved_rooms, [:location_id, :room_id, :date], unique: true

    create_table :reserved_dorm_rooms do |t|
      t.integer  :order_id, null: false
      t.integer  :reserved_room_id, null: false
      
      t.timestamps null: false
    end

    add_index :reserved_dorm_rooms, [:order_id]
  end
end
