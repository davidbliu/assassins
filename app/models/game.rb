class Game < ActiveRecord::Base

	has_many :players, dependent: :destroy
	has_many :assignments, dependent: :destroy
	has_many :kills, dependent: :destroy


	def get_player_names
		return self.players.pluck(:name)
	end	

	def get_ongoing_assignments
		return self.assignments.where(status: 'incomplete')
	end

	def get_killed_assignments
		return self.assignments.where(status: 'complete')
	end

	# def get_dead_assignments
	# 	return self.assignments.where(status: 'failed')
	# end

	def get_leaderboard
		kills = self.assignments.where(status: 'complete')
		killer_ids = kills.pluck(:player_id)
		# return killer_ids
		leaderboard = Array.new
		killer_ids.uniq.each do |elem|
			leader = Hash.new
			leader["name"] = Player.find(elem).name
			leader["kills"] = killer_ids.count(elem).to_i
		 	leaderboard << leader
		end
		sorted_leaderboard = leaderboard.sort_by { |leader| leader["kills"] }
		return sorted_leaderboard.reverse
	end


	def get_assignments(player_id)
		return self.assignments.where(player_id: player_id)
	end

	def is_correct_code(assignment_id, kill_code)
		p_id = self.assignments.find(assignment_id).player_2_id
		player_2 = self.players.find(p_id)
		if player_2.code.to_s == kill_code.to_s
			return true
		end
		return false
	end

	def is_correct_reverse_code(assignment_id, kill_code)
		p_id = self.assignments.find(assignment_id).player_id
		player = self.players.find(p_id)
		if player.code.to_s == kill_code.to_s
			return true
		end
		return false
	end
	def do_storm
		p 'killing off players that arent active'
		kills = self.get_killed_assignments
		active_players = kills.pluck(:player_id).uniq
		p active_players
		# render json: 'storm done'
		# players_who_have_killed = 

	end



	#
	# gets current ring from the exising unfinished assignments
	#
	def get_ring_from_assignments
		ring = Array.new
		ongoing_assignments = self.assignments.where(status: 'incomplete')
		num_assignments = ongoing_assignments.length
		players = self.players
		curr_assignment = ongoing_assignments.first
		curr_player = players.find(curr_assignment.player_id)
		ring << curr_player
		for i in (1..num_assignments-1)
			curr_assignment = ongoing_assignments.where(player_id: curr_assignment.player_2_id).first
			curr_player = players.find(curr_assignment.player_id)
			ring << curr_player
		end

		# @ring = ring
		return ring
	end
	'''
	algorithm described in README
	'''
	def create_ring(players = self.players, blacklist_size = 3)
		committees = players.uniq.collect(&:committee)
		num_players = players.length
		blacklist = Queue.new
		assigned = Array.new
		while assigned.length < num_players
			assigned_ids = assigned.map{|x| x.id}
			committee = committees.sample
			committees.delete(committee)
			if not committee
				while blacklist.length>0
					committees<<blacklist.pop
				end
			else
				player_query = players.where(committee: committee).where.not(id: assigned_ids)
				if player_query.length > 0
					player = player_query.sample
					assigned << player
					# successfully assigned with this committee, place into blacklist
					blacklist << committee
					# if too full, recycle back a committee
					if blacklist.length > blacklist_size
						committees << blacklist.pop
					end
				end
			end
		end
		return assigned
	end
	# end of create_ring

	'''
	create assignments like this (1,2), (2,3), (3,4), (4,5)...
	'''
	def create_assignments_from_ring(ring)
		#
		# remove previous assignments
		#
		self.assignments.where(status:"incomplete").destroy_all
		assignments = []
		end_index = ring.clone.length-1
		ring.append(ring[0])
		for i in (0..end_index)
			assignment = self.assignments.new
			assignment.player_id = ring[i].id
			assignment.player_2_id = ring[i+1].id
			assignment.time_started = Time.now# now
			assignment.status = 'incomplete'

			p ring[i].name+' has to kill '+ring[i+1].name

			assignment.save
		end
	end
	# end of create assignments from ring

	'''
	player 1 killed player2. kill code already validated
	'''
	def register_kill(assignment_id, is_reverse=false)
		#
		# set statuses in both their assignments
		#
		assignment = self.assignments.find(assignment_id)
		winner_id = assignment.player_id
		loser_id = assignment.player_2_id
		loser_assignment = self.assignments.where(player_id: loser_id).where(status: 'incomplete').first
		
		if loser_assignment == nil
			p 'no loser assignment'
			return
		end
		if assignment.status != 'incomplete' or loser_assignment.status != 'incomplete'
			p 'something is wrong, assignments arent incomplete'
			return
		end

		assignment.status = 'complete'
		loser_assignment.status = 'failed'
		assignment.save
		loser_assignment.save
		p 'this is the loser assignment, it is failed '+loser_assignment.id.to_s
		p 'this is the winner assignment, it is complete '+assignment.id.to_s
		#
		# make new assignment
		#
		new_assignment = self.assignments.new
		new_assignment.player_id = winner_id
		new_assignment.player_2_id = loser_assignment.player_2_id
		new_assignment.time_started = Time.now
		new_assignment.status = 'incomplete'
		new_assignment.save
		p 'this is a new assignment, it is incomplete '+new_assignment.id.to_s
	end


	def convert_reverse_kills
		reverse_kill = self.assignments.where(status:"reverse")
		reverse_kill.each do |rk|
			rk.status = "complete"
			new_player_id = rk.player_2_id
			new_player_2_id = rk.player_id
			rk.player_id = new_player_id
			rk.player_2_id = new_player_2_id
			rk.save
		end
	end
	def register_reverse_kill(assignment_id)
		#
		# set statuses in both their assignments
		#
		p 'REGISTERING REVERSE KILL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
		# return
		assignment = self.assignments.find(assignment_id)
		reverser_id = assignment.player_2_id
		loser_id = assignment.player_id

		# other assignemnt is the guy who shoould have killed the guy who just got reverse f'ed
		other_assignment = self.assignments.where(player_2_id: loser_id).first
		# loser_assignment = self.assignments.where(player_id: loser_id).where(status: 'incomplete').first
		
		if other_assignment == nil
			p 'no other assignment'
			return
		end

		assignment.status = 'reverse'
		other_assignment.status = 'canceled'
		assignment.save
		other_assignment.save

		
		# make new assignment if doesnt already exist
		new_player_1 = other_assignment.player_id
		new_player_2 = reverser_id
		if self.assignments.where(player_id: new_player_1).where(player_2_id: new_player_2).length > 0
			p 'doent exist yet'
		else
			p 'creating new assignment'
			new_assignment = self.assignments.new
			new_assignment.player_id = other_assignment.player_id
			new_assignment.player_2_id = reverser_id
			new_assignment.time_started = Time.now
			new_assignment.status = 'incomplete'
			new_assignment.save
		end

		self.convert_reverse_kills
	end

	def self.generate_name(existing_names)
		first = ['stinky', 'lumpy', 'buttercup', 'gidget', 'crusty', 'greasy', 'fluffy', 'cheeseball', 'chim-chim', 'poopsie',
		 'flunky', 'booger', 'pinky', 'zippy', 'goober', 'doofus', 'slimy', 'loopy', 'snotty', 'falafel', 'dorkey',
		  'squeezit', 'oprah', 'skipper', 'dinky', 'zsa-zsa']

		middle = ['diaper', 'toilet', 'giggle', 'bubble', 'girdle', 'barf', 'lizard', 'waffle', 'cootie', 'monkey',
		 'potty', 'liver', 'banana', 'rhino', 'burger', 'hamster', 'toad', 'gizzard', 'pizza', 'gerbil', 'chicken',
		  'pickle', 'chuckle', 'tofu', 'gorilla', 'stinker']

		last = ['head', 'mouth', 'face', 'nose', 'tush', 'breath', 'pants', 'shorts', 'lips', 'honker', 'butt', 'brain',
		 'tushie', 'chunks', 'hiney', 'biscuits', 'toes', 'buns', 'fanny', 'sniffer', 'sprinkles', 'kisser',
		  'squirt', 'humperdinck', 'brains', 'juice']

		f_name = first.sample
		m_name = middle.sample
		l_name = last.sample
		name = f_name+'_'+m_name+'_'+l_name
		while existing_names.include?(name) 
			f_name = first.sample
			m_name = middle.sample
			l_name = last.sample
			name = f_name+'_'+m_name+'_'+l_name
		end
		return name
	end



end
