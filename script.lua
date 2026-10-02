-- RECEBA 2.3 | Hub minimalista 580x430 | Luau / Roblox
-- Revisao conservadora: atalhos opcionais, FLOAT sem conflito, FLING com limite seguro.
-- Demais sistemas preservados.
-- Inspirado nos comportamentos do Infinite Yield. Execucao local: o servidor pode rejeitar alteracoes.
local P=game:GetService('Players'); local R=game:GetService('RunService'); local U=game:GetService('UserInputService')
local L=game:GetService('Lighting'); local T=game:GetService('TeleportService'); local H=game:GetService('HttpService')
local RS=game:GetService('ReplicatedStorage'); local V=game:GetService('VirtualUser'); local G=game:GetService('GuiService')
local me=P.LocalPlayer; local pg=me:WaitForChild('PlayerGui')
if _G.NuclearBobo5 and type(_G.NuclearBobo5.Cleanup)=='function' then pcall(_G.NuclearBobo5.Cleanup) end
local old=pg:FindFirstChild('RECEBA_2_0'); if old then old:Destroy() end
local C={bg=Color3.fromRGB(12,12,15),panel=Color3.fromRGB(23,23,28),field=Color3.fromRGB(36,36,43),red=Color3.fromRGB(210,38,50),blue=Color3.fromRGB(38,121,225),white=Color3.fromRGB(240,240,242)}
local S={Active=true,Connections={},Flags={invisible=false,fly=false,float=false,noclip=false,infjump=false,speed=false,slowgravity=false,esp=false,bright=false,antiafk=false,grabtools=false,autorejoin=false,antilag=false},Favorites={},Waypoints={},Binds={},Events={},speed=50,flyspeed=50,dash=10,height=-80,keys={},selected=nil,flingSelected=nil,spectate=nil,OriginalGravity=workspace.Gravity,OriginalLighting={Brightness=L.Brightness,Ambient=L.Ambient,OutdoorAmbient=L.OutdoorAmbient,GlobalShadows=L.GlobalShadows,FogEnd=L.FogEnd},originalWalk=nil,originalCollisions={},originalTrans={},floatOffset=-3.1,flingBusy=false,objects={},Position=UDim2.new(.5,-290,.5,-215)}
_G.NuclearBobo5=S
local function con(sig,fn) local c=sig:Connect(fn); table.insert(S.Connections,c); return c end
local function new(k,props,parent) local o=Instance.new(k); for a,b in pairs(props or {}) do o[a]=b end; o.Parent=parent; return o end
local function round(o) new('UICorner',{CornerRadius=UDim.new(0,5)},o) end
local function text(parent,t,x,y,w,h) return new('TextLabel',{BackgroundTransparency=1,Text=t,TextColor3=C.white,Font=Enum.Font.Gotham,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h)},parent) end
local function btn(parent,t,x,y,w,h,fn) local b=new('TextButton',{BackgroundColor3=C.red,Text=t,TextColor3=C.white,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h)},parent); round(b); if fn then b.MouseButton1Click:Connect(fn) end; return b end
local function input(parent,t,x,y,w,h,fn) local b=new('TextBox',{BackgroundColor3=C.field,Text=t,TextColor3=C.white,Font=Enum.Font.Gotham,TextSize=12,ClearTextOnFocus=false,BorderSizePixel=0,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h)},parent); round(b); if fn then b.FocusLost:Connect(function(enter) if enter then fn(b.Text) end end) end; return b end
local gui=new('ScreenGui',{Name='RECEBA_2_0',ResetOnSpawn=false,IgnoreGuiInset=true},pg); S.Gui=gui
local main=new('Frame',{Size=UDim2.fromOffset(580,430),Position=S.Position,BackgroundColor3=C.bg,BorderSizePixel=0,Active=true,Draggable=true},gui); round(main); S.Main=main
text(main,'RECEBA 2.3',12,5,240,30).TextSize=17
local toastFrame=new('Frame',{Position=UDim2.new(1,-270,0,8),Size=UDim2.fromOffset(260,46),BackgroundColor3=C.panel,Visible=false},gui); round(toastFrame)
local toastText=text(toastFrame,'',8,3,244,40)
local toastSerial=0
local function toast(t) if not S.Active then return end; toastSerial+=1; local id=toastSerial; toastText.Text=tostring(t); toastFrame.Visible=true; task.delay(3,function() if S.Active and id==toastSerial then toastFrame.Visible=false end end) end
local function chr() local c=me.Character; return c,c and c:FindFirstChildOfClass('Humanoid'),c and c:FindFirstChild('HumanoidRootPart') end
local function target(id) for _,p in ipairs(P:GetPlayers()) do if p.UserId==id then return p end end end
local function root(p) return p and p.Character and p.Character:FindFirstChild('HumanoidRootPart') end
local function playerHum(p) return p and p.Character and p.Character:FindFirstChildOfClass('Humanoid') end
local function state(f,b) S.Flags[f]=b; if S.ToggleButtons and S.ToggleButtons[f] then local o=S.ToggleButtons[f]; o.BackgroundColor3=b and C.blue or C.red; o.Text=(S.ToggleNames[f] or f):upper()..(b and ': ON' or ': OFF') end end
S.ToggleButtons={};S.ToggleNames={}
local function toggle(parent,name,key,x,y,w,h,action) S.ToggleNames[key]=name; local b=btn(parent,name:upper()..': OFF',x,y,w,h,function() local on=not S.Flags[key]; if action then action(on) else state(key,on) end end); S.ToggleButtons[key]=b; return b end
local function restoreAppearance() for o,v in pairs(S.originalTrans) do if o.Parent then o.Transparency=v end end; S.originalTrans={} end
local function invis(on)
 state('invisible',on)
 if on then
  local c=chr()
  if c then for _,o in ipairs(c:GetDescendants()) do
   if o:IsA('BasePart') then S.originalTrans[o]=o.Transparency; o.Transparency=.7 end
  end end
 else restoreAppearance() end
