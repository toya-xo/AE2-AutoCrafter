local AUTOCRAFTS = {
    --[[
    Ex: Minimum 3 buckets 
    {
        input = "minecraft:iron_ingot",
        output = "minecraft:bucket",
        ratio = 3,
        threshold = 10,
        craftType = 2,
        maxCraft = 16
    }--]]
    --[[
    Ex: When there is more than 1k oak_planks it craft sticks
    {
        input="minecraft:oak_planks",
        output="minecraft:stick",
        ratio=2,
        threshold=1000,
        craftType=1,
        maxCraft=1000
    }]]--
}

local ME = peripheral.find("me_bridge")
local SCREEN = peripheral.find("monitor")
local INTERVAL = 5

local function clear()
    SCREEN.clear()
    SCREEN.setCursorPos(1,1)
end

SCREEN.setTextScale(0.5)
SCREEN.setBackgroundColor(colors.black)
SCREEN.setTextColor(colors.white)

local function drawUI(lines)
    clear()
    for i, line in ipairs(lines) do
        SCREEN.setCursorPos(1, i)
        SCREEN.write(line)
    end
    SCREEN.setCursorPos(1, #lines + 2)
    SCREEN.write("Last update: " .. os.date("%H:%M:%S"))
end    

while true do
    local ui = {}

    for _, craft in ipairs(AUTOCRAFTS) do
        local inputItem  = ME.getItem({ name = craft.input })
        local outputItem = ME.getItem({ name = craft.output })
        local crafting = ME.isCrafting({ name = craft.output })
        local inputCount  = inputItem and inputItem.count or 0
        local outputCount = outputItem and outputItem.count or 0

        local inputName  = inputItem and inputItem.displayName or craft.input
        local outputName = outputItem and outputItem.displayName or craft.output

        local amount = 0
        

        -- TYPE 1 : Convert excess
        if craft.craftType == 1 and inputCount >= craft.threshold + craft.ratio then
            amount = math.min(craft.maxCraft, math.floor((inputCount - craft.threshold) / craft.ratio))
            
            if amount > 0 and not crafting then
                local ok, job = pcall(ME.craftItem, { name = craft.output, count = amount })
                if ok then
                    print("CRAFT STARTED: "..craft.output.." x"..amount)
                else
                    print("CRAFT FAILED: "..craft.output)
                end
            end
        end

        -- TYPE 2 : Always keep <number> of <block>
        if craft.craftType == 2 then
            amount = math.min(craft.maxCraft, craft.threshold - outputCount)

            if amount > 0 and not crafting then
                local ok, job = pcall(ME.craftItem, { name = craft.output, count = amount })
                if ok then
                    print("CRAFT STARTED: "..craft.output.." x"..amount)
                else
                    print("CRAFT FAILED: "..craft.output)
                end
            end
        end

        table.insert(ui, string.format(
            "%s: %d -> %s: %d (Craft: %d)",
            inputName,
            inputCount,
            outputName,
            outputCount,
            amount
        ))
    end

    drawUI(ui)
    sleep(INTERVAL)
end
