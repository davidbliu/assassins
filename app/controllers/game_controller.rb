class GameController < ApplicationController
	def index
		@game = Game.where(name: 'test_game').first
	end	
end
