local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local StarterGui=game:GetService("StarterGui")
local Lighting=game:GetService("Lighting")

local LP=Players.LocalPlayer
local PG=LP:WaitForChild("PlayerGui")
local CAM=workspace.CurrentCamera
local UD=UDim2

if not _G.VoidConfig then _G.VoidConfig={LoadScreenEnabled=true} end

local C={Void=Color3.fromRGB(6,2,16),Bg=Color3.fromRGB(14,5,28),Panel=Color3.fromRGB(24,12,45),Panel2=Color3.fromRGB(38,20,65),Line=Color3.fromRGB(70,40,110),Cyan=Color3.fromRGB(180,100,255),Purple=Color3.fromRGB(110,50,200),Green=Color3.fromRGB(160,220,255),Red=Color3.fromRGB(255,70,120),Text=Color3.fromRGB(230,215,255),Dim=Color3.fromRGB(140,110,180),BarBg=Color3.fromRGB(30,18,50)}

local BASE_JUMP=50
local baseSpeed,lastSetSpeed=16,16
local speedToggleDesc
local spectateTarget,followTarget
local spectateSetOn,followSetOn

local State={NoclipEnabled=false,InfiniteJumpEnabled=false,SpeedEnabled=false,JumpEnabled=false,ESPHighlightEnabled=false,ESPNameEnabled=false,ESPHealthEnabled=false,InstantInteractEnabled=false,PromptESPEnabled=false,RemoveFogEnabled=false,NightVisionEnabled=false,HitboxEnabled=false,SpeedMultiplier=1,CustomJump=50,HitboxSize=10,HitboxTransparency=0.7,HitboxColor=Color3.fromRGB(255,215,0),LoadScreenEnabled=_G.VoidConfig.LoadScreenEnabled}

local ESPObjects={}
local PromptESPObjects={}
local infJumpConn,instantConn,promptConn,hitboxConn,noclipConn
local HitboxOrig=setmetatable({},{__mode="k"})
local SCRIPT_START=tick()

