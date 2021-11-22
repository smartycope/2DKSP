extends Node

var debugCount = 0 setget cantset ,_incrementDebugCounter
# var current_scene = null
var instancedScenes = {}

onready var root = get_tree().get_root()
#* The last scene is always loaded as the current scene
onready var current_scene = root.get_child(root.get_child_count() - 1)

func _incrementDebugCounter():
    debugCount += 1
    return debugCount

func cantset(_val):
    pass

func _ready():
    randomize()

    #* Call test code here
    # assert(null != 0)


func toast(labelNode, text, time=2.5):
    labelNode.text = text
    yield(get_tree().create_timer(time), "timeout")

    if is_instance_valid(labelNode):
        labelNode.text = ""

func popup(title, text):
    var p = AcceptDialog.new()
    p.window_title = title
    p.dialog_text = text
    p.popup_exclusive = false
    p.connect("confirmed", p, "free")
    get_tree().get_root().add_child(p)
    p.popup_centered()


class SceneLoader:
    extends Object
    # signal scene_ready(scene)
    signal scene_ready

    var tree_func
    var instanced_scenes
    var current_scene

    func _init(sceneTreeFunc, currentScene, sceneName, isPath=false, freeCurrentScene=true, isSaved=false, instancedScenes={}):
        tree_func = sceneTreeFunc
        current_scene = currentScene
        instanced_scenes = instancedScenes

        if isSaved:
            assert(not isPath)
            call_deferred("_deferred_load_scene", sceneName, freeCurrentScene)
        else:
            call_deferred("_deferred_goto_scene", sceneName if isPath else "res://" + sceneName + ".tscn", freeCurrentScene)

    func _deferred_goto_scene(name, free=true):
        var oldScene = current_scene

        # Load the new scene.
        var s = ResourceLoader.load(name)

        # Instance the new scene.
        current_scene = s.instance()

        # Add it to the active scene, as child of root.
        tree_func.call_func().get_root().add_child(current_scene)

        # Optionally, to make it compatible with the SceneTree.change_scene() API.
        tree_func.call_func().set_current_scene(current_scene)

        self.current_scene = current_scene

        # yield(current_scene, "ready")
        emit_signal("scene_ready", current_scene)

        # It is now safe to remove the old scene
        if free and is_instance_valid(oldScene):
            oldScene.free()


    func _deferred_load_scene(id, free=true):
        var oldScene = current_scene

        # Instance the new scene.
        current_scene = instanced_scenes[id]

        # Add it to the active scene, as child of root.
        tree_func.call_func().get_root().add_child(current_scene)

        # Optionally, to make it compatible with the SceneTree.change_scene() API.
        tree_func.call_func().set_current_scene(current_scene)

        self.current_scene = current_scene

        # yield(current_scene, "ready")
        emit_signal("scene_ready", current_scene)

        # It is now safe to remove the old scene
        if free and is_instance_valid(oldScene):
            oldScene.free()


func saveScene(currentSceneName, currentSceneInstance):
    instancedScenes[currentSceneName] = currentSceneInstance

func gotoSavedScene(name, freeScene=true, isPath=false):
    return SceneLoader.new(funcref(self, "get_tree"), current_scene, name, isPath, freeScene, true, instancedScenes)

func gotoScene(name, freeScene=true, isPath=false):
    return SceneLoader.new(funcref(self, "get_tree"), current_scene, name, isPath, freeScene)


static func getJSON(filename):
    var file = File.new()
    file.open("res://" + filename, File.READ)
    # var data = file.get_var()
    # file.close()
    # return data

    var json = JSON.parse(file.get_as_text())
    file.close()
    assert(json.error == OK)
    return json.result


static func setJSON(filename, data, full=false):
    var file = File.new()
    file.open("res://" + filename, File.WRITE)
    # file.store_var(data)
    file.store_var(to_json(data), full)
    file.close()


static func setJSONvalue(filename, key, value):
    var data = getJSON(filename)
    data[key] = value
    setJSON(filename, data)


static func getJSONvalue(filename, key):
    return getJSON(filename)[key]


