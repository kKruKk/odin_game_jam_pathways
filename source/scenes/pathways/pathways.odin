package pathways

import "core:fmt"
import rl "vendor:raylib"

import cl "../../core_loop"

import sn ".."
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
	using scene:        cl.Scene,
	loop:               ^cl.Loop_Data,
	should_close:       bool,
	is_fps_draw:        bool,
	player:             Player,
	worms:              [dynamic]Entity,
	worm_screen:        rl.RenderTexture2D,
	score_particles:    [dynamic]Score_Particle,
	obstacles:          [dynamic]Entity_Obstacle,
	target_main:        rl.RenderTexture2D,
	window_width:       i32,
	window_height:      i32,
	render_width:       i32,
	render_height:      i32,
	pixel_size:         i32,
	score:              i32,
	score_increase:     i32,
	score_text_mid_pos: rl.Vector2,
	music:              rl.Music,
	music_texture:      rl.Texture2D,
	is_music_off:       bool,
}


Player :: struct {
	dir:          rl.Vector2,
	pos:          rl.Vector2,
	color:        rl.Color,
	target:       [dynamic]rl.RenderTexture2D,
	target_pos_x: [dynamic]f32,
}

Entity :: struct {
	pos:   rl.Vector2,
	color: rl.Color,
}


@(private)
scene_init :: proc(scene: ^cl.Scene, loop: ^cl.Loop_Data) -> bool {
	game := cast(^Game)scene
	game.loop = loop
	game.is_fps_draw = true

	game.window_width = rl.GetScreenWidth()
	game.window_height = rl.GetScreenHeight()

	game.pixel_size = 2
	game.render_width = game.window_width / game.pixel_size
	game.render_height = game.window_height / game.pixel_size

	//if false
	{
		scene := entry_scene.create()
		scene->init(game.loop)
		cl.scene_manager_insert(game.loop.scene_manager, scene, cast(u16)sn.Scene_Name.ENTRY)
		cl.scene_manager_next(game.loop.scene_manager, cast(u16)sn.Scene_Name.ENTRY)
		cl.scene_manager_change(game.loop.scene_manager)

	}

	{
		game.player.pos = {cast(f32)game.render_width / 5, cast(f32)game.render_height / 2}
		game.player.color = {
			cast(u8)rl.GetRandomValue(186, 255),
			cast(u8)rl.GetRandomValue(186, 255),
			cast(u8)rl.GetRandomValue(186, 255),
			255,
		}
		game.player.color = rl.Color{16, 16, 16, 255}
	}


	append(&game.player.target, rl.LoadRenderTexture(game.render_width, game.render_height))
	append(&game.player.target, rl.LoadRenderTexture(game.render_width, game.render_height))
	append(&game.player.target, rl.LoadRenderTexture(game.render_width, game.render_height))
	append(&game.player.target_pos_x, 0)
	append(&game.player.target_pos_x, cast(f32)game.render_width / 2)
	append(&game.player.target_pos_x, cast(f32)game.render_width)


	// init paths and paths_screens 
	{

		e: Entity
		for it in 0 ..< 500 {
			e.pos = rl.Vector2 {
				cast(f32)rl.GetRandomValue(game.render_width, game.render_width * 3),
				cast(f32)rl.GetRandomValue(0, game.render_height),
			}
			e.color = rl.Color {
				cast(u8)rl.GetRandomValue(128, 255),
				cast(u8)rl.GetRandomValue(128, 255),
				cast(u8)rl.GetRandomValue(128, 255),
				255,
			}

			append(&game.worms, e)
		}

		game.worm_screen = rl.LoadRenderTexture(game.render_width, game.render_height)

	}

	{
		// obstacles
		e: Entity_Obstacle
		for it in 0 ..< 10 {
			e.rec.width = cast(f32)rl.GetRandomValue(16, 128)
			e.rec.height = cast(f32)rl.GetRandomValue(16, 128)
			e.rec.x = cast(f32)rl.GetRandomValue(game.render_width, game.render_width * 2)
			e.rec.y = cast(f32)rl.GetRandomValue(0 - cast(i32)e.rec.height, game.render_height)
			e.color = rl.Color {
				cast(u8)rl.GetRandomValue(32, 186),
				cast(u8)rl.GetRandomValue(32, 186),
				cast(u8)rl.GetRandomValue(32, 186),
				255,
			}

			append(&game.obstacles, e)
		}


	}

	game.target_main = rl.LoadRenderTexture(game.render_width, game.render_height)

	game.score_text_mid_pos = {cast(f32)game.render_width / 2, 10}


	game.music = rl.LoadMusicStream("assets/odin_game_jam_music.mp3")
	game.music_texture = rl.LoadTexture("assets/music_note.png")
	return true
}


