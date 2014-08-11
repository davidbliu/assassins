class GameController < ApplicationController
	def index
		@game = Game.where(name: 'test_game').first

		@kills = @game.assignments.where(status: 'complete')
		@fails = @game.assignments.where(status: 'failed')
		@ongoing = @game.assignments.where(status: 'incomplete')
	end	

	def confirm_kill
		@game = Game.where(name: 'test_game').first

		assignment_id = params[:assignment_id]
		kill_code = params[:kill_code]

		if @game.is_correct_code(assignment_id, kill_code)
			redirect_to(:controller => 'game', :action => 'complete_assignment', :assignment_id => assignment_id)
		else
			render :nothing => true, :status => 500, :content_type => 'text/html'
		end 
	end

	def create_game


	end

	def complete_assignment
		@game = Game.where(name: 'test_game').first

		assignment_id = params[:assignment_id].to_s
		@game.register_kill(assignment_id)
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def view_assignment
		@game = Game.where(name: 'test_game').first

		player_id = params[:player_id].to_s
		@player = @game.players.find(player_id)
		@current_assignments = @game.assignments.where(player_id: player_id).where(status: 'incomplete')
		@ongoing_assignments = @current_assignments.pluck(:player_2_id)
		@kills = @game.assignments.where(player_id: player_id).where(status: 'complete').pluck(:player_2_id)
		@killed_me = @game.assignments.where(player_2_id: player_id).where(status: 'complete').pluck(:player_id)
		if @current_assignments.length > 0
			@current_assignment = @current_assignments.first
		else
			@current_assignment = nil
		end
		@ongoing_names = @game.players.where('id IN (?)', @ongoing_assignments).pluck(:name)
		@killed_names = @game.players.where('id IN (?)', @kills).pluck(:name)
		@killer_names = @game.players.where('id IN (?)', @killed_me).pluck(:name)
	end

end
