--receba
--[[
    NUCLEARBOBO 5.0
    Sem Key System
    G = Ativar/desativar
    M = Mostrar/esconder menu
]]

-- LIMPEZA DE EXECUCOES ANTERIORES
if _G.NuclearBobo5 then
    local old = _G.NuclearBobo5

    if old.Connections then
        for _, conn in pairs(old.Connections) do
            pcall(function()
                conn:Disconnect()
            end)
        end
    end

    if old.Gui then
        pcall(function()
            old.Gui:Destroy()
        end)
    end
end

_G.NuclearBobo5 = {}

-- SERVICOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- CONFIGURACAO
local Config = {
    ToggleKey = Enum.KeyCode.G,
    UIToggleKey = Enum.KeyCode.M,
    TeleportHeight = -500,
    Transparency = 0.7,

    PrimaryColor = Color3.fromRGB(255, 128, 0),
    BackgroundColor = Color3.fromRGB(10, 10, 10),
    TextColor = Color3.fromRGB(255, 255, 255),
    ActiveColor = Color3.fromRGB(0, 255, 0)
}

-- VARIAVEIS
local character
local humanoid
local rootPart

local invisible = false
local uiVisible = true

local parts = {}
local originalTransparency = {}
local connections = {}

local gui
local mainFrame

-- ANIMACAO ARCO-IRIS
local function createSmoothRainbow(stroke)
    local colors = {
        Color3.new(1, 0, 0),
        Color3.new(1, 0.5, 0),
        Color3.new(1, 1, 0),
        Color3.new(0, 1, 0),
        Color3.new(0, 0.5, 1),
        Color3.new(0.5, 0, 1),
        Color3.new(1, 0, 1)
    }

    local currentIndex = 2
    local nextIndex = 3
    local progress = 0

    while stroke and stroke.Parent do
        stroke.Color = colors[currentIndex]:Lerp(
            colors[nextIndex],
            progress
        )

        progress = progress + 0.02

        if progress >= 1 then
            progress = 0
            currentIndex = nextIndex
            nextIndex = currentIndex % #colors + 1
        end

        task.wait(0.016)
    end
end

-- NOTIFICACAO
task.spawn(function()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "NUCLEARBOBO 5.0",
            Text = "Carregado! Pressione G para ativar.",
            Duration = 3
        })
    end)
end)

-- PERSONAGEM
local function setupCharacter()
    character = player.Character
        or player.CharacterAdded:Wait()

    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")

    parts = {}
    originalTransparency = {}

    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
            originalTransparency[obj] = obj.Transparency
        end
    end

    if invisible then
        for _, part in pairs(parts) do
            part.Transparency = Config.Transparency
        end
    end
end

-- ATUALIZAR INTERFACE
local function updateUI()
    if not mainFrame then
        return
    end

    local toggleBtn = mainFrame:FindFirstChild("ToggleBtn")
    local statusLabel = mainFrame:FindFirstChild("StatusLabel")

    if toggleBtn then
        toggleBtn.Text = invisible and "ACTIVE" or "INACTIVE"

        toggleBtn.BackgroundColor3 =
            invisible and Config.ActiveColor
            or Config.PrimaryColor
    end

    if statusLabel then
        statusLabel.Text =
            invisible and "SYSTEM ACTIVE"
            or "SYSTEM INACTIVE"

        statusLabel.TextColor3 =
            invisible and Config.ActiveColor
            or Config.PrimaryColor
    end
end

-- ATIVAR / DESATIVAR
local function toggleInvisibility()
    invisible = not invisible

    for _, part in pairs(parts) do
        if part and part.Parent then
            if invisible then
                part.Transparency = Config.Transparency
            else
                part.Transparency =
                    originalTransparency[part] or 0
            end
        end
    end

    updateUI()
end

-- ESCONDER MENU
local function toggleUI()
    uiVisible = not uiVisible

    if gui then
        gui.Enabled = uiVisible
    end
end