@(private)
scene_close :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene

	for t in game.player.target {
		rl.UnloadRenderTexture(t)
	}
	delete(game.player.target)
	delete(game.worms)

	delete(game.obstacles)
	delete(game.score_particles)

	rl.UnloadRenderTexture(game.worm_screen)
	rl.UnloadRenderTexture(game.target_main)
	rl.UnloadMusicStream(game.music)
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


	game.player.dir = {0, 0}
	if rl.IsKeyDown(.W) {
		game.player.dir.y = -1
	}
	if rl.IsKeyDown(.S) {
		game.player.dir.y = 1
	}
	if rl.IsKeyDown(.A) {
		game.player.dir.x = -1
	}
	if rl.IsKeyDown(.D) {
		game.player.dir.x = 1
	}

	mouse := rl.GetMousePosition()
	if rl.CheckCollisionPointRec(mouse, {cast(f32)rl.GetScreenWidth() - 64, 32, 16, 16}) {
		if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
			game.is_music_off = !game.is_music_off
		}
	} else if rl.IsMouseButtonDown(rl.MouseButton.LEFT) {

		mouse /= cast(f32)game.pixel_size
		diff := mouse - game.player.pos

		if diff.x > 16 {
			game.player.dir.x = 1
		} else if diff.x < -16 {
			game.player.dir.x = -1
		}
		if diff.y > 16 {
			game.player.dir.y = 1
		} else if diff.y < -16 {
			game.player.dir.y = -1
		}


	}

}


@(private)
scene_update :: proc(scene: ^cl.Scene, dt: f32) -> bool {
	game := cast(^Game)scene

	rl.UpdateMusicStream(game.music)


	if game.is_music_off {
		rl.SetMusicVolume(game.music, 0)
	} else {
		rl.SetMusicVolume(game.music, 0.5)
	}

	speed: f32 = 100
	game.player.dir = rl.Vector2Normalize(game.player.dir)
	game.player.pos = game.player.pos + (game.player.dir * speed * dt)


	worm_update(game, dt)
	obstacle_update(game, dt)

	game.player.color = rl.Color{16, 16, 16, 255}
	#reverse for o in game.obstacles {
		if rl.CheckCollisionPointRec(game.player.pos, o.rec) {
			game.player.color.r = o.color.r + 64
			game.player.color.g = o.color.g + 64
			game.player.color.b = o.color.b + 64
			break
		}
	}

	update_score(game, dt)

	return true
}


draw_player_target :: proc(g: ^Game) {

	color: rl.Color = {16, 16, 16, 2}
	for t, index in g.player.target {

		rl.BeginTextureMode(t)

		rl.DrawRectangle(0, 0, g.render_width, g.render_height, color)
		pos := g.player.pos
		pos.x -= g.player.target_pos_x[index]

		rl.DrawPoly(pos, 3, 8, cast(f32)(rl.GetRandomValue(0, 360)), g.player.color)

		rl.EndTextureMode()

	}

	for &t, index in g.player.target {
		g.player.target_pos_x[index] -= g.player.pos.x / cast(f32)g.loop.max_ups
		if cast(i32)g.player.target_pos_x[index] + t.texture.width <= 0 {

			rl.BeginTextureMode(t)
			rl.ClearBackground(rl.Color{255, 255, 255, 0})
			rl.EndTextureMode()

			g.player.target_pos_x[index] = cast(f32)t.texture.width - 4
		}

	}
}


@(private)
scene_output :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene


	draw_player_target(game)
	worm_render_to_texture(game)

	rl.BeginTextureMode(game.target_main)
	rl.ClearBackground(rl.Color{220, 186, 200, 255})

	for o in game.obstacles {
		rl.DrawRectangleRec(o.rec, o.color)
	}


	for t, index in game.player.target {
		rl.DrawTextureRec(
			t.texture,
			{0, 0, cast(f32)game.render_width, cast(f32)-game.render_height},
			{game.player.target_pos_x[index], 0},
			rl.WHITE,
		)
	}
	worm_render(game)
	//render_score_particles(game)
	rl.UpdateMusicStream(game.music)

	rl.DrawPoly(game.player.pos, 3, 8, cast(f32)(rl.GetRandomValue(0, 360)), game.player.color)

	text: cstring = fmt.ctprint("SCORE", game.score)
	text_size := rl.MeasureText(text, 10)

	txt_pos := rl.Vector2{cast(f32)(game.render_width / 2) - cast(f32)(text_size / 2), 10}
	rl.DrawText(text, cast(i32)txt_pos.x, cast(i32)txt_pos.y, 10, rl.PINK)

	text = fmt.ctprint("+", game.score_increase)
	text_size = rl.MeasureText(text, 10)
	rl.DrawText(text, game.render_width / 2 - (text_size / 2), 20, 10, rl.PINK)


	if (game.is_fps_draw) {
		rl.DrawText(rl.TextFormat("FPS: %i", game.loop.stat_fps), 10, 10, 10, rl.GREEN)
	}


	rl.EndTextureMode()

	rl.BeginDrawing()

	rl.DrawTexturePro(
		game.target_main.texture,
		{0, 0, cast(f32)game.render_width, cast(f32)-game.render_height},
		{0, 0, cast(f32)game.window_width, cast(f32)game.window_height},
		{0, 0},
		0,
		rl.WHITE,
	)

	music_color := rl.PINK
	if game.is_music_off {
		music_color = rl.GRAY
	}
	rl.DrawTexture(game.music_texture, cast(i32)rl.GetScreenWidth() - 64, 32, music_color)

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
