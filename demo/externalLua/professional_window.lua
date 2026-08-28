local function onCloseWindow(save)
	if save then
		Host.emit("state_saved", { -- placeholder, o state real fica em escopo de onOpenWindow
		})
	end
	Host.emit("window_closed", {})
	UI.close_current()
end

-- Monta uma linha da "grade" de edição de personagem: seta esquerda,
-- imagem central, seta direita.
local function build_char_row(texture_path)
	return {
		type = "section",
		direction = "horizontal",
		gap = 4,
		children = {
			{
				type = "button",
				icon = "res://demo/externalLua/left_arrow.png",
				theme_overrides = { constants = { icon_max_width = 16 }, colors = { icon_hover_color = -2.5 } },
			},
			{
				type = "sprite",
				texture = texture_path,
				hframes = 1,
				vframes = 1,
				fps = 0,
				width = 64,
				height = 64,
			},
			{
				type = "button",
				icon = "res://demo/externalLua/right_arrow.png",
				theme_overrides = { constants = { icon_max_width = 16 }, colors = { icon_hover_color = -2.5 } },
			},
		}
	}
end

function onOpenWindow(state)
	local function save_and_close()
		Host.emit("state_saved", state)
		Host.emit("window_closed", {})
		UI.close_current()
	end

	local function close_without_saving()
		Host.emit("window_closed", {})
		UI.close_current()
	end

	return {
		theme = "alternate",
		background_texture = "res://demo/externalLua/background.png",
		size = {600, 500},
		modal = false,
		position = { mode = "center" },
		children = {

			-- Header
			{
				type = "section",
				direction = "horizontal",
				size_mode = "fixed",
				padding = {5, 0, 0, 0},
				height = 23,
				children = {
					{
						type = "label",
						text = state.title,
						size_mode = "fill",
						ratio = 1,
					},
					{
						type = "button",
						size_mode = "fit",
						icon = "res://demo/externalLua/close.png",
						on_click = close_without_saving,
						theme_overrides = { constants = { icon_max_width = 23 }, colors = { icon_hover_color = -2.5 } },
					}
				}
			},

			-- Resto: padding 5, contém conteúdo principal + rodapé
			{
				type = "section",
				direction = "vertical",
				size_mode = "fill",
				padding = 10,
				gap = 8,
				children = {

					-- Conteúdo principal
					{
						type = "scroll",
						children = {
							{
								type = "section",
								direction = "vertical",
								size_mode = "fill",
								ratio = 1,
								gap = 8,
								children = {

									-- Metade de cima: edição de personagem + dados
									{
										type = "section",
										direction = "horizontal",
										size_mode = "fill",
										ratio = 1,
										gap = 8,
										children = {

											-- Esquerda: edição visual do personagem
											{
												type = "section",
												direction = "vertical",
												panel = true,
												style = "char_edit_bg",
												size_mode = "fit",
												padding = 8,
												gap = 4,
												children = {
													build_char_row(state.textures.head),
													build_char_row(state.textures.torso),
													build_char_row(state.textures.legs),
												}
											},

											-- Direita: nome, sobrenome, sexo
											{
												type = "section",
												direction = "vertical",
												size_mode = "fill",
												ratio = 1,
												gap = 6,
												padding = {0, 0, 10, 0},
												children = {
													{
														type = "section",
														direction = "horizontal",
														gap = 6,
														children = {
															{ type = "label", text = "Nome", width = 150 },
															{
																type = "input",
																id = "first_name_input",
																value = state.first_name,
																placeholder = "Digite seu nome",
																size_mode = "fill",
																ratio = 1,
																on_value_changed = function(v)
																	state.first_name = v
																end
															}
														}
													},
													{
														type = "section",
														direction = "horizontal",
														gap = 6,
														children = {
															{ type = "label", text = "Sobrenome", width = 150 },
															{
																type = "input",
																id = "last_name_input",
																value = state.last_name,
																placeholder = "Digite seu sobrenome",
																size_mode = "fill",
																ratio = 1,
																on_value_changed = function(v)
																	state.last_name = v
																end
															}
														}
													},
													{
														type = "section",
														direction = "horizontal",
														gap = 6,
														children = {
															{ type = "label", text = "Sexo", width = 150 },
															{
																type = "radio_group",
																direction = "horizontal",
																value = state.gender,
																options = {
																	{ value = "m", text = "M ", width = 50, padding = 5 },
																	{ value = "f", text = "F ", width = 50 },
																},
																on_change = function(v)
																	state.gender = v
																end
															}
														}
													},
												}
											}
										}
									},

									-- Metade de baixo: abas genéricas
									{
										type = "tabbar",
										size_mode = "fill",
										ratio = 1,
										tabs = {
											{ title = "Aba 1", content = { type = "section", children = { { type = "label", text = "Conteúdo 1" } } } },
											{ title = "Aba 2", content = { type = "section", children = { { type = "label", text = "Conteúdo 2" } } } },
											{ title = "Aba 3", content = { type = "section", children = { { type = "label", text = "Conteúdo 3" } } } },
										}
									}
								}
							}
						}
					},

					-- Rodapé: OK / Cancelar, alinhados à direita
					{
						type = "section",
						direction = "horizontal",
						size_mode = "fixed",
						height = 40,
						align = "end",
						gap = 8,
						children = {
							{ type = "button", text = "OK", on_click = save_and_close, width = 80 },
							{ type = "button", text = "Cancelar", on_click = close_without_saving, width = 80 },
						}
					}
				}
			}
		}
	}
end
