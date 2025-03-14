package click_scene

import "core:fmt"
import rl "vendor:raylib"

import sn "../"
import cl "../../core_loop"
import "../entry_scene"


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
	using scene:         cl.Scene,
	loop:                ^cl.Loop_Data,
	should_close:        bool,
	close_counter:       i32,
	is_fps_draw:         bool,
	target:              rl.RenderTexture2D,
}

Entity :: struct {
	x:       f32,
	y:       f32,
	color:   rl.Color,
	counter: i32,
}


@(private)
scene_init :: proc(scene: ^cl.Scene, loop: ^cl.Loop_Data) -> bool {
	game := cast(^Game)scene
	game.loop = loop

	game.target = rl.LoadRenderTexture(rl.GetScreenWidth(), rl.GetScreenHeight())
	game.close_counter = cast(i32)game.loop.max_ups

	return true
}
@(private)
scene_close :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene

	rl.UnloadRenderTexture(game.target)
	
}
@(private)
scene_on_enter :: proc(scene: ^cl.Scene) {
}


@(private)
scene_input :: proc(scene: ^cl.Scene) {
}


@(private)
scene_update :: proc(scene: ^cl.Scene, dt: f32) -> bool {
	game := cast(^Game)scene

	if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) &&
		   rl.CheckCollisionPointRec(rl.GetMousePosition(), {350, 290, 100, 20}) ||
	   rl.IsKeyPressed(.SPACE) {
		game.should_close = true
	}


	if game.close_counter <= 0 {
		scene->close()
		cl.scene_manager_remove(game.loop.scene_manager, cast(u16)sn.Scene_Name.BOOT)

		entry := entry_scene.create()
		entry->init(game.loop)

		cl.scene_manager_insert(game.loop.scene_manager, entry, cast(u16)sn.Scene_Name.ENTRY)
		cl.scene_manager_next(game.loop.scene_manager, cast(u16)sn.Scene_Name.ENTRY)
		cl.scene_manager_change(game.loop.scene_manager)
	}

	return true
}

@(private)
scene_output :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene

	width := cast(f32)rl.GetScreenWidth()
	height := cast(f32)rl.GetScreenHeight()

	if game.should_close {
		rl.BeginTextureMode(game.target)
		rl.DrawRectangle(0, 0, cast(i32)width, cast(i32)height, rl.Color{0, 0, 0, 4})
		rl.EndTextureMode()
		game.close_counter -= 1
	}


	rl.BeginDrawing()
	rl.ClearBackground(rl.Color{16, 16, 16, 255})

	rl.DrawTextureRec(game.target.texture, {0, 0, width, -height}, {0, 0}, rl.WHITE)

	if (game.is_fps_draw) {
		rl.DrawText(rl.TextFormat("FPS: %i", game.loop.stat_fps), 10, 10, 20, rl.GREEN)
	}

	text: cstring = "CLICK TO BOOT"
	text_size := rl.MeasureText(text,20)
	text_x := rl.GetScreenWidth()/2 - text_size/2

	if !game.should_close {
		rl.DrawText(text, text_x, 292, 20, rl.Color{16, 16, 16, 255})
		rl.DrawText(text, text_x, 290, 20, rl.PINK)
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
