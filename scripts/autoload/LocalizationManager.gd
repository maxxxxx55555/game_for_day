extends Node
## Presentation translates canonical copy; save identifiers and callbacks never change.
signal language_changed(language:String)
const DisplayLookup=preload("res://scripts/localization/DisplayTranslation.gd")
const Guard=preload("res://scripts/security/SaveGuard.gd")
const SETTINGS_FILE:String="user://presentation.cfg"
var current_language:String="ru"
var language_confirmed:bool=false
var translations:Dictionary={}
var aliases:Dictionary={}
var direct:Dictionary={}
var patterns:Array[Dictionary]=[]
var fragments:Array[String]=[]
var translation_resources:Array[DisplayLookup]=[]
var format_tokens:RegEx=RegEx.new()
func _exit_tree() -> void:
	# TranslationServer outlives autoload Nodes; detach scripted lookups before teardown.
	for resource:DisplayLookup in translation_resources:
		TranslationServer.remove_translation(resource)
		resource.manager=null
	translation_resources.clear()
func _ready() -> void:
	if format_tokens.compile("%(?:[-+0#]*[0-9]*(?:\\.[0-9]+)?[sdif])")!=OK:
		push_error("Invalid built-in regular expression")
	var decoded:Variant=BuildIntegrity.read_json("res://data/strings/localization.json")
	if not decoded is Dictionary:
		push_error("Compiled localization catalog missing")
		return
	translations=decoded.strings
	aliases=decoded.aliases
	for key:Variant in translations:
		var entry:Dictionary=translations[key]
		for raw:String in [str(entry.ru),clean(str(entry.ru))]:
			var target:String=clean(str(entry.en)) if raw==clean(str(entry.ru)) else str(entry.en)
			direct[raw]=target
			direct[raw.replace("%%","%")]=target.replace("%%","%")
			if "%" in raw and raw!=target: add_pattern(raw,target)
	fragments.assign(direct.keys())
	fragments.sort_custom(func(a:String,b:String)->bool:return a.length()>b.length())
	patterns.sort_custom(func(a:Dictionary,b:Dictionary)->bool:return a.specificity>b.specificity)
	for language:String in ["ru","en"]:
		var resource:DisplayLookup=preload("res://scripts/localization/DisplayTranslation.gd").new()
		resource.locale=language
		resource.manager=self
		translation_resources.append(resource)
		TranslationServer.add_translation(resource)
	load_settings()
func source(key:String) -> String:
	if not translations.has(key):
		push_error("Missing localization key: "+key)
		return key
	return str(translations[key].ru)
func get_string(key:String) -> String:
	var entry:Dictionary=translations.get(key,{})
	return str(entry.get(current_language,key))
func clean(text:String) -> String:
	var result:String=""
	for i:int in text.length():
		var code:int=text.unicode_at(i)
		if code>=0x1f000 and code<=0x1faff or code>=0x2600 and code<=0x27ff or code in [0xfe0f,0x200d]:continue
		result+=text[i]
	return result.strip_edges()
func add_pattern(raw:String,target:String) -> void:
	var tokens:RegEx=RegEx.new()
	if tokens.compile("%(?:[-+0#]*[0-9]*(?:\\.[0-9]+)?[sdif]|%)")!=OK:
		push_error("Invalid built-in regular expression")
	var regex:String="(?s)^"
	var cursor:int=0
	var count:int=0
	var literal_length:int=0
	for match:RegExMatch in tokens.search_all(raw):
		var part:String=raw.substr(cursor,match.get_start()-cursor)
		regex+=escape_regex(part)
		literal_length+=part.length()
		var token:String=match.get_string()
		if token=="%%":regex+="%"
		else:
			regex+="(-?[0-9]+(?:[.,][0-9]+)?)" if token[-1] in ["d","i","f"] else "(.*?)"
			count+=1
		cursor=match.get_end()
	regex+=escape_regex(raw.substr(cursor))+"$"
	if count==0:return
	var compiled:RegEx=RegEx.new()
	if compiled.compile(regex)==OK:patterns.append({"regex":compiled,"target":target,"tokens":tokens,"specificity":literal_length+raw.length()-cursor})
