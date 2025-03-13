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
	using scene:         cl.Scene,
	loop:                ^cl.Loop_Data,
	should_close:        bool,
	close_counter:       i32,
	is_fps_draw:         bool,
	text_str:            cstring,
	text_x:              f32,
	text_y:              f32,
	show_button_coutner: u32,
	is_show_button:      bool,
	target:              rl.RenderTexture2D,
	entities:            [dynamic]Entity,
	music:               rl.Music,
	music_texture:       rl.Texture2D,
	is_music_off:        bool,
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

	// text 
	game.text_str = "throughTheSky"
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

	game.music = rl.LoadMusicStream("assets/odin_game_jam_music_intro.mp3")
	game.music_texture = rl.LoadTexture("assets/music_note.png")

	return true
}
@(private)
scene_close :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene

	delete(game.entities)
	rl.UnloadMusicStream(game.music)
	rl.UnloadRenderTexture(game.target)
	rl.UnloadTexture(game.music_texture)
}
@(private)
scene_on_enter :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene

	rl.SetMusicVolume(game.music, 0.5)
	rl.PlayMusicStream(game.music)


}


@(private)
scene_input :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene
	if rl.IsKeyPressed(.F1) {
		game.is_fps_draw = !game.is_fps_draw
	}

	if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) && rl.CheckCollisionPointRec(rl.GetMousePosition(),{cast(f32)rl.GetScreenWidth()-64,32,16,16})
	{
		game.is_music_off = !game.is_music_off
	}

}


@(private)
scene_update :: proc(scene: ^cl.Scene, dt: f32) -> bool {
	game := cast(^Game)scene

	if rl.IsMusicReady(game.music) == false {return true}

	if rl.GetMusicTimePlayed(game.music) / rl.GetMusicTimeLength(game.music) >= 0.9 {

		rl.StopMusicStream(game.music)

	}

	rl.UpdateMusicStream(game.music)
	
	
	if game.is_music_off {
		rl.SetMusicVolume(game.music,0)
	} else {
		rl.SetMusicVolume(game.music,0.5)
	}

	if game.should_close {
		game.text_y -= 30 * dt
	} else if game.text_y < cast(f32)rl.GetScreenHeight() / 3 {
		game.text_y += 30 * dt
	} else {
		game.show_button_coutner += 1

		if game.show_button_coutner > cast(u32)(1 / dt) {

			game.is_show_button = true
			if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) &&
				   rl.CheckCollisionPointRec(rl.GetMousePosition(), {350, 290, 100, 20}) ||
			   rl.IsKeyPressed(.SPACE) {
				game.should_close = true
			}
		}
	}

	v: rl.Vector2
	speed: f32 = 120 / cast(f32)game.loop.max_ups

	for &it in game.entities {

		if it.counter > 0 {
			it.counter -= 1
		}

		if it.y < -64 || it.counter == 0 {
			it.color.a = 255
			it.y = cast(f32)(rl.GetScreenHeight() + rl.GetRandomValue(32, 600 * 2))
			it.counter = rl.GetRandomValue(
				cast(i32)game.loop.max_ups,
				cast(i32)game.loop.max_ups * 13,
			)
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
	}

	if game.close_counter <= 0 {
		scene->close()
		cl.scene_manager_next(game.loop.scene_manager, 0)
		cl.scene_manager_change(game.loop.scene_manager)
	}

	return true
}

@(private)
scene_output :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene

	rl.UpdateMusicStream(game.music)

	width := cast(f32)rl.GetScreenWidth()
	height := cast(f32)rl.GetScreenHeight()

	if game.should_close {
		rl.BeginTextureMode(game.target)
		rl.DrawRectangle(0, 0, cast(i32)width, cast(i32)height, rl.Color{0, 0, 0, 4})
		rl.EndTextureMode()
		game.close_counter -= 1
	} else {

		rl.BeginTextureMode(game.target)

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

	rl.DrawText(
		game.text_str,
		cast(i32)game.text_x - 6,
		cast(i32)game.text_y + 2,
		40,
		rl.Color{16, 16, 16, 255},
	)
	rl.DrawText(game.text_str, cast(i32)game.text_x - 8, cast(i32)game.text_y, 40, rl.PINK)
	if (game.is_fps_draw) {
		rl.DrawText(rl.TextFormat("FPS: %i", game.loop.stat_fps), 10, 10, 20, rl.GREEN)
	}

	if game.is_show_button && !game.should_close {
		rl.DrawText("PLAY", 382, 292, 20, rl.Color{16, 16, 16, 255})
		rl.DrawText("PLAY", 380, 290, 20, rl.PINK)
	}

	music_color := rl.PINK 
	if game.is_music_off {
		music_color = rl.GRAY
	}
	rl.DrawTexture(game.music_texture, cast(i32)width - 64, 32, music_color)

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
