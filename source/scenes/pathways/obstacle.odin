package pathways

import rl "vendor:raylib"
Entity_Obstacle :: struct {
	rec:   rl.Rectangle,
	color: rl.Color,
}

obstacle_update :: proc(g: ^Game, dt: f32) {

	width := g.render_width
	height := g.render_height

	for &o in g.obstacles {
		o.rec.x -= 50 * dt

		if o.rec.x < -o.rec.width {
			o.rec.x = cast(f32)g.render_width
			o.rec.y = cast(f32)rl.GetRandomValue(0, height - cast(i32)o.rec.height)
		}

	}


}
