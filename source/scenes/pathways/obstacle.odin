package pathways

import rl "vendor:raylib"
// Entity_Obstacle :: struct {
//     e : Entity,
// 	width : i32,
//     height : i32,
// }

obstacle_update :: proc(g: ^Game, dt: f32) {

	width := rl.GetScreenWidth()
	height := rl.GetScreenHeight()

	for &o in g.obstacles {
		o.x -= 50 * dt

		if o.x < -o.width {
			o.x = cast(f32)rl.GetRandomValue(width, width * 2)
			o.y = cast(f32)rl.GetRandomValue(0, height - cast(i32)o.height)
		}

	}


}
