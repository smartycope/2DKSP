extends Node2D

var parts = {
    'Tanks': [],
    'Engines': [],
    'Control Modules': []
}

var rootPart
var heldPart


func _ready():
    loadParts()


func loadParts():
    for type in parts.keys():
        var node = get_node('GUI/ItemsPanel/PartTabs/' + type)
        var dir = Directory.new()
        var path = 'res://Scenes/Parts/' + type

        if dir.open(path) == OK:
            dir.list_dir_begin()
            var filename = dir.get_next()
            while filename != "":
                if dir.current_is_dir():
                    pass
                else:
                    var part = load(path + '/' + filename)
                    parts[type].append(part)
                    var p = part.instance()
                    node.add_item(p.title, p.thumbnail, true)
                filename = dir.get_next()
        else:
            print("An error occurred when trying to access the path %s." % path)


func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.is_action_pressed('mouse_left'):
            # We're setting down a part
            if heldPart:
                var parent = heldPart.get_parent()
                if parent and parent is Part:
                    parent.place()
                heldPart = null
            # We're picking up a part
            else:
                heldPart = getChildUnderPoint(event.position)
                if heldPart:
                    var parent = heldPart.get_parent()
                    if parent and parent is Part:
                        parent.pickUp()

        if event.button_index == BUTTON_MIDDLE and event.is_action_pressed('mouse_middle'):
            heldPart = null
            var selection = getChildUnderPoint(event.position)
            if selection:
                var parent = heldPart.get_parent()
                if parent and parent is Part:
                    parent.queue_free()

    elif event is InputEventMouseMotion:
        if heldPart and not heldPart.snapping:
            heldPart.position = event.position


func getChildUnderPoint(point):
    $MouseGetter.position = point
    $MouseGetter.force_raycast_update()
    return $MouseGetter.get_collider()
    # return Cope.debug($MouseGetter.get_collider(), 'Under mouse')


func _on_Tanks_item_selected(index):
    heldPart = parts['Tanks'][index].instance()
    heldPart.initVAB()
    heldPart.position = get_viewport().get_mouse_position()
    add_child(heldPart)

func _on_Engines_item_selected(index):
    heldPart = parts['Engines'][index].instance()
    heldPart.initVAB()
    heldPart.position = get_viewport().get_mouse_position()
    add_child(heldPart)

func _on_Control_Modules_item_selected(index):
    heldPart = parts['Control Modules'][index].instance()
    heldPart.initVAB()
    heldPart.position = get_viewport().get_mouse_position()
    add_child(heldPart)
