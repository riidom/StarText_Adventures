extends RichTextLabel



func init(text: String, meta: String) -> void:
	self.name = meta
	self.bbcode_text = "[url=%s]%s[/url]" % [meta, text]


func _on_InTextButton_meta_clicked(meta) -> void:
	G.emit_signal("action_triggered", meta)
	self.add_color_override("default_color", Color.black)


func _on_InTextButton_meta_hover_started(_meta) -> void:
	self.add_color_override("default_color", Color(.7, .9, 1))


func _on_InTextButton_meta_hover_ended(_meta) -> void:
	self.add_color_override("default_color", Color(1, 1, 1))