local function new(c,p) local i=Instance.new(c);local pt;for k,v in pairs(p or {}) do if k=="Parent" then pt=v else i[k]=v end end;if pt then i.Parent=pt end;return i end
local function corner(p,r) return new("UICorner",{CornerRadius=UDim.new(0,r),Parent=p}) end
local function stroke(p,c,t,tr) return new("UIStroke",{Color=c,Thickness=t or 1,Transparency=tr or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=p}) end
local function grad(p,a,b,r) return new("UIGradient",{Color=ColorSequence.new(a,b),Rotation=r or 0,Parent=p}) end
local function tw(i,d,p,s,dr) local t=TweenService:Create(i,TweenInfo.new(d,s or Enum.EasingStyle.Quad,dr or Enum.EasingDirection.Out),p);t:Play();return t end
local function hex(n) local s="" for _=1,n do s=s..string.format("%X",math.random(0,15)) end return s end
local function techCorners(parent,color,len,thick,trans) for _,s in ipairs({{0,0,len,thick},{0,0,thick,len},{1,0,len,thick},{1,0,thick,len},{0,1,len,thick},{0,1,thick,len},{1,1,len,thick},{1,1,thick,len}}) do new("Frame",{AnchorPoint=Vector2.new(s[1],s[2]),Position=UD.new(s[1],0,s[2],0),Size=UD.fromOffset(s[3],s[4]),BackgroundColor3=color,BackgroundTransparency=trans or 0,BorderSizePixel=0,Parent=parent}) end end
local function diamond(parent,x,y,sz,color,trans) local d=new("Frame",{Position=UD.fromOffset(x,y),Size=UD.fromOffset(sz,sz),BackgroundColor3=color,BackgroundTransparency=trans or 0,BorderSizePixel=0,Rotation=45,Parent=parent});corner(d,2);return d end
local function ring(parent,sz,color,thick,trans) local f=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(sz,sz),BackgroundTransparency=1,Parent=parent});corner(f,sz/2);stroke(f,color,thick,trans);return f end
local function fitScale(g,bw,pd,mn) local s=g:FindFirstChildOfClass("UIScale") or new("UIScale",{Scale=1,Parent=g});local function u() s.Scale=math.clamp((CAM.ViewportSize.X-(pd or 40))/bw,mn or .6,1) end;u();CAM:GetPropertyChangedSignal("ViewportSize"):Connect(u);return s end
local function makeAlpha(root)
    local d={}
    local function col(x) local pr
        if x:IsA("TextLabel") or x:IsA("TextButton") or x:IsA("TextBox") then pr="TextTransparency"
        elseif x:IsA("ImageLabel") or x:IsA("ImageButton") then pr="ImageTransparency"
        elseif x:IsA("Frame") then pr="BackgroundTransparency"
        elseif x:IsA("UIStroke") then pr="Transparency" end
        if pr then d[#d+1]={i=x,p=pr,b=x[pr]} end
    end
    col(root);for _,x in ipairs(root:GetDescendants()) do col(x) end
    local a={}
    function a.set(t) for _,r in ipairs(d) do r.i[r.p]=r.b+(1-r.b)*t end end
    function a.tweenTo(t,du) for _,r in ipairs(d) do tw(r.i,du,{[r.p]=r.b+(1-r.b)*t}) end end
    return a
end
local function makeDraggable(t,h,onClick)
    h=h or t
    local dg,ds,sp,mv=false,nil,nil,false
    h.InputBegan:Connect(function(input,gp) if gp then return end if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dg,mv=true,false;ds=input.Position;sp=t.Position end end)
    UserInputService.InputChanged:Connect(function(input) if not dg then return end if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then local d=input.Position-ds;if d.Magnitude>4 then mv=true end;local vp=CAM.ViewportSize;t.Position=UD.new(0,math.clamp(sp.X.Offset+d.X,-t.AbsoluteSize.X+60,vp.X-60),0,math.clamp(sp.Y.Offset+d.Y,0,vp.Y-30)) end end)
    UserInputService.InputEnded:Connect(function(input) if not dg then return end if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dg=false;if not mv and onClick then task.defer(onClick) end end end)
end

local function notify(t,x) pcall(function() StarterGui:SetCore("SendNotification",{Title=t,Text=x,Duration=4}) end) end
local function getChar() local c=LP.Character;if not c then return nil,nil end;return c,c:FindFirstChildOfClass("Humanoid") end
local function updateBaseSpeedLbl() if speedToggleDesc and speedToggleDesc.Parent then speedToggleDesc.Text="原始移速: "..math.floor(baseSpeed+0.5) end end

local function setNoclip(enabled)
    State.NoclipEnabled=enabled
    if noclipConn then noclipConn:Disconnect();noclipConn=nil end
    local char=LP.Character
    if not char then return end
    if not enabled then
        for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.CanCollide=true end end
        return
    end
    for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    noclipConn=RunService.Heartbeat:Connect(function()
        if not State.NoclipEnabled then return end
        local c=LP.Character;if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end end
    end)
end

local function setInfiniteJump(enabled)
    State.InfiniteJumpEnabled=enabled
    if infJumpConn then infJumpConn:Disconnect();infJumpConn=nil end
    if enabled then infJumpConn=UserInputService.JumpRequest:Connect(function() local _,h=getChar();if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end
end

local function applyJump()
    local _,h=getChar();if not h then return end
    h.UseJumpPower=true
    h.JumpPower=State.JumpEnabled and State.CustomJump or BASE_JUMP
end

local function setJump(v) State.CustomJump=v;applyJump() end
local function setJumpEnabled(v) State.JumpEnabled=v;applyJump() end

local function stopSpectate()
    spectateTarget=nil
    local _,h=getChar()
    if h then CAM.CameraSubject=h end
    if spectateSetOn then spectateSetOn(false) end
end

local function stopFollow()
    followTarget=nil
    if followSetOn then followSetOn(false) end
end

RunService.Heartbeat:Connect(function(dt)
    local char,h=getChar()
    if not h then return end

    if not State.SpeedEnabled then
        local cur=h.WalkSpeed
        if math.abs(cur-lastSetSpeed)>0.01 then baseSpeed=cur;lastSetSpeed=cur;updateBaseSpeedLbl() end
    else
        local cur=h.WalkSpeed
        if math.abs(cur-lastSetSpeed)>0.01 then baseSpeed=cur;updateBaseSpeedLbl() end
        h.WalkSpeed=baseSpeed
        lastSetSpeed=baseSpeed
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local extra=baseSpeed*State.SpeedMultiplier-baseSpeed
            if extra>0 then
                local dir=h.MoveDirection
                if dir.Magnitude>0.01 then
                    local delta=dir.Unit*extra*dt
                    hrp.CFrame=hrp.CFrame+delta
                    if CAM then CAM.CFrame=CAM.CFrame+delta end
                end
            end
        end
    end

    if spectateTarget then
        if not spectateTarget.Parent then stopSpectate()
        else
            local tc=spectateTarget.Character
            if tc then
                local th=tc:FindFirstChildOfClass("Humanoid")
                if th and th.Health>0 and CAM.CameraSubject~=th then CAM.CameraSubject=th end
            end
        end
    end

    if followTarget then
        if not followTarget.Parent then stopFollow()
        else
            local tc=followTarget.Character
            if tc then
                local thrp=tc:FindFirstChild("HumanoidRootPart")
                if thrp then
                    local mhrp=char:FindFirstChild("HumanoidRootPart")
                    if mhrp then mhrp.CFrame=CFrame.new(thrp.Position) end
                end
            end
        end
    end
end)

local function saveHitboxOrig(char)
    if HitboxOrig[char] then return end
    local head=char:FindFirstChild("Head")
    local root=char:FindFirstChild("HumanoidRootPart")
    HitboxOrig[char]={
        head=head and {Size=head.Size,Transparency=head.Transparency,CanCollide=head.CanCollide,Material=head.Material,Color=head.Color},
        root=root and {Size=root.Size,Transparency=root.Transparency,CanCollide=root.CanCollide,Material=root.Material,Color=root.Color},
    }
end

local function applyHitbox(char)
    if not char then return end
    local h=char:FindFirstChildOfClass("Humanoid")
    if not h or h.Health<=0 then return end
    saveHitboxOrig(char)
    local sz=Vector3.new(State.HitboxSize,State.HitboxSize,State.HitboxSize)
    for _,name in ipairs({"HumanoidRootPart","Head"}) do
        local part=char:FindFirstChild(name)
        if part then
            part.Size=sz;part.Transparency=State.HitboxTransparency
            part.Color=State.HitboxColor;part.Material=Enum.Material.Neon;part.CanCollide=false
        end
    end
end

local function resetHitbox(char)
    local d=HitboxOrig[char];if not d then return end
    local head=char:FindFirstChild("Head")
    local root=char:FindFirstChild("HumanoidRootPart")
    if head and d.head then head.Size=d.head.Size;head.Transparency=d.head.Transparency;head.CanCollide=d.head.CanCollide;head.Material=d.head.Material;head.Color=d.head.Color end
    if root and d.root then root.Size=d.root.Size;root.Transparency=d.root.Transparency;root.CanCollide=d.root.CanCollide;root.Material=d.root.Material;root.Color=d.root.Color end
    HitboxOrig[char]=nil
end

local function refreshHitbox()
    if not State.HitboxEnabled then return end
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then applyHitbox(p.Character) end end
end

local function setHitboxEnabled(enabled)
    State.HitboxEnabled=enabled
    if hitboxConn then hitboxConn:Disconnect();hitboxConn=nil end
    if not enabled then
        for char,_ in pairs(HitboxOrig) do resetHitbox(char) end
        return
    end
    refreshHitbox()
    hitboxConn=RunService.RenderStepped:Connect(function()
        if not State.HitboxEnabled then return end
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then applyHitbox(p.Character) end end
    end)
end

local function setHitboxSize(v) State.HitboxSize=v;refreshHitbox() end
local function setHitboxTransparency(v) State.HitboxTransparency=v;refreshHitbox() end
local function setHitboxColor(c) State.HitboxColor=c;refreshHitbox() end

local function setInstantInteract(enabled)
    State.InstantInteractEnabled=enabled
    if instantConn then instantConn:Disconnect();instantConn=nil end
    if enabled then
        local function patch(p) if p:IsA("ProximityPrompt") then p.HoldDuration=0 end end
        for _,o in ipairs(workspace:GetDescendants()) do patch(o) end
        instantConn=workspace.DescendantAdded:Connect(function(o) if State.InstantInteractEnabled then patch(o) end end)
    end
end

local function runExternal(url,name) local ok,err=pcall(function() loadstring(game:HttpGet(url))() end);if not ok then notify(name,"脚本加载失败: "..tostring(err)) end end
local function flyingScript() runExternal("https://pastebin.com/raw/ZBzcTm1f","飞行") end

local function clearPlayerESP(player)
    local d=ESPObjects[player];if not d then return end
    if d.highlight then d.highlight:Destroy() end
    if d.billboard then d.billboard:Destroy() end
    ESPObjects[player]=nil
end

local function createPlayerESP(player)
    if player==LP then return end
    clearPlayerESP(player)
    if not (State.ESPHighlightEnabled or State.ESPNameEnabled or State.ESPHealthEnabled) then return end
    local char=player.Character;if not char then return end
    local d={}
    if State.ESPHighlightEnabled then
        local hl=Instance.new("Highlight")
        hl.Adornee=char;hl.FillColor=Color3.fromRGB(200,100,255);hl.FillTransparency=0.4
        hl.OutlineColor=Color3.fromRGB(255,255,255);hl.OutlineTransparency=0
        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;hl.Parent=char
        d.highlight=hl
    end
    if State.ESPNameEnabled or State.ESPHealthEnabled then
        local head=char:FindFirstChild("Head")
        if head then
            local bg=Instance.new("BillboardGui")
            bg.Adornee=head;bg.Size=UDim2.new(0,110,0,30);bg.StudsOffset=Vector3.new(0,2.2,0)
            bg.AlwaysOnTop=true;bg.Parent=head
            if State.ESPNameEnabled then
                local nl=Instance.new("TextLabel")
                nl.Size=UDim2.new(1,0,0,12);nl.BackgroundTransparency=1
                nl.TextColor3=Color3.fromRGB(255,255,255);nl.TextStrokeTransparency=0;nl.TextStrokeColor3=Color3.fromRGB(0,0,0)
                nl.Font=Enum.Font.SourceSansBold;nl.TextSize=12;nl.Text=player.Name;nl.Parent=bg
            end
            if State.ESPHealthEnabled then
                local barBg=Instance.new("Frame")
                barBg.Size=UDim2.new(1,0,0,5);barBg.Position=UDim2.new(0,0,0,State.ESPNameEnabled and 14 or 10)
                barBg.BackgroundColor3=C.BarBg;barBg.BorderSizePixel=0;barBg.Parent=bg
                corner(barBg,2);stroke(barBg,Color3.fromRGB(0,0,0),1,0.3)
                local fill=Instance.new("Frame")
                fill.Size=UDim2.new(1,0,1,0);fill.BackgroundColor3=C.Green;fill.BorderSizePixel=0;fill.Parent=barBg
                corner(fill,2)
                d.barFill=fill
            end
            d.billboard=bg
        end
    end
    ESPObjects[player]=d
end

local function updateESPLabels()
    for player,d in pairs(ESPObjects) do
        if d.barFill and d.barFill.Parent then
            local char=player.Character
            if char then
                local h=char:FindFirstChildOfClass("Humanoid")
                if h and h.MaxHealth>0 then
                    local pct=math.clamp(h.Health/h.MaxHealth,0,1)
                    d.barFill.Size=UDim2.new(pct,0,1,0)
                    d.barFill.BackgroundColor3 = pct>0.6 and C.Green or (pct>0.3 and Color3.fromRGB(200,150,255) or C.Red)
                end
            end
        end
    end
end

local function refreshAllESP() for _,p in ipairs(Players:GetPlayers()) do if p~=LP then createPlayerESP(p) end end end
local function clearAllESP() for player,_ in pairs(ESPObjects) do clearPlayerESP(player) end end

local function createPromptESP(prompt)
    if PromptESPObjects[prompt] then return end
    local parent=prompt.Parent
    if not parent or not parent:IsA("BasePart") then return end
    local bg=Instance.new("BillboardGui")
    bg.Adornee=parent;bg.Size=UDim2.new(0,200,0,40);bg.StudsOffset=Vector3.new(0,2.5,0)
    bg.AlwaysOnTop=true;bg.Parent=parent
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,1,0);lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(180,220,255);lbl.TextStrokeTransparency=0;lbl.TextStrokeColor3=Color3.fromRGB(0,0,0)
    lbl.Font=Enum.Font.SourceSansBold;lbl.TextSize=14;lbl.Parent=bg
    PromptESPObjects[prompt]={gui=bg,label=lbl}
    task.spawn(function()
        local raw=prompt.ObjectText
        if raw=="" or raw==nil then raw=prompt.ActionText end
        if raw=="" or raw==nil then raw=prompt.Name end
        if lbl.Parent then lbl.Text="🔧 "..(raw or "Interact") end
    end)
end

local function clearPromptESP(p) local d=PromptESPObjects[p];if d and d.gui then d.gui:Destroy() end;PromptESPObjects[p]=nil end

local function refreshPromptESP()
    for prompt,_ in pairs(PromptESPObjects) do if not prompt.Parent then clearPromptESP(prompt) end end
    for _,o in ipairs(workspace:GetDescendants()) do if o:IsA("ProximityPrompt") then createPromptESP(o) end end
end

local function updatePromptESPLabels()
    for prompt,d in pairs(PromptESPObjects) do
        if d.label and d.label.Parent then
            local raw=prompt.ObjectText
            if raw=="" or raw==nil then raw=prompt.ActionText end
            if raw=="" or raw==nil then raw=prompt.Name end
            local nt="🔧 "..(raw or "Interact")
            if d.label.Text~=nt then d.label.Text=nt end
        end
    end
end

local function setPromptESP(enabled)
    State.PromptESPEnabled=enabled
    if promptConn then promptConn:Disconnect();promptConn=nil end
    if enabled then
        refreshPromptESP()
        promptConn=workspace.DescendantAdded:Connect(function(o) if State.PromptESPEnabled and o:IsA("ProximityPrompt") then createPromptESP(o) end end)
    else
        for prompt,_ in pairs(PromptESPObjects) do clearPromptESP(prompt) end
    end
end

local fogOrig,atmoOrig=nil,nil
local function setRemoveFog(enabled)
    State.RemoveFogEnabled=enabled
    local atmo=Lighting:FindFirstChildOfClass("Atmosphere")
    if enabled then
        if fogOrig==nil then fogOrig={Lighting.FogStart,Lighting.FogEnd,Lighting.FogColor} end
        Lighting.FogStart=0;Lighting.FogEnd=1000000;Lighting.FogColor=Color3.fromRGB(255,255,255)
        if atmo then if atmoOrig==nil then atmoOrig={atmo.Density,atmo.Offset} end;atmo.Density=0;atmo.Offset=0 end
    else
        if fogOrig then Lighting.FogStart=fogOrig[1];Lighting.FogEnd=fogOrig[2];Lighting.FogColor=fogOrig[3];fogOrig=nil end
        if atmoOrig and atmo then atmo.Density=atmoOrig[1];atmo.Offset=atmoOrig[2];atmoOrig=nil end
    end
end

local nvOrig,nvCC=nil,nil
local function setNightVision(enabled)
    State.NightVisionEnabled=enabled
    if enabled then
        if nvOrig==nil then nvOrig={Lighting.Brightness,Lighting.Ambient,Lighting.OutdoorAmbient,Lighting.GlobalShadows,Lighting.ClockTime} end
        Lighting.Brightness=3;Lighting.Ambient=Color3.fromRGB(140,140,140);Lighting.OutdoorAmbient=Color3.fromRGB(160,160,160);Lighting.GlobalShadows=false
        if not nvCC then
            nvCC=Instance.new("ColorCorrectionEffect")
            nvCC.Name="VoidNightVision";nvCC.Brightness=0.15;nvCC.Contrast=0.05;nvCC.Saturation=0
            nvCC.Parent=Lighting
        end
    else
        if nvOrig then Lighting.Brightness=nvOrig[1];Lighting.Ambient=nvOrig[2];Lighting.OutdoorAmbient=nvOrig[3];Lighting.GlobalShadows=nvOrig[4];Lighting.ClockTime=nvOrig[5];nvOrig=nil end
        if nvCC then nvCC:Destroy();nvCC=nil end
    end
end

local function closeAllFeatures()
    setNoclip(false);setInfiniteJump(false);setInstantInteract(false);setPromptESP(false)
    setRemoveFog(false);setNightVision(false);setHitboxEnabled(false)
    State.ESPHighlightEnabled=false;State.ESPNameEnabled=false;State.ESPHealthEnabled=false
    State.SpeedEnabled=false;State.JumpEnabled=false
    stopSpectate();stopFollow()
    local _,h=getChar();if h then h.WalkSpeed=baseSpeed;h.UseJumpPower=true;h.JumpPower=BASE_JUMP end
    clearAllESP()
end

local function onPlayerAdded(player)
    if player==LP then return end
    if State.ESPHighlightEnabled or State.ESPNameEnabled or State.ESPHealthEnabled then
        task.spawn(function() if player.Character then createPlayerESP(player) end end)
    end
    if State.HitboxEnabled then
        task.spawn(function() if player.Character then applyHitbox(player.Character) end end)
    end
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if State.ESPHighlightEnabled or State.ESPNameEnabled or State.ESPHealthEnabled then createPlayerESP(player) end
        if State.HitboxEnabled then task.wait(0.2);applyHitbox(char) end
    end)
