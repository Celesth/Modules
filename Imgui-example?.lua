local window = ImGui_new({
    Title = "test"
})

window:Label("label!")

window:Button("button!", function()
    print("pressed!")
end)

window:Toggle("toggle!", false, function(v)
    print("toggle!", v)
end)

window:Slider("slider!", 5, 1, 10, function(v)
    print("slider!", v)
end)

window:Dropdown("dropdown!", "option 1", {"option 1", "option 2"}, function(v)
    print("dropdown!", v)
end)

window:ColorPicker("color!", Color3.new(1, 1, 1), function(v)
    print("color!", v)
end)

window:Render()
