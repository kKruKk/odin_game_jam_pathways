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
	using scene:   cl.Scene,
	loop:          ^cl.Loop_Data,
	should_close:  bool,
	is_fps_draw:   bool,
	player:        Player,
	entities:      [dynamic]Entity,
	paths:         [dynamic]Paths,
	paths_screens: map[Path_Screen_Key]rl.RenderTexture2D,
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

	width := rl.GetScreenWidth()
	height := rl.GetScreenHeight()

	if false {
		scene := entry_scene.create()
		cl.scene_manager_insert(game.loop.scene_manager, scene, cast(u16)sn.Scene_Name.ENTRY)
		cl.scene_manager_next(game.loop.scene_manager, cast(u16)sn.Scene_Name.ENTRY)
		cl.scene_manager_change(game.loop.scene_manager)
		game.loop.scene_manager.scene->init(game.loop)
	}

	{
		game.player.pos = {100, 300}
		game.player.color = {
			cast(u8)rl.GetRandomValue(186, 255),
			cast(u8)rl.GetRandomValue(186, 255),
			cast(u8)rl.GetRandomValue(186, 255),
			255,
		}
	}


	append(&game.player.target, rl.LoadRenderTexture(rl.GetScreenWidth(), rl.GetScreenHeight()))
	append(&game.player.target, rl.LoadRenderTexture(rl.GetScreenWidth(), rl.GetScreenHeight()))
	append(&game.player.target, rl.LoadRenderTexture(rl.GetScreenWidth(), rl.GetScreenHeight()))
	append(&game.player.target_pos_x, 0)
	append(&game.player.target_pos_x, cast(f32)rl.GetScreenWidth() / 2)
	append(&game.player.target_pos_x, cast(f32)rl.GetScreenWidth())

	{
		for it in 0 ..< 32 {
			append(
				&game.entities,
				Entity {
					pos = {
						cast(f32)rl.GetRandomValue(rl.GetScreenWidth(), rl.GetScreenWidth() * 2),
						cast(f32)rl.GetRandomValue(0, rl.GetScreenHeight()),
					},
					color = rl.Color {
						cast(u8)rl.GetRandomValue(128, 255),
						cast(u8)rl.GetRandomValue(128, 255),
						cast(u8)rl.GetRandomValue(128, 255),
						255,
					},
				},
			)
		}
	}

	// init paths and paths_screens 
	{

		for it in 0 ..< 1000 {
			append(
				&game.paths,
				Paths {
					pos = {
						cast(f32)rl.GetRandomValue(rl.GetScreenWidth(), rl.GetScreenWidth() * 2),
						cast(f32)rl.GetRandomValue(0, rl.GetScreenHeight()),
					},
					color = rl.Color {
						cast(u8)rl.GetRandomValue(128, 255),
						cast(u8)rl.GetRandomValue(128, 255),
						cast(u8)rl.GetRandomValue(128, 255),
						255,
					},
				},
			)
		}

		map_insert(&game.paths_screens,Path_Screen_Key{0,0},rl.LoadRenderTexture(width,height)) 

	}


	return true
}


@(private)
scene_close :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene

	delete(game.entities)
	for t in game.player.target {
		rl.UnloadRenderTexture(t)
	}
	delete(game.player.target)

	delete(game.paths)
	for key, val in game.paths_screens {
		rl.UnloadRenderTexture(val)
	}
	delete(game.paths_screens)
}
@(private)
scene_on_enter :: proc(scene: ^cl.Scene) {}


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

}


@(private)
scene_update :: proc(scene: ^cl.Scene,dt : f32) -> bool {
	game := cast(^Game)scene

	speed: f32 = 200 * dt
	game.player.dir = rl.Vector2Normalize(game.player.dir)
	game.player.pos = game.player.pos + (game.player.dir * speed)


	speed = game.player.pos.x * dt

	// update entities 
	for &e in game.entities {
		e.pos.x -= speed

		if e.pos.x < 0 {
			e.pos = {
				cast(f32)rl.GetRandomValue(rl.GetScreenWidth(), rl.GetScreenWidth() * 3),
				cast(f32)rl.GetRandomValue(0, rl.GetScreenHeight()),
			}
		}
	}

	path_update(game,dt)

	return true
}


draw_player_target :: proc(g: ^Game) {

	color: rl.Color = {16, 16, 16, 4}
	for t, index in g.player.target {
		// if index == 1 {
		// 	color = {16,16,16,64}
		// } else if index == 2 {
		// 	color = {0,255,255,64}
		// }

		rl.BeginTextureMode(t)
		rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), color)
		pos := g.player.pos
		pos.x -= g.player.target_pos_x[index]

		rl.DrawPoly(pos, 3, 16, cast(f32)(rl.GetRandomValue(0, 360)), g.player.color)

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


	rl.BeginDrawing()
	rl.ClearBackground(rl.Color{255, 255, 255, 255})

	// for e in game.entities {
	// 	rl.DrawRectangle(cast(i32)e.pos.x, cast(i32)e.pos.y, 16, 16, e.color)
	// }

	draw_player_target(game)
	
	
	for t, index in game.player.target {
		rl.DrawTextureRec(
			t.texture,
			{0, 0, cast(f32)rl.GetScreenWidth(), cast(f32)-rl.GetScreenHeight()},
			{game.player.target_pos_x[index], 0},
			rl.WHITE,
		)
	}
	path_render(game)

	rl.DrawPoly(game.player.pos, 3, 16, cast(f32)(rl.GetRandomValue(0, 360)), game.player.color)
	
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
