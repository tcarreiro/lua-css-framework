local function injectionSafeGuard(state)
	if state["name"] == nil then state["name"] = "" end
	if state["slider"] == nil then state["slider"] = 50 end
	if state["checkbox"] == nil then state["checkbox"] = true end
	if state["radiogroup"] == nil then state["radiogroup"] = "small" end
	if state["textedit"] == nil then state["textedit"] = "" end
	if state["color"] == nil then state["color"] = "#3399ff" end
	return state
end

function onOpenWindow(state)
	state = injectionSafeGuard(state)

	local function onCloseWindow()
		Host.emit("window_closed", state)
		UI.close_current()
	end

	return {
		size = {420, 520},
		padding = {10, 10, 10, 10},
		modal = true, -- Só funciona se position.mode = center
		panel = true,
		style = "texture",  -- TESTE: classe "texture" do Panel.tgdss como fundo da janela inteira
		--style_vars = { bg_color = "res://demo/assets/images/icon.png" },
		--style = "color",  -- TESTE: classe "color" do Panel.tgdss, fundo sólido no header
		--style_vars = { bg_color = "#FF0000" },
		position = {
			--mode = "center",
			mode = "relative",
			placement = "below_left", -- só tem efeito se position.mode = "relative"
			offset = {0, 5}
		},
		children = {
			{
				type = "section",
				direction = "vertical",
				size_mode = "fixed",
				height = 23,
				panel = true,
				style = "color",  -- TESTE: classe "color" do Panel.tgdss, fundo sólido no header
				style_vars = { bg_color = "TRANSPARENT" },
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
								style = "primary",
								style_vars = { bg_color = "#2a2a35" },
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
								style = "primary",
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
								style = "primary",
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
								option_style = "primary",  -- aplica a mesma classe a todas as opções
								options = {
									{value = "small", text = "Pequeno"},
									{value = "medium", text = "Médio", style = "secondary"},
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
									print("textedit updated: "  .. new_text)
								end
							},
							--{
								--type = "tabbar",
								--style = "primary",
								--on_tab_changed = function(index)
									--print("[tabbar] on_tab_changed: " .. tostring(index))
								--end,
								--tabs = { -- having trouble when more than one tab is available
									----{
										----title = "Aba 1",
										----content = {
											----type = "section",
											----children = {
												----{type = "label", text = "Conteúdo da Aba 1"}
											----}
										----}
									----},
									--{
										--title = "Aba 2",
										--content = {
											--type = "section",
											--children = {
												--{type = "label", text = "Conteúdo da Aba 2"}
											--}
										--}
									--}
								--}
							--},
							{
								type = "colorpicker_button",
								height = 40,
								style = "primary",
								value = state.color,
								on_value_changed = function(color)
									state.color = color
									Host.emit("state_changed", state)
								end
							},
							--{
								--type = "colorpicker",
								--value = state.color,
								--style = "primary",
								--hex_visible = false,
								--sliders_visible = false,
								--presets_visible = false,
								--on_value_changed = function(c)
									--state.color = color
									--Host.emit("state_changed", state)
								--end
							--},
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
			--{
				--type = "section",
				--direction = "horizontal",
				--size_mode = "fixed",
				--height = 40,
				--align = "end",
				--gap = 8,
				--children = {
					--{ type = "button", text = "OK", on_click = save_and_close, width = 80 },
					--{ type = "button", text = "Cancelar", on_click = close_without_saving, width = 80 },
				--}
			--},
			{
				type = "section",
				direction = "horizontal",
				--size_mode = "fit",
				align = "center",
				gap = 8,
				children = {
					{
						type = "button",
						style = "primary",
						size_mode = "fill",
						icon = "res://demo/assets/images/icon.png",
						text = "Fechar",
						animation = { hover = "soft_pulse", click = "press_bounce" },
						sound = { hover = "ui_hover", click = "ui_click" },
						on_click = onCloseWindow
					}
				}
			}
		}
	}
end
