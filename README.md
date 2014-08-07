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

here are some methods you should be able to execute

`get_alive`, `get_assigned(player)`, `get_dead`

# Stories

what happens when you say you killed someone?
