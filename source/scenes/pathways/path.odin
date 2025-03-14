package pathways

import rl "vendor:raylib"
Path_Segment :: struct {
	rec:   rl.Rectangle,
	color: rl.Color,
}

Path :: struct {
	spawn_pos:      rl.Vector2,
	last_rec_index: int,
	segments:       [dynamic]Path_Segment,
}

destroy_path :: proc(p: ^Path) {
	delete(p.segments)
}

new_path :: proc(screen_width, screen_height: f32, size: i32) -> ^Path {
	result := new(Path)

	result.spawn_pos = {screen_width, screen_height / 2}
	segment: Path_Segment

	for _ in 0 ..< size {

		path_generate_segment_size_and_color(&segment, result.spawn_pos)

		segment.rec.x = -128
		segment.rec.y =
		cast(f32)rl.GetRandomValue(
			cast(i32)(result.spawn_pos.y - segment.rec.height),
			cast(i32)(result.spawn_pos.y + segment.rec.height),
		)

		append(&result.segments, segment)
	}

	result.last_rec_index = len(result.segments) - 1

	return result
}

path_generate_segment_size_and_color :: proc(segment: ^Path_Segment, spawn_pos: rl.Vector2) {

	segment.rec.width = cast(f32)rl.GetRandomValue(16, 128)
	segment.rec.height = cast(f32)rl.GetRandomValue(16, 64)

	segment.color = rl.Color {
		cast(u8)rl.GetRandomValue(32, 186),
		cast(u8)rl.GetRandomValue(32, 186),
		cast(u8)rl.GetRandomValue(32, 186),
		255,
	}
}

@(private = "file")
dt_acc: f32

path_update :: proc(path: ^Path, screen_width, screen_height: i32, dt: f32) {

	dt_acc += dt

	if dt_acc >= 5 {
		dt_acc -= 5
		path.spawn_pos.y = cast(f32)rl.GetRandomValue(-screen_height, screen_height * 2)
	}

	if path.spawn_pos.y < cast(f32)screen_height / 7 {
		path.spawn_pos.y = cast(f32)screen_height / 7
	} else if path.spawn_pos.y >
	   cast(f32)screen_height / 7 * 6 {path.spawn_pos.y = cast(f32)screen_height / 7 * 6}

	mid_y: f32

	for &s, index in path.segments {
		s.rec.x -= 50 * dt

		if s.rec.x + s.rec.width <= 0 {

			path_generate_segment_size_and_color(&s, path.spawn_pos)

			mid_y =
				path.segments[path.last_rec_index].rec.y +
				path.segments[path.last_rec_index].rec.height / 2


			if mid_y > path.spawn_pos.y {
				s.rec.y =
					mid_y -
					cast(f32)rl.GetRandomValue(
							cast(i32)(s.rec.height / 8 * 7),
							cast(i32)(s.rec.height),
						)
			} else {
				s.rec.y = mid_y + cast(f32)rl.GetRandomValue(cast(i32)(-s.rec.height / 8), 0)
			}


			s.rec.x =
				path.segments[path.last_rec_index].rec.x +
				path.segments[path.last_rec_index].rec.width

			path.last_rec_index = index

		}
	}
}

path_render_segments :: proc(path: Path) {

	edge_size: i32 : 8

	for s in path.segments {

		rl.DrawRectangleRec(s.rec, s.color)

		rl.DrawRectangleGradientV(
			cast(i32)s.rec.x,
			cast(i32)s.rec.y,
			cast(i32)s.rec.width + 1,
			edge_size,
			rl.Color{s.color.b, s.color.g, s.color.r, 255},
			rl.Color{255, 255, 255, 0},
		)

		rl.DrawRectangle(
			cast(i32)s.rec.x,
			cast(i32)s.rec.y - edge_size / 2,
			cast(i32)s.rec.width + 1,
			edge_size / 2,
			rl.Color{s.color.r + 64, s.color.g + 64, s.color.b + 64, 255},
		)


		rl.DrawRectangleGradientV(
			cast(i32)s.rec.x,
			cast(i32)(s.rec.y + s.rec.height) - edge_size,
			cast(i32)s.rec.width + 1,
			edge_size,
			rl.Color{255, 255, 255, 0},
			rl.Color{s.color.b, s.color.g, s.color.r, 255},
		)


		rl.DrawRectangle(
			cast(i32)s.rec.x,
			cast(i32)(s.rec.y + s.rec.height),
			cast(i32)s.rec.width + 1,
			edge_size / 2,
			rl.Color{s.color.r + 64, s.color.g + 64, s.color.b + 64, 255},
		)
	}
}
