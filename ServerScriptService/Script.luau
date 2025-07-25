local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local UseItemEvent = ReplicatedStorage:WaitForChild("UseItemEvent")
local ItemData = require(ReplicatedStorage:WaitForChild("ItemData")) -- モジュールで定義済み

UseItemEvent.OnServerEvent:Connect(function(player, itemName)
	print(player.Name .. " が " .. itemName .. " を使用しました！")

	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end

	-- アイテムが存在するかチェック
	local item = inventory:FindFirstChild(itemName)
	if not item or not item:IsA("IntValue") or item.Value <= 0 then
		warn("アイテムが見つからない、または所持数ゼロ")
		return
	end

	local itemInfo = ItemData[itemName]
	if not itemInfo then
		warn("ItemDataに定義されていません: " .. itemName)
		return
	end

	-- 効果処理
	if itemInfo.Type == "Heal" then
		local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + itemInfo.Amount)
		end
	elseif itemInfo.Type == "Speed" then
		local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = humanoid.WalkSpeed + itemInfo.Amount

			-- 一定時間で戻す
			task.delay(itemInfo.Duration or 5, function()
				if humanoid then
					humanoid.WalkSpeed = 16
				end
			end)
		end
	end

	-- 所持数を1減らす or 削除
	item.Value -= 1
	if item.Value <= 0 then
		item:Destroy()
	end
end)
