local SAVE_NAME = "gamedata_v1"

-- initialize default values
local defaults = {
    hp = 100,
    max_hp = 100,
    currency = 0,
    minigame_points = 0,
    inventory = {}
}

-- load or create save
function load_gamedata()
    cartdata(SAVE_NAME)  -- use named slot
    local data = dget(0)
    if data == 0 then
        -- first time, create new save
        gamedata = {
            hp = 100,
            max_hp = 100,
            currency = 0,
            minigame_points = 0,
            inventory = {}
        }
        save_gamedata()
    else
        -- decode from cartdata
        gamedata = {
            hp = peek(0x5e00),
            max_hp = peek(0x5e01),
            currency = peek2(0x5e02),
            minigame_points = peek2(0x5e04),
            inventory = {}
        }
        -- load inventory (up to 10 slots)
        for i=1,10 do
            local item = peek(0x5e06 + i - 1)
            if item > 0 then
                gamedata.inventory[i] = item
            end
        end
    end
end

-- save gamedata to cartdata
function save_gamedata()
    cartdata(SAVE_NAME)  -- ensure we're in the right slot
    poke(0x5e00, gamedata.hp)
    poke(0x5e01, gamedata.max_hp)
    poke2(0x5e02, gamedata.currency)
    poke2(0x5e04, gamedata.minigame_points)
    
    -- save inventory
    for i=1,10 do
        local item = gamedata.inventory[i] or 0
        poke(0x5e06 + i - 1, item)
    end
    
    -- mark as saved
    dset(0, 1)
end

-- HP management
function take_damage(amount)
    gamedata.hp = max(0, gamedata.hp - amount)
    save_gamedata()
end

function heal(amount)
    gamedata.hp = min(gamedata.max_hp, gamedata.hp + amount)
    save_gamedata()
end

function set_hp_percent(percent)
    gamedata.hp = flr(gamedata.max_hp * percent / 100)
    save_gamedata()
end

-- currency management
function add_currency(amount)
    gamedata.currency += amount
    save_gamedata()
end

function spend_currency(amount)
    if gamedata.currency >= amount then
        gamedata.currency -= amount
        save_gamedata()
        return true
    end
    return false
end

-- minigame points
function add_minigame_points(amount)
    gamedata.minigame_points += amount
    save_gamedata()
end

-- inventory management
function add_inventory(item_id, count)
    count = count or 1
    for i=1,count do
        for j=1,10 do
            if gamedata.inventory[j] == nil then
                gamedata.inventory[j] = item_id
                break
            end
        end
    end
    save_gamedata()
end

function remove_inventory(slot)
    gamedata.inventory[slot] = nil
    save_gamedata()
end

function get_inventory_item(slot)
    return gamedata.inventory[slot]
end

-- reset health to specific breakpoints after fight
function reset_hp_after_fight()
    if gamedata.hp <= 0 then
        set_hp_percent(75)
    elseif gamedata.hp <= gamedata.max_hp * 0.25 then
        set_hp_percent(25)
    elseif gamedata.hp <= gamedata.max_hp * 0.5 then
        set_hp_percent(50)
    elseif gamedata.hp <= gamedata.max_hp * 0.75 then
        set_hp_percent(75)
    end
end

-- debug: print all data
function print_gamedata()
    printh("=== GAMEDATA ===")
    printh("HP: " .. gamedata.hp .. "/" .. gamedata.max_hp)
    printh("Currency: " .. gamedata.currency)
    printh("Minigame Points: " .. gamedata.minigame_points)
    printh("Inventory: ")
    for i=1,10 do
        if gamedata.inventory[i] then
            printh("  Slot " .. i .. ": Item " .. gamedata.inventory[i])
        end
    end
end