extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var table:=TableSpec.new()
 var view:=TablePresentation.new()
 view._table=table
 var failures:=0
 for segment in table.rail_segments():
  if not segment.jaw: continue
  var pocket:Dictionary=table.pocket_definitions()[segment.pocket_id]
  var side:="a" if segment.a.distance_to(pocket.mouth_a)<.000001 else "b"
  var fall:Vector2=pocket["fall_"+side]
  var mesh:=view._cushion_mesh(segment.a,fall,segment.inward)
  var faces:=mesh.get_faces()
  var interior:=Vector3.ZERO
  for vertex in faces: interior+=vertex
  interior/=faces.size()
  var bad_faces:Array=[]
  for i in range(0,faces.size(),3):
   var center:Vector3=(faces[i]+faces[i+1]+faces[i+2])/3
   var normal:Vector3=-(faces[i+1]-faces[i]).cross(faces[i+2]-faces[i]).normalized()
   var signed_outward:=normal.dot(center-interior)
   if signed_outward<=.000001:
    failures+=1
    bad_faces.append({"triangle":i/3,"normal":str(normal),"signed_outward_m":signed_outward})
  print(JSON.stringify({"pocket":segment.pocket_id,"side":side,"mouth":str(segment.a),"fall":str(fall),"inward":str(segment.inward),"length_m":segment.a.distance_to(fall),"bad_faces":bad_faces}))
 print("SHORT GREEN SPAN COUNTEREXAMPLE: %d faces fail outwardness; no full cushion-solid acceptance" % failures)
 view.free()
 quit(1 if failures else 0)