end

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if State.NoclipEnabled then setNoclip(true) end
    local _,h=getChar()
    if h then
        baseSpeed=h.WalkSpeed;lastSetSpeed=baseSpeed;updateBaseSpeedLbl()
        h.UseJumpPower=true;h.JumpPower=State.JumpEnabled and State.CustomJump or BASE_JUMP
    end
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then task.defer(createPlayerESP,p) end end
end)

for _,p in ipairs(Players:GetPlayers()) do onPlayerAdded(p) end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
    if spectateTarget==player then stopSpectate() end
    if followTarget==player then stopFollow() end
    clearPlayerESP(player)
end)

task.spawn(function()
    while task.wait(0.2) do
        if State.ESPHealthEnabled then updateESPLabels() end
        if State.PromptESPEnabled then
            updatePromptESPLabels()
            for prompt,d in pairs(PromptESPObjects) do if not prompt.Parent or not d.gui.Parent then clearPromptESP(prompt) end end
        end
    end
end)

local function runLoadScreen()
    local gui=new("ScreenGui",{Name="VoidLoad",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=9999,Parent=PG})
    local mask=new("Frame",{Size=UD.fromScale(1,1),BackgroundColor3=C.Void,BackgroundTransparency=1,BorderSizePixel=0,Parent=gui})
    local splash=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(260,130),BackgroundColor3=C.Bg,BorderSizePixel=0,Visible=false,Parent=gui})
    corner(splash,6);stroke(splash,C.Cyan,1,0.4);techCorners(splash,C.Cyan,12,2,0.1)
    local splashScale=new("UIScale",{Scale=0.88,Parent=splash})
    local logoBox=new("Frame",{AnchorPoint=Vector2.new(.5,0),Position=UD.new(.5,0,0,16),Size=UD.fromOffset(44,44),BackgroundTransparency=1,Parent=splash})
    local oRing=ring(logoBox,44,C.Cyan,1.5,0.25)
    local mRing=ring(logoBox,32,C.Purple,1.2,0.35)
    local dCore=diamond(logoBox,12,12,20,C.Cyan,0);grad(dCore,C.Cyan,C.Purple,45)
    diamond(logoBox,17,17,10,C.Bg,0)
    new("TextLabel",{Position=UD.new(0,0,0,68),Size=UD.new(1,0,0,16),BackgroundTransparency=1,Text="V O I D",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=14,Parent=splash})
    new("TextLabel",{Position=UD.new(0,0,0,86),Size=UD.new(1,0,0,12),BackgroundTransparency=1,Text="INITIALIZING",TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=9,Parent=splash})
    local sBar=new("Frame",{AnchorPoint=Vector2.new(.5,0),Position=UD.new(.5,0,0,106),Size=UD.fromOffset(180,3),BackgroundColor3=C.Panel2,BorderSizePixel=0,Parent=splash})
    corner(sBar,2)
    local sFill=new("Frame",{Size=UD.new(0,0,1,0),BackgroundColor3=C.Cyan,BorderSizePixel=0,Parent=sBar})
    corner(sFill,2);grad(sFill,C.Cyan,C.Purple,0)
    local root=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(340,140),BackgroundColor3=C.Bg,BorderSizePixel=0,Visible=false,Parent=gui})
    corner(root,6);stroke(root,C.Cyan,1,0.4);techCorners(root,C.Cyan,14,2,0.1)
    local scale=fitScale(root,340,40,0.65)
    local header=new("Frame",{Size=UD.new(1,0,0,26),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=root})
    corner(header,6)
    new("Frame",{Position=UD.new(0,0,0,20),Size=UD.new(1,0,0,6),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=root})
    diamond(header,10,8,10,C.Cyan,0)
    new("TextLabel",{Position=UD.fromOffset(26,0),Size=UD.new(1,-90,1,0),BackgroundTransparency=1,Text="VOID  //  INJECTION",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=header})
    new("TextLabel",{Position=UD.new(1,-70,0,0),Size=UD.fromOffset(62,26),BackgroundTransparency=1,Text="SECURE",TextColor3=C.Green,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Right,Parent=header})
    new("Frame",{Position=UD.new(0,0,0,26),Size=UD.new(1,0,0,1),BackgroundColor3=C.Line,BackgroundTransparency=0.5,BorderSizePixel=0,Parent=root})
    local pArea=new("Frame",{Position=UD.fromOffset(12,36),Size=UD.fromOffset(96,94),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=root})
    corner(pArea,5);stroke(pArea,C.Line,1,0.5)
    local avBox=new("Frame",{AnchorPoint=Vector2.new(.5,0),Position=UD.new(.5,0,0,8),Size=UD.fromOffset(48,48),BackgroundTransparency=1,Parent=pArea})
    local avRing=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(48,48),BackgroundTransparency=1,Parent=avBox})
    corner(avRing,24);stroke(avRing,C.Cyan,1.2,0.3)
    local avImg=new("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(40,40),BackgroundColor3=C.Panel2,BorderSizePixel=0,Image="",Parent=avBox})
    corner(avImg,20);stroke(avImg,C.Line,1,0.3)
    local pNameLbl=new("TextLabel",{Position=UD.fromOffset(4,60),Size=UD.new(1,-8,0,12),BackgroundTransparency=1,Text="Player",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=9,TextTruncate=Enum.TextTruncate.AtEnd,Parent=pArea})
    local uidLbl=new("TextLabel",{Position=UD.fromOffset(4,74),Size=UD.new(1,-8,0,10),BackgroundTransparency=1,Text="UID 000000",TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=8,TextTruncate=Enum.TextTruncate.AtEnd,Parent=pArea})
    local lArea=new("Frame",{Position=UD.fromOffset(116,36),Size=UD.fromOffset(212,94),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=root})
    corner(lArea,5);stroke(lArea,C.Line,1,0.5)
    local spinBox=new("Frame",{Position=UD.fromOffset(10,22),Size=UD.fromOffset(38,38),BackgroundTransparency=1,Parent=lArea})
    local spinOut=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(38,38),BackgroundTransparency=1,Parent=spinBox})
    corner(spinOut,19);stroke(spinOut,C.Cyan,1.4,0.3)
    local spinOutDot=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.new(1,0,.5,0),Size=UD.fromOffset(5,5),BackgroundColor3=C.Cyan,BorderSizePixel=0,Parent=spinOut})
    corner(spinOutDot,2.5)
    local spinMid=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(24,24),BackgroundTransparency=1,Parent=spinBox})
    corner(spinMid,12);stroke(spinMid,C.Purple,1.2,0.4)
    local spinCore=diamond(spinBox,13,13,12,C.Cyan,0)
    grad(spinCore,C.Cyan,C.Purple,45)
    local titleLbl=new("TextLabel",{Position=UD.fromOffset(58,10),Size=UD.new(1,-68,0,14),BackgroundTransparency=1,Text="正在注入...",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=lArea})
    local subLbl=new("TextLabel",{Position=UD.fromOffset(58,26),Size=UD.new(1,-68,0,11),BackgroundTransparency=1,Text="INJECT  CORE",TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=lArea})
    local pctLbl=new("TextLabel",{Position=UD.fromOffset(58,40),Size=UD.new(1,-68,0,16),BackgroundTransparency=1,Text="  0%",TextColor3=C.Cyan,Font=Enum.Font.Code,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=lArea})
    local barBg=new("Frame",{Position=UD.fromOffset(58,64),Size=UD.new(1,-68,0,5),BackgroundColor3=C.Panel2,BorderSizePixel=0,Parent=lArea})
    corner(barBg,3)
    local barFill=new("Frame",{Size=UD.new(0,0,1,0),BackgroundColor3=C.Cyan,BorderSizePixel=0,Parent=barBg})
    corner(barFill,3);grad(barFill,C.Cyan,C.Purple,0)
    local streamLbl=new("TextLabel",{Position=UD.fromOffset(58,74),Size=UD.new(1,-68,0,11),BackgroundTransparency=1,Text=">> 0000 0000 0000",TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,Parent=lArea})
    task.spawn(function()
        local ok,th=pcall(function() return Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
        if ok and th then avImg.Image=th end
    end)
    pNameLbl.Text=LP.Name
    uidLbl.Text="UID "..LP.UserId
    local okCard=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(320,110),BackgroundColor3=C.Bg,BorderSizePixel=0,Visible=false,Parent=gui})
    corner(okCard,6);stroke(okCard,C.Green,1,0.35);techCorners(okCard,C.Green,12,2,0.15)
    local okScale=new("UIScale",{Scale=0.9,Parent=okCard})
    local pulseOuter=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromOffset(46,42),Size=UD.fromOffset(42,42),BackgroundTransparency=1,Parent=okCard})
    corner(pulseOuter,21);stroke(pulseOuter,C.Green,1.2,0.7)
    local checkBox=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromOffset(46,42),Size=UD.fromOffset(22,22),BackgroundTransparency=1,Parent=okCard})
    for _,cfg in ipairs({{7,12,9,2.5,45},{14,9,15,2.5,-48}}) do
        local f=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromOffset(cfg[1],cfg[2]),Size=UD.fromOffset(cfg[3],cfg[4]),Rotation=cfg[5],BackgroundColor3=C.Green,BorderSizePixel=0,Parent=checkBox})
        corner(f,1.5)
    end
    new("TextLabel",{Position=UD.fromOffset(80,26),Size=UD.new(1,-90,0,16),BackgroundTransparency=1,Text="脚本加载成功",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=okCard})
    new("TextLabel",{Position=UD.fromOffset(80,46),Size=UD.new(1,-90,0,32),BackgroundTransparency=1,Text="网络延迟可能导致脚本加载时间大幅度延长",TextColor3=C.Dim,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,Parent=okCard})

    local function runLoader(title,sub,accent,dur)
        root.Visible=true;titleLbl.Text=title;subLbl.Text=sub
        root:FindFirstChildOfClass("UIStroke").Color=accent;pctLbl.TextColor3=accent
        local so=spinOut:FindFirstChildOfClass("UIStroke");if so then so.Color=accent end
        spinOutDot.BackgroundColor3=accent;spinCore.BackgroundColor3=accent;barFill.BackgroundColor3=accent
        scale.Scale=0.9;tw(scale,0.35,{Scale=1},Enum.EasingStyle.Back);task.wait(0.12)
        local a1,a2=0,0
        local c1=RunService.RenderStepped:Connect(function(dt) a1=a1+dt*300;a2=a2-dt*200;spinOut.Rotation=a1;spinMid.Rotation=a2 end)
        local acc=0
        local c2=RunService.RenderStepped:Connect(function(dt) acc=acc+dt;if acc>0.09 then acc=0;streamLbl.Text=">> "..hex(4).." "..hex(4).." "..hex(4) end end)
        local t0=os.clock()
        local c3=RunService.RenderStepped:Connect(function()
            local t=math.clamp((os.clock()-t0)/dur,0,1);local e=1-(1-t)^2
            barFill.Size=UD.new(e,0,1,0);pctLbl.Text=string.format("  %d%%",math.floor(e*100))
        end)
        task.wait(dur);c3:Disconnect()
        barFill.Size=UD.new(1,0,1,0);pctLbl.Text="  100%"
        task.wait(0.2);c1:Disconnect();c2:Disconnect()
        tw(scale,0.2,{Scale=0.9});task.wait(0.22);root.Visible=false
    end

    tw(mask,0.5,{BackgroundTransparency=0.4})
    local aS=makeAlpha(splash)
    splash.Visible=true;splashScale.Scale=0.88;aS.set(1)
    tw(splashScale,0.4,{Scale=1},Enum.EasingStyle.Back);aS.tweenTo(0,0.4)
    local a=0
    local sC=RunService.RenderStepped:Connect(function(dt) a=a+dt*90;oRing.Rotation=a;mRing.Rotation=-a*0.7 end)
    local t0=os.clock()
    local bC=RunService.RenderStepped:Connect(function()
        local t=math.clamp((os.clock()-t0)/1.3,0,1);sFill.Size=UD.new(1-(1-t)^2,0,1,0)
    end)
    task.wait(1.4);bC:Disconnect();sC:Disconnect()
    aS.tweenTo(1,0.28);task.wait(0.3);splash.Visible=false;splash:Destroy()
    task.wait(0.3)
    runLoader("正在注入脚本核心...","INJECT  CORE",C.Cyan,1.6)
    task.wait(0.12)
    runLoader("正在加载功能模块...","LOAD  FEATURES",C.Purple,1.4)
    task.wait(0.12)
    local aO=makeAlpha(okCard)
    okCard.Visible=true;okScale.Scale=0.85;aO.set(1)
    tw(okScale,0.38,{Scale=1},Enum.EasingStyle.Back);aO.tweenTo(0,0.38)
    local pC=RunService.RenderStepped:Connect(function(dt) pulseOuter.Rotation=pulseOuter.Rotation+dt*200 end)
    task.wait(1.6);pC:Disconnect()
    aO.tweenTo(1,0.26);task.wait(0.28)
    okCard.Visible=false;okCard:Destroy();root:Destroy()
    tw(mask,0.55,{BackgroundTransparency=1});task.wait(0.5);gui:Destroy()
