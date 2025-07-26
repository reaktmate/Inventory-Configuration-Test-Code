local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local inventoryUI = playerGui:WaitForChild("InventoryUI")
local scrollingFrame = inventoryUI:WaitForChild("Frame"):WaitForChild("ScrollingFrame")

local ItemData = require(ReplicatedStorage:WaitForChild("ItemDataModule"))
local UseItemEvent = ReplicatedStorage:WaitForChild("UseItemEvent")

local Inventory = {} -- クライアント側の所持数

local function updateInventoryUI(inv)
	-- 既存のボタン全部削除
	for _, child in pairs(scrollingFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	-- UI再構築
	for itemName, count in pairs(inv) do
		local data = ItemData[itemName]
		if data then
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, 0, 0, 40)
			button.BackgroundColor3 = Color3.fromRGB(60, 140, 180)
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.Text = data.Name .. " x" .. count
			button.Font = Enum.Font.GothamBold
			button.TextSize = 18
			button.Parent = scrollingFrame

			button.MouseButton1Click:Connect(function()
				print("使う: " .. itemName)
				local newInventory = UseItemEvent:InvokeServer(itemName)
				if newInventory then
					Inventory = newInventory
					updateInventoryUI(Inventory)
				end
			end)
		end
	end
end

-- 最初に初期表示（サーバーから在庫もらう想定）
local function initializeInventory()
	local newInventory = UseItemEvent:InvokeServer("") -- 空文字などで初期データ要求
	if newInventory then
		Inventory = newInventory
		updateInventoryUI(Inventory)
	end
end

initializeInventory()