func escape_regex(text:String) -> String:
	var result:String=""
	for letter:String in text:
		if letter in "\\.^$|?*+()[]{}":result+="\\"
		result+=letter
	return result
func display(text:String,depth:int=0) -> String:
	if current_language=="ru":return russian_numbers(text)
	if depth>5:return text
	if direct.has(text):return str(direct[text])
	for pattern:Dictionary in patterns:
		var matcher:RegEx=pattern.regex
		var match:RegExMatch=matcher.search(text)
		if not match:continue
		var rendered:String=""
		var cursor:int=0
		var index:int=1
		var target:String=pattern.target
		var pattern_tokens:RegEx=pattern.tokens
		for token:RegExMatch in pattern_tokens.search_all(target):
			rendered+=target.substr(cursor,token.get_start()-cursor)
			if token.get_string()=="%%":rendered+="%"
			else:
				rendered+=display(match.get_string(index),depth+1)
				index+=1
			cursor=token.get_end()
		return rendered+target.substr(cursor)
	# Joined paragraphs and rule responses combine independently translated pieces.
	var result:String=text
	for fragment:String in fragments:
		if fragment.length()<2 or format_tokens.search(fragment):continue
		if fragment in result:result=result.replace(fragment,str(direct[fragment]))
	if "\n" in result:
		var lines:PackedStringArray=result.split("\n")
		for i:int in lines.size():lines[i]=display(lines[i],depth+1)
		result="\n".join(lines)
	return result
func russian_numbers(text:String) -> String:
	# Display only: no serialized money, canonical event title or RNG is changed.
	var grouping:RegEx=RegEx.new()
	if grouping.compile("[0-9]{1,3}(?:,[0-9]{3})+")!=OK:
		push_error("Invalid built-in regular expression")
	var groups:Array[RegExMatch]=grouping.search_all(text)
	for i:int in range(groups.size()-1,-1,-1):
		var group:RegExMatch=groups[i]
		text=text.substr(0,group.get_start())+group.get_string().replace(","," ")+text.substr(group.get_end())
	var regex:RegEx=RegEx.new()
	if regex.compile("([0-9]+)\\.([0-9]+)([KMB]?)")!=OK:
		push_error("Invalid built-in regular expression")
	var result:String=text
	var matches:Array[RegExMatch]=regex.search_all(text)
	for i:int in range(matches.size()-1,-1,-1):
		var match:RegExMatch=matches[i]
		var suffix:String={"K":get_string("number.thousand"),"M":get_string("number.million"),"B":get_string("number.billion")}.get(match.get_string(3),"")
		result=result.substr(0,match.get_start())+match.get_string(1)+","+match.get_string(2)+suffix+result.substr(match.get_end())
	return result
func set_language(language:String,persist:bool=true) -> void:
	if language not in ["ru","en"]:return
	current_language=language
	TranslationServer.set_locale(language)
	if persist:
		language_confirmed=true
		save_settings()
	language_changed.emit(language)
func save_settings() -> void:
	var config:ConfigFile=ConfigFile.new()
	config.set_value("language","locale",current_language)
	config.set_value("language","confirmed",language_confirmed)
	var ok:bool=Guard.atomic_text(SETTINGS_FILE,config.encode_to_text())
	GameManager.report_write(SETTINGS_FILE,ok)
func load_settings() -> void:
	var config:ConfigFile=ConfigFile.new()
	var text:String=Guard.bounded_text(SETTINGS_FILE)
	var preferred:String="ru" if OS.get_locale_language()=="ru" else "en"
	# Existing 1.4 profiles were Russian-only; preserve their presentation until an explicit choice.
	if text.is_empty() and FileAccess.file_exists("user://dynasty_save.cfg"):preferred="ru"
	if text.length()<=65536 and Guard.safe_text(text) and config.parse(text)==OK:
		var value:Variant=config.get_value("language","locale",preferred)
		if value in ["ru","en"]:preferred=value
		language_confirmed=config.get_value("language","confirmed",false)==true
	var qa_language:String=OS.get_environment("GAME_LANGUAGE")
	if qa_language in ["ru","en"]:preferred=qa_language
	set_language(preferred,false)
