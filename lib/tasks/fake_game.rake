'''
This is a test file
creates a game
simulates game-time stuff
global view of game
'''
task :create_game => :environment do
	Game.where(name: 'test_game').destroy_all
	game = Game.new
	game.name = 'test_game'
	game.save()
end
task :create_players => :environment do
	game = Game.where(name:'test_game').first
	p game.name+' is the game i will create players for homie'
	p 'here are the players in this game'
	p game.players
	p 'removing all old players'
	Player.destroy_all
	#
	# test is 15 players across 5 committees
	#
	player_names = ['santa', 'tj', 'max', 'target', 'mervyn', 'macy', 'jc', 'penny', 'marcus', 'tyrone', 'sylvestor', 'tweety','john', 'joanne', 'lin', 'jane']
	committees = [2, 2,2,3,4,5,2,2,3,4,2,1,2,3,4,5]
	index = 0
	for player_name in player_names
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
		player.code = kill_code
		player.committee = committees[index]
		player.save
		p player.name
		index = index + 1 
	end
end

task :import_players => :environment do
	game = Game.where(name:'test_game').first_or_create
	p game.name+' is the game i will create players for homie'
	p 'here are the players in this game'
	p game.players
	p 'removing all old players'
	Player.destroy_all

	existing_names = []
	index = 0
	require 'yaml'
	player_list = Array.new
	File.open('member_dump_current.yaml', "r") do |file|
	  player_list = YAML::load(file)
	end
	for pl in player_list
		player_name = pl['name']
		# old_member_index = index
		old_member_index = pl['uid']
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
end	
task :global_view => :environment do
	game = Game.where(name:'test_game').first
	# game.players.each do |player|
	# 	p player.name
	# 	p player.committee 
	# 	p player.status
	# end
	p game.get_player_names
	p game.assignments.pluck(:player_id)
end

task :make_name => :environment do
	names = []
	for i in (0..89)
		name = Game.generate_name(names)
		names << name
		p name
	end
end

task :create_ring => :environment do
	game = Game.where(name:'test_game').first
	p 'creating ring...'
	assigned = game.create_ring
	p 'this is the full assignments'
	assigned.each do |p|
		p p.name+' '+p.committee.to_s
	end
end



task :create_assignments => :environment do
	game = Game.where(name:'test_game').first
	p 'destroying old assignments'
	game.assignments.destroy_all
	p 'creating assignments...'
	ring = game.create_ring
	game.create_assignments_from_ring(ring)
end