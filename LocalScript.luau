--[[
    📂 Script: Inventory UI Generator
    🎮 場所: StarterPlayer > StarterPlayerScripts（LocalScript）
    📋 概要: インベントリUI内のアイテムボタンを生成し、クリックで使用処理をサーバーへ送信
--]]

-- サービス取得
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- プレイヤー情報とGUIへのアクセス
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local inventoryUI = playerGui:WaitForChild("InventoryUI")
local scrollingFrame = inventoryUI:WaitForChild("Frame"):WaitForChild("ScrollingFrame")

-- アイテム情報を格納したModuleScriptを取得
local ItemData = require(ReplicatedStorage:WaitForChild("ItemDataModule"))

-- サーバーへ「アイテム使ったよ！」と伝えるイベント
local UseItemEvent = ReplicatedStorage:WaitForChild("UseItemEvent")

-- 🧪 仮インベントリ（あとでサーバーから取得されるように変更予定）
local Inventory = {
	["HealthPotion"] = 2,
	["SpeedBoots"] = 1,
}

-- 📛 既存のボタンをすべて削除（UI更新時にリセットするため）
for _, child in pairs(scrollingFrame:GetChildren()) do
	if child:IsA("TextButton") then
		child:Destroy()
	end
end

-- 🔁 インベントリ内のアイテム分、ボタンを生成
for itemName, count in pairs(Inventory) do
	local data = ItemData[itemName]

	if data then
		-- 🎨 ボタン生成とデザイン設定
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, 0, 0, 40)
		button.BackgroundColor3 = Color3.fromRGB(60, 140, 180)
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.Text = data.Name .. " x" .. count
		button.Font = Enum.Font.GothamBold
		button.TextSize = 18
		button.Parent = scrollingFrame

		-- 🖱️ ボタンクリックで使用イベント発火
		button.MouseButton1Click:Connect(function()
			print("使う: " .. itemName)
			UseItemEvent:FireServer(itemName)
		end)
	end
end
