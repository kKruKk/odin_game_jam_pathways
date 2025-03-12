package pathways

import rl "vendor:raylib"


worm_update :: proc(g: ^Game, dt: f32) {

	speed := 100 * dt 
	dir: rl.Vector2

	for &w, index in g.worms {

		if w.pos.x < 0 {

			w.pos.x = cast(f32)rl.GetRandomValue(g.render_width, g.render_width * 2)
			w.pos.y = cast(f32)rl.GetRandomValue(-8, g.render_height - 8)

		} else if w.pos.x < g.player.pos.x + 64 &&
		   w.pos.x > g.player.pos.x &&
		   w.pos.y + 64 > g.player.pos.y &&
		   w.pos.y - 64 < g.player.pos.y {

			if w.pos.y <= g.player.pos.y {
				dir = {-1, cast(f32)rl.GetRandomValue(-8, 4)}
			} else {
				dir = {-1, cast(f32)rl.GetRandomValue(-4, 8)}
			}

		} else {
			dir = {-1, cast(f32)rl.GetRandomValue(-8, 8)}
		}

		dir = rl.Vector2Normalize(dir)
		dir *= speed

		w.pos += dir
	}
}

worm_render_to_texture :: proc(g: ^Game){
rl.BeginTextureMode(g.worm_screen)

	rl.DrawRectangle(
		0,
		0,
		g.worm_screen.texture.width,
		g.worm_screen.texture.height,
		rl.Color{128, 64, 128, 2},
	)

	render_score_particles(g)


	for w in g.worms {
		rl.DrawPoly(w.pos, 8, 16, cast(f32)(rl.GetRandomValue(0, 360)), rl.Color{186,196,220,255})
		
	}

	color := g.player.color
	rl.DrawCircleGradient(
		cast(i32)g.player.pos.x,
		cast(i32)g.player.pos.y,
		32,
		rl.Color{color.b,color.g,color.r,255},
		rl.Color{255,255, 255, 0},
	)
	// rl.DrawCircleGradient(
	// 	cast(i32)g.player.pos.x,
	// 	cast(i32)g.player.pos.y,
	// 	64,
	// 	rl.Color{color.b,color.g,color.r, 0},
	// 	rl.Color{color.b,color.g,color.r, 64},
	// )
	// rl.DrawCircleGradient(
	// 	cast(i32)g.player.pos.x,
	// 	cast(i32)g.player.pos.y,
	// 	128,
	// 	rl.Color{16, 186, 220, 16},
	// 	rl.Color{16, 16, 16, 0},
	// )

	rl.EndTextureMode()
}
worm_render :: proc(g: ^Game) {

	

	rl.DrawTextureRec(
		g.worm_screen.texture,
		{0, 0, cast(f32)g.render_width, cast(f32)-g.render_height},
		{0, 0},
		rl.WHITE,
	)

}
