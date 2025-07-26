local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- InventoryUIがPlayerGuiに追加されるのを待つ
local inventoryUI = playerGui:WaitForChild("InventoryUI", 10)  -- 10秒待つ（timeout）

if not inventoryUI then
	warn("InventoryUIがPlayerGuiに見つかりませんでした")
	return
end

local frame = inventoryUI:WaitForChild("Frame")

print("InventoryUI準備完了")

UserInputService.InputBegan:Connect(function(input, processed)
	print("InputBegan イベント発火")
	if processed then
		print("Inputは処理済みです")
		return
	end

	if input.KeyCode == Enum.KeyCode.Q then
		frame.Visible = not frame.Visible
		print("Qキー押されたよ！Frame.Visible=", frame.Visible)
	end
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local inventoryUI = playerGui:WaitForChild("InventoryUI")
local frame = inventoryUI:WaitForChild("Frame")
local scrollingFrame = frame:WaitForChild("ScrollingFrame")

local UseItemFunction = ReplicatedStorage:WaitForChild("UseItemFunction")
local ItemData = require(ReplicatedStorage:WaitForChild("ItemDataModule"))

-- プレイヤーの手元にあるインベントリテーブル
local inventory = {}

-- UI更新関数
local function updateInventoryUI(inventoryTable)
	-- 既存のボタンを全部消す
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	-- アイテムごとにボタンを作成
	for itemName, count in pairs(inventoryTable) do
		local data = ItemData[itemName]
		if data then
			local function createButton(itemName, count, data)
				local button = Instance.new("TextButton")
				button.Size = UDim2.new(1, 0, 0, 40)
				button.BackgroundColor3 = Color3.fromRGB(80, 160, 200)
				button.TextColor3 = Color3.new(1, 1, 1)
				button.Text = data.Name .. " x" .. count
				button.Font = Enum.Font.Gotham
				button.TextSize = 16
				button.Parent = scrollingFrame

				button.MouseButton1Click:Connect(function()
					print("🧪 使用：", itemName)
					local newInventory = UseItemFunction:InvokeServer(itemName)
					if newInventory then
						inventory = newInventory -- 手元のインベントリ更新
						updateInventoryUI(newInventory)
					else
						warn("⚠️ サーバーからインベントリ更新が返ってこなかった")
					end
				end)
			end
			createButton(itemName, count, data)
		end
	end
end

-- ゲーム開始時にプレイヤーのInventoryフォルダから初期データを取得してUI表示
local function initializeInventory()
	local inventoryFolder = player:WaitForChild("Inventory", 10) -- 10秒待つ
	if not inventoryFolder then
		warn("Inventoryフォルダが見つかりませんでした")
		return
	end

	local tempInventory = {}
	for _, itemValue in pairs(inventoryFolder:GetChildren()) do
		if itemValue:IsA("IntValue") then
			tempInventory[itemValue.Name] = itemValue.Value
		end
	end

	inventory = tempInventory
	updateInventoryUI(inventory)
end

-- 最初に呼ぶ
initializeInventory()

-- QキーでインベントリUIの開閉
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Q then
		frame.Visible = not frame.Visible
		print("QキーでInventoryUI表示切替:", frame.Visible)
	end
end)
