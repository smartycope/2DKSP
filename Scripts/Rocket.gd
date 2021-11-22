extends RigidBody2D
class_name Rocket


func cantset(_val): pass

const throttleIncrement = 1
const turnIncrement = 10
const mouseDistSensitivity = .001

#* Members
# Currently avaialable, unadjusted thrust
var thrust = 0    setget cantset, calculateThrust
var altitude = 0  setget , calculateAltitude
var twr = 1       setget cantset, calculateTWR
# In pixels
var height = 270  setget cantset, calculateHeight
# How well you can change directions out of 1
var nibleness = 1 setget cantset, calculateNibleness
var dv = 0        setget cantset, calculateDeltaV

var title:String
var isAccelerating = false
var throttle = 0 setget constrainThrottle
var fuel = 0

var tanks = []
var engines = [load('res://Scenes/Parts/Engines/RaptorEngine.tscn').instance()]
var parts = engines + tanks
# var currentSOI:Planet
# var path: OrbitalPath


#* Getters
# Currently avaialable, unadjusted thrust
func calculateThrust():
    var net = 0
    for i in engines:
        net += i.thrust_kn
    return net

func calculateAltitude():
    Cope.todo('get rocket attitude')
    return altitude

func calculateTWR():
    Cope.debug(thrust)
    return self.thrust / weight

func calculateHeight():
    Cope.todo()
    return height

func calculateNibleness():
    Cope.todo()
    return nibleness

func calculateDeltaV():
    Cope.todo()
    return dv


func constrainThrottle(t):
    return t
    if t > throttleIncrement * 10:
        t = throttleIncrement * 10
    if t < 0:
        t = 0
    return t


func turningVector():
    #* Just go up
    return Vector2.UP
    #* Just go towards the mouse
    # return position.direction_to(get_viewport().get_mouse_position())
    #* Go towards the mouse, but speed up based on how far the mouse is
    # return (get_viewport().get_mouse_position() - position) * mouseDistSensitivity
    #* Go towards the front of the rocket
    # return position.direction_to($Direction.position)
    # return $Direction.position.direction_to(position)
    #* Go in the direction of our own rotation
    # return self.rotation * some math formula


func _ready():
    for i in parts:
        mass += i.mass
    for i in tanks:
        fuel += tanks


func construct(_withParts):
    Cope.todo('rocket contruction function')


func stage():
    # isAccelerating = true
    add_central_force(turningVector() * throttle * self.thrust)
    # self.add_central_force(turningVector() * 500)
    # Cope.debug(Vector2.UP * throttle, 'throttling to')
    Cope.todo('add a stager to rocket')

# func _integrate_forces(state):
#     state.add_central_force((throttle * self.thrust) * turningVector())


# func _physics_process(delta):
    # add_central_force((throttle * self.thrust) * turningVector())


func throttleUp(amt=throttleIncrement):
    self.throttle += amt
    add_central_force(turningVector() * amt * self.thrust)

func throttleDown(amt=throttleIncrement):
    self.throttle -= amt
    add_central_force(turningVector() * amt * self.thrust)

func turnLeft(amt=turnIncrement):
    add_force(Vector2(0, 0), Vector2.LEFT * self.nibleness * amt)
    # self.rotate(-deg2rad(self.nibleness * amt))

func turnRight(amt=turnIncrement):
    add_force(Vector2(0, 0), Vector2.RIGHT * self.nibleness * amt)
    # self.rotate(deg2rad(self.nibleness * amt))
