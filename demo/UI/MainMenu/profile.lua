UI.defineComponent("ProfileForm", {
	props = { name = "string" },
	events = { "confirm", "cancel" },
	render = function(p)
		local current_name = p.name

		return Modal {
			ref = "profile_modal",
			backdrop_color = "#FFFFFF",
			drop_shadow_color = "#00000044",
			drop_shadow_size = 5,
			slots = {
				content = Div{
					class = "main-menu",
					display = "block",
					padding = 10,
					children = {
						Div{
							children = {
								Input{
									class = "main-menu-input",
									height = 28,
									type = "text",
									value = current_name,
									icon = "res://demo/assets/images/right_arrow.png",
									icon_side = "right",
									on_changed = function(v) current_name = v end,
								},
							},
						},
						Div{
							display = "flex",
							children = {
								Div{
									display = "flex",
									gap = 8,
									children = {
										Button{
											label = "OK",
											on_pressed = function()
												p.on_confirm(current_name)
												UI.callMethod("profile_modal", "close")
											end,
										},

										Button{
											label = "Cancelar",
											on_pressed = function()
												p.on_cancel()
												UI.callMethod("profile_modal", "close")
											end,
										},
									},
								},
							},
						},
					},
				},
			},
		}
	end
})
