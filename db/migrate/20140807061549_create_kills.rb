class CreateKills < ActiveRecord::Migration
  def change
    create_table :kills do |t|
      t.integer :player_id
      t.integer :plyer_2_id
      t.time :time_killed
      t.timestamps
    end
  end
end
