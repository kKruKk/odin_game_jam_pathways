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
	using scene:  cl.Scene,
	loop:         ^cl.Loop_Data,
	should_close: bool,
	is_fps_draw:  bool,

    text_str : cstring,
    text_x : f32,
    text_y : f32,
    is_show_button : bool,
}

@(private)
scene_init :: proc(scene: ^cl.Scene, loop: ^cl.Loop_Data) -> bool {
	game := cast(^Game)scene
	game.loop = loop

    // text 
    game.text_str = "Odin Pathways"
    text_size := rl.MeasureTextEx(rl.GetFontDefault(), game.text_str,40,0)
    game.text_x = cast(f32)rl.GetScreenWidth()/ 2 - text_size.x / 2 
    game.text_y = 0 - text_size.y 
    
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

    if game.text_y < cast(f32)rl.GetScreenHeight()/3 {
        game.text_y += 60 / cast(f32)game.loop.max_ups
    } else {
        game.is_show_button = true
        if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) && rl.CheckCollisionPointRec(rl.GetMousePosition(),{350,290,100,20}) {
            game.should_close = true
        }
    }

	return true
}

@(private)
scene_output :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene

	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
    rl.DrawText( game.text_str,cast(i32)game.text_x,cast(i32)game.text_y,40,rl.PINK)
	if (game.is_fps_draw) {
		rl.DrawText(rl.TextFormat("FPS: %i", game.loop.stat_fps), 10, 10, 20, rl.GREEN)
	}

    if game.is_show_button {
        //rl.GuiButton({350,290,100,20},"PLAY")
        rl.DrawText("PLAY",380,290,20,rl.RAYWHITE)
    }
	rl.EndDrawing()
}

counter : i32

@(private)
scene_each_second :: proc(scene: ^cl.Scene) {
	game := cast(^Game)scene

	fmt.printfln(
		"update  %0.3f ms\nrender  %0.3f ms\nloop    %0.3f ms\n",
		game.loop.stat_update_average_time,
		game.loop.stat_render_average_time,
		game.loop.stat_loop_average_time,
	)

    counter += 1 
    if game.should_close {
        scene->close()
        cl.scene_manager_back_to_boot(game.loop.scene_manager)
    }
}

