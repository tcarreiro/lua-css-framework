UI.defineComponent("MainMenu", {
	name = "MainMenu",
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
	
		return Div{
			class = "main-menu",
			direction = "row",
			children = {
				RichTextLabel{
					class = "main-menu-label",
					autowrap = "off",
					font_color = "#000000",
					text = "[wave]Ola,[/wave] [rainbow]thiago[/rainbow]!!!"
				},
				--RichTextLabel{
					--class = "main-menu-label",
					--text = "[wave]OI[/wave] [rainbow]thiago",
				--},
				Input{
					class = "main-menu-input",
					placeholder = "Digite seu nome...",
				},
				Button{
					label = "OPEN",
					class = "main-menu-button",
					on_pressed = open_profile,
				},
			}
		}
	end
})
