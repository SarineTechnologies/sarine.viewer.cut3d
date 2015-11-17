
/*!
sarine.viewer.threejs - v0.10.0 -  Tuesday, November 17th, 2015, 3:12:45 PM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
 */

(function() {
  var Threejs, Viewer,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Viewer = (function() {
    var error, rm;

    rm = ResourceManager.getInstance();

    function Viewer(options) {
      console.log("");
      this.first_init_defer = $.Deferred();
      this.full_init_defer = $.Deferred();
      this.src = options.src, this.element = options.element, this.autoPlay = options.autoPlay, this.callbackPic = options.callbackPic;
      this.id = this.element[0].id;
      this.element = this.convertElement();
      Object.getOwnPropertyNames(Viewer.prototype).forEach(function(k) {
        if (this[k].name === "Error") {
          return console.error(this.id, k, "Must be implement", this);
        }
      }, this);
      this.element.data("class", this);
      this.element.on("play", function(e) {
        return $(e.target).data("class").play.apply($(e.target).data("class"), [true]);
      });
      this.element.on("stop", function(e) {
        return $(e.target).data("class").stop.apply($(e.target).data("class"), [true]);
      });
      this.element.on("cancel", function(e) {
        return $(e.target).data("class").cancel().apply($(e.target).data("class"), [true]);
      });
    }

    error = function() {
      return console.error(this.id, "must be implement");
    };

    Viewer.prototype.first_init = Error;

    Viewer.prototype.full_init = Error;

    Viewer.prototype.play = Error;

    Viewer.prototype.stop = Error;

    Viewer.prototype.convertElement = Error;

    Viewer.prototype.cancel = function() {
      return rm.cancel(this);
    };

    Viewer.prototype.loadImage = function(src) {
      return rm.loadImage.apply(this, [src]);
    };

    Viewer.prototype.setTimeout = function(delay, callback) {
      return rm.setTimeout.apply(this, [this.delay, callback]);
    };

    return Viewer;

  })();

  this.Viewer = Viewer;

  Threejs = (function(_super) {
    var THREE, addMouseHandler, camera, cameraInfo, canvasWidht, color, controls, createScene, drawArrow, drawInfo, drawMesh, drawText, edges, font, fontSize, info, infoOnly, loadScript, mesh, mouseDown, mouseX, mouseY, projectSceneToInfo, render, renderer, rotateScene, rotation, scale, scene, sceneInfo, shape, url;

    __extends(Threejs, _super);

    THREE = void 0;

    scene = void 0;

    sceneInfo = void 0;

    renderer = void 0;

    controls = void 0;

    mesh = void 0;

    Threejs.material = void 0;

    camera = void 0;

    cameraInfo = void 0;

    scale = void 0;

    url = void 0;

    info = void 0;

    canvasWidht = void 0;

    fontSize = void 0;

    color = void 0;

    font = void 0;

    mouseDown = false;

    mouseX = false;

    mouseY = false;

    infoOnly = false;

    info = false;

    edges = void 0;

    shape = void 0;

    function Threejs(options) {
      Threejs.__super__.constructor.call(this, options);
      color = options.color, font = options.font, infoOnly = options.infoOnly;
      color = color || 0xffffff;
      scale = 1;
      shape = options.stoneProperties.shape.toLowerCase();
      this.version = $(this.element).data("version") || "v1";
      this.viewersBaseUrl = stones[0].viewersBaseUrl;
    }

    Threejs.prototype.getScene = function() {
      return scene;
    };

    Threejs.prototype.getSceneInfo = function() {
      return sceneInfo;
    };

    Threejs.prototype.getRenderer = function() {
      return renderer;
    };

    Threejs.prototype.convertElement = function() {
      this.element.css({
        width: '100%',
        height: '100%',
        "min-width": 200,
        "min-height": 200
      });
      return this.element;
    };

    Threejs.prototype.first_init = function() {
      var defer, _t;
      _t = this;
      defer = $.Deferred();
      if (shape !== 'round' && shape !== 'modifiedround') {
        this.loadImage(this.callbackPic).then(function(img) {
          var canvas;
          canvas = $("<canvas >");
          canvas.attr({
            "class": "no_stone",
            "width": img.width,
            "height": img.height
          });
          canvas[0].getContext("2d").drawImage(img, 0, 0, img.width, img.height);
          _t.element.append(canvas);
          return defer.resolve(_t);
        });
        defer;
      } else {
        loadScript(this.viewersBaseUrl + "atomic/" + this.version + "/assets/three.bundle.js").then(function() {
          return $.when($.get(_t.src + "SRNSRX.srn"), $.getJSON(_t.src + "Info.json")).then(function(data, json) {
            var rawData;
            createScene.apply(_t);
            info = json[0];
            rawData = data[0].replace(/\s/g, "^").match(/Mesh(.*?)}/)[0].replace(/[Mesh|{|}]/g, "").split("^").filter(function(s) {
              return s.length > 0;
            });
            drawMesh.apply(_t, [
              {
                vertices: rawData.slice(1, +parseInt(rawData[0]) + 1 || 9e9).map(function(str) {
                  return str.replace(',', '').split(';').slice(0, 3);
                }),
                polygons: rawData.slice(parseInt(rawData[0]) + 2, +rawData.length + 1 || 9e9).map(function(str) {
                  return str.replace(/(\d+;)/, '').replace(/(;;|;,)/, "").split(",");
                })
              }
            ]);
            info = drawInfo.apply(_t);
            if (!infoOnly) {
              addMouseHandler.apply(_t);
            }
            return defer.resolve(_t);
          }).fail(function() {
            _t.loadImage(_t.callbackPic).then(function(img) {
              var canvas;
              canvas = $("<canvas >");
              canvas.attr({
                "class": "no_stone",
                "width": img.width,
                "height": img.height
              });
              canvas[0].getContext("2d").drawImage(img, 0, 0, img.width, img.height);
              _t.element.append(canvas);
              return defer.resolve(_t);
            });
            return defer;
          });
        });
      }
      return defer;
    };

    Threejs.prototype.full_init = function() {
      var defer;
      defer = $.Deferred();
      defer.resolve(this);
      return defer;
    };

    Threejs.prototype.play = function() {};

    Threejs.prototype.stop = function() {};

    loadScript = function(url) {
      var defer, onload, s, _t;
      onload = function() {
        THREE = GetTHREE();
        return defer.resolve(_t);
      };
      _t = this;
      defer = $.Deferred();
      if (($("[src='" + url + "']")[0])) {
        $("[src='" + url + "']").on("load", onload);
        return defer;
      }
      s = $("<script>", {
        type: "text/javascript"
      }).appendTo("body").end()[0];
      s.onload = onload;
      s.src = url;
      return defer;
    };

    rotateScene = function(deltaX, deltaY) {
      mesh.rotation.x += deltaY / 100;
      return mesh.rotation.z -= deltaX / 100;
    };

    addMouseHandler = function() {
      var canvas, onDocumentTouchMove, onDocumentTouchStart, onMouseMove, onMousedown, onMouseup;
      canvas = renderer.domElement;
      onMouseMove = function(evt) {
        var deltaX, deltaY;
        if (!mouseDown) {
          return;
        }
        evt.preventDefault();
        deltaX = evt.clientX - mouseX;
        deltaY = evt.clientY - mouseY;
        mouseX = evt.clientX;
        mouseY = evt.clientY;
        return rotateScene(deltaX, deltaY);
      };
      onMousedown = function(evt) {
        evt.preventDefault();
        mouseDown = true;
        mouseX = evt.clientX;
        return mouseY = evt.clientY;
      };
      onMouseup = function(evt) {
        evt.preventDefault();
        return mouseDown = false;
      };
      onDocumentTouchStart = (function(_this) {
        return function(event) {
          if (event.touches.length === 1) {
            event.preventDefault();
            mouseX = event.touches[0].pageX;
            return mouseY = event.touches[0].pageY;
          }
        };
      })(this);
      onDocumentTouchMove = (function(_this) {
        return function(event) {
          var deltaX, deltaY;
          if (event.touches.length === 1) {
            event.preventDefault();
            deltaX = event.touches[0].pageX - mouseX;
            deltaY = event.touches[0].pageY - mouseY;
            mouseX = event.touches[0].pageX;
            mouseY = event.touches[0].pageY;
            return rotateScene(deltaX, deltaY);
          }
        };
      })(this);
      renderer.domElement.addEventListener("touchstart", onDocumentTouchStart, false);
      document.getElementsByTagName("body")[0].addEventListener("touchend", onMouseup, false);
      document.getElementsByTagName("body")[0].addEventListener("touchmove", onDocumentTouchMove, false);
      document.getElementsByTagName("body")[0].addEventListener('mousemove', onMouseMove, false);
      renderer.domElement.addEventListener('mousedown', onMousedown, false);
      return document.getElementsByTagName("body")[0].addEventListener('mouseup', onMouseup, false);
    };

    render = function() {
      if (mesh) {
        edges.rotation.x = mesh.rotation.x;
        edges.rotation.z = mesh.rotation.z;
        edges.updateMatrix();
      }
      if (!infoOnly) {
        requestAnimationFrame(render);
      }
      renderer.clear();
      renderer.render(scene, camera);
      if (mesh && mesh.rotation && (parseInt(mesh.rotation.x / (Math.PI / 2) + 0.95) - 1) % 4 === 0 && (parseInt(mesh.rotation.x / (Math.PI / 2) + 0.05) - 1) % 4 === 0) {
        return renderer.render(sceneInfo, cameraInfo);
      }
    };

    drawMesh = function(data) {
      var geom, setFaces, vert, _i, _j, _len, _len1, _ref, _ref1;
      setFaces = function(points, geometry) {
        geometry.faces.push(new THREE.Face3(points[0], points[1], points[2]));
        if (points.length !== 3) {
          points.splice(1, 1);
          setFaces(points, geometry);
        }
        return geometry.computeFaceNormals();
      };
      geom = new THREE.Geometry();
      _ref = data.vertices;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        vert = _ref[_i];
        geom.vertices.push(new THREE.Vector3(vert[0] * scale, vert[1] * scale, vert[2] * scale));
      }
      _ref1 = data.polygons;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        vert = _ref1[_j];
        setFaces(vert, geom);
      }
      mesh = new THREE.Mesh(geom, this.material);
      mesh.material.opacity = 1;
      mesh.material.transparent = false;
      mesh.geometry.center();
      scene.add(rotation(mesh));
      edges = new THREE.EdgesHelper(mesh.clone(), 0x000000);
      edges.renderOrder = 1;
      edges.material.linewidth = 2;
      scene.add(rotation(edges));
      edges.position.setZ(100);
      edges.updateMatrix();
      return mesh;
    };

    rotation = function(obj) {
      obj.rotation.x = Math.PI / 2;
      return obj;
    };

    createScene = function() {
      scene = new THREE.Scene();
      sceneInfo = new THREE.Scene();
      camera = new THREE.OrthographicCamera(13000 / -2.5, 13000 / 2.5, 13000 / 2.5, 13000 / -2.5, -10000, 10000);
      scene.add(camera);
      camera.position.set(0, 0, 5000);
      camera.lookAt(scene.position);
      renderer = new THREE.WebGLRenderer({
        alpha: true,
        logarithmicDepthBuffer: false,
        antialias: true
      });
      renderer.autoClear = false;
      canvasWidht = this.element.height() > this.element.width() ? this.element.width() : this.element.height();
      cameraInfo = new THREE.OrthographicCamera(canvasWidht / -2, canvasWidht / 2, canvasWidht / 2, canvasWidht / -2, -10000, 10000);
      sceneInfo.add(cameraInfo);
      $(renderer.domElement).on("top", function() {
        return mesh.rotation.x = Math.PI;
      });
      $(renderer.domElement).on("side", function() {
        return mesh.rotation.x = Math.PI / 2;
      });
      $(renderer.domElement).on("bottom", function() {
        return mesh.rotation.x = 0;
      });
      $(renderer.domElement).on("transparent", function() {
        mesh.material.opacity = mesh.material.opacity === 1 ? 0 : 1;
        return mesh.material.transparent = !mesh.material.transparent;
      });
      renderer.setPixelRatio(window.devicePixelRatio ? window.devicePixelRatio : 1);
      renderer.setSize(canvasWidht, canvasWidht);
      this.element[0].appendChild(renderer.domElement);
      this.material = new THREE.MeshBasicMaterial({
        color: 0xcccccc
      });
      return render();
    };

    projectSceneToInfo = function(origin) {
      origin.set(origin.x / (camera.right / cameraInfo.right), origin.y / (camera.right / cameraInfo.right), origin.z / (camera.right / cameraInfo.right));
      return origin;
    };

    drawArrow = function(options) {
      var data, dir, far, gap, hex, infoObj, length, name, origin, textObj, topToButtom, xy, xyFar;
      name = options.name, origin = options.origin, length = options.length, hex = options.hex, topToButtom = options.topToButtom, data = options.data, dir = options.dir, far = options.far;
      xyFar = topToButtom ? 'x' : 'y';
      origin["set" + xyFar.toUpperCase()](origin[xyFar] * far);
      origin = projectSceneToInfo(origin);
      textObj = drawText({
        texts: data,
        position: origin,
        names: Object.getOwnPropertyNames(data).filter(function(val) {
          return val.indexOf("mm") > -1 || val.indexOf("percentages") > -1;
        })
      });
      infoObj = new THREE.Object3D();
      infoObj.name = "info";
      xy = topToButtom ? 'y' : 'x';
      gap = 5;
      if (topToButtom) {
        textObj.children.forEach(function(v) {
          return v.position.setX((origin.x > 0 ? gap : -1 * gap) + origin.x + v.geometry.boundingBox[origin.x > 0 ? "max" : "min"].x);
        });
        gap = 0;
      } else {
        gap += Math.max.apply({}, textObj.children.map(function(v) {
          return v.geometry.boundingBox.max[xy];
        }));
        gap -= Math.min.apply({}, textObj.children.map(function(v) {
          return v.geometry.boundingBox.min[xy];
        }));
      }
      length = (data['mm'] ? data['mm'] : data['height-mm']) / 2 * 1000 / (camera.right / cameraInfo.right) - gap / 2;
      infoObj.add(textObj);
      infoObj.add(new THREE.ArrowHelper(dir, origin.clone()["set" + xy.toUpperCase()](origin[xy] + gap / 2), length, hex, 5, 5));
      if (topToButtom) {
        dir.setY(dir.y * -1);
      } else {
        dir.setX(dir.x * -1);
      }
      infoObj.add(new THREE.ArrowHelper(dir, origin.clone()["set" + xy.toUpperCase()](origin[xy] - gap / 2), length, hex, 5, 5));
      return infoObj;
    };

    drawText = function(options) {
      var hex, material, names, position, textObj, texts, toFixed;
      texts = options.texts, position = options.position, hex = options.hex, names = options.names, toFixed = options.toFixed;
      textObj = new THREE.Object3D();
      material = new THREE.MeshBasicMaterial({
        color: options.hex || 0x000000
      });
      options.names.forEach((function(_this) {
        return function(val, i) {
          var gap, text, textGeom, textMesh;
          text = (function() {
            switch (false) {
              case !(val.indexOf("mm") > -1):
                return options.texts[val].toFixed(options.toFixed || 2) + "mm";
              case !(val.indexOf("percentages") > -1):
                return options.texts[val].toFixed(options.toFixed || 1) + "%";
              case !(val.indexOf("deg") > -1):
                return options.texts[val].toFixed(options.toFixed || 1) + "°";
            }
          })();
          textGeom = new THREE.TextGeometry(text, {
            size: 10,
            font: "gentilis",
            wieght: "bold"
          });
          textGeom.center();
          gap = (function() {
            switch (false) {
              case options.names.length !== 1:
                return 0;
              case !(options.names.length % 2 === 0 && i === 0):
                return textGeom.boundingBox.max.y * 1.3;
              case !(options.names.length % 2 === 0 && i === 1):
                return textGeom.boundingBox.min.y * 1.3;
            }
          })();
          textMesh = new THREE.Mesh(textGeom, material);
          textMesh.lookAt(camera.position);
          textMesh.position.set(position.x, position.y + gap, position.z);
          return textObj.add(textMesh);
        };
      })(this));
      return textObj;
    };

    drawInfo = function(hex) {
      var Crown, GirdleBottm, GirdleBottmTrue, GirdleTop, GirdleTopTrue, Pavilion, ThicknessMmText, ThicknessPercentageText, TotalDepth, geometry, grildFarX, grildFarY, infoObj, line, material;
      hex = hex || 0x000000;
      infoObj = new THREE.Object3D();
      infoObj.name = "info";
      infoObj.add(drawArrow({
        origin: new THREE.Vector3(0, mesh.geometry.boundingBox.max.z, 0),
        hex: hex,
        topToButtom: false,
        data: info['Length'],
        dir: new THREE.Vector3(1, 0, 0),
        far: 1.50
      }));
      infoObj.add(drawArrow({
        origin: new THREE.Vector3(0, mesh.geometry.boundingBox.max.z, 0),
        hex: hex,
        topToButtom: false,
        data: info['Table Size'],
        dir: new THREE.Vector3(1, 0, 0),
        far: 1.25
      }));
      Crown = new THREE.Vector3(mesh.geometry.boundingBox.max.x, mesh.geometry.boundingBox.max.z - info['Crown']['height-mm'] * 1000 / 2, 0);
      infoObj.add(drawArrow({
        origin: Crown.clone(),
        hex: hex,
        topToButtom: true,
        data: info['Crown'],
        dir: Crown.clone().setY(Crown.y + 1),
        far: 1.05
      }));
      Pavilion = new THREE.Vector3(mesh.geometry.boundingBox.max.x, mesh.geometry.boundingBox.min.z + info['Pavilion']['height-mm'] * 1000 / 2, 0);
      infoObj.add(drawArrow({
        origin: Pavilion.clone(),
        hex: hex,
        topToButtom: true,
        data: info['Pavilion'],
        dir: Pavilion.clone().setY(Pavilion.y * -1),
        far: 1.05
      }));
      TotalDepth = new THREE.Vector3(mesh.geometry.boundingBox.min.x, mesh.geometry.boundingBox.min.z + info['Total Depth']['mm'] * 1000 / 2, 0);
      infoObj.add(drawArrow({
        origin: TotalDepth.clone(),
        hex: hex,
        topToButtom: true,
        data: info['Total Depth'],
        dir: TotalDepth.clone().setY(TotalDepth.y + 1),
        far: 1.05
      }));
      infoObj.add(drawText({
        texts: info['Culet Size'],
        position: projectSceneToInfo(new THREE.Vector3(0, mesh.geometry.boundingBox.min.z * 1.1, 0)),
        names: ['percentages'],
        toFixed: 2
      }));
      infoObj.add(drawText({
        texts: info['Crown'],
        position: projectSceneToInfo(new THREE.Vector3((info['Table Size']['mm'] + (info['Length']['mm'] - info['Table Size']['mm']) / 2) * 500 * 1.2, Crown.y * 1.05, 0)),
        names: ['angel-deg'],
        toFixed: "0"
      }));
      grildFarX = 1.25;
      grildFarY = 0.1;
      infoObj.add(drawText({
        texts: info['Pavilion'],
        position: projectSceneToInfo(new THREE.Vector3((info['Length']['mm'] / 2) * 500 * 1.2, Pavilion.y * 1.1, 0)),
        names: ['angel-deg'],
        toFixed: "0"
      }));
      GirdleTopTrue = new THREE.Vector3(mesh.geometry.boundingBox.min.x * 1.05, Crown.y - info['Crown']['height-mm'] * 500, 0);
      GirdleTop = projectSceneToInfo(GirdleTopTrue.clone());
      ThicknessMmText = drawText({
        texts: info['Girdle'],
        position: GirdleTop.clone().setX(GirdleTop.x * grildFarX).setY(GirdleTop.y + GirdleTop.y * grildFarY),
        names: ['Thickness-mm']
      });
      ThicknessMmText.position.setX(ThicknessMmText.position.x - 5);
      material = new THREE.LineBasicMaterial({
        color: hex
      });
      geometry = new THREE.Geometry();
      geometry.vertices.push(new THREE.Vector3(ThicknessMmText.children[0].position.x + ThicknessMmText.children[0].geometry.boundingBox.max.x, ThicknessMmText.children[0].position.y, ThicknessMmText.children[0].position.z), new THREE.Vector3(GirdleTop.x, GirdleTop.y, GirdleTop.z));
      line = new THREE.Line(geometry, material);
      infoObj.add(ThicknessMmText);
      infoObj.add(line);
      GirdleBottmTrue = new THREE.Vector3(mesh.geometry.boundingBox.min.x * 1.05, Pavilion.y + info['Pavilion']['height-mm'] * 500, 0);
      GirdleBottm = projectSceneToInfo(GirdleBottmTrue.clone());
      ThicknessPercentageText = drawText({
        texts: info['Girdle'],
        position: GirdleBottm.clone().setX(GirdleBottm.x * grildFarX).setY(GirdleBottm.y - GirdleBottm.y * grildFarY),
        names: ['Thickness-percentages']
      });
      ThicknessPercentageText.position.setX((ThicknessMmText.position.x + ThicknessMmText.children[0].geometry.boundingBox.max.x - ThicknessPercentageText.children[0].geometry.boundingBox.max.x) * 0.75);
      material = new THREE.LineBasicMaterial({
        color: hex
      });
      geometry = new THREE.Geometry();
      geometry.vertices.push(new THREE.Vector3(ThicknessMmText.children[0].position.x + ThicknessMmText.children[0].geometry.boundingBox.max.x, ThicknessPercentageText.children[0].position.y, ThicknessPercentageText.children[0].position.z), new THREE.Vector3(GirdleBottm.x, GirdleBottm.y, GirdleBottm.z));
      line = new THREE.Line(geometry, material);
      infoObj.add(ThicknessPercentageText);
      infoObj.add(line);
      sceneInfo.add(infoObj);
      render();
      return void 0;
    };

    return Threejs;

  })(Viewer);

  this.Threejs = Threejs;

}).call(this);
