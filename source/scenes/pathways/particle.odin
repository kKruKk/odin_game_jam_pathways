package pathways

import rl"vendor:raylib"


particle_render_to_texture :: proc(g: ^Game) {
	rl.BeginTextureMode(g.particle_screen)

	rl.DrawRectangle(
		0,
		0,
		g.particle_screen.texture.width,
		g.particle_screen.texture.height,
		rl.Color{128, 64, 128, 2},
	)

	render_score_particles(g)
    render_cloud_particle(g)

	
	color := g.player.color
	rl.DrawCircleGradient(
		cast(i32)g.player.pos.x,
		cast(i32)g.player.pos.y,
		32,
		rl.Color{color.b, color.g, color.r, 255},
		rl.Color{255, 255, 255, 0},
	)

	rl.EndTextureMode()
}