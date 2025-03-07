_G._hoots = _G._hoots or {}

local function hoothook(fn)
    local function proxy(...)
        local this = debug.info(1, "f")
        local hook = _G._hoots[this]
        return (hook.replacement or hook.original)(...)
    end

    local original = hookfunction(fn, proxy)

    local hook = {
        fn = fn,
        original = original,
        replacement = nil
    }

    _G._hoots[fn] = hook
    return hook
end