func _getMetadata(calls=2):
    var frame = get_stack()[calls]
    return '%-4d["%s", line %d, in %s()] ' % [self.debugCount, frame.source.get_file(), frame.line, frame.function]

func getTypename(obj):
    if obj == null:
        return 'null'

    var typ = typeof(obj)
    var builtin_type_names = ["nil", "bool", "int", "real", "string", "vector2", "rect2", "vector3", "maxtrix32",
                              "plane", "quat", "aabb",  "matrix3", "transform", "color", "image", "nodepath",
                              "rid", null, "inputevent", "dictionary", "array", "rawarray", "intarray", "realarray",
                              "stringarray", "vector2array", "vector3array", "colorarray", "?"]

    var otherTypes = [ "AABB", "AcceptDialog", "AESContext", "AnimatableBody2D", "AnimatableBody3D", "AnimatedSprite2D", "AnimatedSprite3D",
        "AnimatedTexture", "Animation", "AnimationNode", "AnimationNodeAdd2", "AnimationNodeAdd3", "AnimationNodeAnimation", "AnimationNodeBlend2",
        "AnimationNodeBlend3", "AnimationNodeBlendSpace1D", "AnimationNodeBlendSpace2D", "AnimationNodeBlendTree", "AnimationNodeOneShot",
        "AnimationNodeOutput", "AnimationNodeStateMachine", "AnimationNodeStateMachinePlayback", "AnimationNodeStateMachineTransition",
        "AnimationNodeTimeScale", "AnimationNodeTimeSeek", "AnimationNodeTransition", "AnimationPlayer", "AnimationRootNode", "AnimationTrackEditPlugin",
        "AnimationTree", "Area2D", "Area3D", "Array", "ArrayMesh", "AspectRatioContainer", "AStar", "AStar2D", "AtlasTexture", "AudioBusLayout",
        "AudioEffect", "AudioEffectAmplify", "AudioEffectBandLimitFilter", "AudioEffectBandPassFilter", "AudioEffectCapture", "AudioEffectChorus",
        "AudioEffectCompressor", "AudioEffectDelay", "AudioEffectDistortion", "AudioEffectEQ", "AudioEffectEQ10", "AudioEffectEQ21", "AudioEffectEQ6",
        "AudioEffectFilter", "AudioEffectHighPassFilter", "AudioEffectHighShelfFilter", "AudioEffectInstance", "AudioEffectLimiter",
        "AudioEffectLowPassFilter", "AudioEffectLowShelfFilter", "AudioEffectNotchFilter", "AudioEffectPanner", "AudioEffectPhaser",
        "AudioEffectPitchShift", "AudioEffectRecord", "AudioEffectReverb", "AudioEffectSpectrumAnalyzer", "AudioEffectSpectrumAnalyzerInstance",
        "AudioEffectStereoEnhance", "AudioListener2D", "AudioListener3D", "AudioServer", "AudioStream", "AudioStreamGenerator",
        "AudioStreamGeneratorPlayback", "AudioStreamMicrophone", "AudioStreamMP3", "AudioStreamOGGVorbis", "AudioStreamPlayback",
        "AudioStreamPlaybackOGGVorbis", "AudioStreamPlaybackResampled", "AudioStreamPlayer", "AudioStreamPlayer2D", "AudioStreamPlayer3D",
        "AudioStreamRandomPitch", "AudioStreamSample", "BackBufferCopy", "BaseButton", "BaseMaterial3D", "Basis", "BitMap", "Bone2D", "BoneAttachment3D",
        "bool", "BoxContainer", "BoxMesh", "BoxShape3D", "Button", "ButtonGroup", "Callable", "CallbackTweener", "Camera2D", "Camera3D", "CameraEffects",
        "CameraFeed", "CameraServer", "CameraTexture", "CanvasGroup", "CanvasItem", "CanvasItemMaterial", "CanvasLayer", "CanvasModulate", "CanvasTexture",
        "CapsuleMesh", "CapsuleShape2D", "CapsuleShape3D", "CenterContainer", "CharacterBody2D", "CharacterBody3D", "CharFXTransform", "CheckBox",
        "CheckButton", "CircleShape2D", "ClassDB", "CodeEdit", "CodeHighlighter", "CollisionObject2D", "CollisionObject3D", "CollisionPolygon2D",
        "CollisionPolygon3D", "CollisionShape2D", "CollisionShape3D", "Color", "ColorPicker", "ColorPickerButton", "ColorRect", "ConcavePolygonShape2D",
        "ConcavePolygonShape3D", "ConeTwistJoint3D", "ConfigFile", "ConfirmationDialog", "Container", "Control", "ConvexPolygonShape2D",
        "ConvexPolygonShape3D", "CPUParticles2D", "CPUParticles3D", "Crypto", "CryptoKey", "CSGBox3D", "CSGCombiner3D", "CSGCylinder3D",
        "CSGMesh3D", "CSGPolygon3D", "CSGPrimitive3D", "CSGShape3D", "CSGSphere3D", "CSGTorus3D", "CSharpScript", "Cubemap", "CubemapArray", "Curve",
        "Curve2D", "Curve3D", "CurveTexture", "CurveXYZTexture", "CylinderMesh", "CylinderShape3D", "DampedSpringJoint2D", "Decal", "Dictionary",
        "DirectionalLight2D", "DirectionalLight3D", "Directory", "DisplayServer", "DTLSServer", "EditorCommandPalette", "EditorDebuggerPlugin",
        "EditorExportPlugin", "EditorFeatureProfile", "EditorFileDialog", "EditorFileSystem", "EditorFileSystemDirectory", "EditorImportPlugin",
        "EditorInspector", "EditorInspectorPlugin", "EditorInterface", "EditorNode3DGizmo", "EditorNode3DGizmoPlugin", "EditorPaths", "EditorPlugin",
        "EditorProperty", "EditorResourceConversionPlugin", "EditorResourcePicker", "EditorResourcePreview", "EditorResourcePreviewGenerator", "EditorSceneImporter",
        "EditorSceneImporterFBX", "EditorSceneImporterGLTF", "EditorScenePostImport", "EditorScript", "EditorScriptPicker", "EditorSelection", "EditorSettings",
        "EditorSpinSlider", "EditorSyntaxHighlighter", "EditorTranslationParserPlugin", "EditorVCSInterface",
        "EncodedObjectAsID", "ENetConnection", "ENetMultiplayerPeer", "ENetPacketPeer", "Engine", "EngineDebugger", "Environment", "Expression", "File", "FileDialog",
        "FileSystemDock", "float", "Font", "FontData", "GDNative", "GDNativeLibrary", "GDScript", "Generic6DOFJoint3D", "Geometry2D", "Geometry3D",
        "GeometryInstance3D", "GLTFAccessor", "GLTFAnimation", "GLTFBufferView", "GLTFCamera", "GLTFDocument",
        "GLTFDocumentExtension", "GLTFDocumentExtensionConvertImporterMesh", "GLTFLight", "GLTFMesh", "GLTFNode", "GLTFSkeleton", "GLTFSkin", "GLTFSpecGloss",
        "GLTFState", "GLTFTexture", "GodotSharp", "GPUParticles2D", "GPUParticles3D", "GPUParticlesAttractor3D", "GPUParticlesAttractorBox",
        "GPUParticlesAttractorSphere", "GPUParticlesAttractorVectorField", "GPUParticlesCollision3D",
        "GPUParticlesCollisionBox", "GPUParticlesCollisionHeightField", "GPUParticlesCollisionSDF", "GPUParticlesCollisionSphere", "Gradient", "GradientTexture",
        "GraphEdit", "GraphNode", "GridContainer", "GridMap", "GrooveJoint2D", "HashingContext", "HBoxContainer", "HeightMapShape3D", "HingeJoint3D", "HMACContext", "HScrollBar",
        "HSeparator", "HSlider", "HSplitContainer", "HTTPClient", "HTTPRequest", "Image", "ImageTexture", "ImageTexture3D", "ImageTextureLayered", "ImmediateMesh",
        "ImporterMesh", "ImporterMeshInstance3D", "Input", "InputEvent", "InputEventAction", "InputEventFromWindow", "InputEventGesture", "InputEventJoypadButton", "InputEventJoypadMotion", "InputEventKey",
        "InputEventMagnifyGesture", "InputEventMIDI", "InputEventMouse", "InputEventMouseButton", "InputEventMouseMotion", "InputEventPanGesture",
        "InputEventScreenDrag", "InputEventScreenTouch", "InputEventShortcut", "InputEventWithModifiers", "InputMap", "InstancePlaceholder", "int", "IntervalTweener",
        "IP", "ItemList", "JavaClass", "JavaClassWrapper", "JavaScript", "JavaScriptObject", "JNISingleton", "Joint2D", "Joint3D", "JSON", "JSONRPC",
        "KinematicCollision2D", "KinematicCollision3D", "Label", "Light2D", "Light3D", "LightmapGI", "LightmapGIData", "Lightmapper", "LightmapperRD", "LightmapProbe",
        "LightOccluder2D", "Line2D", "LineEdit", "LinkButton", "MainLoop", "MarginContainer", "Marshalls", "Material", "MenuButton", "Mesh", "MeshDataTool",
        "MeshInstance2D", "MeshInstance3D", "MeshLibrary", "MeshTexture", "MethodTweener", "MobileVRInterface", "MultiMesh", "MultiMeshInstance2D", "MultiMeshInstance3D", "MultiplayerAPI", "MultiplayerPeer",
        "MultiplayerPeerExtension", "MultiplayerReplicator", "Mutex", "NativeExtension", "NativeExtensionManager", "NativeScript", "NavigationAgent2D", "NavigationAgent3D",
        "NavigationMesh", "NavigationMeshGenerator", "NavigationObstacle2D", "NavigationObstacle3D", "NavigationPolygon", "NavigationRegion2D", "NavigationRegion3D", "NavigationServer2D",
        "NavigationServer3D", "NinePatchRect", "Node", "Node2D", "Node3D", "Node3DGizmo", "NodePath", "NoiseTexture", "Object", "Occluder3D", "OccluderInstance3D",
        "OccluderPolygon2D", "OGGPacketSequence", "OGGPacketSequencePlayback", "OmniLight3D", "OpenSimplexNoise", "OptimizedTranslation", "OptionButton",
        "ORMMaterial3D", "OS", "PackedByteArray", "PackedColorArray", "PackedDataContainer", "PackedDataContainerRef", "PackedFloat32Array", "PackedFloat64Array", "PackedInt32Array", "PackedInt64Array", "PackedScene",
        "PackedStringArray", "PackedVector2Array", "PackedVector3Array", "PacketPeer", "PacketPeerDTLS", "PacketPeerExtension", "PacketPeerStream", "PacketPeerUDP", "Panel", "PanelContainer",
        "PanoramaSkyMaterial", "ParallaxBackground", "ParallaxLayer", "ParticlesMaterial", "Path2D", "Path3D", "PathFollow2D", "PathFollow3D", "PCKPacker", "Performance", "PhysicalBone2D", "PhysicalBone3D", "PhysicalSkyMaterial",
        "PhysicsBody2D", "PhysicsBody3D", "PhysicsDirectBodyState2D", "PhysicsDirectBodyState3D", "PhysicsDirectSpaceState2D", "PhysicsDirectSpaceState3D", "PhysicsMaterial",
        "PhysicsServer2D", "PhysicsServer3D", "PhysicsShapeQueryParameters2D", "PhysicsShapeQueryParameters3D", "PhysicsTestMotionParameters2D", "PhysicsTestMotionParameters3D",
        "PhysicsTestMotionResult2D", "PhysicsTestMotionResult3D", "PinJoint2D", "PinJoint3D", "Plane", "PlaneMesh", "PluginScript", "PointLight2D", "PointMesh", "Polygon2D", "PolygonPathFinder",
        "Popup", "PopupMenu", "PopupPanel", "Position2D", "Position3D", "PrimitiveMesh", "PrismMesh", "ProceduralSkyMaterial", "ProgressBar", "ProjectSettings",
        "PropertyTweener", "ProximityGroup3D", "ProxyTexture", "QuadMesh", "Quaternion", "RandomNumberGenerator", "Range", "RayCast2D", "RayCast3D",
        "RDAttachmentFormat", "RDFramebufferPass", "RDPipelineColorBlendState", "RDPipelineColorBlendStateAttachment", "RDPipelineDepthStencilState", "RDPipelineMultisampleState",
        "RDPipelineRasterizationState", "RDPipelineSpecializationConstant", "RDSamplerState", "RDShaderFile", "RDShaderSource", "RDShaderSPIRV", "RDTextureFormat", "RDTextureView", "RDUniform", "RDVertexAttribute",
        "Rect2", "Rect2i", "RectangleShape2D", "RefCounted", "ReferenceRect", "ReflectionProbe", "RegEx", "RegExMatch", "RemoteTransform2D", "RemoteTransform3D",
        "RenderingDevice", "RenderingServer", "Resource", "ResourceFormatLoader", "ResourceFormatSaver", "ResourceImporter", "ResourceLoader", "ResourcePreloader",
        "ResourceSaver", "ResourceUID", "RibbonTrailMesh", "RichTextEffect", "RichTextLabel", "RID", "RigidBody", "RigidBody2D", "RigidDynamicBody2D", "RigidDynamicBody3D", "RootMotionView", "SceneState", "SceneTree",
        "SceneTreeTimer", "Script", "ScriptCreateDialog", "ScriptEditor", "ScriptEditorBase", "ScrollBar", "ScrollContainer", "SegmentShape2D", "Semaphore", "SeparationRayShape2D",
        "SeparationRayShape3D", "Separator", "Shader", "ShaderGlobalsOverride", "ShaderMaterial", "Shape2D", "Shape3D", "Shortcut", "Signal", "Skeleton2D", "Skeleton3D", "SkeletonIK3D",
        "SkeletonModification2D", "SkeletonModification2DCCDIK", "SkeletonModification2DFABRIK", "SkeletonModification2DJiggle", "SkeletonModification2DLookAt",
        "SkeletonModification2DPhysicalBones", "SkeletonModification2DStackHolder", "SkeletonModification2DTwoBoneIK", "SkeletonModification3D", "SkeletonModification3DCCDIK",
        "SkeletonModification3DFABRIK", "SkeletonModification3DJiggle", "SkeletonModification3DLookAt", "SkeletonModification3DStackHolder", "SkeletonModification3DTwoBoneIK",
        "SkeletonModificationStack2D", "SkeletonModificationStack3D", "Skin", "SkinReference", "Sky", "Slider", "SliderJoint3D", "SoftDynamicBody3D", "SphereMesh",
        "SphereShape3D", "SpinBox", "SplitContainer", "SpotLight3D", "SpringArm3D", "Sprite2D", "Sprite3D", "SpriteBase3D", "SpriteFrames", "StandardMaterial3D", "StaticBody2D",
        "StaticBody3D", "StreamCubemap", "StreamCubemapArray", "StreamPeer", "StreamPeerBuffer", "StreamPeerExtension", "StreamPeerSSL", "StreamPeerTCP", "StreamTexture2D", "StreamTexture2DArray", "StreamTexture3D",
        "StreamTextureLayered", "String", "StringName", "StyleBox", "StyleBoxEmpty", "StyleBoxFlat", "StyleBoxLine", "StyleBoxTexture", "SubViewport", "SubViewportContainer",
        "SurfaceTool", "SyntaxHighlighter", "TabContainer", "Tabs", "TCPServer", "TextEdit", "TextLine", "TextParagraph", "TextServer", "TextServerAdvanced", "TextServerExtension",
        "TextServerFallback", "TextServerManager", "Texture", "Texture2D", "Texture2DArray", "Texture3D", "TextureButton", "TextureLayered", "TextureProgressBar", "TextureRect",
        "Theme", "Thread", "TileData", "TileMap", "TileSet", "TileSetAtlasSource", "TileSetScenesCollectionSource", "TileSetSource",
        "Time", "Timer", "TouchScreenButton", "Transform2D", "Transform3D", "Translation", "TranslationServer", "Tree", "TreeItem", "TriangleMesh", "TubeTrailMesh", "Tween", "Tweener", "UDPServer",
        "UndoRedo", "UPNP", "UPNPDevice", "Variant", "VBoxContainer", "Vector2", "Vector2i", "Vector3", "Vector3i", "VehicleBody3D", "VehicleWheel3D", "VelocityTracker3D",
        "VideoPlayer", "VideoStream", "VideoStreamGDNative", "VideoStreamTheora", "VideoStreamWebm", "Viewport", "ViewportTexture", "VisibleOnScreenEnabler2D", "VisibleOnScreenEnabler3D", "VisibleOnScreenNotifier2D",
        "VisibleOnScreenNotifier3D", "VisualInstance3D", "VisualScript", "VisualScriptBasicTypeConstant", "VisualScriptBuiltinFunc", "VisualScriptClassConstant",
        "VisualScriptComment", "VisualScriptComposeArray", "VisualScriptCondition",
        "VisualScriptConstant", "VisualScriptConstructor", "VisualScriptCustomNode", "VisualScriptCustomNodes", "VisualScriptDeconstruct", "VisualScriptEmitSignal",
        "VisualScriptEngineSingleton", "VisualScriptExpression", "VisualScriptFunction", "VisualScriptFunctionCall",
        "VisualScriptFunctionState", "VisualScriptGlobalConstant", "VisualScriptIndexGet", "VisualScriptIndexSet", "VisualScriptInputAction", "VisualScriptIterator",
        "VisualScriptLists", "VisualScriptLocalVar", "VisualScriptLocalVarSet", "VisualScriptMathConstant", "VisualScriptNode", "VisualScriptOperator",
        "VisualScriptPreload", "VisualScriptPropertyGet", "VisualScriptPropertySet", "VisualScriptResourcePath", "VisualScriptReturn", "VisualScriptSceneNode",
        "VisualScriptSceneTree", "VisualScriptSelect", "VisualScriptSelf", "VisualScriptSequence", "VisualScriptSubCall", "VisualScriptSwitch", "VisualScriptTypeCast", "VisualScriptVariableGet", "VisualScriptVariableSet",
        "VisualScriptWhile", "VisualScriptYield", "VisualScriptYieldSignal", "VisualShader", "VisualShaderNode", "VisualShaderNodeBillboard",
        "VisualShaderNodeBooleanConstant", "VisualShaderNodeBooleanUniform", "VisualShaderNodeClamp", "VisualShaderNodeColorConstant",
        "VisualShaderNodeColorFunc", "VisualShaderNodeColorOp", "VisualShaderNodeColorUniform", "VisualShaderNodeComment", "VisualShaderNodeCompare",
        "VisualShaderNodeConstant", "VisualShaderNodeCubemap", "VisualShaderNodeCubemapUniform", "VisualShaderNodeCurveTexture",
        "VisualShaderNodeCurveXYZTexture", "VisualShaderNodeCustom", "VisualShaderNodeDeterminant", "VisualShaderNodeDotProduct", "VisualShaderNodeExpression",
        "VisualShaderNodeFaceForward", "VisualShaderNodeFloatConstant", "VisualShaderNodeFloatFunc", "VisualShaderNodeFloatOp",
        "VisualShaderNodeFloatUniform", "VisualShaderNodeFresnel", "VisualShaderNodeGlobalExpression", "VisualShaderNodeGroupBase", "VisualShaderNodeIf",
        "VisualShaderNodeInput", "VisualShaderNodeIntConstant", "VisualShaderNodeIntFunc", "VisualShaderNodeIntOp", "VisualShaderNodeIntUniform",
        "VisualShaderNodeIs", "VisualShaderNodeMix", "VisualShaderNodeMultiplyAdd", "VisualShaderNodeOuterProduct", "VisualShaderNodeOutput", "VisualShaderNodeParticleAccelerator",
        "VisualShaderNodeParticleBoxEmitter", "VisualShaderNodeParticleConeVelocity", "VisualShaderNodeParticleEmit", "VisualShaderNodeParticleEmitter", "VisualShaderNodeParticleMultiplyByAxisAngle",
        "VisualShaderNodeParticleOutput", "VisualShaderNodeParticleRandomness", "VisualShaderNodeParticleRingEmitter", "VisualShaderNodeParticleSphereEmitter", "VisualShaderNodeResizableBase", "VisualShaderNodeSample3D",
        "VisualShaderNodeScalarDerivativeFunc", "VisualShaderNodeScreenUVToSDF", "VisualShaderNodeSDFRaymarch", "VisualShaderNodeSDFToScreenUV", "VisualShaderNodeSmoothStep", "VisualShaderNodeStep",
        "VisualShaderNodeSwitch", "VisualShaderNodeTexture", "VisualShaderNodeTexture2DArray", "VisualShaderNodeTexture2DArrayUniform", "VisualShaderNodeTexture3D", "VisualShaderNodeTexture3DUniform", "VisualShaderNodeTextureSDF",
        "VisualShaderNodeTextureSDFNormal", "VisualShaderNodeTextureUniform", "VisualShaderNodeTextureUniformTriplanar", "VisualShaderNodeTransformCompose", "VisualShaderNodeTransformConstant", "VisualShaderNodeTransformDecompose",
        "VisualShaderNodeTransformFunc", "VisualShaderNodeTransformOp", "VisualShaderNodeTransformUniform", "VisualShaderNodeTransformVecMult", "VisualShaderNodeUniform",
        "VisualShaderNodeUniformRef", "VisualShaderNodeUVFunc", "VisualShaderNodeVec3Constant", "VisualShaderNodeVec3Uniform", "VisualShaderNodeVectorCompose", "VisualShaderNodeVectorDecompose", "VisualShaderNodeVectorDerivativeFunc",
        "VisualShaderNodeVectorDistance", "VisualShaderNodeVectorFunc", "VisualShaderNodeVectorLen",
        "VisualShaderNodeVectorOp", "VisualShaderNodeVectorRefract", "VoxelGI", "VoxelGIData", "VScrollBar", "VSeparator", "VSlider", "VSplitContainer",
        "WeakRef", "WebRTCDataChannel", "WebRTCDataChannelExtension", "WebRTCMultiplayerPeer", "WebRTCPeerConnection", "WebRTCPeerConnectionExtension", "WebSocketClient", "WebSocketMultiplayerPeer", "WebSocketPeer",
        "WebSocketServer", "WebXRInterface", "Window", "World2D", "World3D", "WorldBoundaryShape2D",
        "WorldBoundaryShape3D", "WorldEnvironment", "X509Certificate", "XMLParser", "XRAnchor3D", "XRCamera3D", "XRController3D", "XRInterface", "XRInterfaceExtension", "XROrigin3D", "XRPositionalTracker",
        "XRServer"
]

    if(typ == TYPE_OBJECT):
        for type in otherTypes:
            if obj.is_class(type):
                return type
            return '?'
        # return obj.type_of()
    else:
        return builtin_type_names[typ]


func debug(variable=' 6^%/*sdf\\/\\&%$ddd666', name='', stackTrace=false, _calls=1):
    if variable is String and variable == ' 6^%/*sdf\\/\\&%$ddd666':
        print(_getMetadata(), 'HERE! HERE!')
        return

    name += ' = ' if len(name) else ''

    # var trace = ''
    # for i in get_stack().slice(_calls, -1):
    #     trace += '[%s->%s()->%d]\n' % [i.source.get_file(), i.function, i.line]
    # trace = '\n' + trace

    if stackTrace:
        print_stack()

    var hasLen = (variable is Array) or (variable is Dictionary)

    print(_getMetadata(), '<', getTypename(variable), '> ', name, 'null' if variable == null else variable, '(len=%d)' % len(variable) if hasLen else '')
    return variable

func todo(feature=''):
    if feature == '':
        print(_getMetadata(), 'TODO: Implement %s()' % get_stack()[1].function)
    else:
        print(_getMetadata(), 'TODO: %s' % feature)


func note(s=''):
    print(_getMetadata(), s)
