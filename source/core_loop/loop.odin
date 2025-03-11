package core_loop

import "core:time"
import rl "vendor:raylib"

Scene :: struct {
	init:        proc(scene: ^Scene, loop: ^Loop_Data) -> bool,
	close:       proc(scene: ^Scene),
	on_enter:    proc(scene: ^Scene),
	input:       proc(scene: ^Scene),
	update:      proc(scene: ^Scene,dt : f32) -> bool,
	output:      proc(scene: ^Scene),
	each_second: proc(scene: ^Scene),
}

scene_create :: proc() -> ^Scene {
	scene := new(Scene)
	scene_set_default_inteface(scene)
	return scene
}

scene_set_default_inteface :: proc(scene: ^Scene) {

	scene.init = scene_init
	scene.close = scene_close
	scene.on_enter = scene_on_enter
	scene.input = scene_input
	scene.update = scene_update
	scene.output = scene_output
	scene.each_second = scene_each_second

}

@(private)
scene_init :: proc(scene: ^Scene, loop: ^Loop_Data) -> bool {return true}
@(private)
scene_close :: proc(scene: ^Scene) {}
@(private)
scene_on_enter :: proc(scene: ^Scene) {}
@(private)
scene_input :: proc(scene: ^Scene) {}
@(private)
scene_update :: proc(scene: ^Scene,dt : f32) -> bool {return true}
@(private)
scene_output :: proc(scene: ^Scene) {}
@(private)
scene_each_second :: proc(scene: ^Scene) {}


Scene_Manager :: struct {
	scenes:  map[u16]^Scene,
	scene:   ^Scene,
	current: u16,
	next:    u16,
}

destroy_scene_manager :: proc(sm: ^Scene_Manager) {
	for s in sm.scenes {
		free(sm.scenes[s])
	}
	delete(sm.scenes)
	
}

scene_manager_create :: proc(boot_scene: ^Scene) -> Scene_Manager {
	sm := Scene_Manager{scene = boot_scene}
	map_insert(&sm.scenes,0,boot_scene) 
	return sm 
}

scene_manager_insert :: proc(sm: ^Scene_Manager, s: ^Scene, id: u16) {
	if _ , ok := sm.scenes[id]; !ok {
		map_insert(&sm.scenes, id, s)
	}
}

scene_manager_remove :: proc(sm: ^Scene_Manager, id: u16) {
	delete_key(&sm.scenes, id)
}

scene_manager_next :: proc(sm: ^Scene_Manager, id: u16) {
	sm.next = id
}

scene_manager_change :: proc(sm: ^Scene_Manager) {
	sm.current = sm.next
	sm.scene = sm.scenes[sm.current]
	sm.scene->on_enter()
}

Loop_Data :: struct {
	scene_manager:            ^Scene_Manager,
	// timings
	input_step:               f64,
	update_step:              f64,
	render_step:              f64,
	stat_update_average_time: f64,
	stat_render_average_time: f64,
	stat_loop_average_time:   f64,
	seconds_since_app_start:  u64,
	max_ips:                  u32,
	max_ups:                  u32,
	max_fps:                  u32,
	max_ups_buffer:           u32,
	stat_ips:                 u32,
	stat_ups:                 u32,
	stat_fps:                 u32,
	stat_lps:                 u32,
	stat_sps:                 u32,
}

run :: proc(
	scene: ^Scene,
	width, height: i32,
	title: cstring,
	max_ups: f64 = 60,
	max_fps: f64 = 60,
	max_ups_buffer: u32 = 2,
) {

	if scene == nil {return}

	rl.InitWindow(width, height, title)
	defer rl.CloseWindow()

	sm := scene_manager_create(scene)
	defer destroy_scene_manager(&sm)

	loop: Loop_Data
	loop.scene_manager = &sm


	MAX_UPS: f64 = max_ups
	MAX_FPS: f64 = max_fps
	MAX_UPS_DT: f64 = 1.0 / MAX_UPS
	MAX_FPS_DT: f64 = 1.0 / MAX_FPS


	time_acc_loop: f64
	time_start_loop: f64
	time_end_loop: f64
	time_delta: f64

	time_start: f64
	time_acc_update: f64
	time_acc_render: f64

	loop.update_step = MAX_UPS_DT
	loop.max_ups = cast(u32)MAX_UPS
	loop.max_ups_buffer = max_ups_buffer


	acc_update: f64
	ups_buffer_counter: u32

	loop.render_step = MAX_FPS_DT
	loop.max_fps = cast(u32)MAX_FPS


	acc_draw: f64

	is_update: bool
	is_draw: bool

	stat_ups: u32
	stat_fps: u32
	stat_lps: u32
	stat_sps: u32

	if !sm.scene->init(&loop) {
		return
	}
	is_running: bool = !rl.WindowShouldClose()
	main_loop: for is_running {


		time_end_loop = rl.GetTime()

		time_delta = time_end_loop - time_start_loop
		time_start_loop = time_end_loop


		time_acc_loop += time_delta
		acc_update += time_delta
		acc_draw += time_delta

		if time_delta < (loop.update_step / 2.0) {
			time.sleep(time.Millisecond * cast(time.Duration)(loop.update_step / 1.0 * 1000))
			stat_sps += 1
		}


		for acc_update >= loop.update_step && ups_buffer_counter < loop.max_ups_buffer {

			if !is_draw {
				rl.PollInputEvents()
			} else {
				is_draw = false
			}

			is_running = !rl.WindowShouldClose()
			if is_running == false {
				sm.scene->close()
				break main_loop
			}

			sm.scene->input()
		
			time_start = rl.GetTime()
			sm.scene->update(cast(f32)loop.max_ups)
			time_acc_update += rl.GetTime() - time_start
			is_update = true
			acc_update -= loop.update_step
			ups_buffer_counter += 1
			stat_ups += 1
		}

		if ups_buffer_counter < loop.max_ups_buffer {
			ups_buffer_counter = 0
		}


		if is_update && acc_draw >= loop.render_step {

			if (ups_buffer_counter >= loop.max_ups_buffer) {
				ups_buffer_counter = 0
				acc_update = 0
			}


			time_start = rl.GetTime()
			sm.scene->output()
			time_acc_render += rl.GetTime() - time_start


			stat_fps += 1
			acc_draw -= loop.render_step

			if acc_draw * cast(f64)loop.max_ups_buffer >
			   loop.render_step * cast(f64)loop.max_ups_buffer {
				acc_draw = 0
			}
			is_update = false
			is_draw = true
		}


		if time_acc_loop >= 1.0 {
			loop.seconds_since_app_start += 1

			if stat_ups > 0 do loop.stat_update_average_time = time_acc_update / cast(f64)stat_ups * 1000
			if stat_fps > 0 do loop.stat_render_average_time = time_acc_render / cast(f64)stat_fps * 1000
			if stat_lps > 0 do loop.stat_loop_average_time = time_acc_loop / cast(f64)stat_lps * 1000

			sm.scene->each_second()

			time_acc_loop -= 1.0
			time_acc_update = 0
			time_acc_render = 0

			loop.stat_ips = 0
			loop.stat_ups = stat_ups
			loop.stat_fps = stat_fps
			loop.stat_lps = stat_lps
			loop.stat_sps = stat_sps


			stat_ups = 0
			stat_fps = 0
			stat_lps = 0
			stat_sps = 0

			free_all(context.temp_allocator)

		}

		stat_lps += 1


	}
	free_all(context.temp_allocator)

}
