extends Node2D


var planet   = load('res://Scenes/Planets/Earth.tscn').instance()
var skyColor = planet.skyColor setget setSkyColor

# Sky and the GUI are children of Rocket because they have to move with the rocket so that the camera doesn't lose them.
onready var altitudeLabel     = $GUILayer/MarginContainer/GridContainer/altitude
onready var attitudeLabel     = $GUILayer/MarginContainer/GridContainer/attitude
onready var velocityLabel     = $GUILayer/MarginContainer/GridContainer/velocity
onready var accelerationLabel = $GUILayer/MarginContainer/GridContainer/acceleration
onready var deltavLabel       = $GUILayer/MarginContainer/GridContainer/deltav
onready var throttleLabel     = $GUILayer/MarginContainer/GridContainer/throttle
onready var twrLabel          = $GUILayer/MarginContainer/GridContainer/twr
onready var thrustLabel       = $GUILayer/MarginContainer/GridContainer/thrust
onready var gravityLabel      = $GUILayer/MarginContainer/GridContainer/gravity
onready var rocket            = $Rocket
onready var camera            = $Rocket/Camera
onready var sky               = $Background/Sky

func setSkyColor(to):
    # pass
    VisualServer.set_default_clear_color(to)

func _ready():
    rocket.position = $RocketStartPos.position
    # Center the rocket's camera on it
    var rocketOffset = -(rocket.height / 2)
    camera.offset.y = rocketOffset
    camera.limit_bottom = get_viewport_rect().size.y - rocketOffset

    # Set the sky color, cause I don't think it sets itself initially
    # setSkyColor(skyColor)
    setSkyColor(Color.black)

    # Set some rocket stuff
    rocket.gravity_scale = planet.gravity


func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.is_action_pressed('mouse_left'):
            pass

        if event.button_index == BUTTON_MIDDLE and event.is_action_pressed('mouse_middle'):
            pass

    elif event is InputEventMouseMotion:
        pass

    elif event.is_action_pressed('stage'):
        rocket.stage()

    elif event.is_action_pressed('throttle_up'):
        rocket.throttleUp()

    elif event.is_action_pressed('throttle_down'):
        rocket.throttleDown()

    elif event.is_action_pressed('turn_left'):
        rocket.turnLeft()

    elif event.is_action_pressed('turn_right'):
        rocket.turnRight()



func _process(_delta):
    # Update the GUI labels
    altitudeLabel.text = '0'
    attitudeLabel.text = '0'
    velocityLabel.text = str(rocket.linear_velocity)
    accelerationLabel.text = '0'
    deltavLabel.text   = '∞'
    throttleLabel.text = str(rocket.throttle)
    thrustLabel.text   = str(rocket.thrust)
    gravityLabel.text  = str(planet.gravity)
    # twrLabel.text = str(rocket.twr)