end
-- Invisibilidade original RECEBA: deslocamento temporario e retorno no quadro visual.
-- O efeito depende de replicacao/fisica e nao garante invisibilidade no servidor.
local invisiblePending=false
con(R.Heartbeat,function()
 if not S.Active or not S.Flags.invisible or invisiblePending or S.Flags.fly then return end
 local c,h,r=chr()
 if not c or not h or not r or h.Health<=0 then return end
 local cf=r.CFrame; local off=h.CameraOffset
 invisiblePending=true
 local ok=pcall(function()
  local hidden=cf*CFrame.new(0,S.height,0)
  r.CFrame=hidden
  h.CameraOffset=hidden:ToObjectSpace(CFrame.new(cf.Position)).Position
 end)
 if not ok then invisiblePending=false; return end
 task.spawn(function()
  R.RenderStepped:Wait()
  if r.Parent and h.Parent then
   pcall(function() r.CFrame=cf;h.CameraOffset=off end)
  end
  invisiblePending=false
 end)
end)
local function dash() local _,h,r=chr(); if not r or not h or h.Health<=0 then return end; local v=r.CFrame.LookVector; local d=Vector3.new(v.X,0,v.Z); if d.Magnitude>0 then r.CFrame=r.CFrame+d.Unit*S.dash end end
local function fly(on)
 local c,h,r=chr(); if S.flyGyro then S.flyGyro:Destroy();S.flyGyro=nil end; if S.flyVelocity then S.flyVelocity:Destroy();S.flyVelocity=nil end
 if S.flyAnimate and S.flyAnimate.Parent then S.flyAnimate.Disabled=S.flyAnimateWasDisabled end; S.flyAnimate=nil
 if S.Flags.fly and h then h.PlatformStand=S.wasPlatformStand or false;h.AutoRotate=(S.wasAutoRotate~=false) end
 state('fly',false)
 if not on or not r or not h then return end
 if S.Flags.float then S.stopFloat() end
 S.flyVelocity=new('BodyVelocity',{Name='RecebaFlyVelocity',MaxForce=Vector3.new(9e9,9e9,9e9),Velocity=Vector3.zero},r)
 S.flyGyro=new('BodyGyro',{Name='RecebaFlyGyro',MaxTorque=Vector3.new(9e9,9e9,9e9),P=9e4,CFrame=r.CFrame},r)
 local animate=c:FindFirstChild('Animate'); S.flyAnimate=animate;S.flyAnimateWasDisabled=animate and animate.Disabled or false; if animate then animate.Disabled=true end
 for _,track in ipairs(h:GetPlayingAnimationTracks()) do track:Stop(0) end
 S.wasPlatformStand=h.PlatformStand;S.wasAutoRotate=h.AutoRotate;h.PlatformStand=true;h.AutoRotate=false;state('fly',true)
end
local function stopFloat() if S.floatPart then S.floatPart:Destroy();S.floatPart=nil end;state('float',false) end;S.stopFloat=stopFloat
local function floating(on)
    stopFloat()
    if not on then return end
    local c, h, r = chr()
    if not c or not h or not r then return end
    if S.Flags.fly then fly(false) end
    S.floatOffset = -3.1
    S.floatPart = new('Part', {
        Name = 'RecebaFloat',
        Transparency = 1,
        Anchored = true,
        CanCollide = true,
        CanTouch = false,
        Size = Vector3.new(2, 0.2, 1.5),
    }, c)
    state('float', true)
    toast('FLOAT: E sobe / Q desce')
