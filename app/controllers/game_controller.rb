class GameController < ApplicationController
	def index
		@game = Game.where(name: 'test_game').first

		@kills = @game.assignments.where(status: 'complete')
		@fails = @game.assignments.where(status: 'failed')
		@ongoing = @game.assignments.where(status: 'incomplete')
	end	

	def complete_assignment
		@game = Game.where(name: 'test_game').first

		assignment_id = params[:assignment_id].to_s
		p 'this is assignment id'
		p assignment_id

		@game.register_kill(assignment_id)
		render :nothing => true, :status => 200, :content_type => 'text/html'
		# redirect_to root_url
	end
end
