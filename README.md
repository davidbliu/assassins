=======
assassins
=========

web application for managing assassins 

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
```


# Application

### Assignment Procedure
__option one:__ have array of all committees, loop: sample from array without replacement and assign, problem: people at end of array might overlap committees

__option two:__ pick one committee (HT) as separator. looks like this: HT, random, random, random, HT, random, random, random...

__idea:__ have a 'blacklist' of committees you cannot assign from of length like 4 or something. this is a queue. rest of committees are fair game and you sample them randomly. dequeue from blacklist and enqueue committee you just assigned from. worst case under this method is HT, length_of_blacklist, HT

### Interface
here are some methods you should be able to execute

`get_alive`, `get_assigned(player)`, `get_dead`

# Stories

what happens when you say you killed someone?
