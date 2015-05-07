###!
sarine.viewer.threejs - v0.0.0 -  Thursday, May 7th, 2015, 1:56:57 PM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
###

class Viewer
  rm = ResourceManager.getInstance();
  constructor: (options) ->
    console.log("")
    @first_init_defer = $.Deferred()
    @full_init_defer = $.Deferred()
    {@src, @element,@autoPlay,@callbackPic} = options
    @id = @element[0].id;
    @element = @convertElement()
    Object.getOwnPropertyNames(Viewer.prototype).forEach((k)-> 
      if @[k].name == "Error" 
          console.error @id, k, "Must be implement" , @
    ,
      @)
    @element.data "class", @
    @element.on "play", (e)-> $(e.target).data("class").play.apply($(e.target).data("class"),[true])
    @element.on "stop", (e)-> $(e.target).data("class").stop.apply($(e.target).data("class"),[true])
    @element.on "cancel", (e)-> $(e.target).data("class").cancel().apply($(e.target).data("class"),[true])
  error = () ->
    console.error(@id,"must be implement" )
  first_init: Error
  full_init: Error
  play: Error
  stop: Error
  convertElement : Error
  cancel : ()-> rm.cancel(@)
  loadImage : (src)-> rm.loadImage.apply(@,[src])
  setTimeout : (delay,callback)-> rm.setTimeout.apply(@,[@delay,callback]) 
    
@Viewer = Viewer 

