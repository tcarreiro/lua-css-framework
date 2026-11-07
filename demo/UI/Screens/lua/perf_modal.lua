-- Teste de carga: Modal (ref "perf_modal") com um RepeatGrid dentro de um Scroll de altura fixa.
-- Abrir/fechar (toggle pelo ref):  UI.mount(PerfModal{ ref = "perf_modal" })
--   count   = nº de itens (padrão 100)
--   columns = colunas do grid (padrão 6)
--   sync    = true desliga o async do RepeatGrid (para comparar com a construção síncrona)
--
-- Árvore:
--   Modal -> Div -> Label + Scroll(height fixa) -> RepeatGrid (async, hook render_loading) + Button
--
-- Árvore de cada item (5 LuaComponents por item):
--   PerfItemSlot -> Stack
--                    |- PerfFrame -> Stack -> Sprite + Label
--                    '- Button

local ICON = "res://demo/assets/images/logo.png"
local RARITIES = { "common", "uncommon", "rare", "epic" }
local SCROLL_HEIGHT = 420
local GRID_GAP = 6
local GRID_WIDTH = 480      -- largura do grid pronto (ver "Como achar o valor" abaixo)
local SCROLLBAR_WIDTH = 16

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

-- ItemSlot: Stack com o Frame e um Button por cima
UI.defineComponent("PerfItemSlot", {
	props = { title = "string", count = "int", rarity = "string", icon = "string" },
	events = { "select" },
	render = function(p)
		return Stack{
			class = "perf-slot",
			children = {
				PerfFrame{ icon = p.icon, label = p.title, rarity = p.rarity },
				Button{
					class = "perf-slot-btn",
					label = "x" .. p.count,
					on_pressed = function()
						if p.on_select then p.on_select(p.title) end
					end,
				},
			},
		}
	end,
})

-- Modal: o ref passa do elemento PerfModal para o Modal renderizado (ver ComponentRegistry._instantiate_lua)
UI.defineComponent("PerfModal", {
	props = { count = "int", columns = "int", sync = "bool" },
	render = function(p)
		local n = p.count > 0 and p.count or 100
		local cols = p.columns > 0 and p.columns or 6
		return Modal{
			blocking = true,
			class = "perf-modal",
			slots = {
				content = {
					Div{
						class = "dialog perf-modal-body",
						gap = 12,
						children = {
							Label{ class = "settings-title", text = "Perf: " .. n .. " itens" },
							-- altura fixa: o modal não muda de tamanho quando o grid termina de carregar
							Scroll{
								width = GRID_WIDTH + SCROLLBAR_WIDTH,
								height = SCROLL_HEIGHT,
								direction = "vertical",
								children = {
									RepeatGrid{
										async = not p.sync,
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
