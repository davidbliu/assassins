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
		game = Game.where(name: 'test_game').first

		#
		# import players
		#
		p game.name+' is the game i will create players for homie'
		p 'here are the players in this game'
		p game.players
		p 'removing all old players'
		Player.destroy_all

		existing_names = []
		index = 0
		require 'yaml'
		player_list = Array.new
		File.open('member_dump.yaml', "r") do |file|
		  player_list = YAML::load(file)
		end
		for pl in player_list
			player_name = pl['name']
			old_member_index = index
			name = player_name
			status = 'alive'
			kill_code = index.to_s
			#
			# save player in db
			#
			# player = Player.new
			player = game.players.new
			player.member_id = old_member_index
			player.name = name
			player.status = status
			player.code = Game.generate_name(existing_names)
			player.committee = pl['committee']
			player.save
			p player.name
			# index = index + 1 
			existing_names << player.code
		end
		#
		# create assignments
		#
		p 'destroying old assignments'
		game.assignments.destroy_all
		p 'creating assignments...'
		ring = game.create_ring
		game.create_assignments_from_ring(ring)

		result = 'created your game'
		render json: result
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
