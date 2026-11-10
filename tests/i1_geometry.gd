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
 root.add_child(view)
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
  for interval in [[segment.a,segment.b],[segment.b,segment.a],[fall,segment.b],[segment.b,fall]]:
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
 # Inspect production green and brown meshes, including the retained 6.184mm
 # pocket4/5 counterexamples. Full endpoints define the loft, never subspans.
 view._build_rails()
 var jaw_index:=0
 var built_meshes:Array=[]
 for child in view.get_children():
  if child is MeshInstance3D: built_meshes.append(child.mesh)
 var mesh_index:=0
 for segment in table.rail_segments():
  var green:ArrayMesh=built_meshes[mesh_index]
  mesh_index+=1
  if not segment.jaw:
   mesh_index+=1 # rail inlay
   continue
  var brown:ArrayMesh=built_meshes[mesh_index]
  mesh_index+=1
  var pocket:Dictionary=table.pocket_definitions()[segment.pocket_id]
  var fall:Vector2=pocket.fall_a if segment.a.distance_to(pocket.mouth_a)<.000001 else pocket.fall_b
  var fraction:float=segment.a.distance_to(fall)/segment.a.distance_to(segment.b)
  var full:=view._cushion_mesh(segment.a,segment.b,segment.inward)
  var full_faces:PackedVector3Array=full.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
  var section:=[Vector2(0,table.cushion_nose_height),Vector2(-.027,.051),Vector2(-.029,.049),Vector2(-.029,.007)]
  var green_faces:PackedVector3Array=green.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
  var brown_faces:PackedVector3Array=brown.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
  for cross_point in section:
   var start:=view._rail_section_point(segment.a,segment.inward,cross_point)
   var end:=view._rail_section_point(segment.b,segment.inward,cross_point)
   var cut:=start.lerp(end,fraction)
   for pair in [[green_faces,start],[green_faces,cut],[brown_faces,cut],[brown_faces,end]]:
    var nearest:=INF
    for vertex in pair[0]: nearest=minf(nearest,vertex.distance_to(pair[1]))
    check(nearest<.0000002,"production jaw preserves endpoints and identical interpolated split section")
  for mesh in [green,brown]:
   var faces:PackedVector3Array=mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
   var normals:PackedVector3Array=mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
   check(normals[0].y>.3,"production short-span upper normal faces overhead")
   var interior:=Vector3.ZERO
   for vertex in faces: interior+=vertex
   interior/=faces.size()
   for vertex in faces:
    check((Vector2(vertex.x,vertex.z)-segment.a).dot(segment.inward)<.0000002,"jaw remains behind physical nose half-plane outside pocket cavity")
   var edges:Dictionary={}
   for i in range(0,faces.size(),3):
    var center:Vector3=(faces[i]+faces[i+1]+faces[i+2])/3
    var cross:Vector3=-(faces[i+1]-faces[i]).cross(faces[i+2]-faces[i])
    check(cross.length()>1e-9,"production jaw triangle is nondegenerate")
    check(cross.normalized().dot(center-interior)>.000001,"production jaw face points outside its convex loft")
    # Side triangles must stay on the original full-jaw surface. End caps
    # intentionally lie inside that solid at the material cut.
    if i<24:
     for sample in [faces[i],faces[i+1],faces[i+2],center]:
      var distance:=INF
      for j in range(0,24,3):
       distance=minf(distance,sample.distance_to(closest_triangle(sample,full_faces[j],full_faces[j+1],full_faces[j+2])))
      check(distance<.0000002,"split side lies on original full-jaw triangle surface")
    for j in range(3):
     var a:Vector3=faces[i+j]
     var b:Vector3=faces[i+(j+1)%3]
     var key:=str(a)+"|"+str(b)
     edges[key]=int(edges.get(key,0))+1
   for edge in edges:
    var ends:PackedStringArray=edge.split("|")
    check(edges.get(ends[1]+"|"+ends[0],0)==1 and edges[edge]==1,"production jaw is a closed consistently oriented manifold")
   # A convex outward loft plus exact surface coincidence excludes new
   # self-intersection or cavity intrusion relative to the original full jaw.
  jaw_index+=1
 check(jaw_index==12,"all twelve production jaw pairs inspected")
 for child in view.get_children():
  view.remove_child(child)
  child.free()
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
 view._build_camera()
 view._build_aim_and_cue()
 check(view._ghost_ball.mesh is TorusMesh,"marker is hollow topology")
 check(not view._ghost_ball.material_override.no_depth_test,"marker respects target occlusion")
 var cue:=BallState.new(0,0,Vector2.ZERO)
 var target:=BallState.new(1,8,Vector2(.3,0))
 view.set_aim([cue,target],Vector2.RIGHT,cue,.4,true)
 check(view._ghost_ball.visible,"first contact marker remains visible")
 check(absf(view._ghost_ball.position.x-(.3-2*BallState.RADIUS))<.000001,"contact marker retains first-contact algorithm")
 var cached_marker:=view._ghost_ball.mesh
 view._camera.size+=.1
 view._process(0.0)
 check(view._ghost_ball.visible and view._ghost_ball.mesh==cached_marker,"fallback camera refresh retains cached contact marker")
 view.set_aim([cue,target],Vector2.LEFT,cue,.4,true)
 check(not view._ghost_ball.visible,"no marker without target")
 view.set_placement_preview(Vector2(.3,.2),true)
 check(view._ghost_ball.mesh is SphereMesh,"placement retains translucent sphere semantics")
 view.set_aim([cue,target],Vector2.RIGHT,cue,.4,true)
 check(view._ghost_ball.mesh is TorusMesh,"aim restores cached hollow marker after placement")
 check(view._ghost_ball.visible,"restored aim marker is visible after placement")
 check(view._ghost_ball.mesh==cached_marker and view._ghost_ball.material_override.albedo_color.is_equal_approx(Color(.68,.89,.94,.9)),"aim reuses cached marker and restores aim color after placement")
 view.set_aim([cue,target],Vector2.RIGHT,cue,.4,false)
 check(not view._ghost_ball.visible and not view._aim_mesh.visible,"guide-off hides marker and ribbons")
 view.free()
 print("I1 GEOMETRY: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)

# Orthogonal projection inside a triangle, otherwise closest boundary point.
func closest_triangle(p:Vector3,a:Vector3,b:Vector3,c:Vector3)->Vector3:
 var normal:Vector3=(b-a).cross(c-a).normalized()
 var projected:=p-normal*(p-a).dot(normal)
 var inside:=true
 for edge in [[a,b],[b,c],[c,a]]:
  if (edge[1]-edge[0]).cross(projected-edge[0]).dot(normal)<-1e-12: inside=false
 if inside: return projected
 var nearest:=a
 for edge in [[a,b],[b,c],[c,a]]:
  var point:=Geometry3D.get_closest_point_to_segment(p,edge[0],edge[1])
  if p.distance_squared_to(point)<p.distance_squared_to(nearest): nearest=point
 return nearest
