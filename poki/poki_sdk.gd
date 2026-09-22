## Minimal, static Poki SDK bridge for Godot 4 web exports.
##
## The custom Poki HTML shell initializes the JavaScript SDK before Godot starts,
## so this autoload only needs to forward game events and Promise results.
extends Node

const SDK_NAME := "PokiSDK"

signal commercial_break_done(response: Variant)
signal commercial_break_failed(error: Variant)
signal rewarded_break_done(reward_granted: bool)
signal rewarded_break_failed(error: Variant)

var _sdk = null
var _retained_callbacks = []


func _ready() -> void:
	if OS.has_feature("web"):
		_sdk = JavaScriptBridge.get_interface(SDK_NAME)


func is_available() -> bool:
	return _sdk != null


func game_loading_finished() -> void:
	if is_available():
		_sdk.gameLoadingFinished()


func gameLoadingFinished() -> void:
	game_loading_finished()


func gameplay_start() -> void:
	if is_available():
		_sdk.gameplayStart()


func gameplayStart() -> void:
	gameplay_start()


func gameplay_stop() -> void:
	if is_available():
		_sdk.gameplayStop()


func gameplayStop() -> void:
	gameplay_stop()


func commercial_break(on_start: Callable = Callable()) -> void:
	if not is_available():
		commercial_break_done.emit(null)
		return

	var resolve = _javascript_callback(func(_args: Array) -> void:
		commercial_break_done.emit(null)
	)
	var reject = _javascript_callback(func(args: Array) -> void:
		commercial_break_failed.emit(args[0] if not args.is_empty() else "Unknown Poki error")
	)
	var promise = null
	if on_start.is_valid():
		var start = _javascript_callback(func(_args: Array) -> void: on_start.call())
		promise = _sdk.commercialBreak(start)
	else:
		promise = _sdk.commercialBreak()
	promise.then(resolve, reject)


func commercialBreak(on_start: Callable = Callable()) -> void:
	commercial_break(on_start)


func rewarded_break(on_start_or_params = null) -> void:
	if not is_available():
		rewarded_break_done.emit(false)
		return

	var resolve = _javascript_callback(func(args: Array) -> void:
		rewarded_break_done.emit(bool(args[0]) if not args.is_empty() else false)
	)
	var reject = _javascript_callback(func(args: Array) -> void:
		rewarded_break_failed.emit(args[0] if not args.is_empty() else "Unknown Poki error")
	)
	var promise = null
	if on_start_or_params is Callable and on_start_or_params.is_valid():
		var start = _javascript_callback(func(_args: Array) -> void: on_start_or_params.call())
		promise = _sdk.rewardedBreak(start)
	elif on_start_or_params is Dictionary:
		var params: Dictionary = on_start_or_params.duplicate()
		var on_start_callback = params.get("onStart")
		if on_start_callback is Callable and on_start_callback.is_valid():
			params["onStart"] = _javascript_callback(func(_args: Array) -> void: on_start_callback.call())
		promise = _sdk.rewardedBreak(params)
	else:
		promise = _sdk.rewardedBreak()
	promise.then(resolve, reject)


func rewardedBreak(on_start_or_params = null) -> void:
	rewarded_break(on_start_or_params)


func measure(category: String, what: String, action: String) -> void:
	if is_available():
		_sdk.measure(category, what, action)


func get_url_param(key: String) -> Variant:
	return _sdk.getURLParam(key) if is_available() else null


func getURLParam(key: String) -> Variant:
	return get_url_param(key)


func is_ad_blocked() -> bool:
	return bool(_sdk.isAdBlocked()) if is_available() else false


func isAdBlocked() -> bool:
	return is_ad_blocked()


func _javascript_callback(callback: Callable):
	var javascript_callback = JavaScriptBridge.create_callback(callback)
	_retained_callbacks.append(javascript_callback)
	return javascript_callback
