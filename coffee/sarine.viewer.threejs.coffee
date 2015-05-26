###!
sarine.viewer.threejs - v0.6.0 -  Tuesday, May 26th, 2015, 4:25:06 PM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
###
class Threejs extends Viewer 
	THREE = undefined
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
	info = false;
	edges = undefined;
	
	constructor: (options) -> 
		super(options)
		{color,font, infoOnly} = options
		color = color || 0xffffff
		scale = 1
		@version = $(@element).data("version") || "v1"
		@viewersBaseUrl = stones[0].viewersBaseUrl
	getScene : ()-> scene
	getSceneInfo : ()-> sceneInfo
	getRenderer : ()-> renderer
	convertElement : () ->
		@element.css {
			width : '100%'
			height:'100%'
			"min-width" : 200
			"min-height" : 200
			} 
		@element
	first_init : ()->
		_t = @
		defer = $.Deferred()
		loadScript(@viewersBaseUrl + "atomic/" + @version + "/assets/three.bundle.js").then( 
			()->
				createScene.apply(_t)
				$.when($.get(_t.src  + "SRNSRX.srn"),$.getJSON(_t.src + "Info.json")).then((data,json) ->
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
					info = drawInfo.apply(_t);
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
		onload = ()->
			THREE = GetTHREE();
			defer.resolve(_t);
		_t = @
		defer = $.Deferred()
		if($("[src='" + url + "']")[0])
			$("[src='" + url + "']").on("load",onload)
			return defer;
		s = $("<script>", {
			type: "text/javascript"
		}).appendTo("body").end()[0];
		s.onload = onload
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

		onMousedown = (evt)->
			evt.preventDefault();
			mouseDown = true;
			mouseX = evt.clientX;
			mouseY = evt.clientY;
		onMouseup = (evt)-> 
			evt.preventDefault();
			mouseDown = false;

		onDocumentTouchStart = ( event ) =>
			if (event.touches.length == 1) 
				event.preventDefault();
				mouseX = event.touches[0].pageX;
				mouseY = event.touches[0].pageY;

		onDocumentTouchMove = ( event ) =>
			if (event.touches.length == 1) 
				event.preventDefault();
				deltaX = event.touches[0].pageX - mouseX;
				deltaY = event.touches[0].pageY - mouseY;
				mouseX = event.touches[0].pageX;
				mouseY = event.touches[0].pageY;
				rotateScene(deltaX, deltaY);
				 
		renderer.domElement.addEventListener("touchstart", onDocumentTouchStart , false);
		document.getElementsByTagName("body")[0].addEventListener("touchend", onMouseup , false);
		document.getElementsByTagName("body")[0].addEventListener("touchmove", onDocumentTouchMove , false);
		document.getElementsByTagName("body")[0].addEventListener('mousemove', onMouseMove , false)
		renderer.domElement.addEventListener('mousedown', onMousedown , false)
		document.getElementsByTagName("body")[0].addEventListener('mouseup', onMouseup , false)
	render = () ->
		if(mesh)
			edges.rotation.x = mesh.rotation.x;
			edges.rotation.z = mesh.rotation.z;
			edges.updateMatrix()
		if(!infoOnly)
			requestAnimationFrame(render); 
		renderer.clear();
		# controls.update();
		renderer.render(scene, camera);
		if(mesh && mesh.rotation && parseInt(Math.abs(mesh.rotation.x) % (Math.PI * 2) * 10) == parseInt(Math.PI * 5))
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
		mesh.geometry.center()
		scene.add(rotation(mesh))
		edges = new THREE.EdgesHelper(mesh.clone(), 0x000000)
		edges.renderOrder = 1
		edges.material.linewidth = 2;
		scene.add(rotation(edges))
		edges.position.setZ(100)
		edges.updateMatrix()
		mesh
	rotation = (obj) ->
		obj.rotation.x = Math.PI / 2
		obj
	createScene = ()->
		scene = new THREE.Scene() ;
		sceneInfo = new THREE.Scene() ;
		camera = new THREE.OrthographicCamera(12000 / -2.5, 12000 / 2.5, 12000  / 2.5, 12000  / - 2.5, - 10000, 10000) ;
		scene.add(camera) ;
		camera.position.set(0, 0, 5000) ;
		camera.lookAt(scene.position) ;
		# renderer = new THREE.WebGLRenderer({alpha: true} ) ;
		renderer = new THREE.WebGLRenderer({alpha: true ,logarithmicDepthBuffer: false , antialias : true} ) ;
		renderer.autoClear = false;
		canvasWidht = if @element.height() > @element.width() then @element.width() else @element.height();
		cameraInfo = new THREE.OrthographicCamera(canvasWidht / -2, canvasWidht / 2, canvasWidht  / 2, canvasWidht  / - 2, - 10000, 10000) ;
		sceneInfo.add(cameraInfo)
		renderer.setSize(canvasWidht, canvasWidht) ;
		@element[0].appendChild(renderer.domElement) ;
		@material = new THREE.MeshBasicMaterial({ 
			# map: THREE.ImageUtils.loadTexture('http://www.html5canvastutorials.com/demos/assets/crate.jpg'), 
			color: 0xcccccc, 
			# side:THREE.BackSide, 
			# depthWrite: false, 
			# depthTest: false
		})
		render()
	projectSceneToInfo = (origin)->
		origin.set(origin.x / (camera.right / cameraInfo.right),origin.y / (camera.right / cameraInfo.right),origin.z / (camera.right / cameraInfo.right))
		origin
	drawArrow = (options)->
		{name, origin, length, hex, topToButtom,data,dir,far} = options
		xyFar = if topToButtom then 'x' else 'y';
		origin["set"+  xyFar.toUpperCase()](origin[xyFar] * far)
		origin = projectSceneToInfo(origin)
		# origin.set(origin.x / (camera.right / cameraInfo.right),origin.y / (camera.right / cameraInfo.right),origin.z / (camera.right / cameraInfo.right))
		textObj = drawText({
			texts : data,
			position : origin,
			names : Object.getOwnPropertyNames(data).filter((val)-> val.indexOf("mm") > -1 || val.indexOf("percentages") > -1);
		})
		infoObj = new THREE.Object3D();
		infoObj.name = "info"
		xy = if topToButtom then 'y' else 'x';
		gap = 5
		if topToButtom
			textObj.children.forEach((v)->
				v.position.setX((if origin.x > 0 then gap else -1 * gap) + origin.x + v.geometry.boundingBox[if origin.x > 0 then "max" else "min"].x)
			)
			gap = 0
		else
			gap += Math.max.apply {}, textObj.children.map((v)-> v.geometry.boundingBox.max[xy])
			gap -= Math.min.apply {}, textObj.children.map((v)-> v.geometry.boundingBox.min[xy])
		# gap = (textObj.geometry.boundingBox.max[xy] - textObj.geometry.boundingBox.min[xy]) + 10
		length = (if data['mm'] then data['mm'] else data['height-mm'])  / 2 * 1000 /  (camera.right / cameraInfo.right) - gap / 2 
		infoObj.add(textObj)
		infoObj.add(new THREE.ArrowHelper(dir, origin.clone()["set" + xy.toUpperCase()](origin[xy] + gap/2), length, hex ,5,5))
		if topToButtom
			dir.setY(dir.y * -1)
		else
			dir.setX(dir.x * -1)
		infoObj.add(new THREE.ArrowHelper(dir, origin.clone()["set" + xy.toUpperCase()](origin[xy] -  gap/2), length, hex ,5,5))
		infoObj
	drawText = (options)-> 
		{texts,position, hex ,names,toFixed} = options
		textObj = new THREE.Object3D();
		material = new THREE.MeshBasicMaterial({
			color: options.hex || 0x000000
		});
		options.names.forEach((val,i) =>
			text = switch
				when val.indexOf("mm") > -1 then options.texts[val].toFixed(options.toFixed || 2) + "mm" 
				when val.indexOf("percentages") > -1 then  options.texts[val].toFixed(options.toFixed || 1) + "%" 
				when val.indexOf("deg") > -1 then options.texts[val].toFixed(options.toFixed || 1) + "°" 

			textGeom = new THREE.TextGeometry( text , {
				size: 12,
				font: "gentilis", 
				wieght : "bold"
			});
			textGeom.center();
			gap = switch
				when options.names.length == 1 then 0
				when options.names.length % 2 == 0 and  i == 0 then  textGeom.boundingBox.max.y * 1.3
				when options.names.length % 2 == 0 and  i == 1 then  textGeom.boundingBox.min.y * 1.3
			textMesh = new THREE.Mesh( textGeom, material );
			textMesh.lookAt(camera.position)
			textMesh.position.set(position.x,position.y + gap,position.z )
			textObj.add(textMesh)
		);
		textObj
	
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
				data : info['Length'],
				dir :  new THREE.Vector3( 1, 0, 0 )
				far : 1.50
			}));
		# draw the table line
		infoObj.add( 
			drawArrow({
				origin  : new THREE.Vector3( 0, mesh.geometry.boundingBox.max.z, 0 ),
				hex : hex, 
				topToButtom : false,
				data : info['Table Size']
				dir :  new THREE.Vector3( 1, 0, 0 )
				far :  1.25
			}));
		# draw Crown
		Crown =  new THREE.Vector3( 
			mesh.geometry.boundingBox.max.x ,
			mesh.geometry.boundingBox.max.z - info['Crown']['height-mm'] * 1000 / 2,
			0 )
		infoObj.add(drawArrow({
				origin  : Crown.clone()
				hex : hex, 
				topToButtom : true,
				data : info['Crown']
				# dir :  new THREE.Vector3( mesh.geometry.boundingBox.max.x , Crown +  1 , 0 )
				dir :  Crown.clone().setY(Crown.y + 1)
				far : 1.05
			})) 
		# draw Pavilion
		Pavilion =  new THREE.Vector3( 
			mesh.geometry.boundingBox.max.x,
			mesh.geometry.boundingBox.min.z + info['Pavilion']['height-mm'] * 1000 / 2,
			0);
		infoObj.add(drawArrow({
				origin  : Pavilion.clone()
				hex : hex, 
				topToButtom : true,
				data : info['Pavilion']
				# dir :  new THREE.Vector3( mesh.geometry.boundingBox.max.x , Pavilion *  -1 , 0 )
				dir : Pavilion.clone().setY(Pavilion.y * -1)
				far : 1.05
			}))
		# draw TotalDepth
		TotalDepth =  new THREE.Vector3( 
			mesh.geometry.boundingBox.min.x,
			mesh.geometry.boundingBox.min.z + info['Total Depth']['mm'] * 1000 / 2, 
			0 
			)
		infoObj.add(drawArrow({
				origin  : TotalDepth.clone()
				hex : hex, 
				topToButtom : true,
				data : info['Total Depth']
				# dir :  new THREE.Vector3( mesh.geometry.boundingBox.min.x , TotalDepth +  1 , 0 )
				dir :  TotalDepth.clone().setY(TotalDepth.y + 1)
				far : 1.00
			}))
		# draw Culet Size percentages
		infoObj.add(drawText({
				texts : info['Culet Size']
				position : projectSceneToInfo(new THREE.Vector3( 0, mesh.geometry.boundingBox.min.z * 1.1, 0 )),
				names : ['percentages']
				toFixed : 2
			}))
		# draw Crown angel-deg
		infoObj.add(drawText({
				texts : info['Crown']
				position : projectSceneToInfo(new THREE.Vector3( 
					(info['Table Size']['mm']  + (info['Length']['mm'] - info['Table Size']['mm']) / 2 ) * 500 * 1.2, 
					Crown.y * 1.05, 
					0 
					)),
				names : ['angel-deg']
				toFixed : "0"
			}))
		grildFarX = 1.25
		grildFarY = 0.1
		# draw Pavilion angel-deg
		infoObj.add(drawText({
				texts : info['Pavilion']
				position : projectSceneToInfo(new THREE.Vector3( 
					(info['Length']['mm'] / 2) * 500 * 1.2, 
					Pavilion.y * 1.1, 
					0 
					)),
				names : ['angel-deg']
				toFixed : "0"
			}))
		# draw Girdle Thickness-mm
		GirdleTopTrue = new THREE.Vector3( 
						mesh.geometry.boundingBox.min.x, 
						Crown.y - info['Crown']['height-mm'] * 500, 
						0
					)
		GirdleTop = projectSceneToInfo(GirdleTopTrue.clone())
		ThicknessMmText = drawText({
				texts : info['Girdle']
				position : GirdleTop.clone().setX(GirdleTop.x * grildFarX).setY(GirdleTop.y  + GirdleTop.y * grildFarY)
				names : ['Thickness-mm']
			})
		material = new THREE.LineBasicMaterial({
			color: hex
		});

		geometry = new THREE.Geometry();
		geometry.vertices.push(
			new THREE.Vector3( 
				ThicknessMmText.children[0].position.x + ThicknessMmText.children[0].geometry.boundingBox.max.x,
				ThicknessMmText.children[0].position.y,
				ThicknessMmText.children[0].position.z
				),
			new THREE.Vector3( 
				GirdleTop.x,
				GirdleTop.y,
				GirdleTop.z,
				)
		);
		line = new THREE.Line(geometry, material );
		infoObj.add ThicknessMmText
		infoObj.add line
		# draw Girdle Thickness-percentages
		GirdleBottmTrue = new THREE.Vector3( 
						mesh.geometry.boundingBox.min.x, 
						Pavilion.y + info['Pavilion']['height-mm'] * 500, 
						0
					)
		GirdleBottm = projectSceneToInfo(GirdleBottmTrue.clone())
		ThicknessPercentageText = drawText({
				texts : info['Girdle']
				position : GirdleBottm.clone().setX(GirdleBottm.x * grildFarX).setY(GirdleBottm.y  - GirdleBottm.y * grildFarY),
				names : ['Thickness-percentages']
			})
		ThicknessPercentageText.position.setX(ThicknessMmText.position.x + ThicknessMmText.children[0].geometry.boundingBox.max.x - ThicknessPercentageText.children[0].geometry.boundingBox.max.x)
		material = new THREE.LineBasicMaterial({
			color: hex
		});
		geometry = new THREE.Geometry();
		geometry.vertices.push(
			new THREE.Vector3( 
				ThicknessMmText.children[0].position.x + ThicknessMmText.children[0].geometry.boundingBox.max.x,
				ThicknessPercentageText.children[0].position.y,
				ThicknessPercentageText.children[0].position.z
				),
			new THREE.Vector3( 
				GirdleBottm.x,
				GirdleBottm.y,
				GirdleBottm.z,
				)
		);
		line = new THREE.Line(geometry, material );
		infoObj.add ThicknessPercentageText
		infoObj.add line
		sceneInfo.add(infoObj)
		render();
		undefined


@Threejs = Threejs
		
