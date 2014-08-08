class Assignment < ActiveRecord::Base
	
	def get_player
		game = Game.find(self.game_id)
		return game.players.find(self.player_id)
	end
	
	def get_player_2
		game = Game.find(self.game_id)
		return game.players.find(self.player_2_id)
	end
end
