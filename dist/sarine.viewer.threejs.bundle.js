
/*!
sarine.viewer.threejs - v0.3.0 -  Thursday, May 14th, 2015, 11:31:27 AM 
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
    var addMouseHandler, camera, cameraInfo, canvasWidht, color, controls, createScene, drawArrow, drawInfo, drawMesh, drawText, edges, font, fontSize, info, infoOnly, loadScript, mesh, mouseDown, mouseX, mouseY, render, renderer, rotateScene, rotation, scale, scene, sceneInfo, url;

    __extends(Threejs, _super);

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

    function Threejs(options) {
      Threejs.__super__.constructor.call(this, options);
      color = options.color, font = options.font, infoOnly = options.infoOnly;
      color = color || 0xffffff;
      scale = 1;
      this.version = $(this.element).data("version") || "v1";
      this.viewersBaseUrl = stones[0].viewersBaseUrl;
    }

    Threejs.prototype.getScene = function() {
      return scene;
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
      loadScript(this.viewersBaseUrl + "atomic/" + this.version + "/assets/three.bundle.js").then(function() {
        createScene.apply(_t);
        return $.when($.get(_t.src + "SRNSRX.srn"), $.getJSON(_t.src + "Info.json")).then(function(data, json) {
          var rawData;
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
        });
      });
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
      var defer, s, _t;
      _t = this;
      defer = $.Deferred();
      if (($("[src='" + url + "']")[0])) {
        $("[src='" + url + "']").on("load", function() {
          return defer.resolve(_t);
        });
        return defer;
      }
      s = $("<script>", {
        type: "text/javascript"
      }).appendTo("body").end()[0];
      s.onload = function() {
        return defer.resolve(_t);
      };
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
      if (mesh && mesh.rotation && parseInt(mesh.rotation.x * 10) === parseInt(Math.PI * 5)) {
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
      camera = new THREE.OrthographicCamera(12000 / -2.5, 12000 / 2.5, 12000 / 2.5, 12000 / -2.5, -10000, 10000);
      scene.add(camera);
      camera.position.set(0, 0, 5000);
      camera.lookAt(scene.position);
      renderer = new THREE.WebGLRenderer({
        alpha: true,
        logarithmicDepthBuffer: false
      });
      renderer.autoClear = false;
      canvasWidht = this.element.height() > this.element.width() ? this.element.width() : this.element.height();
      cameraInfo = new THREE.OrthographicCamera(canvasWidht / -2, canvasWidht / 2, canvasWidht / 2, canvasWidht / -2, -10000, 10000);
      sceneInfo.add(cameraInfo);
      renderer.setSize(canvasWidht, canvasWidht);
      this.element[0].appendChild(renderer.domElement);
      this.material = new THREE.MeshBasicMaterial({
        color: 0xcccccc
      });
      return render();
    };

    drawArrow = function(options) {
      var data, dir, far, gap, hex, infoObj, length, name, origin, textObj, topToButtom, xy, xyFar;
      name = options.name, origin = options.origin, length = options.length, hex = options.hex, topToButtom = options.topToButtom, data = options.data, dir = options.dir, far = options.far;
      xyFar = topToButtom ? 'x' : 'y';
      origin["set" + xyFar.toUpperCase()](origin[xyFar] * far);
      origin.set(origin.x / (camera.right / cameraInfo.right), origin.y / (camera.right / cameraInfo.right), origin.z / (camera.right / cameraInfo.right));
      textObj = drawText({
        text: data.toFixed(2) + " mm",
        position: origin
      });
      infoObj = new THREE.Object3D();
      infoObj.name = "info";
      xy = topToButtom ? 'y' : 'x';
      gap = (textObj.geometry.boundingBox.max[xy] - textObj.geometry.boundingBox.min[xy]) + 10;
      length = data / 2 * 1000 / (camera.right / cameraInfo.right) - gap / 2;
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
      var hex, material, position, text, textGeom, textMesh;
      text = options.text, position = options.position, hex = options.hex;
      material = new THREE.MeshBasicMaterial({
        color: options.hex || 0x000000
      });
      textGeom = new THREE.TextGeometry(options.text, {
        size: 15,
        font: "gentilis",
        wieght: "bold"
      });
      textGeom.center();
      textMesh = new THREE.Mesh(textGeom, material);
      textMesh.lookAt(camera.position);
      textMesh.position.set(position.x, position.y, position.z);
      return textMesh;
    };

    drawInfo = function(hex) {
      var infoObj, val;
      hex = hex || 0x000000;
      infoObj = new THREE.Object3D();
      infoObj.name = "info";
      infoObj.add(drawArrow({
        origin: new THREE.Vector3(0, mesh.geometry.boundingBox.max.z, 0),
        hex: hex,
        topToButtom: false,
        data: info['Length']['mm'],
        dir: new THREE.Vector3(1, 0, 0),
        far: 1.50
      }));
      infoObj.add(drawArrow({
        origin: new THREE.Vector3(0, mesh.geometry.boundingBox.max.z, 0),
        hex: hex,
        topToButtom: false,
        data: info['Table Size']['mm'],
        dir: new THREE.Vector3(1, 0, 0),
        far: 1.25
      }));
      val = mesh.geometry.boundingBox.max.z - info['Crown']['height-mm'] * 1000 / 2;
      infoObj.add(drawArrow({
        origin: new THREE.Vector3(mesh.geometry.boundingBox.max.x, val, 0),
        hex: hex,
        topToButtom: true,
        data: info['Crown']['height-mm'],
        dir: new THREE.Vector3(mesh.geometry.boundingBox.max.x, val + 1, 0),
        far: 1.15
      }));
      val = mesh.geometry.boundingBox.min.z + info['Pavilion']['height-mm'] * 1000 / 2;
      infoObj.add(drawArrow({
        origin: new THREE.Vector3(mesh.geometry.boundingBox.max.x, val, 0),
        hex: hex,
        topToButtom: true,
        data: info['Pavilion']['height-mm'],
        dir: new THREE.Vector3(mesh.geometry.boundingBox.max.x, val * -1, 0),
        far: 1.15
      }));
      val = mesh.geometry.boundingBox.min.z + info['Total Depth']['mm'] * 1000 / 2;
      infoObj.add(drawArrow({
        origin: new THREE.Vector3(mesh.geometry.boundingBox.min.x, val, 0),
        hex: hex,
        topToButtom: true,
        data: info['Total Depth']['mm'],
        dir: new THREE.Vector3(mesh.geometry.boundingBox.min.x, val + 1, 0),
        far: 1.15
      }));
      sceneInfo.add(infoObj);
      render();
      return void 0;
    };

    return Threejs;

  })(Viewer);

  this.Threejs = Threejs;

}).call(this);
