-- Menggunakan PlayerGui agar kompatibel penuh dengan Delta Executor Mobile
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Hapus GUI lama jika sudah ada agar tidak menumpuk
local oldGui = playerGui:FindFirstChild("DeltaAutoFollowUI")
if oldGui then oldGui:Destroy() end

-- Membuat Interface ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaAutoFollowUI"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

-- Panel Utama Menu
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Bisa digeser dengan jari di HP
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Judul Menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "MOUNT AUTO JUMP & FOLLOW"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Tombol Pemilih Target (Dropdown Trigger)
local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(0, 220, 0, 35)
DropdownBtn.Position = UDim2.new(0, 20, 0, 50)
DropdownBtn.Text = "KLIK: PILIH NAMA TARGET"
DropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DropdownBtn.Font = Enum.Font.SourceSansBold
DropdownBtn.TextSize = 14
DropdownBtn.Parent = MainFrame
local DropCorner = Instance.new("UICorner")
DropCorner.CornerRadius = UDim.new(0, 5)
DropCorner.Parent = DropdownBtn

-- Kontainer List Nama (Scrolling Frame)
local DropdownScroll = Instance.new("ScrollingFrame")
DropdownScroll.Size = UDim2.new(0, 220, 0, 110)
DropdownScroll.Position = UDim2.new(0, 20, 0, 85)
DropdownScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
DropdownScroll.Visible = false
DropdownScroll.ZIndex = 5
DropdownScroll.ScrollBarThickness = 6
DropdownScroll.Parent = MainFrame
local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 5)
ScrollCorner.Parent = DropdownScroll

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = DropdownScroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Tombol Pengatur Speed (-)
local BtnMinus = Instance.new("TextButton")
BtnMinus.Size = UDim2.new(0, 40, 0, 30)
BtnMinus.Position = UDim2.new(0, 20, 0, 100)
BtnMinus.Text = "-"
BtnMinus.BackgroundColor3 = Color3.fromRGB(65, 65, 80)
BtnMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnMinus.TextSize = 20
BtnMinus.Parent = MainFrame

-- Indikator Speed
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 140, 0, 30)
SpeedLabel.Position = UDim2.new(0, 60, 0, 100)
SpeedLabel.Text = "Speed: 16"
SpeedLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SpeedLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.TextSize = 15
SpeedLabel.Parent = MainFrame

-- Tombol Pengatur Speed (+)
local BtnPlus = Instance.new("TextButton")
BtnPlus.Size = UDim2.new(0, 40, 0, 200)
BtnPlus.Position = UDim2.new(0, 200, 0, 100)
BtnPlus.Size = UDim2.new(0, 40, 0, 30)
BtnPlus.Text = "+"
BtnPlus.BackgroundColor3 = Color3.fromRGB(65, 65, 80)
BtnPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnPlus.TextSize = 20
BtnPlus.Parent = MainFrame

-- Tombol Utama PLAY / STOP
local BtnToggle = Instance.new("TextButton")
BtnToggle.Size = UDim2.new(0, 220, 0, 40)
BtnToggle.Position = UDim2.new(0, 20, 0, 150)
BtnToggle.Text = "PLAY (MULAI)"
BtnToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 90)
BtnToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnToggle.Font = Enum.Font.SourceSansBold
BtnToggle.TextSize = 16
BtnToggle.Parent = MainFrame
local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = BtnToggle

---------------------------------------------------------
-- LOGIKA UTAMA & SISTEM PENDETEKSI JALAN/LONCAT
---------------------------------------------------------
local targetPlayer = nil
local isFollowing = false
local currentSpeed = 16

-- Fungsi memperbarui daftar nama pemain aktif di server
local function updateDropdown()
    for _, child in ipairs(DropdownScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local count = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            count = count + 1
            local PBtn = Instance.new("TextButton")
            PBtn.Size = UDim2.new(1, 0, 0, 30)
            PBtn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            PBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            PBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            PBtn.Font = Enum.Font.SourceSans
            PBtn.TextSize = 13
            PBtn.ZIndex = 6
            PBtn.Parent = DropdownScroll
            
            PBtn.MouseButton1Click:Connect(function()
                targetPlayer = p
                DropdownBtn.Text = "TARGET: " .. p.DisplayName
                DropdownScroll.Visible = false
            end)
        end
    end
    DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, count * 30)
end

-- Buka/tutup Dropdown list nama pemain
DropdownBtn.MouseButton1Click:Connect(function()
    DropdownScroll.Visible = not DropdownScroll.Visible
    if DropdownScroll.Visible then updateDropdown() end
end)

-- Tombol Pengatur Kecepatan (+ / -)
BtnPlus.MouseButton1Click:Connect(function()
    currentSpeed = math.min(currentSpeed + 5, 100)
    SpeedLabel.Text = "Speed: " .. tostring(currentSpeed)
end)

BtnMinus.MouseButton1Click:Connect(function()
    currentSpeed = math.max(currentSpeed - 5, 0)
    SpeedLabel.Text = "Speed: " .. tostring(currentSpeed)
end)

-- Aksi Sakelar Tombol PLAY / STOP
BtnToggle.MouseButton1Click:Connect(function()
    if not targetPlayer then
        DropdownBtn.Text = "PILIH TARGET DULU!"
        return
    end
    
    isFollowing = not isFollowing
    if isFollowing then
        BtnToggle.Text = "STOP"
        BtnToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    else
        BtnToggle.Text = "PLAY (MULAI)"
        BtnToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 90)
        -- Hentikan karakter secara instan saat di-stop
        if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
            localPlayer.Character:FindFirstChildOfClass("Humanoid"):Move(Vector3.new(0, 0, 0))
        end
    end
end)

-- Loop Utama Pergerakan Otomatis & Auto Loncat Rintangan
RunService.Heartbeat:Connect(function()
    if not isFollowing or not targetPlayer then return end
    
    local myChar = localPlayer.Character
    local targetChar = targetPlayer.Character
    
    if myChar and targetChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
        local myHRP = myChar.HumanoidRootPart
        local targetHRP = targetChar.HumanoidRootPart
        local humanoid = myChar:FindFirstChildOfClass("Humanoid")
        
        if humanoid and humanoid.Health > 0 then
            -- Terapkan kecepatan dari menu slider
            humanoid.WalkSpeed = currentSpeed
            
            -- Gerakkan karakter ke koordinat posisi target
            humanoid:MoveTo(targetHRP.Position)
            
            -- SISTEM AUTO JUMP OLEH KETINGGIAN:
            -- Jika posisi target berada di atas kepala karakter Anda (selisih tinggi > 2 stud)
            if (targetHRP.Position.Y - myHRP.Position.Y) > 2 then
                humanoid.Jump = true
            end
            
            -- SISTEM AUTO JUMP OLEH RINTANGAN (Raycast):
            -- Mendeteksi objek penghalang/balok/dinding tepat di depan kaki
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = {myChar}
            
            -- Menembakkan sensor sejauh 4 stud ke arah depan karakter
            local rayDirection = myHRP.CFrame.LookVector * 4
            local raycastResult = workspace:Raycast(myHRP.Position - Vector3.new(0, 1.5, 0), rayDirection, raycastParams)
            
            if raycastResult then
                humanoid.Jump = true
            end
        end
    end
end)

-- Jalankan pembaruan list nama saat pertama kali load
updateDropdown()
