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
		
		local function scrolled()
			print("scrolled")
		end
		
		local function reach_start()
			print("reach_start")
		end
		
		local function reach_end()
			print("reach_end")
		end
		
		local function scroll_started()
			print("scroll_started")
		end
		
		local function scroll_ended()
			print("scroll_ended")
		end
		
		return Scroll{ 
			class = "main-scroll",
			children = {
				Label{
					text = "OIOI 1"
				},
				Label{
					text = "OIOI 2"
				},
				Label{
					text = "OIOI 3"
				},
				Label{
					text = "OIOI 4"
				},
				Label{
					text = "OIOI 5"
				},
				Label{
					text = "OIOI 6"
				},
				Label{
					text = "OIOI 7"
				},
				Label{
					text = "OIOI 8"
				},
				Label{
					text = "OIOI 9"
				}
			} 
		}
		
		--return Body{
			--gap = 0,
			--children = {
				--Div{
					--class = "main-menu",
					--padding = 10,
					--children = {
						--Scroll{
							--class = "main-scroll",
							--scrollbar_mode = "grow",
							--padding_left = 20,
							--max_width = 150,
							--on_scrolled = scrolled,
							--on_reached_start = reach_start,
							--on_reached_end = reach_end,
							--on_scroll_started = scroll_started,
							--on_scroll_ended= scroll_ended,
							--children = {
								--Input{ 
									--input_font_color = "#FFFFFF", 
									--label_font_color = "#999999", 
									--label_font_size = 12,
									--on_changed = function(v) current_name = v end
								--},
								----Input{
									----class = "main-menu-input",
									----height = 28,
									----type = "text",
									----value = current_name,
									----icon_side = "right",
									----on_changed = function(v) current_name = v end,
								----},
								--Button{
									--label = "OPEN",
									--class = "main-menu-button",
									--on_pressed = open_profile,
								--}
							--}
						--}
					--}
				--}
			--}
		--}
	end
})
