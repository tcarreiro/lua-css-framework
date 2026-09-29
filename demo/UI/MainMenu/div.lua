UI.defineComponent("MainMenu", {
	name = "MainMenu",
	props = { name = "string" },
	events = { "change" },
	render = function(p)
		return Div{
			class = "main-menu",
			disabled = true,
			children = {
				Label{
					text = current_name,
				},
				Button{
					label = "OPEN",
					disabled = true,
					class = "main-menu-button",
					on_pressed = open_profile,
				},
			}
		}
	end
})
