=======
PBL Assassins 
=========

web application for managing assassins 

```
                                 _           
     /\                         (_)          
    /  \   ___ ___  __ _ ___ ___ _ _ __  ___ 
   / /\ \ / __/ __|/ _` / __/ __| | '_ \/ __|
  / ____ \\__ \__ \ (_| \__ \__ \ | | | \__ \
 /_/    \_\___/___/\__,_|___/___/_|_| |_|___/          
```

# Table of Contents

- [PBL Assassins ](#user-content-pbl-assassins-)
- [Models](#user-content-models)
- [Application](#user-content-application)
	- [Assignment Algorithm](#user-content-assignment-algorithm)
	- [Simulation](#user-content-simulation)
	- [Interface](#user-content-interface)
- [Stories](#user-content-stories)

# Models

```yaml
player
	name
	id
	status (alive or dead)
	kill_code
assignment
	player_id (who this is assigned to)
	player_2_id (who i was assigned to kill)
	time_started
	time_completed
	status
kill
	player_id
	player_2_id (guy that got killed)
	time

game
	players
	assignments
	kills
```


# Application

### Assignment Algorithm
__option one:__ have array of all committees, loop: sample from array without replacement and assign, problem: people at end of array might overlap committees

__option two:__ pick one committee (HT) as separator. looks like this: HT, random, random, random, HT, random, random, random... _problem_ this spaces out HT equally but not necessarily other committees

__idea:__ have a 'blacklist' of committees you cannot assign from of length like 4 or something. this is a queue. rest of committees are fair game and you sample them randomly. dequeue from blacklist and enqueue committee you just assigned from. worst case under this method is HT, length_of_blacklist, HT

__implementation__

```ruby
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
```
__effectiveness?__

here is a result generated with blacklist_size of 3 (each committee at least spaced 3 away). some __manual assignments__ will  probably be needed at the end. _this weird stuff happens when some committees are much larger than others_

```
"jane 5"
"marcus 3"
"sylvestor 2"
"tweety 1"
"mervyn 4"
"macy 5"
"max 2"
"target 3"
"tyrone 4"
"joanne 3"
"penny 2"
"lin 4"
"santa 2"
"tj 2"
"john 2"
"jc 2"
```

### Simulation

see `/lib/tasks/fake_game.rake`

### Interface
here are some methods you should be able to execute

`get_alive`, `get_assigned(player)`, `get_dead`

# Stories

what happens when you say you killed someone?
