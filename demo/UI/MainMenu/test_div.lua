-- test_div.lua
UI.defineComponent("TestScreen", {
	props = { name = "string" },
	events = { "change" },
	render = function(p)
		local current_name = p.name

		local function open_profile()
			UI.mount(ProfileForm{
				name = current_name,
				on_confirm = function(new_name)
					current_name = new_name
					p.on_change({ name = current_name })
				end,
				on_cancel = function() end,
			})
		end
		
		return Body{
			gap = 0,
			children = {
				Div{
					class = "main-menu",
					margin = 5,
					padding = 10,
					children = {
						Scroll{
							scrollbar_width = 5,
							children = {
								Input{
									class = "main-menu-input",
									height = 28,
									type = "text",
									value = current_name,
									icon_side = "right",
									on_changed = function(v) current_name = v end,
								},
								Button{
									label = "OPEN",
									class = "main-menu-button",
									on_pressed = open_profile,
								}
							}
						}
					}
				}
			}
		}
	end
})

--"direction": {"type": TYPE_STRING, "default": "both"},  # "vertical" | "horizontal" | "both"
			--"content_margin": {"type": TYPE_NIL, "default": null},       # distância conteúdo <-> scrollbar
			--"scrollbar_width": {"type": TYPE_INT, "default": null},
			--"track_color": {"type": TYPE_COLOR, "default": null},
			--"grabber_color": {"type": TYPE_COLOR, "default": null},
			--"grabber_hover_color": {"type": TYPE_COLOR, "default": null},
			--"grabber_pressed_color": {"type": TYPE_COLOR, "default": null},
			--"gap": {"type": TYPE_INT, "default": 4},
