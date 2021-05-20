extends Node

var lang = G.settings.lang
var prim := {} # primitive, static phrases that can be simply translated


func get(id: String, params: Dictionary = {}) -> String:
	if !prim.has("de"): init()
	if self.has_method(id):
		 return call(id, params)
	elif prim[lang].has(id) and params.empty():
		return prim[lang][id]
	elif prim[lang].has(id) and !params.empty():
		push_error("'%s' is a primitive, but yet params are passed: %s" % [id, str(params)])
		return prim[lang][id]
	else:
		push_error("No translation for id '%s'. Parameters passed: %s" % [id, str(params)])
		return("")


# MM : Main Menu (buttons)
#  T : Text (event descriptions)
#  I : Instructions (key - action)
#  S : Status texts
#  A : Alerts (red flashing text)


func init():
	prim["de"] = {}
	prim["en"] = {}
	
	prim.de["MM_NewGame"] = "Neues Spiel"
	prim.en["MM_NewGame"] = "New Game"

	prim.de["MM_Back"] = "Zurück zum Spiel"
	prim.en["MM_Back"] = "Back to Game"

	prim.de["MM_Quit"] = "Spiel beenden"
	prim.en["MM_Quit"] = "Quit Game"

	prim.de["MM_SwitchLanguage"] = "Sprache (de/en)"
	prim.en["MM_SwitchLanguage"] = "Language (de/en)"

	prim.de["MM_Fullscreen"] = "Vollbild-/Fenstermodus"
	prim.en["MM_Fullscreen"] = "Fullscreen/Windowed"
	
	prim.de["MM_Load"] = "Laden"
	prim.en["MM_Load"] = "Load"

	prim.de["MM_Save"] = "Speichern"
	prim.en["MM_Save"] = "Save"
	
	prim.de["S_InStation"] = "Schiff liegt auf Station"
	prim.en["S_InStation"] = "Ship on station"
	
	prim.de["S_InSpace"] = "Schiff ist im All"
	prim.en["S_InSpace"] = "Ship is in space"
	
	prim.de["S_OnLane"] = "Schiff ist auf Sternenbahn"
	prim.en["S_OnLane"] = "Ship is on lane"
	
	prim.de["S_destination_cleared"] = "Kein Ziel gesetzt"
	prim.en["S_destination_cleared"] = "No destination set"
	
	prim.de["I_D_Dock"] = "D - Kontaktiere Station und erbitte Erlaubnis zum Andocken."
	prim.en["I_D_Dock"] = "D - Contact station and ask for permission to dock."
	
	prim.de["I_N_Nav"] = "N - Navigationscomputer, wähle auf der Karte ein Ziel aus."
	prim.en["I_N_Nav"] = "N - Navigation computer, pick a destination from map."
	
	prim.de["I_Nav_Instructions"] = "Navigationscomputer - Klicke ein benachbartes Sternensystem auf der Karte, um es als Ziel auszuwählen."
	prim.en["I_Nav_Instructions"] = "Navigation Computer - Click an adjacent star system on the map to pick your next destination."
	
	prim.de["I_C_ClearNav"] = "C - Lösche das momentan gespeicherte Navigationsziel."
	prim.en["I_C_ClearNav"] = "C - Clear current destination."
	
	prim.de["I_J_Jump"] = "J - Starte den Warpantrieb und springe auf die Sternenbahn."
	prim.en["I_J_Jump"] = "J - Start the warp engine and enter the starlane."

	prim.de["I_E_Engines"] = "E - Starte den Antrieb und verlasse die Station."
	prim.en["I_E_Engines"] = "E - Fire up the engines and exit the station."

	prim.de["I_W_Wait"] = "W - Warte, während du noch auf der Sternenbahn reist."
	prim.en["I_W_Wait"] = "W - Wait while the travel on the starlane continues."

	prim.de["I_ESC_Menu"] = "ESC - Hauptmenü"
	prim.en["I_ESC_Menu"] = "ESC - Main Menu"

	prim.de["I_ESC_Cancel"] = "ESC - Abbrechen"
	prim.en["I_ESC_Cancel"] = "ESC - Cancel"

	prim.de["T_Welcome_1"] = "Willkommen an Bord, Käpt'n!"
	prim.de["T_Welcome_2"] = "Das Schiff ist bereit."
	prim.en["T_Welcome_1"] = "Welcome onboard, captain!"
	prim.en["T_Welcome_2"] = "The ship is ready."
	
	prim.de["T_destination_cleared"] = "Ziel im Navigationscomputer gelöscht."
	prim.en["T_destination_cleared"] = "Destination cleared."
	
	prim.de["A_nav_on_lane"] = "Der Navigationscomputer steht auf der Sternenbahn nicht zur Verfügung."
	prim.en["A_nav_on_lane"] = "You can't use the navigation computer while on a lane."
	
	prim.de["A_destination_to_current"] = "Dieses Ziel ist deine momentane Position."
	prim.en["A_destination_to_current"] = "You are already there."
	
	prim.de["A_only_adjacent"] = "Nur benachbarte Sterne sind gültige Ziele"
	prim.en["A_only_adjacent"] = "Only adjacent stars are valid destinations."


func T_location_description(p: Dictionary) -> String:
	var text = []
	if lang == "en":
		
		text.append("You are ")
		
		if p.mention_system:
			text.append("in the system %s, " % p.s_at)
			
		if p.loc == "station":
			text.append("inside the station.")
			
		elif p.loc == "station->space":
			text.append("outside the station.")
			
		elif p.loc == "lane->space":
			text.append("nearby the station, after leaving the starlane.")
			
		elif p.loc == "space->space":
			text.append("still in space?\n")
			
		elif p.loc == "lane":
			text.append("on the starlane between %s and %s." % [p.s_from, p.s_to])
			
		elif p.loc == "space->lane":
			text.append("entering the starlane towards %s." % p.s_to)
	
	elif lang == "de":
		
		text.append("Du bist ")
		
		if p.mention_system:
			text.append("im System %s, " % p.s_at)
			
		if p.loc == "station":
			text.append("im Innern der Station.")
			
		elif p.loc == "station->space":
			text.append("außerhalb der Station.")
			
		elif p.loc == "lane->space":
			text.append("in der Nähe der Station, nachdem du die Sternenbahn verlassen hast.")
			
		elif p.loc == "space->space":
			text.append("noch im Weltraum?")
			
		elif p.loc == "lane":
			text.append("auf der Sternenbahn zwischen %s und %s." % [p.s_from, p.s_to])
			
		elif p.loc == "space->lane":
			text.append("dabei, auf die Sternenbahn Richtung %s zu springen." % p.s_to)		
	
	return PoolStringArray(text).join("")


func T_destination_set(p: Dictionary) -> String:
	var text = ""
	if lang == "en":
		text = "Destination set to %s." % p.star_name
	elif lang == "de":
		text = "%s ist als Ziel im Navigationscomputer gespeichert." % p.star_name
	return text


func A_game_loaded(p: Dictionary) -> String:
	return "Spiel %d geladen." % p.slot if lang == "de" else "Game %d loaded." % p.slot
	
