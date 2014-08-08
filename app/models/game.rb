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

	def get_dead_assignments
		return self.assignments.where(status: 'failed')
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
		self.assignments.destroy_all
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
	def register_kill(assignment_id)
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
			# p Player.find(assignment.player_id).name
			# p Player.find(assignment.player_2_id).name
			# p Player.find(loser_assignment.player_id).name
			# p Player.find(loser_assignment.player_2_id).name
			p assignment.status
			p loser_assignment.status
			p assignment.status != 'incomplete'
			p loser_assignment.status != 'incomplete'
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
end