class Threejs extends Viewer 
	scene = undefined
	sceneInfo = undefined
	renderer = undefined
	controls = undefined
	mesh = undefined
	@material : undefined
	camera = undefined
	cameraInfo = undefined
	scale = undefined
	url = undefined
	info = undefined
	canvasWidht = undefined
	fontSize = undefined
	color = undefined
	font = undefined
	mouseDown = false;
	mouseX = false;
	mouseY = false;
	infoOnly = false;
	
	constructor: (options) -> 
		super(options)
		{color,font, infoOnly} = options
		color = color || 0xffffff
		scale = 1
		@version = $(@element).data("version") || "v1"
		@viewersBaseUrl = stones[0].viewersBaseUrl
	convertElement : () ->
		@element.css {
			width : '100%'
			height:'100%'
			} 
		@element
	first_init : ()->
		_t = @
		defer = $.Deferred()
		loadScript(@viewersBaseUrl + "atomic/" + @version + "/assets/three.bundle.js").then( 
			()->
				createScene.apply(_t)
				$.when($.get(_t.src  + "SRNSRX.srn"),$.getJSON(_t.src + "info.json")).then((data,json) ->
					info = json[0]
					rawData = data[0]
						.replace(/\s/g,"^")
						.match(/Mesh(.*?)}/)[0]
						.replace(/[Mesh|{|}]/g,"")
						.split("^")
						.filter((s)->s.length > 0)

					drawMesh.apply(_t,[{
						vertices : rawData[1..parseInt(rawData[0])].map((str)-> str.replace(',','').split(';')[0..2]),
						polygons :rawData[parseInt(rawData[0]) + 2 .. rawData.length]
							.map((str)-> str.replace(/(\d+;)/, '').replace(/(;;|;,)/,"").split(","))
							}]);
					drawInfo.apply(_t);
					if(!infoOnly)
						addMouseHandler.apply(_t);
					defer.resolve(_t) 
					)
			)
		defer
	full_init : ()-> 
		defer = $.Deferred()
		defer.resolve(@)		
		defer
	play : () -> return		
	stop : () -> return		
	loadScript = (url)->
		defer = $.Deferred()
		_t = @
		s = $("<script>", {
			type: "text/javascript"
		}).appendTo("body").end()[0];
		s.onload = ()-> defer.resolve(_t);
		s.src = url
		defer
	rotateScene = (deltaX,deltaY) ->
		mesh.rotation.x += deltaY / 100;
		mesh.rotation.z -= deltaX / 100;
	addMouseHandler = () ->
		canvas = renderer.domElement
		onMouseMove = (evt)-> 
			if !mouseDown
				return
			evt.preventDefault();
			deltaX = evt.clientX - mouseX;
			deltaY = evt.clientY - mouseY;
			mouseX = evt.clientX;
			mouseY = evt.clientY;
			rotateScene(deltaX, deltaY);
		
		renderer.domElement.addEventListener 'mousemove', ((e)-> onMouseMove(e)), false
		renderer.domElement.addEventListener('mousedown',((evt)->
			evt.preventDefault();
			mouseDown = true;
			mouseX = evt.clientX;
			mouseY = evt.clientY;
			), false)
		renderer.domElement.addEventListener('mouseup',((evt)-> 
			evt.preventDefault();
			mouseDown = false;
			), false)
	render = () ->
		requestAnimationFrame(render);
		renderer.clear();
		# controls.update();
		renderer.render(scene, camera);
		if(mesh && mesh.rotation && parseInt(mesh.rotation.x * 10) == parseInt(Math.PI * 5))
			renderer.render(sceneInfo, cameraInfo);
	drawMesh = (data) ->
		setFaces = (points, geometry) ->
			geometry.faces.push(new THREE.Face3(points[0], points[1], points[2]) )
			if points.length != 3
				points.splice(1, 1)
				setFaces(points, geometry)
			geometry.computeFaceNormals()

		geom = new THREE.Geometry() ;

		for vert in data.vertices
			geom.vertices.push(new THREE.Vector3(vert[0] * scale, vert[1] * scale, vert[2] * scale) )
		for vert in data.polygons
			setFaces(vert, geom)
		mesh = new THREE.Mesh(geom, @material) ;
		mesh.material.opacity = 1
		mesh.material.transparent = false;
		meshWF = new THREE.Mesh( geom.clone(), @material.clone() ) ;
		meshWF.scale.set(0.99 * scale, 0.99 * scale, 0.99 * scale)
		meshWF.material.opacity = 1
		mesh.geometry.center()
		meshWF.geometry.center()
		@edges = new THREE.EdgesHelper(mesh, 0x000000)
		scene.add(rotation(mesh) )
		scene.add(rotation(@edges) )
		mesh
	rotation = (obj) ->
		obj.rotation.x = Math.PI / 2
		obj

	createScene = ()->
		scene = new THREE.Scene() ;
		sceneInfo = new THREE.Scene() ;
		camera = new THREE.OrthographicCamera(12500 / -2.5, 12500 / 2.5, 12500  / 2.5, 12500  / - 2.5, - 10000, 10000) ;
		scene.add(camera) ;
		camera.position.set(0, 0, 5000) ;
		camera.lookAt(scene.position) ;
		# renderer = new THREE.WebGLRenderer({alpha: true} ) ;
		renderer = new THREE.CanvasRenderer({alpha: true} ) ;
		renderer.autoClear = false;
		canvasWidht = if @element.height() > @element.width() then @element.width() else @element.height();
		cameraInfo = new THREE.OrthographicCamera(canvasWidht / -2, canvasWidht / 2, canvasWidht  / 2, canvasWidht  / - 2, - 10000, 10000) ;
		sceneInfo.add(cameraInfo)
		renderer.setSize(canvasWidht, canvasWidht) ;
		@element[0].appendChild(renderer.domElement) ;
		@material = new THREE.MeshBasicMaterial({ color: 0xcccccc, side: THREE.DoubleSide} )
		render()
	drawArrow = (options)->
		{name, origin, length, hex, topToButtom,data,dir,far} = options
		xyFar = if topToButtom then 'x' else 'y';
		origin["set"+  xyFar.toUpperCase()](origin[xyFar] * far)
		origin.set(origin.x / (camera.right / cameraInfo.right),origin.y / (camera.right / cameraInfo.right),origin.z / (camera.right / cameraInfo.right))
		textObj = drawText({
			text : data.toFixed(2) + " mm",
			position : origin
		})
		infoObj = new THREE.Object3D();
		infoObj.name = "info"
		xy = if topToButtom then 'y' else 'x';
		gap = (textObj.geometry.boundingBox.max[xy] - textObj.geometry.boundingBox.min[xy]) + 10
		length = data / 2 * 1000 /  (camera.right / cameraInfo.right) - gap / 2 
		infoObj.add(textObj)
		infoObj.add(new THREE.ArrowHelper(dir, origin.clone()["set" + xy.toUpperCase()](origin[xy] + gap/2), length, hex ,5,5))
		if topToButtom
			dir.setY(dir.y * -1)
		else
			dir.setX(dir.x * -1)
		infoObj.add(new THREE.ArrowHelper(dir, origin.clone()["set" + xy.toUpperCase()](origin[xy] -  gap/2), length, hex ,5,5))
		infoObj
	drawText = (options)-> 
		{text,position, hex} = options
		material = new THREE.MeshBasicMaterial({
			color: options.hex || 0x000000
		});
		textGeom = new THREE.TextGeometry( options.text, {
			size: 15,
			font: "gentilis",
			wieght : "bold"
		});
		textGeom.center();

		textMesh = new THREE.Mesh( textGeom, material );
		textMesh.lookAt(camera.position)
		textMesh.position.set(position.x,position.y,position.z)
		# textMesh.scale.set(5,5,5)
		textMesh
	drawInfo = (hex)-> 
		hex = hex || 0x000000 
		infoObj = new THREE.Object3D();
		infoObj.name = "info"
		# draw length of the diamond
		infoObj.add( 
			drawArrow({
				origin  : new THREE.Vector3( 0, mesh.geometry.boundingBox.max.z, 0 ),
				hex : hex, 
				topToButtom : false,
				data : info['Length']['mm'],
				dir :  new THREE.Vector3( 1, 0, 0 )
				far : 1.50
			}));
		# draw the table line
		infoObj.add( 
			drawArrow({
				origin  : new THREE.Vector3( 0, mesh.geometry.boundingBox.max.z, 0 ),
				hex : hex, 
				topToButtom : false,
				data : info['Table Size']['mm']
				dir :  new THREE.Vector3( 1, 0, 0 )
				far :  1.25
			}));
		infoObj.add(drawArrow({
				origin  : new THREE.Vector3( 0, mesh.geometry.boundingBox.max.z, 0 ),
				hex : hex, 
				topToButtom : false,
				data : info['Table Size']['mm']
				dir :  new THREE.Vector3( 1, 0, 0 )
				far : 1.25
			}))
		val =  mesh.geometry.boundingBox.max.z - info['Crown']['height-mm'] * 1000 / 2;
		infoObj.add(drawArrow({
				origin  : new THREE.Vector3( mesh.geometry.boundingBox.max.x ,val  , 0 )
				hex : hex, 
				topToButtom : true,
				data : info['Crown']['height-mm']
				dir :  new THREE.Vector3( mesh.geometry.boundingBox.max.x , val +  1 , 0 )
				far : 1.25
			})) 
		val =  mesh.geometry.boundingBox.min.z + info['Pavilion']['height-mm'] * 1000 / 2;
		infoObj.add(drawArrow({
				origin  : new THREE.Vector3( mesh.geometry.boundingBox.max.x ,val  , 0 )
				hex : hex, 
				topToButtom : true,
				data : info['Pavilion']['height-mm']
				dir :  new THREE.Vector3( mesh.geometry.boundingBox.max.x , val *  -1 , 0 )
				far : 1.25
			}))
		val =  mesh.geometry.boundingBox.min.z + info['Total Depth']['mm'] * 1000 / 2;
		infoObj.add(drawArrow({
				origin  : new THREE.Vector3( mesh.geometry.boundingBox.min.x ,val  , 0 )
				hex : hex, 
				topToButtom : true,
				data : info['Total Depth']['mm']
				dir :  new THREE.Vector3( mesh.geometry.boundingBox.min.x , val +  1 , 0 )
				far : 1.25 
			}))
		sceneInfo.add(infoObj)
		undefined


@Threejs = Threejs
		


