function love.conf(t)
    t.version = "11.4"
    t.window.title = "Роевой интеллект"

    t.window.fullscreen = true
    t.window.vsync = false
    t.window.display = 1

    t.accelerometerjoystick = false
    t.externalstorage = false
    t.gammacorrect = false
    t.modules.audio = false
    t.modules.image = false
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.sound = false
    t.modules.video = false
    t.modules.thread = false
end