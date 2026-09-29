local function on_tutorial_selected()
	UI.doPlaySound("click")
end

local function on_play_selected()
	UI.doPlaySound("click")
end

local function on_button_hovered()
	UI.doPlaySound("hover")
end

local function on_button_lost_hover()
	print("Exited")
end

function onRender()
	return Section{
		size = "full",
		justify = "center",
		gap = 100,
		flex_grow = 1,
		children = {
			Section{
				class = "main-menu-screen",
				panel = true,
				flex = "row",
				flex_grow = 1,
				padding = 100,
				children = {
					Section{
						class = "main-menu-button-section",
						panel = true,
						padding = 20,
						flex_grow = 2,
						gap = 5,
						justify = "center",
						align = "center",
						children = {
							Section{
								flex = "column",
								width = 50,
								gap = 12,
								children = {
									UI.getComponent("mainMenuButton",
										{ id = "MM_TUTORIAL", label = "MM_TUTORIAL" },
										{ on_pressed = on_tutorial_selected, on_mouse_entered = on_button_hovered, on_mouse_exited = on_button_lost_hover }
									),
									UI.getComponent("mainMenuButton",
										{ id = "MM_PLAY", label = "MM_PLAY" },
										{ on_pressed = on_play_selected, on_mouse_entered = on_button_hovered, on_mouse_exited = on_button_lost_hover }
									),
								}
							}
						}
					},
					Section{
						class = "main-menu-logo-section",
						panel = true,
						padding = 20,
						flex_grow = 3,
						align = "center",
						children = {
							Label{
								label = "Meu Jogo"
							}
						}
					}
				}
			},
			Section{
				class = "main-menu-footer",
				panel = true,
				flex = "row",
				flex_grow = 1,
				children = {
				}
			},
			Section{
				class = "main-menu-footer",
				panel = true,
				flex = "row",
				flex_grow = .03,
				justify = "end",
				align = "end",
				padding = {0, 0, 5, 5},
				children = {
					Label{
						label = "v0.0.000001-B",
					}
				}
			}
		}
	}
end
