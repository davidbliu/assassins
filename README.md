assassins
=========

web application for managing assassins 


# Getting started

## creating a new game
* POST request /create_game with a list of players
* player is a python dictionary
  * name
  * committee

example: curl asdfasdfasdf

__what will happen in the background?__
a new __game__ is created
* game has __players__
 * players have name, commmittee, id (from portal)
* game has __assignments__ 
 * (assassin: player, target: player)
* game has list of complete assignments
* list of players that are out
* list of players that are in

## generating targets

## 


# Design
