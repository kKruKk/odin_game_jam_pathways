package pathways

import rl "vendor:raylib"


@(private = "file")
dt_acc: f32

update_score :: proc(game: ^Game, dt: f32) {


	dt_acc += dt
	// update move and check collison with score text
	#reverse for &p, index in game.score_particles {

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

		particle: Entity

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
		
			particle.dir = {-1, 0}

			particle.speed = cast(f32)rl.GetRandomValue(60, 120)

			particle.color = game.player.color

			particle.dir = rl.Vector2Normalize(particle.dir)
			append(&game.score_particles, particle)
		}
	}

}

render_score_particles :: proc(g: ^Game) {
	for p in g.score_particles {
		rl.DrawPixel(cast(i32)p.pos.x, cast(i32)p.pos.y, p.color)
	}
}
