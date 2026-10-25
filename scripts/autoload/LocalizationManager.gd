extends Node
## Presentation translates canonical copy; save identifiers and callbacks never change.
signal language_changed(language:String)
const Guard=preload("res://scripts/security/SaveGuard.gd")
const SETTINGS_FILE="user://presentation.cfg"
var current_language:="ru"
var language_confirmed:=false
var translations:Dictionary={}
var aliases:Dictionary={}
var direct:Dictionary={}
var patterns:Array[Dictionary]=[]
var fragments:Array[String]=[]
var translation_resources:Array[Translation]=[]
var format_tokens:=RegEx.new()
func _exit_tree() -> void:
	# TranslationServer outlives autoload Nodes; detach scripted lookups before teardown.
	for resource in translation_resources:
		TranslationServer.remove_translation(resource)
		resource.manager=null
	translation_resources.clear()
func _ready() -> void:
	format_tokens.compile("%(?:[-+0#]*[0-9]*(?:\\.[0-9]+)?[sdif])")
	var decoded=JSON.parse_string(FileAccess.get_file_as_string("res://data/strings/localization.json"))
	if not decoded is Dictionary:
		push_error("Compiled localization catalog missing")
		return
	translations=decoded.strings
	aliases=decoded.aliases
	for key in translations:
		var entry:Dictionary=translations[key]
		for raw in [str(entry.ru),clean(str(entry.ru))]:
			var target:=clean(str(entry.en)) if raw==clean(str(entry.ru)) else str(entry.en)
			direct[raw]=target
			direct[raw.replace("%%","%")]=target.replace("%%","%")
			if "%" in raw and raw!=target: add_pattern(raw,target)
	fragments.assign(direct.keys())
	fragments.sort_custom(func(a,b):return a.length()>b.length())
	patterns.sort_custom(func(a,b):return a.specificity>b.specificity)
	for language in ["ru","en"]:
		var resource:Translation=preload("res://scripts/localization/DisplayTranslation.gd").new()
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
	return str(translations.get(key,{}).get(current_language,key))
func clean(text:String) -> String:
	var result:=""
	for i in text.length():
		var code:=text.unicode_at(i)
		if code>=0x1f000 and code<=0x1faff or code>=0x2600 and code<=0x27ff or code in [0xfe0f,0x200d]:continue
		result+=text[i]
	return result.strip_edges()
func add_pattern(raw:String,target:String) -> void:
	var tokens:=RegEx.new()
	tokens.compile("%(?:[-+0#]*[0-9]*(?:\\.[0-9]+)?[sdif]|%)")
	var regex:="(?s)^"
	var cursor:=0
	var count:=0
	var literal_length:=0
	for match in tokens.search_all(raw):
		var part:=raw.substr(cursor,match.get_start()-cursor)
		regex+=escape_regex(part)
		literal_length+=part.length()
		var token:=match.get_string()
		if token=="%%":regex+="%"
		else:
			regex+="(-?[0-9]+(?:[.,][0-9]+)?)" if token[-1] in ["d","i","f"] else "(.*?)"
			count+=1
		cursor=match.get_end()
	regex+=escape_regex(raw.substr(cursor))+"$"
	if count==0:return
	var compiled:=RegEx.new()
	if compiled.compile(regex)==OK:patterns.append({"regex":compiled,"target":target,"tokens":tokens,"specificity":literal_length+raw.length()-cursor})
func escape_regex(text:String) -> String:
	var result:=""
	for letter in text:
		if letter in "\\.^$|?*+()[]{}":result+="\\"
		result+=letter
	return result
func display(text:String,depth:int=0) -> String:
	if current_language=="ru":return russian_numbers(text)
	if depth>5:return text
	if direct.has(text):return str(direct[text])
	for pattern in patterns:
		var match:RegExMatch=pattern.regex.search(text)
		if not match:continue
		var result:=""
		var cursor:=0
		var index:=1
		var target:String=pattern.target
		for token in pattern.tokens.search_all(target):
			result+=target.substr(cursor,token.get_start()-cursor)
			if token.get_string()=="%%":result+="%"
			else:
				result+=display(match.get_string(index),depth+1)
				index+=1
			cursor=token.get_end()
		return result+target.substr(cursor)
	# Joined paragraphs and rule responses combine independently translated pieces.
	var result:=text
	for fragment in fragments:
		if fragment.length()<2 or format_tokens.search(fragment):continue
		if fragment in result:result=result.replace(fragment,str(direct[fragment]))
	if "\n" in result:
		var lines:=result.split("\n")
		for i in lines.size():lines[i]=display(lines[i],depth+1)
		result="\n".join(lines)
	return result
func russian_numbers(text:String) -> String:
	# Display only: no serialized money, canonical event title or RNG is changed.
	var grouping:=RegEx.new()
	grouping.compile("[0-9]{1,3}(?:,[0-9]{3})+")
	var groups:=grouping.search_all(text)
	for i in range(groups.size()-1,-1,-1):
		var group:RegExMatch=groups[i]
		text=text.substr(0,group.get_start())+group.get_string().replace(","," ")+text.substr(group.get_end())
	var regex:=RegEx.new()
	regex.compile("([0-9]+)\\.([0-9]+)([KMB]?)")
	var result:=text
	var matches:=regex.search_all(text)
	for i in range(matches.size()-1,-1,-1):
		var match:RegExMatch=matches[i]
		var suffix:String={"K":" тыс.","M":" млн","B":" млрд"}.get(match.get_string(3),"")
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
	var config:=ConfigFile.new()
	config.set_value("language","locale",current_language)
	config.set_value("language","confirmed",language_confirmed)
	var ok:=Guard.atomic_text(SETTINGS_FILE,config.encode_to_text())
	GameManager.report_write(SETTINGS_FILE,ok)
func load_settings() -> void:
	var config:=ConfigFile.new()
	var text:=Guard.bounded_text(SETTINGS_FILE)
	var preferred:="ru" if OS.get_locale_language()=="ru" else "en"
	if text.length()<=65536 and Guard.safe_text(text) and config.parse(text)==OK:
		var value=config.get_value("language","locale",preferred)
		if value in ["ru","en"]:preferred=value
		language_confirmed=config.get_value("language","confirmed",false)==true
	var qa_language:=OS.get_environment("GAME_LANGUAGE")
	if qa_language in ["ru","en"]:preferred=qa_language
	set_language(preferred,false)
