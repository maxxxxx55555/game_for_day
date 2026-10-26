extends "res://scripts/ReleaseVerification.gd"
signal cycle_finished(code:int)
var checkpoints:int=0
func finish(code:int)->void:cycle_finished.emit(code)
func step_checkpoint(ui:Control)->void:
	var event:Dictionary=ui.active_event.duplicate(true)
	var turn:int=GameManager.total_turns
	for button in [ui.market_btn,ui.biz_btn,ui.settings_btn]:
		button.pressed.emit()
		await get_tree().process_frame
		ui._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	ui.open_market_menu()
	ui.currency_button.pressed.emit()
	await get_tree().process_frame
	ui._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	ui._notification(MainLoop.NOTIFICATION_APPLICATION_PAUSED)
	if GameManager.total_turns!=turn or ui.active_event!=event:push_error("Soak menus rerolled or advanced a life decision")
	LocalizationManager.set_language("ru" if checkpoints%2 else "en")
	checkpoints+=1
