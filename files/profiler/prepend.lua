-- [PROFILER INJECTED BY evaisa.compatibility_fixes]
local __PROFILER_MOD_ID__ = "parallel_parity"
local __PROFILER_START_TIME__ = GameGetRealWorldTimeSinceStarted()
local __PROFILER_DATA__ = {}
local __PROFILER_LOGGED_ONCE__ = {}
local __PROFILER_CAN_PRINT__ = false

local function __profiler_log__(msg)
    table.insert(__PROFILER_DATA__, msg)
end

local function __profiler_flush__()
    for _, msg in ipairs(__PROFILER_DATA__) do
        print(msg)
    end
    __PROFILER_DATA__ = {}
end

local function __profiler_wrap_callback__(name, original_func, once_only)
    if not original_func then return nil end
    return function(...)
        if name == "OnMagicNumbersAndWorldSeedInitialized" then
            __PROFILER_CAN_PRINT__ = true
            __profiler_flush__()
        end
        local should_profile = not once_only or not __PROFILER_LOGGED_ONCE__[name]
        local start = GameGetRealWorldTimeSinceStarted()
        local results = {original_func(...)}
        local elapsed = GameGetRealWorldTimeSinceStarted() - start
        if should_profile and elapsed > 0.001 then
            if __PROFILER_CAN_PRINT__ then
                print(string.format("[PROFILER] [%s] %s took %.4fs", __PROFILER_MOD_ID__, name, elapsed))
            else
                __profiler_log__(string.format("[PROFILER] [%s] %s took %.4fs", __PROFILER_MOD_ID__, name, elapsed))
            end
            if once_only then
                __PROFILER_LOGGED_ONCE__[name] = true
            end
        end
        return unpack(results)
    end
end

