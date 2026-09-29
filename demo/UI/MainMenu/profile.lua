UI.defineComponent("ProfileForm", {
	props = { name = "string" },
	events = { "confirm", "cancel" },
	render = function(p)
		local current_name = p.name

		return Modal {
			ref = "profile_modal",
			slots = {
				content = Div{
					class = "main-menu",
					direction = "column",
					gap = 12,
					children = {
						Div{
							children = {
								Input{
									type = "text",
									value = p.name,
									on_changed = function(v)
										current_name = v
									end,
								},
							},
						},

						Div{
							direction = "row",
							gap = 8,
							children = {
								Div{
									direction = "row",
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
