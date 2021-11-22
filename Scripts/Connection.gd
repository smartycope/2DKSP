extends Area2D
class_name Connection

const sizeMap = {
    -1: [0, 0],
    3:  [10, 20],
    5:  [15, 40],
}

signal connecting

export var size:int = -1

var connected:Connection


func _ready():
    var collision = CollisionShape2D.new()
    collision.shape = CapsuleShape2D.new()
    collision.shape.radius = sizeMap[size][0]
    collision.shape.height = sizeMap[size][1]
    collision.rotation_degrees = 90
    add_child(collision)

    connect("area_entered", self, "_on_area_entered")
    connect("area_exited", self, "_on_area_exited")


func _process(_delta):
    if connected and get_viewport().get_mouse_position().distance_to(connected.position) < sizeMap[size][1] * 2:
        # They're the one doing the poking
        if connected.get_parent().controlledByMouse:
            connected.get_parent().position = position
            Cope.debug(get_parent().position, 'setting to position')
    elif connected:
        connected.get_parent().snapping = false
        get_parent().snapping = false


func _on_area_entered(area):
    # If the thing that just entered is another Connection, it's the same size as us, that size is not -1
    # (surface mount), and nothing is currently connected (we only want to connect one thing at a time)

    Cope.debug(get_parent().controlledByMouse, 'picked up')

    if area.size == self.size and self.size != -1 and not connected:
        connected = area
        # They're the one doing the poking
        # if connected.get_parent().controlledByMouse:
        #     connected.get_parent().position = position
        connected.get_parent().snapping = true
        get_parent().snapping = true

func _on_area_exited(_area):
    Cope.note('disconnected!')
    connected = null
