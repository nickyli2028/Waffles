local SAVE_NAME = "gamedata_v1"

-- load or create save
function load_gamedata()
    cartdata(SAVE_NAME)
    gamedata = {
        hp         = peek(0x5e00),
        max_hp     = peek(0x5e01),
        currency   = peek2(0x5e02),
        minigame_points = peek2(0x5e04),
        inventory  = {},
        food = {
            coffee     = peek(0x5e10),
            fries      = peek(0x5e11),
            bacon_eggs = peek(0x5e12),
        }
    }
    -- default hp if never saved
    if gamedata.hp == 0 then gamedata.hp = 100 end
    if gamedata.max_hp == 0 then gamedata.max_hp = 100 end
    for i=1,10 do
        local item = peek(0x5e06 + i - 1)
        if item > 0 then gamedata.inventory[i] = item end
    end

    doors_unlocked = {}
    for i = 1, 8 do
        doors_unlocked[i] = peek(0x5e20 + i - 1) == 1
    end

end

-- save gamedata to cartdata
function save_gamedata()
    cartdata(SAVE_NAME)
    poke(0x5e00, gamedata.hp)
    poke(0x5e01, gamedata.max_hp)
    poke2(0x5e02, gamedata.currency)
    poke2(0x5e04, gamedata.minigame_points)
    -- save inventory
    for i=1,10 do
        local item = gamedata.inventory[i] or 0
        poke(0x5e06 + i - 1, item)
    end
    poke(0x5e10, gamedata.food.coffee     or 0)
    poke(0x5e11, gamedata.food.fries      or 0)
    poke(0x5e12, gamedata.food.bacon_eggs or 0)
    dset(0, 1)

    for i = 1, 8 do
        poke(0x5e20 + i - 1, doors_unlocked[i] and 1 or 0)
    end
end

--door helpers
function unlock_door(slot)
    doors_unlocked[slot] = true
    save_gamedata()
end

function is_door_unlocked(slot)
    return doors_unlocked[slot] == true
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

function add_minigame_points(amount)
    gamedata.minigame_points += amount
    save_gamedata()
end

function add_food(item, amt)
    amt = amt or 1
    if amt <= 0 then return end
    gamedata.food[item] = (gamedata.food[item] or 0) + amt
    save_gamedata()
end

function has_food(order)
    for item, amt in pairs(order) do
        if (gamedata.food[item] or 0) < amt then return false end
    end
    return true
end

function spend_food(order)
    for item, amt in pairs(order) do
        gamedata.food[item] -= amt
    end
    save_gamedata()
end

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

function print_gamedata()
    printh("=== GAMEDATA ===")
    printh("HP: " .. gamedata.hp .. "/" .. gamedata.max_hp)
    printh("Currency: " .. gamedata.currency)
    printh("Minigame Points: " .. gamedata.minigame_points)
    printh("Food: coffee=" .. gamedata.food.coffee .. " fries=" .. gamedata.food.fries .. " bacon_eggs=" .. gamedata.food.bacon_eggs)
end