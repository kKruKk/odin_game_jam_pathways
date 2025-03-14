package game

import "core:c"

import rl "vendor:raylib"

import cl "core_loop"
import  "scenes/click_scene"
import  "scenes/entry_scene"

import "core:time"



loop: cl.Loop_Data

window_width, window_height: i32
title: cstring
max_ups: f64 : 120
max_fps: f64 : 60
max_ups_buffer: u32 = 10

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

acc_update: f64
ups_buffer_counter: u32
acc_draw: f64

is_update: bool
is_draw: bool

stat_ups: u32
stat_fps: u32
stat_lps: u32
stat_sps: u32

is_running: bool

scene: ^cl.Scene
sm: cl.Scene_Manager


init :: proc() {

	

	

	window_width = 800
	window_height = 600
	title = "throughTheSky"
	//rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	when ODIN_OS == .JS {
		//rl.SetConfigFlags({.VSYNC_HINT})
	}
	rl.InitWindow(window_width, window_height, title)
	// audio
	rl.InitAudioDevice()

	loop.update_step = MAX_UPS_DT
	loop.max_ups = cast(u32)MAX_UPS
	loop.max_ups_buffer = max_ups_buffer


	loop.render_step = MAX_FPS_DT
	loop.max_fps = cast(u32)MAX_FPS

	when ODIN_OS != .JS {
		scene = entry_scene.create()
	} else {
		scene = click_scene.create()
	}
	if scene == nil {return}

	sm = cl.scene_manager_create(scene)
	loop.scene_manager = &sm
	if !sm.scene->init(&loop) {
		return
	}

	when ODIN_OS != .JS {
		is_running = !rl.WindowShouldClose()
	} else {
		is_running = true
	}

	
}

update :: proc() {


	time_end_loop = rl.GetTime()

	time_delta = time_end_loop - time_start_loop
	time_start_loop = time_end_loop


	time_acc_loop += time_delta
	acc_update += time_delta
	acc_draw += time_delta

	when ODIN_OS != .JS {
		if time_delta < (loop.update_step / 2.0) {
			time.sleep(time.Millisecond * cast(time.Duration)(loop.update_step / 1.0 * 1000))
			stat_sps += 1
		}
	}


	for acc_update >= loop.update_step && ups_buffer_counter < loop.max_ups_buffer {

		if !is_draw {
			rl.PollInputEvents()
		}
		is_draw = false


		when ODIN_OS != .JS {
			is_running = !rl.WindowShouldClose()
		}

		if is_running == false {
			sm.scene->close()
			return
		}

		sm.scene->input()

		time_start = rl.GetTime()
		is_running = sm.scene->update(cast(f32)loop.update_step)
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

// In a web build, this is called when browser changes size. Remove the
// `rl.SetWindowSize` call if you don't want a resizable game.
parent_window_size_changed :: proc(w, h: int) {
	rl.SetWindowSize(c.int(w), c.int(h))
}

shutdown :: proc() {
	free_all(context.temp_allocator)
	cl.destroy_scene_manager(&sm)
	rl.CloseAudioDevice()
	rl.CloseWindow()
}

should_run :: proc() -> bool {
	return is_running
}
