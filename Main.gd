extends Node3D

var car: Node3D
var camera: Camera3D
var speed := 0.0
var steering := 0.0
var max_speed := 22.0
var acceleration := 12.0
var friction := 7.0
var touch_controls := true

var road_material: StandardMaterial3D
var building_material: StandardMaterial3D
var car_material: StandardMaterial3D

func _ready():
    create_materials()
    create_world()
    create_car()
    create_camera()
    create_ui()

func create_materials():
    road_material = StandardMaterial3D.new()
    road_material.albedo_color = Color(0.17, 0.19, 0.22)

    building_material = StandardMaterial3D.new()
    building_material.albedo_color = Color(0.72, 0.76, 0.82)

    car_material = StandardMaterial3D.new()
    car_material.albedo_color = Color(0.9, 0.08, 0.04)

func create_world():
    var environment = WorldEnvironment.new()
    var env = Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.75, 0.8, 0.9)
    env.ambient_light_energy = 0.8
    environment.environment = env
    add_child(environment)

    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -30, 0)
    sun.light_energy = 1.2
    add_child(sun)

    make_box(
        Vector3(0, -0.15, 0),
        Vector3(220, 0.3, 220),
        Color(0.25, 0.48, 0.23)
    )

    make_box(
        Vector3(0, 0.02, 0),
        Vector3(18, 0.12, 220),
        Color(0.16, 0.17, 0.19)
    )

    make_box(
        Vector3(0, 0.09, 0),
        Vector3(0.18, 0.03, 220),
        Color(1, 0.85, 0.25)
    )

    make_box(
        Vector3(0, 0.02, 0),
        Vector3(220, 0.12, 18),
        Color(0.16, 0.17, 0.19)
    )

    make_box(
        Vector3(0, 0.09, 0),
        Vector3(220, 0.03, 0.18),
        Color(1, 0.85, 0.25)
    )

    for x in range(-80, 81, 25):
        for z in range(-80, 81, 25):
            if abs(x) < 15 or abs(z) < 15:
                continue

            var height = randf_range(5.0, 18.0)
            var width = randf_range(7.0, 13.0)

            make_box(
                Vector3(x, height / 2.0, z),
                Vector3(width, height, width),
                Color(
                    randf_range(0.45, 0.85),
                    randf_range(0.48, 0.8),
                    randf_range(0.55, 0.9)
                )
            )

func make_box(pos: Vector3, size: Vector3, color: Color):
    var body = StaticBody3D.new()
    body.position = pos

    var mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = size
    mesh.mesh = box

    var material = StandardMaterial3D.new()
    material.albedo_color = color
    mesh.material_override = material
    body.add_child(mesh)

    var collision = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    body.add_child(collision)

    add_child(body)

func create_car():
    car = Node3D.new()
    car.position = Vector3(0, 0.6, 25)
    add_child(car)

    add_car_box(
        Vector3(0, 0.35, 0),
        Vector3(2.0, 0.7, 4.0),
        car_material
    )

    var glass = StandardMaterial3D.new()
    glass.albedo_color = Color(0.1, 0.3, 0.42)

    add_car_box(
        Vector3(0, 0.9, 0.25),
        Vector3(1.55, 0.65, 1.8),
        glass
    )

    var wheel_material = StandardMaterial3D.new()
    wheel_material.albedo_color = Color(0.06, 0.06, 0.07)

    for x in [-1.0, 1.0]:
        for z in [-1.25, 1.25]:
            add_car_box(
                Vector3(x, -0.05, z),
                Vector3(0.35, 0.55, 0.65),
                wheel_material
            )

func add_car_box(pos: Vector3, size: Vector3, material):
    var mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.position = pos
    mesh.material_override = material
    car.add_child(mesh)

func create_camera():
    camera = Camera3D.new()
    camera.position = Vector3(0, 5, 9)
    camera.rotation_degrees = Vector3(-20, 0, 0)
    camera.current = true
    car.add_child(camera)

func create_ui():
    var layer = CanvasLayer.new()
    add_child(layer)

    var panel = ColorRect.new()
    panel.color = Color(0.03, 0.04, 0.08, 0.75)
    panel.position = Vector2(15, 15)
    panel.size = Vector2(260, 75)
    layer.add_child(panel)

    var title = Label.new()
    title.text = "CITY DRIVE 3D"
    title.position = Vector2(28, 20)
    title.add_theme_font_size_override("font_size", 23)
    panel.add_child(title)

    var hint = Label.new()
    hint.text = "Explore the city!"
    hint.position = Vector2(28, 49)
    hint.add_theme_font_size_override("font_size", 15)
    panel.add_child(hint)

    add_button(layer, "◀", Vector2(25, -100), "left")
    add_button(layer, "▶", Vector2(115, -100), "right")
    add_button(layer, "▲", Vector2(-105, -155), "forward")
    add_button(layer, "▼", Vector2(-105, -75), "backward")

func add_button(layer, label_text, offset, action):
    var button = Button.new()
    button.text = label_text
    button.custom_minimum_size = Vector2(75, 65)
    button.anchor_left = 1.0
    button.anchor_right = 1.0
    button.anchor_top = 1.0
    button.anchor_bottom = 1.0
    button.offset_left = offset.x - 75
    button.offset_right = offset.x
    button.offset_top = offset.y
    button.offset_bottom = offset.y + 65
    button.add_theme_font_size_override("font_size", 27)
    layer.add_child(button)

    button.button_down.connect(func():
        set_action(action, true)
    )

    button.button_up.connect(func():
        set_action(action, false)
    )

func set_action(action: String, pressed: bool):
    match action:
        "forward":
            Input.action_press("drive_forward") if pressed else Input.action_release("drive_forward")
        "backward":
            Input.action_press("drive_backward") if pressed else Input.action_release("drive_backward")
        "left":
            Input.action_press("drive_left") if pressed else Input.action_release("drive_left")
        "right":
            Input.action_press("drive_right") if pressed else Input.action_release("drive_right")

func _process(delta):
    if not is_instance_valid(car):
        return

    var forward = Input.is_action_pressed("drive_forward")
    var backward = Input.is_action_pressed("drive_backward")
    var left = Input.is_action_pressed("drive_left")
    var right = Input.is_action_pressed("drive_right")

    if forward:
        speed = move_toward(speed, max_speed, acceleration * delta)
    elif backward:
        speed = move_toward(speed, -max_speed * 0.45, acceleration * delta)
    else:
        speed = move_toward(speed, 0.0, friction * delta)

    steering = float(right) - float(left)

    if abs(speed) > 0.3:
        car.rotate_y(-steering * 1.5 * delta * sign(speed))

    car.position += -car.global_basis.z * speed * delta
    car.position.y = 0.6
