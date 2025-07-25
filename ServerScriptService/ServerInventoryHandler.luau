-- 📂 Script: ServerInventoryHandler
-- 📍 場所: ServerScriptService
-- 🎮 概要: サーバー側でプレイヤーごとのインベントリ管理、アイテム使用処理を行う

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- InventoryServer.lua
-- プレイヤーのインベントリとアイテム使用処理を管理

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UseItemEvent = Instance.new("RemoteEvent")
UseItemEvent.Name = "UseItemEvent"
UseItemEvent.Parent = ReplicatedStorage

local ItemData = require(ReplicatedStorage:WaitForChild("ItemDataModule"))

-- サーバー上でプレイヤーごとのインベントリを保持
local Inventories = {}

-- 効果処理を関数化（再利用性アップ）
local function applyItemEffect(player, itemName, itemInfo)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	if itemInfo.Type == "Heal" then
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + itemInfo.Amount)
	elseif itemInfo.Type == "Speed" then
		humanoid.WalkSpeed += itemInfo.Amount
		task.delay(itemInfo.Duration or 5, function()
			if humanoid then
				humanoid.WalkSpeed = 16
			end
		end)
	end
end

-- アイテム使用のリモートイベント
UseItemEvent.OnServerEvent:Connect(function(player, itemName)
	local inventory = Inventories[player]
	if not inventory then return end

	if inventory[itemName] and inventory[itemName] > 0 then
		local itemInfo = ItemData[itemName]
		if itemInfo then
			applyItemEffect(player, itemName, itemInfo)
			inventory[itemName] -= 1
			if inventory[itemName] <= 0 then
				inventory[itemName] = nil
			end
			print(player.Name .. " が " .. itemName .. " を使用しました。残り: " .. (inventory[itemName] or 0))
		else
			warn("定義されていないアイテム：" .. itemName)
		end
	else
		warn(player.Name .. " は " .. itemName .. " を所持していません。")
	end
end)

-- プレイヤー参加時、仮の在庫追加
Players.PlayerAdded:Connect(function(player)
	Inventories[player] = {
		HealthPotion = 2,
		SpeedBoots = 1
	}
end)

-- プレイヤー退出時にメモリ解放
Players.PlayerRemoving:Connect(function(player)
	Inventories[player] = nil
end)

-- ServerScriptService内のScriptに追記！

game.Players.PlayerAdded:Connect(function(player)
	local inventoryFolder = Instance.new("Folder")
	inventoryFolder.Name = "Inventory"
	inventoryFolder.Parent = player

	-- 初期アイテムをここで追加！
	local starterItems = {
		HealthPotion = 2,
		SpeedBoots = 1
	}

	for itemName, count in pairs(starterItems) do
		local intValue = Instance.new("IntValue")
		intValue.Name = itemName
		intValue.Value = count
		intValue.Parent = inventoryFolder
	end
end)
