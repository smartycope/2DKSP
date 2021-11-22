extends Node2D
class_name Part

export var thumbnail:Texture
export var size:int = -1
export var title:String

var inVAB = false
var snapping = false
var controlledByMouse = false
var stagable = false

func _ready():
    pass


func initVAB(isRoot=false):
    # Cope.debug()
    self.pickUp()
    self.mode = RigidBody2D.MODE_KINEMATIC
    if isRoot:
        Cope.todo('Implement root part')
    else:
        inVAB = true

func _process(_delta):
    pass
    # if inVAB:
        # self.mode = RigidBody2D.MODE_KINEMATIC
        # self.position = get_viewport().get_mouse_position()

func place():
    Cope.note('the part has been placed')
    controlledByMouse = false

func pickUp():
    Cope.note('the part has been picked up')
    controlledByMouse = true

func stage():
    pass
