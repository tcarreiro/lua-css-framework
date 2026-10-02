UI.defineComponent("MainMenu", {
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

		return Box{
			direction = "column",
			class = "main-menu",
			padding = 5,
			margin = 10,
			gap = 12,
			children = {
				Label{ text = current_name },
				Button{ label = "OPEN", class = "main-menu-button", on_pressed = open_profile },
			}
		}
	end
})
