## The Poki HTML shell initializes the JavaScript SDK before Godot starts,
## this autoload only forwards game events. You can configure the autoloads in project settings -> globals

extends Node

const SDK_NAME := "PokiSDK"

signal commercial_break_done(response: Variant)
signal commercial_break_failed(error: Variant)
signal rewarded_break_done(reward_granted: bool)
signal rewarded_break_failed(error: Variant)

var _sdk = null
var _retained_callbacks = []

func _ready():
	if not OS.has_feature("web"): return

	_sdk = JavaScriptBridge.get_interface(SDK_NAME)


func is_available() -> bool:
	return _sdk != null


func game_loading_finished():
	if not is_available(): return

	_sdk.gameLoadingFinished()


func gameplay_start():
	if not is_available(): return

	_sdk.gameplayStart()


func gameplay_stop():
	if not is_available(): return

	_sdk.gameplayStop()


func commercial_break(on_start: Callable = Callable()):
	if not is_available():
		commercial_break_done.emit(null)
		return

	var resolve = _javascript_callback(func(_args: Array): commercial_break_done.emit(null))

	var reject = _javascript_callback(func(args: Array): commercial_break_failed.emit(args[0] if not args.is_empty() else "Unknown Poki error"))

	var promise = null

	if on_start.is_valid():
		var start = _javascript_callback(func(_args: Array): on_start.call())
		promise = _sdk.commercialBreak(start)
	else:
		promise = _sdk.commercialBreak()

	promise.then(resolve, reject)


func rewarded_break(on_start_or_params = null):
	if not is_available():
		rewarded_break_done.emit(false)
		return

	var resolve = _javascript_callback(func(args: Array):
		rewarded_break_done.emit(bool(args[0]) if not args.is_empty() else false)
	)
	var reject = _javascript_callback(func(args: Array):
		rewarded_break_failed.emit(args[0] if not args.is_empty() else "Unknown Poki error")
	)
	var promise = null
	if on_start_or_params is Callable and on_start_or_params.is_valid():
		var start = _javascript_callback(func(_args: Array): on_start_or_params.call())
		promise = _sdk.rewardedBreak(start)
	elif on_start_or_params is Dictionary:
		var params: Dictionary = on_start_or_params.duplicate()
		var on_start_callback = params.get("onStart")
		if on_start_callback is Callable and on_start_callback.is_valid():
			params["onStart"] = _javascript_callback(func(_args: Array): on_start_callback.call())
		promise = _sdk.rewardedBreak(params)
	else:
		promise = _sdk.rewardedBreak()

	promise.then(resolve, reject)


func measure(category: String, what: String, action: String):
	if not is_available(): return

	_sdk.measure(category, what, action)


func get_url_param(key: String) -> Variant:
	return _sdk.getURLParam(key) if is_available() else null


func is_ad_blocked() -> bool:
	return bool(_sdk.isAdBlocked()) if is_available() else false


func _javascript_callback(callback: Callable):
	var javascript_callback = JavaScriptBridge.create_callback(callback)
	_retained_callbacks.append(javascript_callback)
	return javascript_callback
