package template_scene

import "core:fmt"
import rl "vendor:raylib"

import cl "../../core_loop"

create :: proc() -> ^Game {

	scene := new(Game)
	cl.scene_set_default_inteface(cast(^cl.Scene)scene)

	scene.init = scene_init
	scene.close = scene_close
	scene.on_enter = scene_on_enter
	scene.input = scene_input
	scene.update = scene_update
	scene.output = scene_output
	scene.each_second = scene_each_second

	return scene
}

Game :: struct {
	using scene:  cl.Scene,
	loop:         ^cl.Loop_Data,
	should_close: bool,
	is_fps_draw:  bool,
}

@(private)
scene_init :: proc(scene: ^cl.Scene, loop: ^cl.Loop_Data) -> bool {
	game := cast(^Game)scene
	game.loop = loop

	return true
}
@(private)
scene_close :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene

}
@(private)
scene_on_enter :: proc(scene: ^cl.Scene) {}


@(private)
scene_input :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene
	if rl.IsKeyPressed(.F1) {
		game.is_fps_draw = !game.is_fps_draw
	}

}


@(private)
scene_update :: proc(scene: ^cl.Scene) -> bool {
	game := cast(^Game)scene

	return true
}

@(private)
scene_output :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene

	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	if (game.is_fps_draw) {
		rl.DrawText(rl.TextFormat("FPS: %i", game.loop.stat_fps), 10, 10, 20, rl.GREEN)
	}
	rl.EndDrawing()
}
@(private)
scene_each_second :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene

	fmt.printfln(
		"update  %0.3f ms\nrender  %0.3f ms\nloop    %0.3f ms\n",
		game.loop.stat_update_average_time,
		game.loop.stat_render_average_time,
		game.loop.stat_loop_average_time,
	)

}
