extends Node

# Steam variables
var OWNED = false
var ONLINE = false
var STEAM_ID = 0
var STEAM_NAME = ""

# Lobby variables
var DATA
var LOBBY_ID = 0
var LOBBY_MEMBERS = []
var LOBBY_INVITE_ARG = false


func _ready():
	var INIT = Steam.steamInitEx()
	if INIT:
		ONLINE = Steam.loggedOn()
		STEAM_ID = Steam.getSteamID()
		STEAM_NAME = Steam.getPersonaName()
		OWNED = Steam.isSubscribed()
		
		if not OWNED:
			print("User does not own this game.")
			get_tree().quit()
	else:
		print("Failed to initialize Steam. Shutting down...")
		get_tree().quit()


func _process(delta: float) -> void:
	Steam.run_callbacks()
