package pathways

import rl "vendor:raylib"

Cloud_Cluster :: struct {
	clouds:        [dynamic]Entity,
	clouds_screen: rl.RenderTexture2D,
}

// cloud_cluster_init :: proc() {

// 	e: Entity
// 	for it in 0 ..< 500 {
// 		e.pos = rl.Vector2 {
// 			cast(f32)rl.GetRandomValue(game.render_width, game.render_width * 3),
// 			cast(f32)rl.GetRandomValue(0, game.render_height),
// 		}
// 		e.color = rl.Color {
// 			cast(u8)rl.GetRandomValue(128, 255),
// 			cast(u8)rl.GetRandomValue(128, 255),
// 			cast(u8)rl.GetRandomValue(128, 255),
// 			255,
// 		}

// 		append(&game.worms, e)
// 	}

// 	game.worm_screen = rl.LoadRenderTexture(game.render_width, game.render_height)

// }

cloud_update :: proc(g: ^Game, dt: f32) {

	speed := 100 * dt
	dir: rl.Vector2

	for &w, index in g.cloud_particle {

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

render_cloud_particle :: proc(g: ^Game) {
	
	for w in g.cloud_particle {
		rl.DrawPoly(
			w.pos,
			8,
			16,
			cast(f32)(rl.GetRandomValue(0, 360)),
			rl.Color{186, 196, 220, 255},
		)
	}

}
worm_render :: proc(g: ^Game) {

	rl.DrawTextureRec(
		g.particle_screen.texture,
		{0, 0, cast(f32)g.render_width, cast(f32)-g.render_height},
		{0, 0},
		rl.WHITE,
	)

}
