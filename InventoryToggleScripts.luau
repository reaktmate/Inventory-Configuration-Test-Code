-- InventoryToggleScript (LocalScript, StarterPlayerScripts)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local inventoryUI = playerGui:WaitForChild("InventoryUI")
local frame = inventoryUI:WaitForChild("Frame")
local scrollingFrame = frame:WaitForChild("ScrollingFrame")

local ItemData = require(ReplicatedStorage:WaitForChild("ItemDataModule"))
local UseItemEvent = ReplicatedStorage:WaitForChild("UseItemEvent")

-- Qキー押下でインベントリUIの表示/非表示を切り替える
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Q then
		frame.Visible = not frame.Visible
	end
end)

-- プレイヤーのInventoryフォルダからアイテム名と所持数を取得してテーブルで返す関数
local function getInventoryFromFolder()
	local inventoryTable = {}
	local inventoryFolder = player:WaitForChild("Inventory")
	for _, itemValue in pairs(inventoryFolder:GetChildren()) do
		if itemValue:IsA("IntValue") then
			inventoryTable[itemValue.Name] = itemValue.Value
		end
	end
	return inventoryTable
end

-- 引数のinventoryテーブルを元にインベントリUIのボタンを更新する関数
local function updateInventoryUI(inventory)
	-- 既存のボタンを削除
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	-- 新規にアイテムボタンを作成
	for itemName, count in pairs(inventory) do
		local data = ItemData[itemName]
		if data then
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, 0, 0, 40)
			button.BackgroundColor3 = Color3.fromRGB(80, 160, 200)
			button.TextColor3 = Color3.new(1, 1, 1)
			button.Text = data.Name .. " x" .. count
			button.Font = Enum.Font.Gotham
			button.TextSize = 16
			button.Parent = scrollingFrame

			-- ボタン押下時にサーバーへ使用イベントを送信
			button.MouseButton1Click:Connect(function()
				print("使う: " .. itemName)
				UseItemEvent:FireServer(itemName)
			end)
		end
	end
end

-- スクリプト開始時にUIを初期化
updateInventoryUI(getInventoryFromFolder())
