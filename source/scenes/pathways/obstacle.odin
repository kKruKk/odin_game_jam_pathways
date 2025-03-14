package pathways

import rl "vendor:raylib"
Entity_PATH_SEGMENT :: struct {
	rec:   rl.Rectangle,
	color: rl.Color,
}


obstacle_generate_position :: proc(o: ^Entity_PATH_SEGMENT, g: ^Game) {

	o.rec.x = g.obstacle_last.x + g.obstacle_last.width

	o.rec.y =
	cast(f32)rl.GetRandomValue(
		cast(i32)(g.obstacle_last.y - (g.obstacle_last.height / 2)),
		cast(i32)(g.obstacle_last.y + (g.obstacle_last.height)),
	)

	if o.rec.y <= 0 {
		o.rec.y = 0 - o.rec.height / 2
		// o.rec.y = 
		// cast(f32)rl.GetRandomValue(
		// 0,
		// cast(i32)(g.obstacle_last.y + g.obstacle_last.height - 64),
		// )
	}

	if cast(i32)o.rec.y >= g.render_height {
		o.rec.y = cast(f32)g.render_height - o.rec.height / 2
		// o.rec.y = 
		// cast(f32)rl.GetRandomValue(
		// cast(i32)(g.obstacle_last.y - (g.obstacle_last.height / 2 + 64)),
		// cast(i32)(g.obstacle_last.y + (g.obstacle_last.height - 64)),
		// )
	}
}


obstacle_update :: proc(g: ^Game, dt: f32) {

	width := g.render_width
	height := g.render_height

	for &o in g.obstacles {
		o.rec.x -= 50 * dt

		if o.rec.x < -o.rec.width {

			obstacle_generate_position(&o, g)

			o.color = rl.Color {
				cast(u8)rl.GetRandomValue(32, 186),
				cast(u8)rl.GetRandomValue(32, 186),
				cast(u8)rl.GetRandomValue(32, 186),
				255,
			}
		}

		g.obstacle_last = o.rec

	}


}

obstacle_render :: proc(g: ^Game) {

	edge_size: i32 = 8

	for o in g.obstacles {

		rl.DrawRectangleRec(o.rec, o.color)

		rl.DrawRectangleGradientV(
			cast(i32)o.rec.x,
			cast(i32)o.rec.y,
			cast(i32)o.rec.width + 1,
			edge_size,
			rl.Color{o.color.b, o.color.g, o.color.r, 255},
			rl.Color{255, 255, 255, 0},
		)

		rl.DrawRectangle(
			cast(i32)o.rec.x,
			cast(i32)o.rec.y - edge_size / 2,
			cast(i32)o.rec.width + 1,
			edge_size / 2,
			rl.Color{o.color.r + 64, o.color.g + 64, o.color.b + 64, 255},
		)


		rl.DrawRectangleGradientV(
			cast(i32)o.rec.x,
			cast(i32)(o.rec.y + o.rec.height) - edge_size,
			cast(i32)o.rec.width + 1,
			edge_size,
			rl.Color{255, 255, 255, 0},
			rl.Color{o.color.b, o.color.g, o.color.r, 255},
		)


		rl.DrawRectangle(
			cast(i32)o.rec.x,
			cast(i32)(o.rec.y + o.rec.height),
			cast(i32)o.rec.width + 1,
			edge_size / 2,
			rl.Color{o.color.r + 64, o.color.g + 64, o.color.b + 64, 255},
		)
	}
}
