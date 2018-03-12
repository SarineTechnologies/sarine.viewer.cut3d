class Cut3d extends Viewer 
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
	canvasWidth = undefined
	fontSize = undefined
	color = undefined
	font = undefined
	mouseDown = false;
	mouseX = false;
	mouseY = false;
	infoOnly = false;
	info = false;
	edges = undefined;
	shape = undefined;
	cameraWidthHeight = undefined;
	cameraNearFar = undefined;

	constructor: (options) -> 
		super(options)
		{color, font, infoOnly} = options   
		
		cut3DViewConf = (window.configuration.experiences.filter((i)-> return i.atom == 'cut3DView'))[0]		
		color = if cut3DViewConf.color then cut3DViewConf.color.toLowerCase() else 0xcbe3ff		
		scale = if cut3DViewConf.scale && (!isNaN(parseFloat(cut3DViewConf.scale)) && isFinite(cut3DViewConf.scale)) then parseFloat(cut3DViewConf.scale) else 1
		
		cameraWidthHeight = 12000
		cameraNearFar = 10000
		shape = options.stoneProperties.shape.toLowerCase()
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
		#temp support only for round/modifiedround and if webgl not supported
		#if ((shape != 'round' &&  shape != 'modifiedround') || !@webglDetect())
		#	@loadImage(@callbackPic).then (img)->
		#		canvas = $("<canvas >")
		#		canvas.attr({"class": "no_stone" ,"width": img.width, "height": img.height}) 
		#		canvas[0].getContext("2d").drawImage(img, 0, 0, img.width, img.height)
		#		_t.element.append(canvas)
		#		defer.resolve(_t) 
		#	defer
		#end of temp
		#else
		# @showLoader(_t)
		@setCut3dHelperContainer(_t)
		loadScript(@viewersBaseUrl + "atomic/" + @version + "/assets/three.min.js").then( 
			()->		
				#cssPath = _t.viewersBaseUrl + "atomic/" + _t.version + "/assets/cut3d.css"	
				#$('<link>').appendTo('head').attr({type : 'text/css', rel : 'stylesheet'}).attr('href', cssPath)
				@fullSrnSrc = if _t.src.indexOf('##FILE_NAME##') != -1 then _t.src.replace('##FILE_NAME##', 'SRNSRX.srn') else _t.src
				# info.json temp. disabled: @fullJsonSrc = if _t.src.indexOf('##FILE_NAME##') != -1 then _t.src.replace('##FILE_NAME##', 'Info.json') else _t.src
				# info.json temp. disabled: $.when($.get(@fullSrnSrc),$.getJSON(@fullJsonSrc)).then((data,json) ->
				$.get(@fullSrnSrc).then((data) ->
					# mm = json[0]['Length']['mm']
					# scale = 1 # 0.0436 * mm * mm - 0.7119 * mm + 3.6648 #scale the stone to look always the same
					
					createScene.apply(_t)
					# info = json[0]
					# info.json temp. disabled: rawData = data[0] 
					rawData = data
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
					# info = drawInfo.apply(_t);
		
					# _t.hideLoader()	
					if(!infoOnly)
						addMouseHandler.apply(_t);
					defer.resolve(_t) 
					)
				.fail ()-> 
					_t.loadImage(_t.callbackPic).then (img)->
						canvas = $("<canvas >")
						canvas.attr({"class": "no_stone" ,"width": img.width, "height": img.height}) 
						canvas[0].getContext("2d").drawImage(img, 0, 0, img.width, img.height)
						# _t.hideLoader()
						_t.element.append(canvas)
						defer.resolve(_t) 	
					defer					
			)
		defer 
	full_init : ()->  
		defer = $.Deferred()				
		defer.resolve(@)
		defer
	# showLoader : (_t)->
	#	spinner = $('<div class="cut3d-spinner"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div>')
	#	_t.element.append spinner	
	#hideLoader :()->
	#	$('.cut3d-spinner').hide()

	# set empty div for some UI porposes, such as to add 360.png icon
	setCut3dHelperContainer : (_t)->
		spinner = $('<div class="cut3dHelper"></div>')
		_t.element.append spinner

	webglDetect : (return_context) ->
	  if ! !window.WebGLRenderingContext
	    canvas = document.createElement('canvas')
	    names = [
	      'webgl'
	      'experimental-webgl'
	      'moz-webgl'
	      'webkit-3d'
	    ]
	    context = false
	    i = 0
	    while i < names.length
	      try
	        context = canvas.getContext(names[i])
	        if context and typeof context.getParameter == 'function'
	          # WebGL is enabled
	          if return_context
	            # return WebGL object if the function's argument is present
	            return {
	              name: names[i]
	              gl: context
	            }
	          # else, return just true
	          return true
	      catch e
	      i++
	    # WebGL is supported, but disabled
	    return false
	  # WebGL not supported
	  false

	play : () -> return		
	stop : () -> return		
	loadScript = (url)->
		onload = ()->
			THREE = window.THREE # GetTHREE(); 			 
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
		containerElement = document.getElementsByClassName('viewer cut3DView');
		containerElement[0].addEventListener("touchend", onMouseup , false);
		containerElement[0].addEventListener("touchmove", onDocumentTouchMove , false);
		containerElement[0].addEventListener('mousemove', onMouseMove , false)
		renderer.domElement.addEventListener('mousedown', onMousedown , false)
		containerElement[0].addEventListener('mouseup', onMouseup , false)
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
		if(mesh && mesh.rotation && (parseInt(mesh.rotation.x  / (Math.PI / 2) + 0.95)  - 1 ) % 4  == 0 && (parseInt(mesh.rotation.x  / (Math.PI / 2) + 0.05)  - 1 ) % 4  == 0 )
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
			if(vert.length > 1)
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
		# console.log "data.mesh", data, mesh
		mesh
	rotation = (obj) ->		
		obj.rotation.x = Math.PI / 2
		#obj.rotation.z = -8.3; TODO - take the value from lengthDirection
		obj
	createScene = ()->
		scene = new THREE.Scene() ;
		sceneInfo = new THREE.Scene() ;
		camera = new THREE.OrthographicCamera(cameraWidthHeight / -2.5, cameraWidthHeight / 2.5, cameraWidthHeight  / 2.5, cameraWidthHeight  / - 2.5, - cameraNearFar, cameraNearFar) ;
		scene.add(camera) ;
		camera.position.set(0, 0, 5000) 		
		camera.lookAt(scene.position) 
		# renderer = new THREE.WebGLRenderer({alpha: true} ) ;
		renderer = new THREE.WebGLRenderer({alpha: true ,logarithmicDepthBuffer: false , antialias : true} ) ;
		renderer.autoClear = false;
		canvasWidth = if @element.parent().height() > @element.parent().width() then @element.parent().width() else @element.parent().height();
		cameraInfo = new THREE.OrthographicCamera(canvasWidth / -2, canvasWidth / 2, canvasWidth  / 2, canvasWidth  / - 2, - cameraNearFar, cameraNearFar) ;
		sceneInfo.add(cameraInfo)

		# create event for top, side and bottom on the canvas element
		$('.viewer').on("top",()-> mesh.rotation.x = Math.PI)
		$('.viewer').on("side",()-> mesh.rotation.x = Math.PI/2)
		$('.viewer').on("bottom",()-> mesh.rotation.x = 0)

		# create event for toggle transparent on the canvas element
		$('.viewer').on("transparent",()-> 
			mesh.material.opacity = if mesh.material.opacity == 1 then 0 else 1
			mesh.material.transparent = !mesh.material.transparent
		)
		renderer.setPixelRatio( if window.devicePixelRatio then window.devicePixelRatio else 1)
		renderer.setSize(canvasWidth, canvasWidth)
		@element[0].appendChild(renderer.domElement) ;
		@material = new THREE.MeshBasicMaterial({ 
			# map: THREE.ImageUtils.loadTexture('http://www.html5canvastutorials.com/demos/assets/crate.jpg'), 
			color: color
			# side:THREE.BackSide, 
			# depthWrite: false, 
			# depthTest: false  
		})
		render()
	projectSceneToInfo = (origin)->
		origin.set(origin.x / (camera.right / cameraInfo.right), origin.y / (camera.top / cameraInfo.top),origin.z / (camera.right / cameraInfo.right))		
		origin
	drawArrow = (options)->
		{name, origin, length, hex, topToButtom,data,dir,far} = options
		xyFar = if topToButtom then 'x' else 'y';
		origin["set"+  xyFar.toUpperCase()](origin[xyFar] * far)
		origin = projectSceneToInfo(origin)		
				
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
		length = (if data['mm'] then data['mm']  else data['height-mm'])  / 2 * 1000 /  (camera.right / cameraInfo.right) - gap / 2 
		length = length * scale
		infoObj.add(textObj)

		#draw half arrow
		infoObj.add(new THREE.ArrowHelper(dir, origin.clone()["set" + xy.toUpperCase()](origin[xy] + gap/2), length, hex ,5,5))

		#set arrow direction (right -> left /left -> right / top -> bottom / bottom -> top)
		if topToButtom
			dir.setY(dir.y * -1)
		else
			dir.setX(dir.x * -1)

		#draw the arrow second half
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
				size: if (6 + (scale * 4)) > 10 then 10 else (6 + (scale * 4)), 
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

		pavilionEndY = info['Total Depth']['mm'] * 1000 / 2		
		girdleY = pavilionEndY - (info['Crown']['height-mm'] * 1000)
		
		# draw Crown
		Crown =  new THREE.Vector3( 
			mesh.geometry.boundingBox.max.x ,
			(girdleY + (info['Crown']['height-mm'] * 1000 / 2)) * scale,
			0 )
		infoObj.add(drawArrow({
				origin  : Crown.clone()
				hex : hex, 
				topToButtom : true,
				data : info['Crown']
				dir :  Crown.clone().setY(Crown.y + 1)
				far : 1.05
			})) 
		# draw Pavilion
		
		Pavilion =  new THREE.Vector3( 
			mesh.geometry.boundingBox.max.x,
			(girdleY- pavilionEndY) / 2 * scale,
			0);
		infoObj.add(drawArrow({
				origin  : Pavilion.clone()
				hex : hex, 
				topToButtom : true,
				data : info['Pavilion']
				dir : Pavilion.clone().setY(Pavilion.y * -1)
				far : 1.05
			}))
		# draw TotalDepth
		TotalDepth =  new THREE.Vector3( 
			mesh.geometry.boundingBox.min.x,
			0,
			0 
			)
		infoObj.add(drawArrow({
				origin  : TotalDepth.clone()
				hex : hex, 
				topToButtom : true,
				data : info['Total Depth']
				dir :  TotalDepth.clone().setY(TotalDepth.y + 1)
				far : 1.05
			}))
		# draw Culet Size percentages
		infoObj.add(drawText({
				texts : info['Culet Size']
				position : projectSceneToInfo(new THREE.Vector3( 0, mesh.geometry.boundingBox.min.z * 1.1, 0 )),
				names : ['percentages']
				toFixed : 2
			}))
		# draw Crown angel-deg
		rightTableSizeX = info['Table Size']['mm'] * 1000 / 2
		rightLengthX = info['Length']['mm'] * 1000 / 2
		infoObj.add(drawText({
				texts : info['Crown']
				position : projectSceneToInfo(new THREE.Vector3( 
					(rightTableSizeX +  (7 * (rightLengthX - rightTableSizeX)) / 8) * scale, 
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
					(2 * rightLengthX / 3) * scale,  
					Pavilion.y * 1.1, 
					0 
					)),
				names : ['angel-deg']
				toFixed : "0"
			}))
		# draw Girdle Thickness-mm
		GirdleTopTrue = new THREE.Vector3( 
						mesh.geometry.boundingBox.min.x * 1.05, 
						girdleY  * scale,
						0
					)
		GirdleTop = projectSceneToInfo(GirdleTopTrue.clone())
		ThicknessMmText = drawText({
				texts : info['Girdle']
				position : GirdleTop.clone().setX((GirdleTop.x * grildFarX)).setY(GirdleTop.y  + GirdleTop.y * grildFarY)
				names : ['Thickness-mm']
			})

		ThicknessMmText.position.setX(ThicknessMmText.position.x - 5)
		
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
						mesh.geometry.boundingBox.min.x * 1.05, 
						(girdleY - (info['Girdle']['Thickness-mm'] * 1000)) * scale,
						0
					)
		GirdleBottm = projectSceneToInfo(GirdleBottmTrue.clone())
		ThicknessPercentageText = drawText({
				texts : info['Girdle']
				position : GirdleBottm.clone().setX(GirdleBottm.x * grildFarX).setY(GirdleBottm.y  - GirdleBottm.y * grildFarY),
				names : ['Thickness-percentages']
			})
		ThicknessPercentageText.position.setX((ThicknessMmText.position.x + ThicknessMmText.children[0].geometry.boundingBox.max.x - ThicknessPercentageText.children[0].geometry.boundingBox.max.x) * 0.75)		
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


@Cut3d = Cut3d
		
