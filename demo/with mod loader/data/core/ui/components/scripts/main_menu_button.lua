UI.registerComponent("mainMenuButton", {
	class = "main-menu-button",
}, {
	render = function(props)
		return Button{
			id = props.id,
			class = props.class,
			label = props.label,
			on_pressed = props.on_pressed,
			on_mouse_entered = props.on_mouse_entered,
			on_mouse_exited = props.on_mouse_exited,
		}
	end
})
