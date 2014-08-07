'''
This is a test file
creates a game
simulates game-time stuff
global view of game
'''
task :create_players => :environment do
	p 'removing all old players'
	Player.destroy_all
	p Player.all.length
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
algorithm described in readme
'''
def create_ring(players, blacklist_size = 3)
	committees = players.uniq.pluck(:committee)
	num_players = players.length
	blacklist = Queue.new
	assigned = Array.new
	while assigned.length < num_players
		assigned_ids = assigned.map{|x| x.id}
		committee = committees.sample
		committees.delete(committee)
		if not committee
			print 'no committee, recycling blacklist...'
			while blacklist.length>0
				committees<<blacklist.pop
			end
		else
			player_query = players.where(committee: committee).where.not(id: assigned_ids)
			if player_query.length > 0
				player = player_query.sample
				p '     '+'say hello to '+player.name+' '+player.committee.to_s
				p '     '+committee.to_s
				p '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
				assigned << player
				# successfully assigned with this committee, place into blacklist
				blacklist << committee
				# if too full, recycle back a committee
				if blacklist.length > blacklist_size
					committees << blacklist.pop
				end
			else
				p committee.to_s+' is empty!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
			end
		end
	end
	return assigned
end



task :create_ring => :environment do
	p 'creating ring...'
	assigned = create_ring(Player.all)
	p 'this is the full assignments'
	assigned.each do |p|
		p p.name+' '+p.committee.to_s
	end
end


def convert_ring_to_assignments(ring)
	p 'converting ring...'
end
task :create_assignments => :environment do
	p 'creating assignments...'
end