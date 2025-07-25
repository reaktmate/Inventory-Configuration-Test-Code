local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UseItemEvent = ReplicatedStorage:WaitForChild("UseItemEvent")
local ItemData = require(ReplicatedStorage:WaitForChild("ItemDataModule"))

-- 🔁 仮のサーバー用Inventory（将来的にはDataStore対応などもアリ）
local ServerInventories = {}

-- プレイヤーが参加したらインベントリ初期化
game.Players.PlayerAdded:Connect(function(player)
	ServerInventories[player.UserId] = {
		["HealthPotion"] = 2,
		["SpeedBoots"] = 1,
	}
end)

-- プレイヤーが抜けたら破棄（メモリ節約）
game.Players.PlayerRemoving:Connect(function(player)
	ServerInventories[player.UserId] = nil
end)

-- 🎯 UseItem受信処理！
UseItemEvent.OnServerEvent:Connect(function(player, itemName)
	local inventory = ServerInventories[player.UserId]
	if not inventory then return end

	local count = inventory[itemName]
	if count and count > 0 then
		local item = ItemData[itemName]
		if item and item.Effect then
			print(player.Name .. " が " .. itemName .. " を使った！")
			item.Effect(player) -- 効果を発動！

			inventory[itemName] -= 1 -- 所持数減らす

			-- ⚠️ UI更新（クライアントに通知）が必要になるけど、今は割愛中！
		else
			warn("効果が定義されていないアイテム: " .. itemName)
		end
	else
		warn(player.Name .. " は " .. itemName .. " を持っていません！")
	end
end)