end

if State.LoadScreenEnabled then runLoadScreen() end

local function buildUI()
    local gui=new("ScreenGui",{Name="VoidUI",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=9999,Parent=PG})
    local WIN_W,WIN_H=320,340
    local mainHomePos=UD.fromOffset(math.max(8,(CAM.ViewportSize.X-WIN_W)/2),math.max(8,(CAM.ViewportSize.Y-WIN_H)/2))
    local main=new("Frame",{Position=mainHomePos,Size=UD.fromOffset(WIN_W,WIN_H),BackgroundColor3=C.Bg,BorderSizePixel=0,Visible=true,Parent=gui})
    corner(main,8)
    new("ImageLabel",{Name="VoidBackground",Size=UD.fromScale(1,1),Position=UD.fromScale(0,0),BackgroundTransparency=1,Image="rbxassetid://131769990624851",ImageTransparency=0.35,ScaleType=Enum.ScaleType.Crop,ZIndex=0,Parent=main})
    corner(main:FindFirstChild("VoidBackground"),8)
    local mainStroke=stroke(main,C.Cyan,1,0.5)
    techCorners(main,C.Cyan,14,2,0.1)
    local mainScale=fitScale(main,WIN_W,30,0.75)
    local topGrad=grad(new("Frame",{Size=UD.new(1,-24,0,2),Position=UD.new(0,12,0,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Parent=main}),C.Cyan,C.Purple,0)
    topGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,0),NumberSequenceKeypoint.new(1,1)})
    local titleBar=new("Frame",{Size=UD.new(1,0,0,32),BackgroundColor3=C.Panel,BackgroundTransparency=0.35,BorderSizePixel=0,Parent=main})
    corner(titleBar,8)
    new("Frame",{Position=UD.new(0,0,0,24),Size=UD.new(1,0,0,8),BackgroundColor3=C.Panel,BackgroundTransparency=0.35,BorderSizePixel=0,Parent=main})
    local dragHandle=new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=1,Parent=titleBar})
    local logoMini=new("Frame",{Position=UD.fromOffset(10,9),Size=UD.fromOffset(14,14),BackgroundTransparency=1,Parent=titleBar})
    local lmR=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(14,14),BackgroundTransparency=1,Parent=logoMini})
    corner(lmR,7);stroke(lmR,C.Cyan,1.2,0.3)
    local lmD=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(7,7),BackgroundColor3=C.Cyan,BorderSizePixel=0,Rotation=45,Parent=logoMini})
    corner(lmD,1.5);grad(lmD,C.Cyan,C.Purple,45)
    new("TextLabel",{Position=UD.fromOffset(30,0),Size=UD.new(1,-140,1,0),BackgroundTransparency=1,Text="VOID",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=titleBar})
    new("TextLabel",{Position=UD.fromOffset(72,0),Size=UD.fromOffset(60,32),BackgroundTransparency=1,Text="V3 测试版",TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=titleBar})
    local onlineDot=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.new(1,-88,.5,0),Size=UD.fromOffset(6,6),BackgroundColor3=C.Green,BorderSizePixel=0,Parent=titleBar})
    corner(onlineDot,3)
    new("TextLabel",{Position=UD.new(1,-78,.5,-5),Size=UD.fromOffset(28,10),BackgroundTransparency=1,Text="ONLINE",TextColor3=C.Green,Font=Enum.Font.Code,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,Parent=titleBar})
    local minBtn=new("TextButton",{Position=UD.new(1,-38,0,7),Size=UD.fromOffset(14,14),BackgroundColor3=C.Panel2,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=5,Parent=titleBar})
    corner(minBtn,3);stroke(minBtn,C.Line,1,0.4)
    new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(6,1.5),BackgroundColor3=C.Dim,BorderSizePixel=0,Parent=minBtn})
    local closeBtn=new("TextButton",{Position=UD.new(1,-22,0,7),Size=UD.fromOffset(14,14),BackgroundColor3=C.Panel2,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=5,Parent=titleBar})
    corner(closeBtn,3);stroke(closeBtn,C.Line,1,0.4)
    new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(6,1.5),Rotation=45,BackgroundColor3=C.Dim,BorderSizePixel=0,Parent=closeBtn})
    new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(6,1.5),Rotation=-45,BackgroundColor3=C.Dim,BorderSizePixel=0,Parent=closeBtn})

    local tabs={"主要","通用","视觉","剥削","碰撞"}
    local tabCount=#tabs
    local tabBar=new("Frame",{Position=UD.new(0,0,0,32),Size=UD.new(1,0,0,26),BackgroundColor3=C.Panel,BackgroundTransparency=0.35,BorderSizePixel=0,Parent=main})
    new("Frame",{Position=UD.new(0,0,0,25),Size=UD.new(1,0,0,1),BackgroundColor3=C.Line,BackgroundTransparency=0.4,BorderSizePixel=0,Parent=tabBar})
    local tabBtns={}
    local tabHighlight=new("Frame",{Position=UD.fromOffset(0,23),Size=UD.new(1/tabCount,0,0,2),BackgroundColor3=C.Cyan,BorderSizePixel=0,Parent=tabBar})
    grad(tabHighlight,C.Cyan,C.Purple,0)
    for i,name in ipairs(tabs) do tabBtns[i]=new("TextButton",{Position=UD.new((i-1)/tabCount,0,0,0),Size=UD.new(1/tabCount,0,1,0),BackgroundTransparency=1,Text=name,TextColor3=(i==1) and C.Text or C.Dim,Font=Enum.Font.GothamBold,TextSize=10,AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Center,Parent=tabBar}) end

    local content=new("Frame",{Position=UD.new(0,0,0,58),Size=UD.new(1,0,1,-84),BackgroundTransparency=1,Parent=main})
    local pages={}
    local pageCanvas={220,340,260,270,190}
    for i=1,tabCount do
        pages[i]=new("ScrollingFrame",{
            Size=UD.fromScale(1,1),
            BackgroundTransparency=1,
            BorderSizePixel=0,
            ScrollBarThickness=3,
            ScrollBarImageColor3=C.Cyan,
            CanvasSize=UD.new(0,0,0,pageCanvas[i] or 300),
            ScrollingDirection=Enum.ScrollingDirection.Y,
            Visible=(i==1),
            Parent=content
        })
    end

    local resetToggles={}
    local resetSliders={}
    local resetColors={}

    local function makeToggle(parent,y,label,desc,accent,default,cb,noReset)
        local row=new("Frame",{Position=UD.fromOffset(10,y),Size=UD.new(1,-20,0,36),BackgroundColor3=C.Panel,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=parent})
        corner(row,5);stroke(row,C.Line,1,0.5)
        local bar=new("Frame",{Position=UD.fromOffset(0,8),Size=UD.fromOffset(2,20),BackgroundColor3=C.Line,BorderSizePixel=0,Parent=row})
        corner(bar,1)
        new("TextLabel",{Position=UD.fromOffset(12,4),Size=UD.new(1,-90,0,14),BackgroundTransparency=1,Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local dl=new("TextLabel",{Position=UD.fromOffset(12,19),Size=UD.new(1,-90,0,11),BackgroundTransparency=1,Text=desc,TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local track=new("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-12,.5,0),Size=UD.fromOffset(30,16),BackgroundColor3=C.Panel2,BorderSizePixel=0,Parent=row})
        corner(track,8)
        local ts=stroke(track,C.Line,1,0.2)
        local knob=new("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,2,.5,0),Size=UD.fromOffset(12,12),BackgroundColor3=C.Dim,BorderSizePixel=0,Parent=track})
        corner(knob,6)
        local hit=new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=row})
        local on=default or false
        local function setOn(v)
            on=v
            tw(knob,0.18,{Position=on and UD.new(0,16,.5,0) or UD.new(0,2,.5,0),BackgroundColor3=on and accent or C.Dim},Enum.EasingStyle.Back)
            ts.Color=on and accent or C.Line;ts.Transparency=on and 0.2 or 0.6
            tw(bar,0.15,{BackgroundColor3=on and accent or C.Line})
            dl.TextColor3=on and accent or C.Dim
            tw(row,0.15,{BackgroundTransparency=on and 0.3 or 0.15})
            if cb then cb(on) end
        end
        if on then
            knob.Position=UD.new(0,16,.5,0);knob.BackgroundColor3=accent
            ts.Color=accent;ts.Transparency=0.2
            bar.BackgroundColor3=accent;dl.TextColor3=accent;row.BackgroundTransparency=0.3
        end
        hit.Activated:Connect(function() setOn(not on) end)
        if not noReset then table.insert(resetToggles,setOn) end
        return setOn,dl
    end

    local function makeSlider(parent,y,label,accent,minV,maxV,defV,suffix,prec,cb)
        local row=new("Frame",{Position=UD.fromOffset(10,y),Size=UD.new(1,-20,0,38),BackgroundColor3=C.Panel,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=parent})
        corner(row,5);stroke(row,C.Line,1,0.5)
        new("TextLabel",{Position=UD.fromOffset(12,4),Size=UD.new(1,-130,0,14),BackgroundTransparency=1,Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local initTxt=(prec==0) and (tostring(math.floor(defV+0.5))..(suffix or "")) or (string.format("%."..prec.."f",defV)..(suffix or ""))
        local vb=new("TextBox",{Position=UD.new(1,-92,0,4),Size=UD.fromOffset(80,16),BackgroundColor3=C.Panel2,BorderSizePixel=0,Text=initTxt,TextColor3=accent,Font=Enum.Font.Code,TextSize=10,TextXAlignment=Enum.TextXAlignment.Center,ClearTextOnFocus=false,Parent=row})
        corner(vb,3);stroke(vb,C.Line,1,0.4)
        local function fmt(v) return (prec==0) and (math.floor(v+0.5)..(suffix or "")) or (string.format("%."..prec.."f",v)..(suffix or "")) end
        local function rnd(v) v=math.clamp(v,minV,maxV);if prec==0 then return math.floor(v+0.5) end;local m=10^prec;return math.floor(v*m+0.5)/m end
        local pct=(defV-minV)/(maxV-minV)
        local track=new("Frame",{Position=UD.fromOffset(12,26),Size=UD.new(1,-24,0,5),BackgroundColor3=C.Panel2,BorderSizePixel=0,Parent=row})
        corner(track,2.5)
        local fill=new("Frame",{Size=UD.new(pct,0,1,0),BackgroundColor3=accent,BorderSizePixel=0,Parent=track})
        corner(fill,2.5);grad(fill,accent,C.Purple,0)
        local dot=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.new(pct,0,.5,0),Size=UD.fromOffset(11,11),BackgroundColor3=accent,BorderSizePixel=0,Parent=track})
        corner(dot,5.5);stroke(dot,C.Bg,2,0)
        local hit=new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=track})
        local dragging=false
        local function setV(v,fire)
            v=rnd(v);local pp=(v-minV)/(maxV-minV)
            fill.Size=UD.new(pp,0,1,0);dot.Position=UD.new(pp,0,.5,0);vb.Text=fmt(v)
            if fire and cb then cb(v) end
        end
        local function setVal(v) setV(v,true) end
        local function upd(input)
            local pp=math.clamp((input.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            local v=rnd(minV+pp*(maxV-minV))
            local pp2=(v-minV)/(maxV-minV)
            fill.Size=UD.new(pp2,0,1,0);dot.Position=UD.new(pp2,0,.5,0);vb.Text=fmt(v)
            if cb then cb(v) end
        end
        hit.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true;upd(input) end end)
        UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then upd(input) end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
        vb.FocusLost:Connect(function()
            local n=tonumber((vb.Text:gsub("[^%d%.%-]","")))
            if n then setV(n,true) else setV(defV,false) end
        end)
        table.insert(resetSliders,{fn=setVal,default=defV})
    end

    local function makeColorPicker(parent,y,label,desc,accent,colors,defIdx,cb)
        local row=new("Frame",{Position=UD.fromOffset(10,y),Size=UD.new(1,-20,0,36),BackgroundColor3=C.Panel,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=parent})
        corner(row,5);stroke(row,C.Line,1,0.5)
        new("TextLabel",{Position=UD.fromOffset(12,4),Size=UD.new(1,-90,0,14),BackgroundTransparency=1,Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        new("TextLabel",{Position=UD.fromOffset(12,19),Size=UD.new(1,-90,0,11),BackgroundTransparency=1,Text=desc,TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local btns={};local bw,gap=18,4;local cur=defIdx or 1
        for i,c in ipairs(colors) do
            local ro=-12-(#colors-i)*(bw+gap)
            local b=new("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,ro,.5,0),Size=UD.fromOffset(bw,bw),BackgroundColor3=c.Color,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=row})
            corner(b,3);stroke(b,(i==cur) and accent or C.Line,2,(i==cur) and 0 or 0.6)
            btns[i]=b
            b.Activated:Connect(function()
                if i==cur then return end
                local old=cur;cur=i
                local os_=btns[old]:FindFirstChildOfClass("UIStroke");if os_ then os_.Color=C.Line;os_.Transparency=0.6 end
                local ns=btns[i]:FindFirstChildOfClass("UIStroke");if ns then ns.Color=accent;ns.Transparency=0 end
                if cb then cb(c.Color) end
            end)
        end
        table.insert(resetColors,function()
            if cur==1 then return end
            local old=cur;cur=1
            local os_=btns[old]:FindFirstChildOfClass("UIStroke");if os_ then os_.Color=C.Line;os_.Transparency=0.6 end
            local ns=btns[1]:FindFirstChildOfClass("UIStroke");if ns then ns.Color=accent;ns.Transparency=0 end
            if cb then cb(colors[1].Color) end
        end)
    end

    local function makeActionBtn(parent,y,label,desc,accent,btnText,cb)
        local row=new("Frame",{Position=UD.fromOffset(10,y),Size=UD.new(1,-20,0,36),BackgroundColor3=C.Panel,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=parent})
        corner(row,5);stroke(row,C.Line,1,0.5)
        local bar=new("Frame",{Position=UD.fromOffset(0,8),Size=UD.fromOffset(2,20),BackgroundColor3=accent,BorderSizePixel=0,Parent=row})
        corner(bar,1)
        new("TextLabel",{Position=UD.fromOffset(12,4),Size=UD.new(1,-120,0,14),BackgroundTransparency=1,Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        new("TextLabel",{Position=UD.fromOffset(12,19),Size=UD.new(1,-120,0,11),BackgroundTransparency=1,Text=desc,TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local txt=btnText or "执行"
        local btn=new("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-12,.5,0),Size=UD.fromOffset(60,22),BackgroundColor3=accent,BorderSizePixel=0,Text=txt,TextColor3=C.Bg,Font=Enum.Font.GothamBold,TextSize=10,AutoButtonColor=false,Parent=row})
        corner(btn,4)
        local active=false
        local function setActive(v)
            active=v
            btn.Text = v and "关闭" or txt
            btn.BackgroundColor3 = v and C.Red or accent
            btn.TextColor3 = v and C.Text or C.Bg
        end
        btn.MouseEnter:Connect(function() if not active then tw(btn,0.15,{BackgroundTransparency=0.15}) end end)
        btn.MouseLeave:Connect(function() if not active then tw(btn,0.15,{BackgroundTransparency=0}) end end)
        btn.Activated:Connect(function()
            tw(btn,0.06,{Size=UD.fromOffset(56,20)});tw(btn,0.14,{Size=UD.fromOffset(60,22)})
            if cb then cb(setActive,active) end
        end)
        return setActive
    end

    local function makeBigBtn(parent,y,text,accent,cb)
        local btn=new("TextButton",{Position=UD.fromOffset(10,y),Size=UD.new(1,-20,0,50),BackgroundColor3=C.Panel,BackgroundTransparency=0.15,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=parent})
        corner(btn,6);stroke(btn,accent,1,0.35)
        local bar=new("Frame",{Position=UD.fromOffset(0,10),Size=UD.fromOffset(3,30),BackgroundColor3=accent,BorderSizePixel=0,Parent=btn})
        corner(bar,1.5)
        new("TextLabel",{Position=UD.fromOffset(14,0),Size=UD.new(1,-20,1,0),BackgroundTransparency=1,Text=text,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=btn})
        btn.MouseEnter:Connect(function() tw(btn,0.15,{BackgroundTransparency=0.3}) end)
        btn.MouseLeave:Connect(function() tw(btn,0.15,{BackgroundTransparency=0.15}) end)
        btn.Activated:Connect(function()
            tw(btn,0.08,{BackgroundColor3=accent});task.wait(0.1);tw(btn,0.2,{BackgroundColor3=C.Panel})
            if cb then cb() end
        end)
    end

    local function showPlayerSelect(cb)
        local overlay=new("Frame",{Size=UD.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.5,BorderSizePixel=0,ZIndex=100,Parent=gui})
        local list=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(220,240),BackgroundColor3=C.Bg,BorderSizePixel=0,ZIndex=101,Parent=overlay})
        corner(list,6);stroke(list,C.Cyan,1,0.3)
        local header=new("Frame",{Size=UD.new(1,0,0,28),BackgroundColor3=C.Panel,BorderSizePixel=0,ZIndex=102,Parent=list})
        corner(header,6)
        new("TextLabel",{Position=UD.fromOffset(10,0),Size=UD.new(1,-40,1,0),BackgroundTransparency=1,Text="选择玩家",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=103,Parent=header})
        local xBtn=new("TextButton",{Position=UD.new(1,-24,0,5),Size=UD.fromOffset(18,18),BackgroundColor3=C.Panel2,BorderSizePixel=0,Text="×",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false,ZIndex=103,Parent=header})
        corner(xBtn,3)
        local scroll=new("ScrollingFrame",{Position=UD.fromOffset(6,34),Size=UD.new(1,-12,1,-40),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=C.Cyan,CanvasSize=UD.new(0,0,0,2000),ZIndex=102,Parent=list})
        local layout=new("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,Parent=scroll})
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP then
                local btn=new("TextButton",{Size=UD.new(1,-8,0,26),BackgroundColor3=C.Panel,BackgroundTransparency=0.15,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=103,Parent=scroll})
                corner(btn,4);stroke(btn,C.Line,1,0.5)
                new("TextLabel",{Position=UD.fromOffset(8,0),Size=UD.new(1,-8,1,0),BackgroundTransparency=1,Text=plr.Name,TextColor3=C.Text,Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=104,Parent=btn})
                btn.MouseEnter:Connect(function() tw(btn,0.12,{BackgroundTransparency=0.3}) end)
                btn.MouseLeave:Connect(function() tw(btn,0.12,{BackgroundTransparency=0.15}) end)
                btn.Activated:Connect(function() cb(plr);overlay:Destroy() end)
            end
        end
        scroll.CanvasSize=UD.new(0,0,0,layout.AbsoluteContentSize.Y+10)
        xBtn.Activated:Connect(function() overlay:Destroy() end)
    end

    do
        local p=pages[1]
        local sc=new("Frame",{Position=UD.fromOffset(10,6),Size=UD.new(1,-20,0,66),BackgroundColor3=C.Panel,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=p})
        corner(sc,5);stroke(sc,C.Line,1,0.5)
        local av=new("Frame",{Position=UD.fromOffset(10,8),Size=UD.fromOffset(36,36),BackgroundTransparency=1,Parent=sc})
        local ar=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(36,36),BackgroundTransparency=1,Parent=av})
        corner(ar,18);stroke(ar,C.Cyan,1.2,0.3)
        local ai=new("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(30,30),BackgroundColor3=C.Panel2,BorderSizePixel=0,Parent=av})
        corner(ai,15)
        task.spawn(function() local ok,th=pcall(function() return Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end);if ok and th then ai.Image=th end end)
        new("TextLabel",{Position=UD.fromOffset(54,8),Size=UD.new(1,-64,0,14),BackgroundTransparency=1,Text=LP.Name,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=sc})
        new("TextLabel",{Position=UD.fromOffset(54,24),Size=UD.new(1,-64,0,11),BackgroundTransparency=1,Text="UID  "..LP.UserId,TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=sc})
        new("TextLabel",{Position=UD.fromOffset(54,36),Size=UD.new(1,-64,0,11),BackgroundTransparency=1,Text="AGE  "..LP.AccountAge.."D   |   ONLINE",TextColor3=C.Green,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=sc})
        local tl=new("TextLabel",{Position=UD.fromOffset(54,50),Size=UD.new(1,-64,0,12),BackgroundTransparency=1,Text="已使用  00:00:00",TextColor3=C.Cyan,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=sc})
        task.spawn(function()
            while tl.Parent do
                local e=math.floor(tick()-SCRIPT_START)
                tl.Text=string.format("已使用  %02d:%02d:%02d",math.floor(e/3600),math.floor((e%3600)/60),e%60)
                task.wait(1)
            end
        end)
        local rb=new("TextButton",{Position=UD.fromOffset(10,80),Size=UD.new(1,-20,0,26),BackgroundColor3=C.Panel2,BorderSizePixel=0,Text="重置所有功能",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,AutoButtonColor=false,Parent=p})
        corner(rb,5);stroke(rb,C.Line,1,0.5)
        rb.MouseEnter:Connect(function() tw(rb,0.15,{BackgroundColor3=C.Panel}) end)
        rb.MouseLeave:Connect(function() tw(rb,0.15,{BackgroundColor3=C.Panel2}) end)
        rb.Activated:Connect(function()
            for _,s in ipairs(resetToggles) do s(false) end
            for _,s in ipairs(resetSliders) do s.fn(s.default) end
            for _,r in ipairs(resetColors) do r() end
            closeAllFeatures()
            tw(rb,0.08,{BackgroundColor3=C.Green});tw(rb,0.2,{BackgroundColor3=C.Panel2})
        end)
        makeToggle(p,116,"启动加载界面","LOAD SCREEN",C.Cyan,State.LoadScreenEnabled,function(on) State.LoadScreenEnabled=on;_G.VoidConfig.LoadScreenEnabled=on end,true)
        makeActionBtn(p,160,"TX Script","全自动翻译",C.Green,"启动",function()
            local ok,err=pcall(function()
                TX = "TX Script"
                Script = "全自动翻译"
                loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Auto-language"))()
            end)
            if not ok then notify("TX Script","加载失败: "..tostring(err)) end
        end)
    end

    do
        local p=pages[2]
        local _,dl=makeToggle(p,6,"启用移动速度","原始移速: 16",C.Cyan,false,function(on) State.SpeedEnabled=on end)
        speedToggleDesc=dl
        updateBaseSpeedLbl()
        makeSlider(p,46,"速度倍数",C.Cyan,0.1,20,State.SpeedMultiplier,"x",1,function(v) State.SpeedMultiplier=v end)
        makeToggle(p,88,"启用跳跃高度","JUMP TOGGLE",C.Purple,false,function(on) setJumpEnabled(on) end)
        makeSlider(p,128,"跳跃高度",C.Purple,50,300,State.CustomJump,"",0,function(v) setJump(v) end)
        makeToggle(p,170,"无限跳跃","INFINITE JUMP",C.Cyan,State.InfiniteJumpEnabled,function(on) setInfiniteJump(on) end)
        makeActionBtn(p,210,"飞行模式","FLY MODE",C.Cyan,"启动",flyingScript)
        makeToggle(p,250,"穿墙模式","NOCLIP",C.Cyan,State.NoclipEnabled,function(on) setNoclip(on) end)
        makeToggle(p,290,"秒互动","INSTANT INTERACT",C.Purple,State.InstantInteractEnabled,function(on) setInstantInteract(on) end)
    end

    do
        local p=pages[3]
        makeToggle(p,6,"ESP 高亮","HIGHLIGHT PLAYERS",C.Cyan,State.ESPHighlightEnabled,function(on) State.ESPHighlightEnabled=on;refreshAllESP() end)
        makeToggle(p,46,"透视名字","PLAYER NAME",C.Purple,State.ESPNameEnabled,function(on) State.ESPNameEnabled=on;refreshAllESP() end)
        makeToggle(p,86,"透视血量","PLAYER HEALTH",C.Cyan,State.ESPHealthEnabled,function(on) State.ESPHealthEnabled=on;refreshAllESP() end)
        makeToggle(p,126,"透视互动位置","PROMPT ESP",C.Purple,State.PromptESPEnabled,function(on) setPromptESP(on) end)
        makeToggle(p,166,"除雾效果","NO FOG",C.Cyan,State.RemoveFogEnabled,function(on) setRemoveFog(on) end)
        makeToggle(p,206,"夜视模式","NIGHT VISION",C.Purple,State.NightVisionEnabled,function(on) setNightVision(on) end)
    end

    do
        local p=pages[4]
        makeBigBtn(p,10,"通用甩飞  建议开启翻译",C.Red,function() runExternal("https://rawscripts.net/raw/Universal-Script-redzzyg's-fling-system-228233","甩飞") end)
        makeBigBtn(p,70,"走路无旋转甩飞  建议开启翻译",C.Purple,function() runExternal("https://rawscripts.net/raw/Universal-Script-Fling-Gui-230233","甩飞") end)
        makeActionBtn(p,130,"选人传送","传送到所选玩家位置",C.Cyan,"选择",function()
            showPlayerSelect(function(plr)
                local mc=LP.Character;if not mc then return end
                local mhrp=mc:FindFirstChild("HumanoidRootPart");if not mhrp then return end
                local tc=plr.Character;if not tc then return end
                local thrp=tc:FindFirstChild("HumanoidRootPart");if not thrp then return end
                mhrp.CFrame=CFrame.new(thrp.Position+Vector3.new(0,3,0))
            end)
        end)
        spectateSetOn=makeActionBtn(p,170,"选人观战","相机跟随所选玩家",C.Purple,"启动",function(setActive,active)
            if active then
                stopSpectate()
                return
            end
            showPlayerSelect(function(plr)
                spectateTarget=plr
                setActive(true)
                local tc=plr.Character
                if tc then
                    local th=tc:FindFirstChildOfClass("Humanoid")
                    if th then CAM.CameraSubject=th end
                end
            end)
        end)
        followSetOn=makeActionBtn(p,210,"持续贴紧","每帧贴紧所选玩家",C.Green,"启动",function(setActive,active)
            if active then
                stopFollow()
                return
            end
            showPlayerSelect(function(plr)
                followTarget=plr
                setActive(true)
            end)
        end)
    end

    do
        local p=pages[5]
        local colors={{Color=Color3.fromRGB(255,215,0)},{Color=Color3.fromRGB(255,60,60)},{Color=Color3.fromRGB(60,150,255)},{Color=Color3.fromRGB(60,255,120)},{Color=Color3.fromRGB(180,80,255)},{Color=Color3.fromRGB(255,255,255)}}
        makeToggle(p,6,"启用碰撞箱","HITBOX TOGGLE",C.Green,false,function(on) setHitboxEnabled(on) end)
        makeSlider(p,46,"碰撞箱大小",C.Green,1,50,State.HitboxSize,"",0,function(v) setHitboxSize(v) end)
        makeSlider(p,86,"碰撞箱透明度",C.Green,0,1,State.HitboxTransparency,"",2,function(v) setHitboxTransparency(v) end)
        makeColorPicker(p,126,"碰撞箱颜色","点击切换",C.Green,colors,1,function(c) setHitboxColor(c) end)
    end

    local currentTab=1
    local function switchTab(idx)
        if idx==currentTab then return end
        tabBtns[currentTab].TextColor3=C.Dim;tabBtns[idx].TextColor3=C.Text
        pages[currentTab].Visible=false;pages[idx].Visible=true
        tw(tabHighlight,0.22,{Position=UD.fromOffset((idx-1)/tabCount*WIN_W,23)})
        currentTab=idx
    end
    for i,b in ipairs(tabBtns) do
        b.Activated:Connect(function() switchTab(i) end)
        b.MouseEnter:Connect(function() if i~=currentTab then tw(b,0.15,{TextColor3=C.Text}) end end)
        b.MouseLeave:Connect(function() if i~=currentTab then tw(b,0.15,{TextColor3=C.Dim}) end end)
    end

    local sb=new("Frame",{Position=UD.new(0,1,-24),Size=UD.new(1,0,0,24),BackgroundColor3=C.Panel,BackgroundTransparency=0.35,BorderSizePixel=0,Parent=main})
    corner(sb,8)
    new("Frame",{Position=UD.new(0,0,0,0),Size=UD.new(1,0,0,8),BackgroundColor3=C.Panel,BackgroundTransparency=0.35,BorderSizePixel=0,Parent=sb})
    new("Frame",{Position=UD.new(0,0,0,0),Size=UD.new(1,0,0,1),BackgroundColor3=C.Line,BackgroundTransparency=0.4,BorderSizePixel=0,Parent=sb})
    local bl=new("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,10,.5,0),Size=UD.fromOffset(5,5),BackgroundColor3=C.Green,BorderSizePixel=0,Parent=sb})
    corner(bl,2.5)
    new("TextLabel",{Position=UD.fromOffset(20,0),Size=UD.fromOffset(90,24),BackgroundTransparency=1,Text="READY",TextColor3=C.Green,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=sb})
    local pl=new("TextLabel",{Position=UD.new(1,-90,0,0),Size=UD.fromOffset(80,24),BackgroundTransparency=1,Text="PING 12ms",TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Right,Parent=sb})

    local MINI=46
    local miniHomePos=UD.fromOffset(CAM.ViewportSize.X-MINI-20,CAM.ViewportSize.Y*0.4)
    local mini=new("TextButton",{Position=miniHomePos,Size=UD.fromOffset(MINI,MINI),BackgroundColor3=C.Bg,BorderSizePixel=0,Text="",AutoButtonColor=false,Visible=false,Parent=gui})
    corner(mini,MINI/2);stroke(mini,C.Cyan,1.4,0.2)
    local msc=new("UIScale",{Scale=1,Parent=mini})
    local orb=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(30,30),BackgroundTransparency=1,Parent=mini})
    local od=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.new(1,0,.5,0),Size=UD.fromOffset(4,4),BackgroundColor3=C.Cyan,BorderSizePixel=0,Parent=orb})
    corner(od,2)
    local mc2=diamond(mini,15,15,16,C.Cyan,0)
    grad(mc2,C.Cyan,C.Purple,45)
    diamond(mini,19,19,8,C.Bg,0)
    RunService.RenderStepped:Connect(function(dt)
        if not mini.Visible then return end
        orb.Rotation=orb.Rotation+dt*140
        msc.Scale=1+((math.sin(os.clock()*3)+1)/2)*0.04
    end)
    main:GetPropertyChangedSignal("Position"):Connect(function()
        if main.Visible then mainHomePos=main.Position end
    end)
    mini:GetPropertyChangedSignal("Position"):Connect(function()
        if mini.Visible then miniHomePos=mini.Position end
    end)
    makeDraggable(mini,mini,function()
        mini.Visible=false
        main.Position=mainHomePos
        main.Visible=true
        mainScale.Scale=0.86
        tw(mainScale,0.3,{Scale=1},Enum.EasingStyle.Back)
    end)
    makeDraggable(main,dragHandle)
    minBtn.Activated:Connect(function()
        tw(minBtn,0.08,{BackgroundColor3=C.Cyan});tw(minBtn,0.15,{BackgroundColor3=C.Panel2})
        main.Visible=false
        mini.Position=UD.fromOffset(CAM.ViewportSize.X-MINI-20,CAM.ViewportSize.Y*0.4)
        miniHomePos=mini.Position
        mini.Visible=true
        msc.Scale=0.4
        tw(msc,0.35,{Scale=1},Enum.EasingStyle.Back)
    end)
    closeBtn.Activated:Connect(function()
        tw(closeBtn,0.08,{BackgroundColor3=C.Red})
        tw(mainScale,0.18,{Scale=0.85});tw(main,0.18,{BackgroundTransparency=1})
        task.wait(0.2)
        mini.Visible=false;main.Visible=false
        closeAllFeatures()
        task.wait(0.05)
        gui:Destroy()
    end)
    main.Visible=true;mainScale.Scale=0.86
    tw(mainScale,0.38,{Scale=1},Enum.EasingStyle.Back)
    task.spawn(function()
        while main.Parent do
            local p2=(math.sin(os.clock()*2)+1)/2
            mainStroke.Transparency=0.65-p2*0.35
            bl.BackgroundTransparency=p2*0.4
            pl.Text="PING "..math.random(10,18).."ms"
            task.wait(0.8)
        end
    end)
end

buildUI()
