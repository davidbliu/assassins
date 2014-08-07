'''
This is a test file
creates a game
simulates game-time stuff
global view of game
'''
task :make_players => :environment do
	p 'removing all old players'
	Player.destroy_all
	p Player.all.length
	#
	# test is 15 players across 5 committees
	#
	player_names = ['tj', 'max', 'target', 'mervyn', 'macy', 'jc', 'penny', 'marcus', 'tyrone', 'sylvestor', 'tweety','john', 'joanne', 'lin', 'jane']
	committees = [1,2,3,4,5,1,2,3,4,5,1,2,3,4,5]
	index = 0
	for player_name in player_names
		old_member_index = index
		name = player_name
		status = 'alive'
		kill_code = index.to_s

		#
		# save player in db
		#
		player = Player.new
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

task :global_view => :environment do
	Player.all.each do |player|
		p player.name
		p player.committee 
		p player.status
	end
end

'''
assign players into a ring by committees
1,2,3,4,5,1,2,3,4,5,1,2,3,4,5,1,2,3,4,5 like that?
no because 1s are always after 2s
1, diff, diff, diff, diff, diff, diff
procedure: have array of all committees, sample from it repeatedly to place?
then between samples could fuck
'''
task :create_assignments => :environment do
	#
	#
	#
end