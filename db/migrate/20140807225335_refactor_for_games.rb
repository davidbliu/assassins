class RefactorForGames < ActiveRecord::Migration
  def change
  	add_column :players, :game_id, :integer

  	add_column :kills, :game_id, :integer
  	add_column :assignments, :game_id, :integer
  end
end
