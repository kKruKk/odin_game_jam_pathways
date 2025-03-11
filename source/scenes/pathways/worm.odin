package pathways

import rl "vendor:raylib"


worm_update :: proc(g: ^Game, dt: f32) {

	speed := 100 * dt 
	dir: rl.Vector2

	for &w, index in g.worms {

		if w.pos.x < 0 {

			w.pos.x = cast(f32)rl.GetRandomValue(rl.GetScreenWidth(), rl.GetScreenWidth() * 2)
			w.pos.y = cast(f32)rl.GetRandomValue(-8, rl.GetScreenHeight() - 8)

		} else if w.pos.x < g.player.pos.x + 128 &&
		   w.pos.x > g.player.pos.x &&
		   w.pos.y + 128 > g.player.pos.y &&
		   w.pos.y - 128 < g.player.pos.y {

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

path_render :: proc(g: ^Game) {

	rl.BeginTextureMode(g.worm_screen)

	rl.DrawRectangle(
		0,
		0,
		g.worm_screen.texture.width,
		g.worm_screen.texture.height,
		rl.Color{128, 64, 128, 2},
	)

	sw: bool

	for w in g.worms {
		if sw {
			sw = false
			rl.DrawRectangle(cast(i32)w.pos.x, cast(i32)w.pos.y, 2, 2, w.color)
		} else {
			sw = true
			rl.DrawPoly(w.pos, 8, 16, cast(f32)(rl.GetRandomValue(0, 360)), rl.Color{186,196,220,255})
			
		}
	}

	rl.DrawCircleGradient(
		cast(i32)g.player.pos.x,
		cast(i32)g.player.pos.y,
		64,
		g.player.color,
		rl.Color{0,0, 0, 0},
	)
	// rl.DrawCircleGradient(
	// 	cast(i32)g.player.pos.x,
	// 	cast(i32)g.player.pos.y,
	// 	64,
	// 	rl.Color{16, 186, 255, 32},
	// 	rl.Color{16, 16, 16, 0},
	// )
	// rl.DrawCircleGradient(
	// 	cast(i32)g.player.pos.x,
	// 	cast(i32)g.player.pos.y,
	// 	128,
	// 	rl.Color{16, 186, 220, 16},
	// 	rl.Color{16, 16, 16, 0},
	// )

	rl.EndTextureMode()

	rl.DrawTextureRec(
		g.worm_screen.texture,
		{0, 0, cast(f32)rl.GetScreenWidth(), cast(f32)-rl.GetScreenHeight()},
		{0, 0},
		rl.WHITE,
	)

}
