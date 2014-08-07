class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|

      t.string :name
      t.string :member_id
      t.string :status
      t.string :code # kill code
      t.timestamps
    end
  end
end