end
local function noclip(on) state('noclip',on);if not on then for part,v in pairs(S.originalCollisions) do if part.Parent then part.CanCollide=v end end;S.originalCollisions={} end end
local function speed(on) local _,h=chr();if h then if S.originalWalk==nil then S.originalWalk=h.WalkSpeed end;h.WalkSpeed=on and S.speed or S.originalWalk end;state('speed',on) end
local function gravity(on) workspace.Gravity=on and 45 or S.OriginalGravity;state('slowgravity',on) end
local function bright(on) state('bright',on); if on then L.Brightness=math.max(2,S.OriginalLighting.Brightness);L.Ambient=Color3.fromRGB(110,110,110);L.OutdoorAmbient=Color3.fromRGB(125,125,125);L.GlobalShadows=false;L.FogEnd=100000 else for k,v in pairs(S.OriginalLighting) do L[k]=v end end end
-- ESP adaptativo: usa somente dados que o cliente realmente consegue ler.
-- A prioridade e Team; se nao existir, consulta atributos e valores replicados.
-- Sem cargo identificado, usa cinza. Nao adivinha cargos secretos.
local ROLE_KEYS = { 'Role', 'RoleName', 'CurrentRole', 'PlayerRole', 'RoundRole', 'Cargo', 'Job', 'Class', 'Faction', 'Group', 'Rank', 'Occupation', 'Profession' }
local ROLE_COLORS = {
    murderer = Color3.fromRGB(235, 65, 65),
    assassin = Color3.fromRGB(235, 65, 65),
    killer = Color3.fromRGB(235, 65, 65),
    assassino = Color3.fromRGB(235, 65, 65),
    sheriff = Color3.fromRGB(65, 150, 255),
    police = Color3.fromRGB(65, 150, 255),
    policeman = Color3.fromRGB(65, 150, 255),
    policial = Color3.fromRGB(65, 150, 255),
    cop = Color3.fromRGB(65, 150, 255),
    innocent = Color3.fromRGB(65, 220, 130),
    inocente = Color3.fromRGB(65, 220, 130),
    prisoner = Color3.fromRGB(255, 170, 60),
    prisioneiro = Color3.fromRGB(255, 170, 60),
    criminal = Color3.fromRGB(255, 100, 75),
    guard = Color3.fromRGB(65, 150, 255),
    guarda = Color3.fromRGB(65, 150, 255),
}
local UNKNOWN_COLOR = Color3.fromRGB(170, 170, 180)

local function roleText(value)
    if typeof(value) ~= 'string' then
        return nil
    end
    value = value:match('^%s*(.-)%s*$')
    if value == '' or #value > 50 then
        return nil
    end
    return value
end

local ROLE_CONTAINERS = {
    'leaderstats', 'Data', 'PlayerData', 'Stats', 'Status',
    'Information', 'Info', 'RoundData', 'GameData',
}

local function readRoleValue(holder)
    if not holder then return nil end

    -- Procura nomes usuais, sem tratar qualquer texto como cargo.
    for _, key in ipairs(ROLE_KEYS) do
        local attribute = roleText(holder:GetAttribute(key))
        if attribute then return attribute end

        local child = holder:FindFirstChild(key)
        if child and child:IsA('StringValue') then
            local value = roleText(child.Value)
            if value then return value end
        end
    end

    -- Alguns jogos usam nomes em minusculas ou variantes de capitalizacao.
    for name, value in pairs(holder:GetAttributes()) do
        for _, key in ipairs(ROLE_KEYS) do
            if name:lower() == key:lower() then
                local found = roleText(value)
                if found then return found end
            end
        end
    end

    for _, child in ipairs(holder:GetChildren()) do
        if child:IsA('StringValue') then
            for _, key in ipairs(ROLE_KEYS) do
                if child.Name:lower() == key:lower() then
                    local found = roleText(child.Value)
                    if found then return found end
                end
            end
        end
    end
    return nil
end

local function replicatedRole(player)
    local role = readRoleValue(player) or readRoleValue(player.Character)
    if role then return role end

    for _, containerName in ipairs(ROLE_CONTAINERS) do
        role = readRoleValue(player:FindFirstChild(containerName))
        if role then return role end
    end

    -- Limite de profundidade para evitar varrer o mapa inteiro.
    for _, child in ipairs(player:GetChildren()) do
        if child:IsA('Folder') or child:IsA('Configuration') then
            role = readRoleValue(child)
            if role then return role end
        end
    end
    return nil
end

local function getPlayerRole(player)
    -- Cargo especifico tem prioridade; equipes sao usadas como fallback.
    local role = replicatedRole(player)
    if not role and player.Team and player.Team.Name ~= '' then
        return player.Team.Name, player.TeamColor.Color, true
    end
    if not role then
        return 'Desconhecido', UNKNOWN_COLOR, false
    end

    local lower = role:lower()
    local color = ROLE_COLORS[lower]
    if not color then
        -- Cargos nao previstos ganham cores estaveis e distintas.
        -- Colisoes de cor ainda sao possiveis; nao e identificacao secreta.
        local hash = 0
        for index = 1, #lower do
            hash = (hash * 31 + lower:byte(index)) % 360
        end
        color = Color3.fromHSV(hash / 360, 0.76, 1)
    end
    return role, color, true
end

local function clearESP(player)
    local objects = S.espObjects and S.espObjects[player]
    if not objects then
        return
    end
    for _, object in ipairs(objects) do
        if object and object.Parent then
            object:Destroy()
        end
    end
    S.espObjects[player] = nil
end

S.espObjects = {}
S.espRoles = {}

local function updateESP(player)
    local objects = S.espObjects[player]
    if not objects then
        return
    end
    local role, color, known = getPlayerRole(player)
    local label = player.DisplayName
    if known then
        label = label .. ' [' .. role .. ']'
    end
    if not objects[1] or not objects[1].Parent or not objects[3] or not objects[3].Parent then
        return
    end
    objects[1].OutlineColor = color
    objects[3].Text = label
    objects[3].TextColor3 = color
