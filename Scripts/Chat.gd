extends RichTextLabel

var chatText = [""]

func say(text):
	chatText.insert(0, text)
	print_rich(text)

func _process(_delta):
	#chatText.insert(0,"")
	chatText = chatText.slice(0,3)
	var chat = ""
	for item in range(chatText.size()):
		if chatText[(chatText.size()-1)-item] != "":
			chat = chat + chatText[(chatText.size()-1)-item] + "\n"
	text = chat
