class Game < ActiveRecord::Base

	has_many :players, dependent: :destroy
	has_many :assignments, dependent: :destroy
	has_many :kills, dependent: :destroy


	def get_player_names
		return self.players.pluck(:name)
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
end
