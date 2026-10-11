-- test_frame_animation.lua
UI.defineComponent("TestScreen", {
	props = { name = "string" },
	render = function(p)
		local button = Body{
			gap = 0,
			children = {
				Div{ 
					background_image = "demo/assets/images/background.png", 
					background_image_slice = {16, 16, 24, 24}, 
					children = {
						Div{
							--class = "frame",
							padding = 400,
							margin = 30,
							children = {
								RichTextLabel{
									text = "Oi, me chamo [color=red][b][wave]Thiago",
									font_color = "#FFFFFF",
									bbcode_enabled = true,
								},
								Sprite{ 
									texture = "demo/assets/images/icon.png", 
									hframes = 2, 
									vframes = 2, 
									duration = 2, 
									loop = true,
									on_finished = function() 
										print("fim") 
									end 
								},
								Sprite{ 
									texture = "demo/assets/images/icon.png", 
									hframes = 2, 
									vframes = 2, 
									fps = 10, 
									loop = false,
									width = 64, 
									height = 64, 
									on_finished = function() 
										print("fim") 
									end 
								},
								Div{
									ref = "card",
									class = "card selected",
									children = {
										Button{
											label = "OPEN",
											class = "main-menu-button",
											on_pressed = function()
												UI.callMethod("card", "toggle_class", { "selected" })
												--local is_selected = UI.callMethod("card", "get_state", { "selected"})
												--UI.callMethod("card", "set_state", { "selected", not is_selected })
											end
										},
									}
								},
							}
						},
					}
				}
			}
		}
		--UI.callMethod("card", "set_state", { "locked", true })                 -- .card:locked
		--UI.callMethod("card", "set_prop", { "background_color", "#335533" })   -- anima, se houver transition
		
		return button
	end
})
