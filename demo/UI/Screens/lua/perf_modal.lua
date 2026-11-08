-- Teste de carga: Modal (ref "perf_modal") com um RepeatGrid dentro de um Scroll de altura e largura fixas.
-- Abrir/fechar (toggle pelo ref):  UI.mount(PerfModal{ ref = "perf_modal" })
--   count   = nº de itens (padrão 100)
--   columns = colunas do grid (padrão 6)
--   sync    = true desliga o async do RepeatGrid (para comparar com a construção síncrona)
--
-- Drag & drop: todo slot é origem (o slot fica onde está e um fantasma segue o mouse) e alvo (aceita qualquer
-- outro slot). O slot sob o fantasma ganha a classe automática "drop-ok" (borda amarela, ver perf_modal.lcss);
-- ao soltar não acontece nada.
--
-- Árvore:
--   Modal -> Div -> Label + Scroll -> RepeatGrid (async, hook render_loading) + Button
--
-- Árvore de cada item (5 LuaComponents por item):
--   PerfItemSlot -> Stack
--                    |- PerfFrame -> Stack -> Sprite + Label
--                    '- Button transparente por cima: desenha a borda e recebe o mouse / o arraste

local ICON = "res://demo/assets/images/logo.png"
local RARITIES = { "common", "uncommon", "rare", "epic" }
local SLOT_SIZE = 80        -- lado fixo do slot: o grid fica previsível e a largura do Scroll se calcula
local GRID_GAP = 6
local SCROLL_HEIGHT = 420
local SCROLLBAR_WIDTH = 16  -- reserva para a barra vertical
local LOADING_UNTIL = 24    -- loading até os 24 primeiros; depois aparecem em grupos de 12 (-1 = até o fim, 0 = sem loading)

local function make_items(n)
	local items = {}
	for i = 1, n do
		items[i] = {
			title = "Item " .. i,
			count = (i * 7) % 99 + 1,
			rarity = RARITIES[(i % #RARITIES) + 1],
		}
	end
	return items
end

-- Loading: mostrado pelo RepeatGrid enquanto a construção assíncrona não termina
UI.defineComponent("LoadingItems", {
	props = { text = "string" },
	render = function(p)
		return Label{
			class = "settings-hint",
			text = p.text ~= "" and p.text or "Carregando itens...",
		}
	end,
})

-- Frame: ícone + nome, empilhados
UI.defineComponent("PerfFrame", {
	props = { icon = "string", label = "string", rarity = "string" },
	render = function(p)
		return Stack{
			class = "perf-frame perf-" .. p.rarity,
			children = {
				Sprite{ texture = p.icon, width = 48, height = 48 },
				Label{ class = "perf-frame-label", text = p.label },
			},
		}
	end,
})

-- ItemSlot: Stack com o Frame e um Button transparente por cima.
-- O Button recebe os props de drag & drop (é ele quem fica sob o mouse) e, por isso, as classes
-- automáticas "dragging" (origem) e "drop-ok" (alvo sob o fantasma).
-- Cuidado: p é um Dictionary do Godot; nomes como size/keys/values/get/has/erase viram MÉTODOS.
UI.defineComponent("PerfItemSlot", {
	props = { title = "string", count = "int", rarity = "string", icon = "string", ghost = "bool" },
	events = { "select" },
	render = function(p)
		local button = {
			class = "perf-slot-btn",
			label = "x" .. p.count,
			width = SLOT_SIZE,
			height = SLOT_SIZE,
		}

		if not p.ghost then
			button.on_pressed = function()
				if p.on_select then p.on_select(p.title) end
			end

			-- origem: todo slot. O payload precisa ser uma tabela NÃO vazia para ligar o arraste.
			button.drag_type = "perf_slot"
			button.drag_payload = { title = p.title, rarity = p.rarity }
			button.on_drag_preview = function()
				return PerfItemSlot{ title = p.title, count = p.count, rarity = p.rarity, icon = p.icon, ghost = true }
			end

			-- alvo: todo slot aceita outro slot. Sem on_can_drop, o motor aceita qualquer payload do tipo certo.
			button.drop_accept = "perf_slot"
			button.on_drop = function(payload, mods)
				-- soltar não faz nada: o slot de origem continua onde estava
			end
		end

		local cell = {
			class = p.ghost and "perf-slot ghost" or "perf-slot",
			width = SLOT_SIZE,
			height = SLOT_SIZE,
			children = {
				PerfFrame{ icon = p.icon, label = p.title, rarity = p.rarity },
				Button(button),
			},
		}
		if p.ghost then cell.pointer_events = "none" end   -- o fantasma nunca intercepta o mouse
		return Stack(cell)
	end,
})

-- Modal: o ref passa do elemento PerfModal para o Modal renderizado (ver ComponentRegistry._instantiate_lua)
UI.defineComponent("PerfModal", {
	props = { count = "int", columns = "int", windowed = "bool", sync = "bool", margin = "any" },
	render = function(p)
		local n = p.count > 0 and p.count or 100
		local cols = p.columns > 0 and p.columns or 6
		local scroll_width = cols * SLOT_SIZE + (cols - 1) * GRID_GAP + SCROLLBAR_WIDTH
		return Modal{
			blocking = not p.windowed,
			class = "perf-modal",
			margin = p.margin,
			backdrop_color = p.windowed and "#00000000" or "#000000AA",
			slots = {
				content = {
					Div{
						class = "dialog perf-modal-body",
						gap = 12,
						children = {
							Label{ class = "settings-title", text = "Perf: " .. n .. " itens" },
							-- tamanho fixo: o modal não muda de tamanho quando o grid termina de carregar
							Scroll{
								width = scroll_width,
								height = SCROLL_HEIGHT,
								direction = "vertical",
								class = "pr-2",
								children = {
									RepeatGrid{
										async = not p.sync,
										loading_until = LOADING_UNTIL,
										columns = cols,
										gap = GRID_GAP,
										items = make_items(n),
										render_item = function(item, index)
											return PerfItemSlot{
												title = item.title,
												count = item.count,
												rarity = item.rarity,
												icon = ICON,
											}
										end,
										render_loading = function()
											return LoadingItems{ text = "Carregando itens..." }
										end,
									},
								},
							},
							Button{
								class = "menu-button",
								label = "CLOSE",
								on_pressed = function() UI.callMethod("perf_modal", "close") end,
							},
						},
					},
				},
			},
		}
	end,
})
