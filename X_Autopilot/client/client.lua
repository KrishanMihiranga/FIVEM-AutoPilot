local Speed = Config.NormalSpeed
local Drive = Config.NormalDrive
local mode = "normal"

function IsAllowedVehicle(veh)
    -- Add the model names or class hashes of the vehicles you want to allow for Auto-Pilot here
    local allowedVehicles = {
        "adder", -- Example: "adder" is the model name of the vehicle, you can add more vehicles here
        "police",
        "firetruk",
        "sultan",
    }

    local model = GetEntityModel(veh)
    local modelHash = type(model) == 'string' and GetHashKey(model) or model

    for _, allowedVehicle in ipairs(allowedVehicles) do
        if modelHash == GetHashKey(allowedVehicle) then
            return true
        end
    end

    return false
end

function DriveToBlipCoord(player, blipCoords, speed, drivingStyle)
    local veh = GetVehiclePedIsIn(player, false)

    if DoesBlipExist(GetFirstBlipInfoId(8)) then
        ClearPedTasks(player)
        TaskVehicleDriveToCoordLongrange(player, veh, blipCoords.x, blipCoords.y, blipCoords.z, tonumber(speed), drivingStyle, 2.0)
    end
end

function ParkVehicle(player)
    local veh = GetVehiclePedIsIn(player, false)
    local forwardVector = GetEntityForwardVector(veh)
    local position = GetEntityCoords(player)
    local rightVector = vector3(forwardVector.y, -forwardVector.x, 0.0)

    local parkPosition = position + (rightVector * 10.0) -- Adjust the parking distance as needed

    SetVehicleForwardSpeed(veh, 0.0)
    SetVehicleOnGroundProperly(veh)
    SetEntityCoords(veh, parkPosition.x, parkPosition.y, parkPosition.z, true, true, true)
end

if Config.NormalKeybind then
    RegisterCommand('+normalpilot', function()
        local player = PlayerPedId()
        if IsPedInAnyVehicle(player) and IsAllowedVehicle(GetVehiclePedIsIn(player, false)) then
            mode = "normal"
            Drive = Config.NormalDrive

            if DoesBlipExist(GetFirstBlipInfoId(8)) then
                local blip = GetFirstBlipInfoId(8)
                local bCoords = GetBlipCoords(blip)
                DriveToBlipCoord(player, bCoords, tonumber(Speed), Drive)

                local message = Config.Translate[5]
                TriggerEvent('chatMessage', 'SYSTEM', {255, 255, 255}, message)
            end
        end
    end, false)

    RegisterCommand('-normalpilot', function()
        if IsPedInAnyVehicle(PlayerPedId()) and IsAllowedVehicle(GetVehiclePedIsIn(PlayerPedId(), false)) then
            ClearPedTasks(PlayerPedId())
        end
    end, false)
    RegisterKeyMapping('+normalpilot', 'Autopilot (Normal Driving)', 'keyboard', Config.DefaultKey)
end

if Config.CrazyKeybind then
    RegisterCommand('+crazypilot', function()
        local player = PlayerPedId()
        if IsPedInAnyVehicle(player) and IsAllowedVehicle(GetVehiclePedIsIn(player, false)) then
            mode = "crazy"
            Drive = Config.CrazyDrive

            if DoesBlipExist(GetFirstBlipInfoId(8)) then
                local blip = GetFirstBlipInfoId(8)
                local bCoords = GetBlipCoords(blip)
                DriveToBlipCoord(player, bCoords, tonumber(Speed), Drive)

                local message = Config.Translate[6]
                TriggerEvent('chatMessage', 'SYSTEM', {255, 255, 255}, message)
            end
        end
    end, false)

    RegisterCommand('-crazypilot', function()
        if IsPedInAnyVehicle(PlayerPedId()) and IsAllowedVehicle(GetVehiclePedIsIn(PlayerPedId(), false)) then
            ClearPedTasks(PlayerPedId())
        end
    end, false)
    RegisterKeyMapping('+crazypilot', 'Autopilot (Aggressive Driving)', 'keyboard', Config.CrazyKey)
end

RegisterCommand(Config.StartCommand, function(source, args)
    local player = PlayerPedId()

    if IsPedInAnyVehicle(player) then
        if table.concat(args," ") == Config.NormalCMD then
            mode = "normal"
        end
        if table.concat(args," ") == Config.CrazyCMD then
            mode = "crazy"
        end
        if mode == 'crazy' then
            Drive = Config.CrazyDrive
            Speed = Config.CrazySpeed
        elseif mode == 'normal' then
            Drive = Config.NormalDrive
            Speed = Config.NormalSpeed
        end

        if DoesBlipExist(GetFirstBlipInfoId(8)) then
            local blip = GetFirstBlipInfoId(8)
            local bCoords = GetBlipCoords(blip)
            DriveToBlipCoord(player, bCoords, tonumber(Speed), Drive)

            local message = Config.Translate[1]
            TriggerEvent('chatMessage', 'SYSTEM', {255, 255, 255}, message)
        else
            local message = Config.Translate[2]
            TriggerEvent('chatMessage', 'SYSTEM', {255, 0, 0}, message)
        end
    else
        local message = Config.Translate[3]
        TriggerEvent('chatMessage', 'SYSTEM', {255, 0, 0}, message)
    end
end, false)

RegisterCommand(Config.StopCommand, function(source, args)
    if IsPedInAnyVehicle(PlayerPedId()) and IsAllowedVehicle(GetVehiclePedIsIn(PlayerPedId(), false)) then
        ClearPedTasks(PlayerPedId())

        local message = Config.Translate[4]
        TriggerEvent('chatMessage', 'SYSTEM', {255, 255, 255}, message)
    else
        local message = Config.Translate[3]
        TriggerEvent('chatMessage', 'SYSTEM', {255, 0, 0}, message)
    end
end, false)
