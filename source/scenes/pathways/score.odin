package pathways

import rl "vendor:raylib"

Score_Particle :: struct {
	pos:   rl.Vector2,
	dir:   rl.Vector2,
	color: rl.Color,
	speed: f32,
}

@(private = "file")
dt_acc: f32

update_score :: proc(game: ^Game, dt: f32) {


	dt_acc += dt
	// update move and check collison with score text
	#reverse for &p, index in game.score_particles {

		// dir := p.pos - {-10,cast(f32)game.render_height / 2}
		// dir = rl.Vector2Normalize(dir)
		// dir = dir * ( dt * 2 )

		// p.dir -= dir 
		// p.dir = rl.Vector2Normalize(p.dir)


		if p.pos.x < game.player.pos.x + 32 &&
		   p.pos.x > game.player.pos.x &&
		   p.pos.y + 64 > game.player.pos.y &&
		   p.pos.y - 64 < game.player.pos.y {

			if p.pos.y <= game.player.pos.y {
				p.dir = {-1, cast(f32)rl.GetRandomValue(-8, 4)}
			} else {
				p.dir = {-1, cast(f32)rl.GetRandomValue(-4, 8)}
			}

		} else {
			p.dir = {-1, cast(f32)rl.GetRandomValue(-8, 8)}
		}

		p.dir = rl.Vector2Normalize(p.dir)

		p.pos += (p.speed * dt * p.dir)


		// if rl.CheckCollisionPointCircle(p.pos, game.score_text_mid_pos, 32) {
		// 	unordered_remove(&game.score_particles, index)
		// 	game.score += 1

		// }

		if p.pos.x < 0 {
			unordered_remove(&game.score_particles, index)
			when ODIN_OS == .JS {
				game.score += 2
			} else {
				game.score += 1
			}
		}
	}


	r := cast(i32)game.player.color.r - 16
	g := cast(i32)game.player.color.g - 16
	b := cast(i32)game.player.color.b - 16

	game.score_increase = (r + g * 2 + b * 4) / 10


	if dt_acc >= 1 {
		dt_acc -= 1

		particle: Score_Particle

		max_spawn: i32

		when ODIN_OS == .JS {
			max_spawn = game.score_increase / 2
		} else {
			max_spawn = game.score_increase
		}
		for _ in 0 ..< max_spawn {
			particle.pos = {
				cast(f32)rl.GetRandomValue(game.render_width, game.render_width * 2),
				cast(f32)rl.GetRandomValue(0, game.render_height),
			}
			// particle.dir = {
			// 	cast(f32)rl.GetRandomValue(-1000, 1000),
			// 	cast(f32)rl.GetRandomValue(-1000, 1000),
			// }
			particle.dir = {-1, 0}

			particle.speed = cast(f32)rl.GetRandomValue(60, 120)
			//particle.speed = 100

			// particle.color = {
			// 	cast(u8)rl.GetRandomValue(186,255),
			// 	cast(u8)rl.GetRandomValue(186,255),
			// 	cast(u8)rl.GetRandomValue(186,255),
			// 	255
			// }
			// particle.color.a = 255
			// particle.color.r = game.player.color.r - 64
			// particle.color.g = game.player.color.g - 64
			// particle.color.b = game.player.color.b - 64
			particle.color = game.player.color

			particle.dir = rl.Vector2Normalize(particle.dir)
			append(&game.score_particles, particle)
		}
	}

}

render_score_particles :: proc(g: ^Game) {
	for p in g.score_particles {
		//rl.DrawPoly(p.pos,3,4,cast(f32)rl.GetRandomValue(0,360),p.color)
		rl.DrawPixel(cast(i32)p.pos.x, cast(i32)p.pos.y, p.color)
	}
}
