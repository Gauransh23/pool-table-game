extends SceneTree
var failures := 0
var checks := 0
func check(value: bool, message: String) -> void:
 checks += 1
 if not value:
  failures += 1
  printerr("FAIL: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var view := TablePresentation.new()
 var table := TableSpec.new()
 view._table=table
 for segment in table.rail_segments():
  for endpoint in [segment.a,segment.b]:
   var nose := view._rail_section_point(endpoint,segment.inward,Vector2(0,table.cushion_nose_height))
   check(nose.distance_to(Vector3(endpoint.x,table.cushion_nose_height,endpoint.y))<.0000001,"nose remains exact")
   for neighbor in table.rail_segments():
    if neighbor==segment: continue
    if neighbor.a.distance_to(endpoint)<.000001 or neighbor.b.distance_to(endpoint)<.000001:
     for section in [Vector2(-.027,.051),Vector2(-.029,.049),Vector2(-.029,.007)]:
      check(view._rail_section_point(endpoint,segment.inward,section).distance_to(view._rail_section_point(endpoint,neighbor.inward,section))<.00005,"shared rail/jaw section seam <=0.05mm")
 # A nose-edge-only oracle cannot see a backface-culled surface. Inspect the
 # actual packed mesh normals and every face for each directed jaw interval.
 for segment in table.rail_segments():
  if not segment.jaw: continue
  var pocket:Dictionary=table.pocket_definitions()[segment.pocket_id]
  var fall:Vector2=pocket.fall_a if segment.a.distance_to(pocket.mouth_a)<.000001 else pocket.fall_b
  for interval in [[segment.a,fall],[fall,segment.b],[segment.b,fall],[fall,segment.a]]:
   var mesh:=view._cushion_mesh(interval[0],interval[1],segment.inward)
   var normals:PackedVector3Array=mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
   check(normals[0].y>.3,"actual upper jaw face faces overhead under backface culling")
   var faces:PackedVector3Array=mesh.get_faces()
   var interior:=Vector3.ZERO
   for vertex in faces: interior+=vertex
   interior/=faces.size()
   for i in range(0,faces.size(),3):
    var center:Vector3=(faces[i]+faces[i+1]+faces[i+2])/3
    var normal:Vector3=-(faces[i+1]-faces[i]).cross(faces[i+2]-faces[i]).normalized()
    check(normal.dot(center-interior)>0.000001,"actual directed jaw face/endcap normal points outside its solid")
 for pocket in table.pocket_definitions():
  var mesh := view._pocket_liner_mesh(pocket)
  var vertices:PackedVector3Array=mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
  var pairs=[ [pocket.fall_a,pocket.back_a],[pocket.back_a,pocket.back_b],[pocket.back_b,pocket.fall_b] ]
  for i in range(18):
   var p:=Vector2(vertices[i].x,vertices[i].z)
   var pair:Array=pairs[i/6]
   check(p.distance_to(Geometry2D.get_closest_point_to_segment(p,pair[0],pair[1]))<.0000001,"liner cavity face retains physical wall")
  for i in range(0,vertices.size(),3):
   var center:Vector3=(vertices[i]+vertices[i+1]+vertices[i+2])/3
   var fall_mid:Vector2=(pocket.fall_a+pocket.fall_b)*.5
   check(Vector2(center.x,center.z).distance_to(fall_mid)>.001,"no front fall-edge cap")
 view._build_rail_deck()
 var merged:=SurfaceTool.new()
 merged.begin(Mesh.PRIMITIVE_TRIANGLES)
 for child in view.get_node("JoinedRailDeck").get_children():
  merged.append_from(child.mesh,0,Transform3D.IDENTITY)
 var vertices:PackedVector3Array=merged.commit().get_faces()
 for i in range(0,vertices.size(),3):
  var center:Vector3=(vertices[i]+vertices[i+1]+vertices[i+2])/3
  if absf(center.y-.051)<.0000001:
   check((vertices[i+1]-vertices[i]).cross(vertices[i+2]-vertices[i]).normalized().y<-.9,"deck top normals face out")
   for pocket in table.pocket_definitions():
    check(not Geometry2D.is_point_in_polygon(Vector2(center.x,center.z),pocket.opening),"deck leaves physical cutout open")
 view._build_rails()
 var all_edges:Array=[]
 for child in view.get_children():
  if child is MeshInstance3D:
   var faces:PackedVector3Array=child.mesh.get_faces()
   for i in range(0,faces.size(),3):
    for j in range(3): all_edges.append([faces[i+j],faces[i+(j+1)%3]])
 for segment in table.rail_segments():
  for fraction in [0.0,.1,.25,.5,.75,.9,1.0]:
   var p:Vector2=segment.a.lerp(segment.b,fraction)
   var point:=Vector3(p.x,table.cushion_nose_height,p.y)
   var nearest:=INF
   for edge in all_edges:
    nearest=minf(nearest,point.distance_to(Geometry3D.get_closest_point_to_segment(point,edge[0],edge[1])))
   check(nearest<.00005,"built full mouth-to-back jaw/rail nose remains visible at physical height")
 view._build_aim_and_cue()
 check(view._ghost_ball.mesh is TorusMesh,"marker is hollow topology")
 check(not view._ghost_ball.material_override.no_depth_test,"marker respects target occlusion")
 var cue:=BallState.new(0,0,Vector2.ZERO)
 var target:=BallState.new(1,8,Vector2(.3,0))
 view.set_aim([cue,target],Vector2.RIGHT,cue,.4,true)
 check(view._ghost_ball.visible,"first contact marker remains visible")
 check(absf(view._ghost_ball.position.x-(.3-2*BallState.RADIUS))<.000001,"contact marker retains first-contact algorithm")
 view.set_aim([cue,target],Vector2.LEFT,cue,.4,true)
 check(not view._ghost_ball.visible,"no marker without target")
 view.set_placement_preview(Vector2(.3,.2),true)
 check(view._ghost_ball.mesh is SphereMesh,"placement retains translucent sphere semantics")
 view.set_aim([cue,target],Vector2.RIGHT,cue,.4,true)
 check(view._ghost_ball.mesh is TorusMesh,"aim restores cached hollow marker after placement")
 view.free()
 print("I1 GEOMETRY: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
