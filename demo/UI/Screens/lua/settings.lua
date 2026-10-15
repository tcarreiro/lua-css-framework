local function row(title, control, label_width)
  return 
		Div{ 
			id = "row-wrapper",
			display = "flex",
			gap = 16,
			padding = 30,
			children = {
				Div{
					id = "label-wrapper",
					alignment = "center",
					children = {
						Label{ text = title, class = "settings-label", width = label_width},
					}
				},
				control,
				Div{id = "separator", flex_grow = 5}
			}
	}
end

UI.defineComponent("SettingsScreen", {
  events = { "navigate" },
  render = function(p)
	local settings_store = UI.store("settings")
	local draft_store = settings_store.draft()        -- cópia local, editada pelos inputs
	print(settings_store.get_at("quality_options")[0])
	-- true enquanto o rascunho for igual ao aplicado; APPLY e SAVE acompanham -- Reativo
	local not_dirty = UI.bind(draft_store, function() return not draft_store.dirty() end)
	
	local function back_to_menu()
	  if p.on_navigate then p.on_navigate("main_menu") end
	end

	local function confirm(message, action)
	  UI.mount(ConfirmDialog{ message = message, on_confirm = action })
	end

	return Body{ children = {
	  Div{ class = "settings-screen", flex_grow = 1, gap = 16,
		children = {
			Label{ id = "section_name", text = "SETTINGS", class = "settings-title" },
			
			Label{
				id = "applied_config", 
				class = "settings-hint",
				text = UI.bind(settings_store, function()
					--return settings_store.get_at("vsync")
					return "Aplicado: " .. settings_store.get_at("resolution")
					  .. " | vsync " .. tostring(settings_store.get_at("vsync"))
					  .. " | volume " .. settings_store.get_at("volume")
					  .. " | quality " .. settings_store.get_at("quality_options")[settings_store.get_at("quality")-1].label
				  end),
			},
			
			Label{
				id = "draft_config", 
				class = "settings-hint",
				text = UI.bind(draft_store, function()
					--return draft_store.get_at("vsync")
					return "Rascunho: " .. draft_store.get_at("resolution")
					  .. " | vsync " .. tostring(draft_store.get_at("vsync"))
					  .. " | volume " .. draft_store.get_at("volume")
					  .. " | quality " .. draft_store.get_at("quality_options")[draft_store.get_at("quality")-1].label
				  end),
			},
			
			Scroll{
				flex_grow = 1,
				children = {
					row('Resolução', Dropdown{
						class = 'settings-input', width = 300,
						options = settings_store.get_at("resolution_options"),
						model = draft_store.model('resolution'),
					}, 240),
					row('VSync', Checkbox{
						class = 'checkbox', label = 'Ligado',
						model = draft_store.model('vsync')
					}, 240),
					row('Volume', Slider{
						class = 'slider', width = 300, min = 0, max = 100, step = 1, show_value = true,
						track_height = 8, thumb_size = 22,
						model = draft_store.model('volume'),
					}, 240),
					row('Qualidade', RadioGroup{
						options = settings_store.get_at("quality_options"),
						model = draft_store.model('quality'),
						on_changed = function(v) print(v) end
					}, 240),
				}
			},
			

			Div{ id = "actions", display = "flex", gap = 12,
				children = {
					Div{ flex_grow = 1 },   -- empurra os botões para a direita
					Button{
						label = "APPLY", class = "menu-button", disabled = not_dirty,
						on_mouse_entered = function()
							if draft_store.dirty() then
								UI.playSoundEffect("som")
							end
						end,
						on_pressed = function() 
							confirm("Salvar as configurações?", function()
								draft_store.commit()
							end)
						end,
					},
					Button{
						label = "SAVE", class = "menu-button", disabled = not_dirty,
						on_mouse_entered = function()
							if draft_store.dirty() then
								UI.playSoundEffect("som")
							end
						end,
						on_pressed = function()
						  confirm("Salvar as configurações e voltar ao menu principal?", function()
							draft_store.commit()
							back_to_menu()
						  end)
						end,
					},
					Button{
						label = "BACK", class = "menu-button",
						on_pressed = function()
							if not draft_store.dirty() then
								back_to_menu()
								return
							end
							confirm("Descartar as alterações e voltar ao menu principal?", function()
								draft_store.discard()
								back_to_menu()
							end)
						end,
					},
				}
			},
		}
	},
	} }
  end,
})
