extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var args=OS.get_cmdline_user_args()
 var width=1100 if "--small" in args else (1920 if "--full" in args else 1600)
 root.size=Vector2i(width,700 if width==1100 else (1080 if width==1920 else 900))
 var game=load("res://scenes/main.tscn").instantiate()
 game.session_path="user://task-i-never-user-practice.json"
 root.add_child(game)
 game.hud.hide_menu()
 game.set_process(false)
 game.table_view.set_overhead(not "--lounge" in args)
 await game.table_view._camera_tween.finished

 var rack="--rack" in args
 var pocket_id=1
 for arg in args:
  if arg.begins_with("--pocket="): pocket_id=int(arg.trim_prefix("--pocket="))
 var pocket=TableSpec.new().pocket_definitions()[pocket_id]
 var selected=[]
 for ball in game.balls:
  if rack or ball.number in [0,8,14]: selected.append(ball)
 game.balls.clear()
 for ball in selected: game.balls.append(ball)
 game.table_view._ball_nodes.values().map(func(v): v.queue_free())
 game.table_view._ball_nodes.clear()
 for ball in game.balls:
  if rack: continue
  if ball.number==0: ball.position=Vector2(-.94,-.40)
  if ball.number==8: ball.position=Vector2(-1.20,-.37)
  if ball.number==14:
   ball.position=Vector2(-1.05,-.52)
   ball.orientation=Quaternion(Vector3.RIGHT,PI*.5)
 if not rack and "--pocket" in args:
  var center:Vector2=pocket.mouth_center-pocket.outward*.17
  for i in range(game.balls.size()):
   game.balls[i].position=center+Vector2(-pocket.outward.y,pocket.outward.x)*(.075*(i-1))
 if "--cluster" in args:
  game.balls[0].position=Vector2(-.3,0)
  game.balls[1].position=Vector2(0,0)
  game.balls[2].position=Vector2(.045,.038)
 game.table_view.sync_balls(game.balls)
 game.aim_direction=Vector2.RIGHT if "--cluster" in args else Vector2(-.11,-.12).normalized()
 game._last_aim_state.clear()
 game._refresh_aim()
 if "--guide-off" in args: game.table_view.set_aim(game.balls,game.aim_direction,game._cue_ball(),.4,false)
 if "--placement" in args: game.table_view.set_placement_preview(Vector2(.3,.2),not "--invalid" in args)
 if "--unlit" in args:
  unlit(game.table_view)
 if "--overlay" in args:
  var geometry:=ImmediateMesh.new()
  var material:=StandardMaterial3D.new()
  material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
  material.albedo_color=Color(1,.15,.1)
  material.no_depth_test=true
  geometry.surface_begin(Mesh.PRIMITIVE_LINES,material)
  for segment in TableSpec.new().rail_segments():
   for p in [segment.a,segment.b]: geometry.surface_add_vertex(Vector3(p.x,TableSpec.new().cushion_nose_height,p.y))
  for definition in TableSpec.new().pocket_definitions():
   for p in [definition.fall_a,definition.fall_b]: geometry.surface_add_vertex(Vector3(p.x,.001,p.y))
  geometry.surface_end()
  var overlay:=MeshInstance3D.new()
  overlay.mesh=geometry
  game.table_view.add_child(overlay)
 for i in range(5): await process_frame
 await RenderingServer.frame_post_draw
 var path="/tmp/i1-current.png"
 for arg in args:
  if arg.begins_with("--output="): path=arg.trim_prefix("--output=")
 var error=root.get_texture().get_image().save_png(path)
 if error != OK: quit(1); return
 var camera=game.table_view.camera()
 var data={"capture":path,"framebuffer":str(root.size),"viewport":str(root.get_visible_rect().size),"design_size":str(root.content_scale_size),"play_area":str(game.hud.table_area_rect()),"camera_transform":str(camera.global_transform),"engine":Engine.get_version_info(),"source_sha256":FileAccess.get_sha256("res://scripts/presentation/table_presentation.gd"),"fixture_sha256":FileAccess.get_sha256("res://tests/i1_capture.gd"),"native_os_transform":"NOT_MEASURED; native window framebuffer capture", "camera_size":camera.size,"balls":[]}
 for ball in game.balls:
  var center=Vector3(ball.position.x,ball.height,ball.position.y)
  var left=camera.unproject_position(center-camera.global_basis.x*BallState.RADIUS)
  var right=camera.unproject_position(center+camera.global_basis.x*BallState.RADIUS)
  data.balls.append({"number":ball.number,"position":str(ball.position),"height":ball.height,"phase":ball.phase,"velocity":str(ball.velocity),"angular_velocity":str(ball.angular_velocity),"orientation":str(ball.orientation),"diameter_px":left.distance_to(right)})
 data["arguments"]=args
 data["sources"]={}
 for source in ["res://scripts/presentation/table_presentation.gd","res://scripts/presentation/ball_visual.gd","res://scripts/sim/table_spec.gd","res://assets/shaders/ball_surface.gdshader","res://assets/shaders/cloth_surface.gdshader","res://assets/shaders/wood_surface.gdshader"]:
  if FileAccess.file_exists(source): data["sources"][source]=FileAccess.get_sha256(source)
 data["draw_calls"]=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
 data["primitives"]=Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
 var f=FileAccess.open(path+".json",FileAccess.WRITE)
 if f==null: quit(1); return
 f.store_string(JSON.stringify(data,"  "))
 f.close()
 print(JSON.stringify(data))
 game.queue_free()
 await process_frame
 quit()

func unlit(node:Node) -> void:
 if node is MeshInstance3D:
  var material:=StandardMaterial3D.new()
  material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
  material.albedo_color=Color(.45,.55,.6)
  node.material_override=material
 for child in node.get_children(): unlit(child)
