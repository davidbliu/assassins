class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :player_id
  	  t.integer :player_2_id
  	  t.time :time_started
  	  t.time :time_completed
  	  t.string :status
      t.timestamps
    end
  end
end
