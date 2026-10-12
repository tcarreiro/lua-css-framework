local function row(title, input)
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
						Label{ text = title, class = "settings-label"},
					}
				},
				input,
				Div{id = "separator", flex_grow = 5}
			}
	}
end

UI.defineComponent("SettingsScreen", {
  events = { "navigate" },
  render = function(p)
	local settings_store = UI.store("settings")
	local draft_store = settings_store.draft()        -- cópia local, editada pelos inputs
	
	-- true enquanto o rascunho for igual ao aplicado; APPLY e SAVE acompanham
	local not_dirty = UI.bind(draft_store, function() return not draft_store.dirty() end)
	
	local function back_to_menu()
	  if p.on_navigate then p.on_navigate("main_menu") end
	end

	local function confirm(message, action)
	  UI.mount(ConfirmDialog{ message = message, on_confirm = action })
	end

	local function get_prop(store, prop)
		local val = store.get_at(prop)
		if val == nil then
			val = 0
		end
		return val
	end

	return Body{ children = {
	  Div{ class = "screen settings-screen", flex_grow = 1, gap = 16,
		children = {
			Label{ id = "section_name", text = "SETTINGS", class = "settings-title" },
			
			Label{
				id = "applied_config", 
				class = "settings-hint",
				text = UI.bind(settings_store, function()
					return "Aplicado: " .. get_prop(settings_store, "resolution")
					  .. " | vsync " .. get_prop(settings_store, "vsync")
					  .. " | volume " .. get_prop(settings_store, "volume")
				  end),
			},
			
			Label{
				id = "draft_config", 
				class = "settings-hint",
				text = UI.bind(draft_store, function()
					return "Rascunho: " .. get_prop(draft_store, "resolution")
					  .. " | vsync " .. get_prop(draft_store, "vsync")
					  .. " | volume " .. get_prop(draft_store, "volume")
				  end),
			},

			row("Resolução", Input{
				class = "settings-input", width = 300,
				value = draft_store.get_at("resolution"),
				on_changed = function(v) draft_store.set_at("resolution", v) end,
			}),
			
			row("VSync (0 ou 1)", Input{
				class = "settings-input", width = 300, type = "number",
				value = draft_store.get_at("vsync"),
				on_changed = function(v)
					draft_store.set_at("vsync", v)
				end,
			}),
			
			row("Volume (0 a 100)", Input{
				class = "settings-input", width = 300, type = "number",
				value = draft_store.get_at("volume"),
				on_changed = function(v)
					draft_store.set_at("volume", v)
				end,
			}),

			Div{id = "separator_1",  flex_grow = 1 },
			Div{ id = "actions", display = "flex", gap = 12,
				children = {
					Div{ flex_grow = 1 },   -- empurra os botões para a direita
					Button{
						label = "APPLY", class = "menu-button", disabled = not_dirty,
						on_pressed = function() draft_store.commit() end,
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
						label = "CANCEL", class = "menu-button",
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
