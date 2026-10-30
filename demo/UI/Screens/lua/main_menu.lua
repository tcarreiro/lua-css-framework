UI.defineComponent("MainMenu", {
  events = { "navigate" }, -- Declara o evento 'navigate'. Quem usa o componente recebe o handler em p.on_navigate
  render = function(p)

	local function go(target)
		if p.on_navigate then p.on_navigate(target) end
	end

	local function button(btn_id, label, navigation_target, class_on_hover)
		if class_on_hover == nil then
			class_on_hover = ""
		end
		return Button{ 
			id = btn_id,
			ref = btn_id,
			label = label,
			class = "menu-button " .. class_on_hover,
			on_pressed = function()
				UI.playSoundEffect("click")
				go(navigation_target)
			end,
			on_mouse_entered = function()
				UI.playSoundEffect("hover")
			end,
		}
	end
	
	return Body{
		children = {
			Div{
				class = "menu-screen",
				flex_grow = 1,
				children = {
					Div{
						flex_grow = 1,
						display = "flex",
						children = {
							-- 60%: a logo
							Div{ class = 'menu-logo', flex_grow = 60, align_items = 'center', children = {
								--Sprite{ texture = 'res://demo/assets/images/logo.png', width = 800, height = 500 }, -- get texture path from GameConfig
								Stack{ 
									children = {
										ParticleEmitter{ amount = 40, color = '#7a8cff', blend = 'add', particle_scale = { 0.5, 0.8 } },
										Sprite{ texture = 'res://demo/assets/images/logo.png', width = 800, height = 500 },
										ShaderEffect{ ref = 'hero_fx', effect = 'scanlines', params = { intensity = 0.6 } },
										ShaderEffect{ ref = 'hero_fx', effect = 'vignette', params = { intensity = 1 } },
										ParticleEmitter{
											amount = 40, texture = "res://demo/assets/images/T_VFX_RoundSmoke71.png", emit_angle = -90, -- get texture path from GameConfig
											spread = 30, speed = { 40, 80 }, color = '#ffd27a',
											color_end = '#ff4000', blend = 'add', particle_scale = { 0.2, 0.3 },
										},
									} 
								},
							}},
							-- 33% de 40%: botões, centralizados na vertical por espaçadores
							Div{ class = 'menu-actions', flex_grow = 40, display = 'flex', padding_bottom = 120, 
								children = {
									Div{flex_grow = 1},
									Div{ flex_grow = 1, gap = 20, alignment = 'end',
										children = {
											button("play_btn", "PLAY", "play", ""),
											button("settings_btn", "SETTINGS", "settings", ""),
											button("quit_btn", "QUIT", "quit", "text-color-red"),
										}
									},
									Div{flex_grow = 1},
								}
							}
						} 
					},
					Div{
						class = "menu-version",
						alignment = "end",
						display = "flex",
						children = {
							Label{text = "v. 0.00.01-00001"},  -- get version from GameConfig
						}
					}
				}
			},
			
		}
	}
  end,
})