end

local function addESP(player)
    clearESP(player)
    if not S.Flags.esp or player == me or not player.Character then
        return
    end
    local head = player.Character:FindFirstChild('Head')
    if not head then
        return
    end

    local outline = new('Highlight', {
        Adornee = player.Character,
        FillTransparency = 1,
        OutlineTransparency = 0,
        OutlineColor = UNKNOWN_COLOR,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
    }, gui)

    local billboard = new('BillboardGui', {
        Adornee = head,
        AlwaysOnTop = true,
        Size = UDim2.fromOffset(220, 28),
        StudsOffsetWorldSpace = Vector3.new(0, 3, 0),
    }, gui)

    local label = text(billboard, player.DisplayName, 0, 0, 220, 28)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextStrokeTransparency = 0
    S.espObjects[player] = { outline, billboard, label }
    updateESP(player)
end

local function esp(on)
    state('esp', on)
    for _, player in ipairs(P:GetPlayers()) do
        if on then
            addESP(player)
        else
            clearESP(player)
        end
    end
end
local function tools() local backpack=me:FindFirstChildOfClass('Backpack');if not backpack then return end;local count=0;for _,container in ipairs({L,RS}) do for _,o in ipairs(container:GetDescendants()) do if o:IsA('Tool') or o:IsA('HopperBin') then local ok=pcall(function() o:Clone().Parent=backpack end);if ok then count+=1 end end end end;toast('TOOLS: '..count..' copias locais') end
local function grabtools() local c,h,r=chr();if not h or not r then return end;for _,o in ipairs(workspace:GetChildren()) do if o:IsA('Tool') and o:FindFirstChild('Handle') then pcall(function() h:EquipTool(o) end) end end end
local function scan() S.ScanResults={};for _,container in ipairs({workspace,RS}) do for _,o in ipairs(container:GetDescendants()) do if o:IsA('BasePart') or o:IsA('Model') or o:IsA('Tool') or o:IsA('ClickDetector') or o:IsA('ProximityPrompt') then table.insert(S.ScanResults,o) end end end;return S.ScanResults end
local function tp(p) local r=root(p);local _,_,my=chr();if r and my then my.CFrame=r.CFrame*CFrame.new(3,0,0) end end
local function spectate(p) S.spectate=p and p.UserId or nil;local cam=workspace.CurrentCamera;local h=playerHum(p) or playerHum(me);if cam and h then cam.CameraType=Enum.CameraType.Custom;cam.CameraSubject=h end end
-- Fling experimental: tenta detectar afastamento com velocidade alta.
-- Limite de cinco segundos; observacao local nao confirma resultado no servidor.
local function fling(p)
    if S.flingBusy or not p or p == me then return end
    local targetRoot = root(p)
    local _, _, myRoot = chr()
    if not targetRoot or not myRoot then return end

    S.flingBusy = true
    local origin = myRoot.CFrame
    local originalVelocity = myRoot.AssemblyLinearVelocity
    local originalSpin = myRoot.AssemblyAngularVelocity
    local startPosition = targetRoot.Position
    local lastPosition = startPosition

    task.spawn(function()
        local observed = false
        local ok = pcall(function()
            local startTime = os.clock()
            local evidenceSince = nil
            while S.Active and myRoot.Parent and targetRoot.Parent
                and os.clock() - startTime < 5 do
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(.15, 0, .15)
                myRoot.AssemblyLinearVelocity = Vector3.new(50000, 50000, 50000)
                myRoot.AssemblyAngularVelocity = Vector3.new(0, 100000, 100000)

                -- Exige afastamento da posicao inicial e movimento rapido
                -- entre observacoes. Ainda e apenas uma estimativa local.
                local positionNow = targetRoot.Position
                local displacement = (positionNow - startPosition).Magnitude
                local speedNow = targetRoot.AssemblyLinearVelocity.Magnitude
                local moving = (positionNow - lastPosition).Magnitude > 1.5
                lastPosition = positionNow
                if displacement > 30 and speedNow > 40 and moving then
                    evidenceSince = evidenceSince or os.clock()
                    if os.clock() - evidenceSince > .2 then
                        observed = true
                        break
                    end
                else
                    evidenceSince = nil
                end
                R.Heartbeat:Wait()
            end
        end)

        if myRoot.Parent then
            myRoot.AssemblyAngularVelocity = originalSpin
            myRoot.AssemblyLinearVelocity = originalVelocity
            myRoot.CFrame = origin
            task.wait(.08)
            if myRoot.Parent then myRoot.CFrame = origin end
        end
        S.flingBusy = false
        if S.Active then
            if not ok then
                toast('Fling interrompido por erro')
            elseif observed then
                toast('Movimento do alvo detectado; nao garante fling no servidor')
            else
                toast('Fling finalizado por limite de tempo (5s)')
            end
        end
    end)
