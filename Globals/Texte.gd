extends Node

var lang = G.settings.lang
var prim := {} # primitive, static phrases that can be simply translated


func get(id: String, params: Array = []) -> String:
	if !prim.has("de"): init()
	if self.has_method(id):
		 return call(id, params)
	elif prim[lang].has(id):
		return prim[lang][id]
	else:
		push_error("No translation for id '%s'. Parameters passed: %s" % [id, str(params)])
		return("")


# MM : Main Menu (buttons)
#  T : Text (event descriptions)
#  I : Instructions (key - action)
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

	prim.de["T_Welcome_1"] = "Willkommen an Bord, Käpt'n!"
	prim.de["T_Welcome_2"] = "Das Schiff ist bereit."
	prim.en["T_Welcome_1"] = "Welcome onboard, captain!"
	prim.en["T_Welcome_2"] = "The ship is ready."


func someFunc(_params) -> String:
	return "complex string that needs some handling"
