class AddCommitteeToPlayers < ActiveRecord::Migration
  def change
  	add_column :players, :committee, :integer
  end
end
