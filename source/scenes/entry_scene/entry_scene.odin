package entry_scene

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
	using scene:    cl.Scene,
	loop:           ^cl.Loop_Data,
	should_close:   bool,
	close_counter:  i32,
	is_fps_draw:    bool,
	text_str:       cstring,
	text_x:         f32,
	text_y:         f32,
	is_show_button: bool,
	target:         rl.RenderTexture2D,
	entities:       [dynamic]Entity,
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

	game.is_fps_draw = true

	// text 
	game.text_str = "yOuR path"
	text_size := rl.MeasureTextEx(rl.GetFontDefault(), game.text_str, 40, 2)
	game.text_x = cast(f32)rl.GetScreenWidth() / 2 - text_size.x / 2
	game.text_y = 0 - text_size.y

	game.target = rl.LoadRenderTexture(rl.GetScreenWidth(), rl.GetScreenHeight())


	screen_width := rl.GetScreenWidth()
	screen_height := rl.GetScreenHeight()

	for it in 0 ..< 1000 {
		append(
			&game.entities,
			Entity {
				cast(f32)rl.GetRandomValue(0, rl.GetScreenWidth()),
				cast(f32)(rl.GetScreenHeight() + rl.GetRandomValue(32, screen_height * 2)),
				rl.Color {
					cast(u8)rl.GetRandomValue(128, 255),
					cast(u8)rl.GetRandomValue(128, 255),
					cast(u8)rl.GetRandomValue(128, 255),
					255,
				},
				rl.GetRandomValue(cast(i32)game.loop.max_ups, cast(i32)game.loop.max_ups * 13),
			},
		)
	}

	game.close_counter = cast(i32)game.loop.max_ups

	return true
}
@(private)
scene_close :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene

	delete(game.entities)
	rl.UnloadRenderTexture(game.target)
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

	if game.text_y < cast(f32)rl.GetScreenHeight() / 3 {
		game.text_y += 60 / cast(f32)game.loop.max_ups
	} else {
		game.is_show_button = true
		if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) &&
		   rl.CheckCollisionPointRec(rl.GetMousePosition(), {350, 290, 100, 20}) {
			game.should_close = true
		}

	}
	v: rl.Vector2
	speed: f32 = 120 / cast(f32)game.loop.max_ups
	for &it in game.entities {
		if it.y < -64 || it.counter == 0 {
			it.color.a = 255
			it.y = cast(f32)(rl.GetScreenHeight() + rl.GetRandomValue(32, 600 * 2))
			it.counter = rl.GetRandomValue(
				cast(i32)game.loop.max_ups,
				cast(i32)game.loop.max_ups * 13,
			)
		}
		if it.counter > 0 {
			it.counter -= 1
		}

		v.x = cast(f32)rl.GetRandomValue(-6, 6)
		v.y = -1

		if it.x > 300 && it.x <= 400 && it.y < 450 {
			v.x = cast(f32)rl.GetRandomValue(-6, 2)
		} else if it.x >= 400 && it.x < 500 && it.y < 450 {
			v.x = cast(f32)rl.GetRandomValue(-2, 6)
		}


		v = rl.Vector2Normalize(v)
		it.x += v.x * speed
		it.y += v.y * speed

		// if it.y < 300 {
		//     if it.color.a >= 4 {
		//         it.color.a -= cast(u8)rl.GetRandomValue(0,4)
		//     }
		// }
	}

	if game.close_counter <= 0 {
		scene->close()
		cl.scene_manager_back_to_boot(game.loop.scene_manager)
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
		rl.DrawRectangle(0, 0, cast(i32)width, cast(i32)height, rl.Color{0, 0, 0, 2})
		rl.EndTextureMode()
		game.close_counter -= 1
	} else {

		rl.BeginTextureMode(game.target)

		// rl.DrawRectangleGradientV(0,0,800,400,rl.Color{0,0,0,16},rl.Color{0,0,0,0})

		for it in game.entities {
			if it.y > -32 && it.y < 800 + 32 && it.counter > 0 {
				rl.DrawRectangle(cast(i32)it.x, cast(i32)it.y, 2, 2, it.color)
			}
		}
		rl.EndTextureMode()
	}


	rl.BeginDrawing()
	rl.ClearBackground(rl.Color{16, 16, 16, 255})

	rl.DrawTextureRec(game.target.texture, {0, 0, width, -height}, {0, 0}, rl.WHITE)

	border_width := (width / 2 - (game.text_x - 32)) * 2
	border_height := (height / 2 - (game.text_y - 16)) + 32

	// rl.DrawRectangleRounded(
	// 	{game.text_x - 32, game.text_y - 16, border_width, border_height},
	// 	0.5,8,rl.Color{16, 16, 16, 220},
	// )

	rl.DrawText(game.text_str, cast(i32)game.text_x - 6, cast(i32)game.text_y + 2, 40, rl.BLACK)
	rl.DrawText(game.text_str, cast(i32)game.text_x - 8, cast(i32)game.text_y, 40, rl.PINK)
	if (game.is_fps_draw) {
		rl.DrawText(rl.TextFormat("FPS: %i", game.loop.stat_fps), 10, 10, 20, rl.GREEN)
	}

	if game.is_show_button {
		rl.DrawText("PLAY", 382, 292, 20, rl.BLACK)
		rl.DrawText("PLAY", 380, 290, 20, rl.PINK)
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