end
local function rejoin() local ok=false;if game.JobId~='' then ok=pcall(function() T:TeleportToPlaceInstance(game.PlaceId,game.JobId,me) end) end;if not ok then pcall(function() T:Teleport(game.PlaceId,me) end) end end
local function serverhop() toast('Procurando servidor...');task.spawn(function() local ok,res=pcall(function() return H:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/'..game.PlaceId..'/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true')) end);if not ok or not res or not res.data then toast('SERVER HOP indisponivel');return end;for _,s in ipairs(res.data) do if s.id~=game.JobId and s.playing<s.maxPlayers then T:TeleportToPlaceInstance(game.PlaceId,s.id,me);return end end;toast('Nenhum outro servidor encontrado') end) end
local function antilag(on) state('antilag',on);if on then S.graphicsBackup={};for _,o in ipairs(workspace:GetDescendants()) do if o:IsA('BasePart') then S.graphicsBackup[o]={o.Material,o.CastShadow,o.Reflectance};o.Material=Enum.Material.Plastic;o.CastShadow=false;o.Reflectance=0 elseif o:IsA('ParticleEmitter') or o:IsA('Trail') then S.graphicsBackup[o]={o.Enabled};o.Enabled=false end end else for o,vals in pairs(S.graphicsBackup or {}) do if o.Parent then if o:IsA('BasePart') then o.Material=vals[1];o.CastShadow=vals[2];o.Reflectance=vals[3] else o.Enabled=vals[1] end end end;S.graphicsBackup={} end end
local function savewp(name) local _,_,r=chr();if r and name~='' then S.Waypoints[name]=r.CFrame;toast('Local salvo: '..name) end end
local function gowp(name) local _,_,r=chr();if r and S.Waypoints[name] then r.CFrame=S.Waypoints[name];toast('Teleporte: '..name) else toast('Waypoint nao encontrado') end end
-- GUI: duas linhas de abas; corpo com rolagem para manter 580x430
local tabNames={'INVISIBLE','MOVEMENT','TELEPORT','FLING','VISUAL','TOOLS','SERVER','WAYPOINTS','CONFIG'}
local pages={};local tabs={};local current='INVISIBLE'
for i,name in ipairs(tabNames) do local x=10+((i-1)%5)*114;local y=43+math.floor((i-1)/5)*34;tabs[name]=btn(main,name,x,y,108,28,function() for n,p in pairs(pages) do p.Visible=n==name;tabs[n].BackgroundColor3=n==name and C.blue or C.red end;current=name end) end
for _,name in ipairs(tabNames) do local f=new('ScrollingFrame',{Position=UDim2.fromOffset(10,116),Size=UDim2.fromOffset(560,305),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,CanvasSize=UDim2.fromOffset(0,480),Visible=false},main);pages[name]=f end
local function row(page,title,fn,y) return btn(page,title,10,y,535,33,fn) end
local function numfield(page,title,value,y,fn) text(page,title,10,y,265,30);return input(page,tostring(value),285,y,260,30,function(t) local n=tonumber(t);if n and n==n and math.abs(n)<1e7 then fn(n) end end) end
-- INVISIBLE
local f=pages.INVISIBLE;toggle(f,'Invisible','invisible',10,10,535,36,invis);numfield(f,'Altura de deslocamento',S.height,58,function(n) S.height=math.clamp(n,-1000,1000) end);text(f,'Configure o atalho na aba CONFIG. Invisibilidade depende do servidor.',10,105,530,45)
-- MOVEMENT
f=pages.MOVEMENT;toggle(f,'Fly','fly',10,5,260,35,fly);toggle(f,'Float','float',285,5,260,35,floating)
toggle(f,'Noclip','noclip',10,48,260,35,noclip);toggle(f,'Infinite jump','infjump',285,48,260,35)
toggle(f,'Speed','speed',10,91,260,35,speed);toggle(f,'Gravidade lenta','slowgravity',285,91,260,35,gravity)
numfield(f,'Velocidade de caminhada',S.speed,140,function(n) S.speed=math.clamp(n,1,300);if S.Flags.speed then speed(true) end end)
numfield(f,'Velocidade do FLY',S.flyspeed,180,function(n) S.flyspeed=math.clamp(n,1,300) end)
text(f,'FLY: WASD na direcao da camera, Espaco sobe, Ctrl desce.',10,224,530,25)
text(f,'FLOAT: E sobe / Q desce enquanto estiver ativo.',10,251,530,25)
row(f,'DASH (atalho configuravel)',dash,287)
numfield(f,'Distancia do DASH (studs)',S.dash,329,function(n) S.dash=math.clamp(n,1,500) end)
-- PLAYER LISTS
local function makePlayers(page, field, allowFavorite)
    local list = new('ScrollingFrame', {
        Position = UDim2.fromOffset(10, 5),
        Size = UDim2.fromOffset(270, 275),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.fromOffset(0, 0),
    }, page)
    round(list)
    local selected = text(page, 'Nenhum jogador', 290, 5, 255, 38)

    local function refresh()
        local position = list.CanvasPosition
        for _, item in ipairs(list:GetChildren()) do
            if item:IsA('TextButton') then item:Destroy() end
        end
        local players = {}
        for _, player in ipairs(P:GetPlayers()) do
            if player ~= me then table.insert(players, player) end
        end
        table.sort(players, function(a, b)
            local fa, fb = S.Favorites[a.UserId], S.Favorites[b.UserId]
            if fa ~= fb then return fa == true end
            return a.Name:lower() < b.Name:lower()
        end)
        for index, player in ipairs(players) do
            local y = (index - 1) * 35 + 3
            local width = allowFavorite and 217 or 258
            local nameButton = btn(list,
                player.DisplayName .. ' (@' .. player.Name .. ')',
                4, y, width, 31, function()
                    S[field] = player.UserId
                    selected.Text = player.Name
                    refresh()
                end)
            nameButton.BackgroundColor3 = S[field] == player.UserId and C.blue or C.field
            nameButton.TextSize = 10
            if player.Team then nameButton.TextColor3 = player.TeamColor.Color end

            if allowFavorite then
                local star = btn(list, S.Favorites[player.UserId] and '★' or '☆',
                    224, y, 38, 31, function()
                        S.Favorites[player.UserId] = not S.Favorites[player.UserId]
                        refresh()
                    end)
                star.BackgroundColor3 = S.Favorites[player.UserId] and C.blue or C.field
                star.TextSize = 19
            end
        end
        list.CanvasSize = UDim2.fromOffset(0, #players * 35 + 5)
        list.CanvasPosition = position
    end
    return refresh, selected
end

f = pages.TELEPORT
local refreshTP = makePlayers(f, 'selected', true)
btn(f, 'TELEPORTAR', 290, 50, 255, 36, function()
    tp(target(S.selected))
end)
btn(f, 'ESPECTAR / PARAR', 290, 95, 255, 36, function()
    local player = target(S.selected)
    if S.spectate then
        spectate(nil)
    elseif player then
        spectate(player)
    else
        toast('Selecione um jogador')
    end
end)
text(f, '★ favorita e leva o jogador ao topo da lista.', 290, 148, 250, 48)
-- FLING
f=pages.FLING;local refreshFling=makePlayers(f,'flingSelected');btn(f,'FLING / RETORNAR',290,50,255,39,function() fling(target(S.flingSelected)) end);text(f,'Ate 5s. Para ao detectar deslocamento do alvo; sem garantia no servidor.',290,105,250,95)
-- VISUAL
f=pages.VISUAL;toggle(f,'ESP: cores por equipe/cargo','esp',10,10,535,38,esp)
toggle(f,'Full bright','bright',10,57,535,38,bright)
text(f,'Cargo replicado > equipe. Cinza = nao identificado.',10,108,530,40)
-- TOOLS
f=pages.TOOLS;row(f,'GET ALL TOOLS (copia ferramentas replicadas)',tools,5);toggle(f,'GRAB TOOLS (pegar ferramentas caidas)','grabtools',10,45,535,34)
local scanFilter=input(f,'Filtrar nome ou caminho...',10,88,340,31)
local scanView=new('ScrollingFrame',{Position=UDim2.fromOffset(10,125),Size=UDim2.fromOffset(535,170),BackgroundColor3=C.panel,BorderSizePixel=0,ScrollBarThickness=4,CanvasSize=UDim2.fromOffset(0,0)},f);round(scanView)
btn(f,'FULL MAP SCAN',358,88,187,31,function()
 local all=scan();local arr={};local filter=scanFilter.Text:lower();for _,obj in ipairs(all) do if filter=='' or obj.Name:lower():find(filter,1,true) or obj:GetFullName():lower():find(filter,1,true) then arr[#arr+1]=obj end end;for _,o in ipairs(scanView:GetChildren()) do if o:IsA('TextButton') then o:Destroy() end end
 for i=1,math.min(200,#arr) do local obj=arr[i];local b=btn(scanView,obj.ClassName..': '..obj.Name,4,(i-1)*27,520,25,function() local path=obj:GetFullName();if setclipboard then pcall(setclipboard,path) end;toast('PATH: '..path);if S.scanHighlight then S.scanHighlight:Destroy() end;if obj:IsA('BasePart') or obj:IsA('Model') then S.scanHighlight=new('Highlight',{Adornee=obj,FillTransparency=.8,OutlineColor=C.blue,FillColor=C.blue},gui) end end);b.BackgroundColor3=C.field;b.TextSize=10 end
 scanView.CanvasSize=UDim2.fromOffset(0,math.min(200,#arr)*27);toast('MAP SCAN: '..#arr..' resultados / '..#all..' objetos. Clique para copiar caminho')
end)
-- SERVER
f=pages.SERVER;row(f,'REJOIN (mesmo servidor)',rejoin,5);row(f,'SERVER HOP (outro servidor)',serverhop,45)
toggle(f,'ANTI-AFK','antiafk',10,88,535,34);toggle(f,'AUTO REJOIN','autorejoin',10,128,535,34);toggle(f,'ANTI-LAG','antilag',10,168,535,34,antilag)
text(f,'Auto Rejoin depende de permissoes do cliente. Nao reexecuta o hub.',10,213,530,65)
-- WAYPOINTS
f=pages.WAYPOINTS;local wpName=input(f,'nome do local',10,8,535,35)
btn(f,'SALVAR POSICAO',10,52,260,36,function() savewp(wpName.Text);if S.refreshWP then S.refreshWP() end end)
btn(f,'IR PARA LOCAL',285,52,260,36,function() gowp(wpName.Text) end)
local wpList=new('ScrollingFrame',{Position=UDim2.fromOffset(10,98),Size=UDim2.fromOffset(535,190),BackgroundColor3=C.panel,ScrollBarThickness=4,CanvasSize=UDim2.fromOffset(0,0)},f)
local function refreshWP() for _,o in ipairs(wpList:GetChildren()) do if o:IsA('TextButton') then o:Destroy() end end;local i=0;for name in pairs(S.Waypoints) do i+=1;local nm=name;local b=btn(wpList,nm,4,(i-1)*31,520,28,function() wpName.Text=nm;gowp(nm) end);b.BackgroundColor3=C.field end;wpList.CanvasSize=UDim2.fromOffset(0,i*31) end
S.refreshWP=refreshWP;con(wpName.FocusLost,refreshWP)
-- CONFIG: somente teclas de atalho. Os recursos continuam nas suas abas.
f = pages.CONFIG
text(f, 'ATALHOS PERSONALIZADOS', 10, 4, 530, 25).TextSize = 15
text(f, 'Sem tecla por padrao. Clique na tecla e pressione outra. ESC cancela.', 10, 29, 530, 28)

local shortcutActions = {
    { id = 'invisible', label = 'Invisibilidade', default = nil,
      action = function() if not S.Flags.float then invis(not S.Flags.invisible) end end },
    { id = 'dash', label = 'Dash', default = nil,
      action = function() if not S.Flags.float then dash() end end },
    { id = 'fly', label = 'Fly', default = nil,
      action = function() fly(not S.Flags.fly) end },
    { id = 'float', label = 'Float', default = nil,
      action = function() floating(not S.Flags.float) end },
    { id = 'noclip', label = 'Noclip', default = nil,
      action = function() noclip(not S.Flags.noclip) end },
    { id = 'infjump', label = 'Infinite Jump', default = nil,
      action = function() state('infjump', not S.Flags.infjump) end },
    { id = 'speed', label = 'Speed', default = nil,
      action = function() speed(not S.Flags.speed) end },
    { id = 'slowgravity', label = 'Gravidade lenta', default = nil,
      action = function() gravity(not S.Flags.slowgravity) end },
    { id = 'esp', label = 'ESP', default = nil,
      action = function() esp(not S.Flags.esp) end },
    { id = 'bright', label = 'Full Bright', default = nil,
      action = function() bright(not S.Flags.bright) end },
}

local awaitingShortcut = nil
local shortcutButtons = {}
local shortcutByKey = {}
for _, entry in ipairs(shortcutActions) do
    S.keys[entry.id] = entry.default
end
local function refreshShortcuts()
    table.clear(shortcutByKey)
    for _, entry in ipairs(shortcutActions) do
        local key = S.keys[entry.id]
        if key then shortcutByKey[key] = entry.action end
        local button = shortcutButtons[entry.id]
        if button then
            button.Text = awaitingShortcut == entry.id and 'PRESSIONE...' or
                (key and key.Name or 'SEM TECLA')
        end
    end
end
for index, entry in ipairs(shortcutActions) do
    local y = 65 + (index - 1) * 37
    text(f, entry.label, 10, y, 290, 30)
    shortcutButtons[entry.id] = btn(f, '', 305, y, 240, 30, function()
        awaitingShortcut = entry.id
        refreshShortcuts()
    end)
end
text(f, 'M = menu. Delete limpa atalho. E/Q controlam FLOAT ativo.',
    10, 444, 535, 30)
refreshShortcuts()

-- EVENTOS E LOOPS
local captureKeys = {}
con(U.InputBegan, function(inputObject, processed)
    if inputObject.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local key = inputObject.KeyCode

    if awaitingShortcut then
        if key == Enum.KeyCode.Escape then
            awaitingShortcut = nil
            refreshShortcuts()
            return
        end
        if key == Enum.KeyCode.Delete or key == Enum.KeyCode.Backspace then
            S.keys[awaitingShortcut] = nil
            awaitingShortcut = nil
            refreshShortcuts()
            return
        end
        if key == Enum.KeyCode.M then
            toast('M e reservado para o menu')
            awaitingShortcut = nil
            refreshShortcuts()
            return
        end
        for id, existing in pairs(S.keys) do
            if existing == key then S.keys[id] = nil end
        end
        S.keys[awaitingShortcut] = key
        awaitingShortcut = nil
        refreshShortcuts()
        return
    end

    if processed or U:GetFocusedTextBox() then return end
    captureKeys[key] = true
    if key == Enum.KeyCode.M then
        main.Visible = not main.Visible
        return
    end
    -- E e Q sao controles exclusivos do FLOAT enquanto ele estiver ativo.
    if S.Flags.float and (key == Enum.KeyCode.E or key == Enum.KeyCode.Q) then
        return
    end
    local action = shortcutByKey[key]
    if action then action() end
end)
con(U.InputEnded, function(inputObject)
    captureKeys[inputObject.KeyCode] = nil
end)
con(U.JumpRequest,function() if S.Flags.infjump then local _,h=chr();if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
con(R.Stepped,function()
 local c,h,r=chr()
 if S.Flags.noclip and c then for _,o in ipairs(c:GetDescendants()) do if o:IsA('BasePart') then if S.originalCollisions[o]==nil then S.originalCollisions[o]=o.CanCollide end;o.CanCollide=false end end end
 if S.Flags.float and S.floatPart and r then S.floatPart.CFrame=r.CFrame*CFrame.new(0,S.floatOffset,0) end
end)
con(R.RenderStepped,function(dt)
 local c,h,r=chr();local camera=workspace.CurrentCamera
 if S.Flags.fly and S.flyVelocity and S.flyGyro and camera and h and r then
  local cf=camera.CFrame;local move=Vector3.zero
  if U:IsKeyDown(Enum.KeyCode.W) then move+=cf.LookVector end
  if U:IsKeyDown(Enum.KeyCode.S) then move-=cf.LookVector end
  if U:IsKeyDown(Enum.KeyCode.D) then move+=cf.RightVector end
  if U:IsKeyDown(Enum.KeyCode.A) then move-=cf.RightVector end
  if U:IsKeyDown(Enum.KeyCode.Space) then move+=Vector3.yAxis end
  if U:IsKeyDown(Enum.KeyCode.LeftControl) then move-=Vector3.yAxis end
  if move.Magnitude>1 then move=move.Unit end
  S.flyVelocity.Velocity=move*S.flyspeed;S.flyGyro.CFrame=cf
  h.PlatformStand=true
  for _,track in ipairs(h:GetPlayingAnimationTracks()) do track:Stop(0) end
 end
 if S.spectate and camera then local h2=playerHum(target(S.spectate));if h2 then camera.CameraSubject=h2 else spectate(nil) end end
end)
-- FLOAT original: E sobe, Q desce enquanto pressionadas.
-- Nao sao atalhos para ligar/desligar o FLOAT.
con(U.InputBegan, function(inputObject, processed)
    if processed or not S.Flags.float then return end
    if inputObject.KeyCode == Enum.KeyCode.E then
        S.floatOffset += 1.5
    elseif inputObject.KeyCode == Enum.KeyCode.Q then
        S.floatOffset -= 0.5
    end
end)
con(U.InputEnded, function(inputObject)
    if not S.Flags.float then return end
    if inputObject.KeyCode == Enum.KeyCode.E then
        S.floatOffset -= 1.5
    elseif inputObject.KeyCode == Enum.KeyCode.Q then
        S.floatOffset += 0.5
    end
end)
con(me.Idled,function() if S.Flags.antiafk then pcall(function() V:CaptureController();V:ClickButton2(Vector2.new(0,0)) end) end end)
con(G.ErrorMessageChanged,function(msg) if S.Flags.autorejoin and msg and msg~='' then task.delay(2,function() if S.Active and S.Flags.autorejoin then rejoin() end end) end end)
con(me.CharacterAdded,function(c) if not S.Active then return end;S.originalWalk=nil;S.originalTrans={};S.originalCollisions={};state('invisible',false);if S.Flags.fly then fly(false) end;if S.Flags.float then stopFloat() end;task.wait(.6);local h=playerHum(me);if h and S.Flags.speed then S.originalWalk=h.WalkSpeed;h.WalkSpeed=S.speed end end)
con(P.PlayerAdded,function(p) con(p.CharacterAdded,function() task.wait(.5);if S.Flags.esp then addESP(p) end end) end)
for _,p in ipairs(P:GetPlayers()) do if p~=me then con(p.CharacterAdded,function() task.wait(.5);if S.Flags.esp then addESP(p) end end) end end
con(P.PlayerRemoving,function(p) clearESP(p);if S.spectate==p.UserId then spectate(nil) end end)
local timer=0
con(R.Heartbeat,function(dt)
 timer+=dt;if timer<2 then return end;timer=0
 if S.Flags.grabtools then grabtools() end
 if S.Flags.speed then local _,h=chr();if h then h.WalkSpeed=S.speed end end
 if S.Flags.bright then bright(true) end
 if S.Flags.esp then
  for _, player in ipairs(P:GetPlayers()) do
   if player ~= me and player.Character then
    local objects = S.espObjects[player]
    if not objects or not objects[1].Parent or objects[1].Adornee ~= player.Character then
     addESP(player)
    else
     updateESP(player)
    end
   end
  end
 end
 if current=='TELEPORT' then refreshTP() elseif current=='FLING' then refreshFling() elseif current=='WAYPOINTS' then refreshWP() end
end)
-- CLEANUP
S.Cleanup=function()
 if not S.Active then return end;S.Active=false
 -- Desativa controles antes de restaurar o personagem.
 S.Flags.float = false
 invis(false);fly(false);stopFloat();noclip(false);speed(false);gravity(false);bright(false);esp(false);spectate(nil);if S.Flags.antilag then antilag(false) end
 if S.scanHighlight then S.scanHighlight:Destroy() end
 for _,c in ipairs(S.Connections) do pcall(function() c:Disconnect() end) end
 if gui.Parent then gui:Destroy() end
end
for name,page in pairs(pages) do page.Visible=name=='INVISIBLE' end;tabs.INVISIBLE.BackgroundColor3=C.blue
refreshTP();refreshFling();toast('RECEBA 2.3 carregado! M = menu')
