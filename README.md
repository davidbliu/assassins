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

### Interface
here are some methods you should be able to execute

`get_alive`, `get_assigned(player)`, `get_dead`

# Stories

what happens when you say you killed someone?
