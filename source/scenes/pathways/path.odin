package pathways

import rl"vendor:raylib"

Path_Screen_Key :: struct {
	x: i32,
	y: i32,
}

Paths :: struct {
	pos: rl.Vector2,
	color: rl.Color,
}


path_update :: proc(g : ^Game,dt : f32) {

    speed := g.player.pos.x * dt / 2
    dir : rl.Vector2 

    for &p in g.paths {

        if p.pos.x < 0 {
            p.pos.x = cast(f32)rl.GetRandomValue(rl.GetScreenWidth(),rl.GetScreenWidth()*2)
            p.pos.y = cast(f32)rl.GetRandomValue(0,rl.GetScreenHeight())
        }


        if p.pos.x < g.player.pos.x + 128 && p.pos.x > g.player.pos.x && p.pos.y + 128 > g.player.pos.y && p.pos.y - 128 < g.player.pos.y {

            if p.pos.y <= g.player.pos.y{
                dir = {-1,cast(f32)rl.GetRandomValue(-8,2)}
            } else {
                dir = {-1,cast(f32)rl.GetRandomValue(-2,8)}
            }
        } else {
            dir = {-1,cast(f32)rl.GetRandomValue(-8,8)}
        }
        dir = rl.Vector2Normalize(dir)
        dir *= speed 

        p.pos += dir 
        
    }
}

path_render :: proc(g : ^Game){

    key : Path_Screen_Key
    
    width := rl.GetScreenWidth()
    height := rl.GetScreenHeight()

    for k,v in g.paths_screens {
        rl.BeginTextureMode(v)
        rl.DrawRectangle(0,0,v.texture.width,v.texture.height,rl.Color{128,64,128,4})


        for p in g.paths {
                rl.DrawRectangle(cast(i32)p.pos.x,cast(i32)p.pos.y,4,4,p.color)
        }

        rl.DrawCircleGradient(cast(i32)g.player.pos.x,cast(i32)g.player.pos.y,32,rl.Color{16,186,255,64},rl.Color{16,16,16,0})
        rl.DrawCircleGradient(cast(i32)g.player.pos.x,cast(i32)g.player.pos.y,64,rl.Color{16,186,255,32},rl.Color{16,16,16,0})
        rl.DrawCircleGradient(cast(i32)g.player.pos.x,cast(i32)g.player.pos.y,128,rl.Color{16,186,220,16},rl.Color{16,16,16,0})

        rl.EndTextureMode()
    }

    for k,v in g.paths_screens {
        rl.DrawTextureRec(
			v.texture,
			{0, 0, cast(f32)rl.GetScreenWidth(), cast(f32)-rl.GetScreenHeight()},
			{cast(f32)k.x,cast(f32)k.y},
			rl.WHITE,
		)
    }
}