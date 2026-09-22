extends Control


func _on_gameplay_start_pressed():
	PokiSDK.gameplay_start()
	print("gameplay_start")


func _on_gameplay_stop_pressed():
	PokiSDK.gameplay_stop()
	print("gameplay_stop")

func _on_commercial_ad_pressed():
	PokiSDK.commercial_break()
	print("commercial_break")