-- CRIAR MENU
local function createMainUI()
    if gui then
        gui:Destroy()
    end

    gui = Instance.new("ScreenGui")
    gui.Name = "NuclearBobo5UI"
    gui.ResetOnSpawn = false
    gui.Enabled = uiVisible
    gui.Parent = player:WaitForChild("PlayerGui")

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 220, 0, 190)
    mainFrame.Position = UDim2.new(0.5, -110, 0.1, 0)
    mainFrame.BackgroundColor3 = Config.BackgroundColor
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    -- BORDA ARCO-IRIS
    local mainBorder = Instance.new("UIStroke")
    mainBorder.Color = Config.PrimaryColor
    mainBorder.Thickness = 2
    mainBorder.Parent = mainFrame

    task.spawn(function()
        createSmoothRainbow(mainBorder)
    end)

    -- TITULO
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "NUCLEARBOBO 5.0"
    title.TextColor3 = Config.PrimaryColor
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.Parent = mainFrame

    local titleStroke = Instance.new("UIStroke")
    titleStroke.Thickness = 1
    titleStroke.Transparency = 0.5
    titleStroke.Parent = title

    task.spawn(function()
        createSmoothRainbow(titleStroke)
    end)

    -- DIVISORIA
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -40, 0, 1)
    divider.Position = UDim2.new(0, 20, 0, 60)
    divider.BackgroundColor3 = Config.PrimaryColor
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.Parent = mainFrame

    -- BOTAO
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(1, -40, 0, 50)
    toggleBtn.Position = UDim2.new(0, 20, 0, 75)
    toggleBtn.Text = "INACTIVE"
    toggleBtn.BackgroundColor3 = Config.PrimaryColor
    toggleBtn.TextColor3 = Config.TextColor
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.7
    btnStroke.Parent = toggleBtn

    task.spawn(function()
        createSmoothRainbow(btnStroke)
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        toggleInvisibility()
    end)

    -- STATUS
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -40, 0, 25)
    statusLabel.Position = UDim2.new(0, 20, 0, 135)
    statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    statusLabel.BackgroundTransparency = 0.3
    statusLabel.BorderSizePixel = 0
    statusLabel.Text = "SYSTEM INACTIVE"
    statusLabel.TextColor3 = Config.PrimaryColor
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.Parent = mainFrame

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 4)
    statusCorner.Parent = statusLabel

    -- INSTRUCOES
    local instructions = Instance.new("TextLabel")
    instructions.Size = UDim2.new(1, -20, 0, 20)
    instructions.Position = UDim2.new(0, 10, 1, -25)
    instructions.BackgroundTransparency = 1
    instructions.Text = "G: Toggle | M: Hide UI"
    instructions.TextColor3 = Color3.fromRGB(150, 150, 150)
    instructions.Font = Enum.Font.Gotham
    instructions.TextSize = 10
    instructions.Parent = mainFrame

    updateUI()
    _G.NuclearBobo5.Gui = gui
end

-- TELEPORT LOOP
local function startTeleportLoop()
    connections.Heartbeat =
        RunService.Heartbeat:Connect(function()

        if invisible
            and character
            and rootPart
            and humanoid
            and rootPart.Parent
            and humanoid.Health > 0 then

            local cf = rootPart.CFrame
            local camOffset = humanoid.CameraOffset

            local hidden = cf * CFrame.new(
                0,
                Config.TeleportHeight,
                0
            )

            rootPart.CFrame = hidden

            humanoid.CameraOffset =
                hidden:ToObjectSpace(
                    CFrame.new(cf.Position)
                ).Position

            RunService.RenderStepped:Wait()

            if rootPart and rootPart.Parent then
                rootPart.CFrame = cf
            end

            if humanoid and humanoid.Parent then
                humanoid.CameraOffset = camOffset
            end
        end
    end)
end

-- INICIALIZACAO
setupCharacter()
createMainUI()
startTeleportLoop()

-- TECLAS
connections.KeyToggle =
    UserInputService.InputBegan:Connect(
        function(input, gameProcessed)

        if gameProcessed then
            return
        end

        if input.KeyCode == Config.ToggleKey then
            toggleInvisibility()

        elseif input.KeyCode == Config.UIToggleKey then
            toggleUI()
        end
    end
)

-- RESPAWN
connections.CharacterAdded =
    player.CharacterAdded:Connect(function()

        invisible = false

        task.wait(1)

        setupCharacter()
        createMainUI()
    end)

-- LIMPEZA
connections.PlayerLeaving =
    player:GetPropertyChangedSignal("Parent"):Connect(
        function()

        if not player.Parent then
            for _, conn in pairs(connections) do
                pcall(function()
                    conn:Disconnect()
                end)
            end
        end
    end
)

_G.NuclearBobo5.Connections = connections

print("[NUCLEARBOBO 5.0] Loaded successfully.")
print("G = Toggle Invisibility")
print("M = Show/Hide UI")
