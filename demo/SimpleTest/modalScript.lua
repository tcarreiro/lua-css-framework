local state

local function injectionSafeGuard(state)
	if state["name"] == nil then
		state["name"] = ""
	end
	if state["slider"] == nil then
		state["slider"] = 50
	end
	if state["checkbox"] == nil then
		state["checkbox"] = true
	end
	if state["radiogroup"] == nil then
		state["radiogroup"] = "small"
	end
	if state["textedit"] == nil then
		state["textedit"] = ""
	end
	if state["color"] == nil then
		state["color"] = "#3399ff"
	end
	return state
end

local function onCloseWindow()
	Host.emit("window_closed", state)
	UI.close_current()
end

function onOpenWindow(state)
	state = injectionSafeGuard(state)
	return {
		theme = "default",
		size = {420, 520},
		padding = {10, 10, 10, 10},
		modal = false,
		position = {
			mode = "relative",
			placement = "below_left",
			offset = {0, 4}
		},
		children = {
			{
				type = "section",
				direction = "vertical",
				size_mode = "fixed",
				height = 40,
				children = {
					{type = "label", text = "Teste de Componentes"}
				}
			},
			{
				type = "section",
				direction = "vertical",
				size_mode = "fill",
				gap = 8,
				children = {
					{
						type = "scroll",
						children = {
							{
								type = "input",
								id = "nome_input",
								placeholder = "Digite seu nome",
								value = state.name,
								on_value_changed = function(new_text)
									state.name = new_text
									Host.emit("state_changed", state)
								end,
								on_submit = function(text)
									onCloseWindow()
								end
							},
							{
								type = "slider",
								min = 0,
								max = 100,
								step = 1,
								value = state.slider,
								on_value_changed = function(value)
									state.slider = value
									Host.emit("state_changed", state)
								end
							},
							{
								type = "checkbox",
								theme = "alternate",
								text = "Aceito os termos",
								checked = state.checkbox,
								on_toggled = function(pressed)
									state.checkbox = pressed
									Host.emit("state_changed", state)
								end
							},
							{
								type = "radio_group",
								direction = "vertical",
								options = {
									{value = "small", text = "Pequeno"},
									{value = "medium", text = "Médio"},
									{value = "large", text = "Grande"}
								},
								value = state.radiogroup,
								on_change = function(value)
									state.radiogroup = value
									Host.emit("state_changed", state)
								end
							},
							{
								type = "textedit",
								height = 120,
								value = state.textedit,
								props = {
									editable = true,
									context_menu_enabled = true,
									emoji_menu_enabled = false,
									shortcut_keys_enabled = true
								},
								on_value_changed = function(new_text)
									state.textedit = new_text
									Host.emit("state_changed", state)
								end
							},
							{
								type = "tabbar",
								on_tab_changed = function(index)
									print("[tabbar] on_tab_changed: " .. tostring(index))
								end,
								tabs = {
									{
										title = "Aba 1",
										content = {
											type = "section",
											children = {
												{type = "label", text = "Conteúdo da Aba 1"}
											}
										}
									},
									{
										title = "Aba 2",
										content = {
											type = "section",
											children = {
												{type = "label", text = "Conteúdo da Aba 2"}
											}
										}
									}
								}
							},
							{
								type = "colorpicker",
								height = 40,
								value = state.color,
								on_value_changed = function(color)
									state.color = color
									Host.emit("state_changed", state)
								end
							},
							{
								type = "sprite", 
								texture = "res://demo/assets/images/icon.png",
								hframes = 2, 
								vframes = 2, 
								fps = 1, 
								width = 32, 
								height = 32
							}
						}
					}
				}
			},
			{
				type = "section",
				direction = "vertical",
				size_mode = "fit",
				children = {
					{
						type = "button",
						icon = "res://demo/assets/images/icon.png",
						icon_position = "center",
						vertical_icon_position = "top",
						text_position = "center",
						text = "Fechar",
						theme_overrides = {
							colors = {
								font_color = "#ffffff",
								font_hover_color = "#ffcc00AA",
							},
							constants = {
								outline_size = 3,
								icon_max_width = 40,
							},
							font_sizes = {
								font_size = 20,
							}
						},
						animation = { hover = "soft_pulse", click = "press_bounce" },
						sound = { hover = "ui_hover", click = "ui_click" },
						on_click = onCloseWindow
					}
				}
			}
		}
	}
end
