-- OK fecha o modal e executa a ação; CANCEL só fecha.
UI.defineComponent("ConfirmDialog", { -- defineComponent cria e registra um componente
  props = { message = "string" },
  events = { "confirm", "cancel" },
  render = function(p)
	local function finish(handler)
	  return function()
		UI.callMethod("confirm_dialog", "close")
		if handler then handler() end
	  end
	end

	return Modal{
	  ref = "confirm_dialog",
	  blocking = true,
	  backdrop_color = "#000000AA",
	  slots = { content = Div{ class = "dialog", gap = 16, children = {
		Label{ text = p.message, class = "dialog-message" },
		Div{ display = "flex", gap = 12, children = {
		  Div{ flex_grow = 1 }, -- espaçamento
		  Button{ label = "OK", class = "menu-button", on_pressed = finish(p.on_confirm) },
		  Button{ label = "CANCEL", class = "menu-button", on_pressed = finish(p.on_cancel) },
		} },
	  } } },
	}
  end,
})
