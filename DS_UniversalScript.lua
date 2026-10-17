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
    function a.tweenTo(t,du) for _,r in ipairs(d) do tw(r.i,du,{[r.p]=r.b+(1-r.b)*t},Enum.EasingStyle.Quart) end end
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
    if not enabled then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.CanCollide=true end end return end
    for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    noclipConn=RunService.Heartbeat:Connect(function() if not State.NoclipEnabled then return end local c=LP.Character;if not c then return end for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end end end)
end
local function setInfiniteJump(enabled)
    State.InfiniteJumpEnabled=enabled
    if infJumpConn then infJumpConn:Disconnect();infJumpConn=nil end
    if enabled then infJumpConn=UserInputService.JumpRequest:Connect(function() local _,h=getChar();if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end
end
local function applyJump() local _,h=getChar();if not h then return end h.UseJumpPower=true h.JumpPower=State.JumpEnabled and State.CustomJump or BASE_JUMP end
local function setJump(v) State.CustomJump=v;applyJump() end
local function setJumpEnabled(v) State.JumpEnabled=v;applyJump() end

local GuardZones={Enabled=false,Size=0,Buttons={},FadeToken=0,Gui=nil}
local function setupGuardZones()
    if GuardZones.Gui then return end
    local sg=new("ScreenGui",{Name="VoidGuard",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=9998,Parent=PG})
    GuardZones.Gui=sg
    local configs={
        {name="Top",anchor=Vector2.new(0,0),pos=UD.new(0,0,0,0),size=UD.new(1,0,0,0)},
        {name="Bottom",anchor=Vector2.new(0,1),pos=UD.new(0,0,1,0),size=UD.new(1,0,0,0)},
        {name="Left",anchor=Vector2.new(0,0),pos=UD.new(0,0,0,0),size=UD.new(0,0,1,0)},
        {name="Right",anchor=Vector2.new(1,0),pos=UD.new(1,0,0,0),size=UD.new(0,0,1,0)},
    }
    for _,cfg in ipairs(configs) do
        local b=new("TextButton",{Name=cfg.name,AnchorPoint=cfg.anchor,Position=cfg.pos,Size=cfg.size,BackgroundColor3=Color3.fromRGB(255,90,140),BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,Active=false,Parent=sg})
        GuardZones.Buttons[cfg.name]=b
    end
end
local function applyGuardSize(size)
    size=math.clamp(math.floor(size+0.5),0,200)
    GuardZones.Size=size
    local b=GuardZones.Buttons
    if not b.Top then return end
    b.Top.Size=UD.new(1,0,0,size)
    b.Bottom.Size=UD.new(1,0,0,size)
    b.Left.Size=UD.new(0,size,1,0)
    b.Right.Size=UD.new(0,size,1,0)
    local active=GuardZones.Enabled and size>0
    for _,v in pairs(b) do v.Active=active end
end
local function flashGuardZones(size)
    applyGuardSize(size)
    GuardZones.FadeToken=GuardZones.FadeToken+1
    local myToken=GuardZones.FadeToken
    if size<=0 then return end
    for _,v in pairs(GuardZones.Buttons) do v.BackgroundTransparency=0.45 end
    task.delay(5,function()
        if GuardZones.FadeToken~=myToken then return end
        for _,v in pairs(GuardZones.Buttons) do tw(v,1.4,{BackgroundTransparency=1},Enum.EasingStyle.Quart) end
    end)
end
local function setGuardEnabled(on) GuardZones.Enabled=on;applyGuardSize(GuardZones.Size) end
setupGuardZones()

local function stopSpectate() spectateTarget=nil local _,h=getChar() if h then CAM.CameraSubject=h end if spectateSetOn then spectateSetOn(false) end end
local function stopFollow() followTarget=nil if followSetOn then followSetOn(false) end end
RunService.Heartbeat:Connect(function(dt)
    local char,h=getChar()
    if not h then return end
    if not State.SpeedEnabled then
        local cur=h.WalkSpeed
        if math.abs(cur-lastSetSpeed)>0.01 then baseSpeed=cur;lastSetSpeed=cur;updateBaseSpeedLbl() end
    else
        local cur=h.WalkSpeed
        if math.abs(cur-lastSetSpeed)>0.01 then baseSpeed=cur;updateBaseSpeedLbl() end
        h.WalkSpeed=baseSpeed;lastSetSpeed=baseSpeed
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
        else local tc=spectateTarget.Character if tc then local th=tc:FindFirstChildOfClass("Humanoid") if th and th.Health>0 and CAM.CameraSubject~=th then CAM.CameraSubject=th end end end
    end
    if followTarget then
        if not followTarget.Parent then stopFollow()
        else local tc=followTarget.Character if tc then local thrp=tc:FindFirstChild("HumanoidRootPart") if thrp then local mhrp=char:FindFirstChild("HumanoidRootPart") if mhrp then mhrp.CFrame=CFrame.new(thrp.Position) end end end end
    end
end)
local function saveHitboxOrig(char)
    if HitboxOrig[char] then return end
    local head=char:FindFirstChild("Head");local root=char:FindFirstChild("HumanoidRootPart")
    HitboxOrig[char]={head=head and {Size=head.Size,Transparency=head.Transparency,CanCollide=head.CanCollide,Material=head.Material,Color=head.Color},root=root and {Size=root.Size,Transparency=root.Transparency,CanCollide=root.CanCollide,Material=root.Material,Color=root.Color}}
end
local function applyHitbox(char)
    if not char then return end
    local h=char:FindFirstChildOfClass("Humanoid");if not h or h.Health<=0 then return end
    saveHitboxOrig(char)
    local sz=Vector3.new(State.HitboxSize,State.HitboxSize,State.HitboxSize)
    for _,name in ipairs({"HumanoidRootPart","Head"}) do
        local part=char:FindFirstChild(name)
        if part then part.Size=sz;part.Transparency=State.HitboxTransparency;part.Color=State.HitboxColor;part.Material=Enum.Material.Neon;part.CanCollide=false end
    end
end
local function resetHitbox(char)
    local d=HitboxOrig[char];if not d then return end
    local head=char:FindFirstChild("Head");local root=char:FindFirstChild("HumanoidRootPart")
    if head and d.head then head.Size=d.head.Size;head.Transparency=d.head.Transparency;head.CanCollide=d.head.CanCollide;head.Material=d.head.Material;head.Color=d.head.Color end
    if root and d.root then root.Size=d.root.Size;root.Transparency=d.root.Transparency;root.CanCollide=d.root.CanCollide;root.Material=d.root.Material;root.Color=d.root.Color end
    HitboxOrig[char]=nil
end
local function refreshHitbox() if not State.HitboxEnabled then return end for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then applyHitbox(p.Character) end end end
local function setHitboxEnabled(enabled)
    State.HitboxEnabled=enabled
    if hitboxConn then hitboxConn:Disconnect();hitboxConn=nil end
    if not enabled then for char,_ in pairs(HitboxOrig) do resetHitbox(char) end return end
    refreshHitbox()
    hitboxConn=RunService.RenderStepped:Connect(function() if not State.HitboxEnabled then return end for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then applyHitbox(p.Character) end end end)
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
        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;hl.Parent=char;d.highlight=hl
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
                corner(fill,2);d.barFill=fill
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
                    d.barFill.BackgroundColor3=pct>0.6 and C.Green or (pct>0.3 and Color3.fromRGB(200,150,255) or C.Red)
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
local Freecam={Speed=2,Sensitivity=0.01,Enabled=false,Rig=nil,Loop=nil,Yaw=0,Pitch=0,MoveInput=Vector2.zero,Connections={},Touch={Move=nil,Look=nil,MoveStart=nil},_InputInited=false}
local function InitFreecamInput()
    if Freecam._InputInited then return end Freecam._InputInited=true
    local UIS=UserInputService
    table.insert(Freecam.Connections,UIS.TouchStarted:Connect(function(t)
        if not Freecam.Enabled then return end
        if t.Position.X<CAM.ViewportSize.X/2 then
            if not Freecam.Touch.Move then Freecam.Touch.Move=t;Freecam.Touch.MoveStart=t.Position;Freecam.MoveInput=Vector2.zero end
        else if not Freecam.Touch.Look then Freecam.Touch.Look=t end end
    end))
    table.insert(Freecam.Connections,UIS.TouchMoved:Connect(function(t)
        if not Freecam.Enabled then return end
        if t==Freecam.Touch.Move and Freecam.Touch.MoveStart then
            local d=t.Position-Freecam.Touch.MoveStart
            Freecam.MoveInput=Vector2.new(math.clamp(d.X/80,-1,1),math.clamp(-d.Y/80,-1,1))
        elseif t==Freecam.Touch.Look then
            local d=t.Delta
            Freecam.Yaw-=d.X*Freecam.Sensitivity
            Freecam.Pitch=math.clamp(Freecam.Pitch-d.Y*Freecam.Sensitivity,math.rad(-85),math.rad(85))
        end
    end))
    table.insert(Freecam.Connections,UIS.TouchEnded:Connect(function(t)
        if t==Freecam.Touch.Move then Freecam.Touch.Move=nil;Freecam.Touch.MoveStart=nil;Freecam.MoveInput=Vector2.zero end
        if t==Freecam.Touch.Look then Freecam.Touch.Look=nil end
    end))
end
local function StartFreecam()
    if Freecam.Enabled then return end Freecam.Enabled=true;InitFreecamInput()
    local char=LP.Character;if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart");local hum=char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    if not Freecam.Rig then Freecam.Rig=Instance.new("Part");Freecam.Rig.Anchored=true;Freecam.Rig.CanCollide=false;Freecam.Rig.Transparency=1;Freecam.Rig.Size=Vector3.new(1,1,1);Freecam.Rig.Parent=workspace end
    Freecam.Rig.CFrame=CAM.CFrame;root.Anchored=true;hum.AutoRotate=false;hum.PlatformStand=true
    CAM.CameraType=Enum.CameraType.Scriptable
    local x,y=CAM.CFrame:ToEulerAnglesYXZ();Freecam.Yaw=y;Freecam.Pitch=x
    Freecam.Loop=RunService.RenderStepped:Connect(function()
        local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if r then r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero end
        local rotCF=CFrame.Angles(0,Freecam.Yaw,0)*CFrame.Angles(Freecam.Pitch,0,0)
        local cf=CFrame.new(Freecam.Rig.Position)*rotCF
        local move=(cf.RightVector*Freecam.MoveInput.X)+(cf.LookVector*Freecam.MoveInput.Y)
        Freecam.Rig.CFrame=CFrame.new(Freecam.Rig.Position+move*Freecam.Speed)*rotCF
        CAM.CFrame=Freecam.Rig.CFrame
    end)
end
local function StopFreecam()
    if not Freecam.Enabled then return end Freecam.Enabled=false
    if Freecam.Loop then Freecam.Loop:Disconnect();Freecam.Loop=nil end
    for _,c in pairs(Freecam.Connections) do pcall(function() c:Disconnect() end) end
    Freecam.Connections={};Freecam._InputInited=false;Freecam.MoveInput=Vector2.zero;Freecam.Touch.Move=nil;Freecam.Touch.Look=nil
    local char=LP.Character
    if char then local r=char:FindFirstChild("HumanoidRootPart");local h=char:FindFirstChildOfClass("Humanoid")
        if r then r.Anchored=false end
        if h then h.AutoRotate=true;h.PlatformStand=false end
    end
    if Freecam.Rig then Freecam.Rig:Destroy();Freecam.Rig=nil end
    CAM.CameraType=Enum.CameraType.Custom
end
local AntiFallEnabled=false;local AntiFallConn=nil
local function StartAntiFall(ch)
    if AntiFallConn then AntiFallConn:Disconnect();AntiFallConn=nil end
    local root=ch:WaitForChild("HumanoidRootPart")
    AntiFallConn=RunService.Heartbeat:Connect(function()
        if not AntiFallEnabled or not root or not root.Parent then return end
        local v=root.AssemblyLinearVelocity;root.AssemblyLinearVelocity=Vector3.zero
        RunService.RenderStepped:Wait();root.AssemblyLinearVelocity=v
    end)
end
local function ToggleAntiFall(s)
    AntiFallEnabled=s
    if s then if LP.Character then StartAntiFall(LP.Character) end;notify("防摔落伤害","已开启")
    else if AntiFallConn then AntiFallConn:Disconnect();AntiFallConn=nil end;notify("防摔落伤害","已关闭") end
end
LP.CharacterAdded:Connect(function(c) if AntiFallEnabled then StartAntiFall(c) end end)
local InteractESP={Enabled=false,Color=Color3.fromRGB(0,255,0),Highlights={},Conn=nil}
local function IsInteractive_Old(o) return o and (o:IsA("ProximityPrompt") or o:IsA("ClickDetector")) end
local function FindAdornPart_Old(t)
    if not t then return nil end
    if t:IsA("BasePart") then return t end
    if t:IsA("Model") then if t.PrimaryPart then return t.PrimaryPart end for _,c in pairs(t:GetChildren()) do if c:IsA("BasePart") then return c end end end
    return nil
end
local function AddInteractESP(target)
    if not target or InteractESP.Highlights[target] then return end
    if not (target:IsA("BasePart") or target:IsA("Model")) then return end
    local ok,hl=pcall(function()
        local h=Instance.new("Highlight");h.Name="InteractESP";h.Adornee=target
        h.FillColor=InteractESP.Color;h.OutlineColor=Color3.fromRGB(255,255,255)
        h.FillTransparency=0.5;h.OutlineTransparency=0;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=target
        return h
    end)
    if not ok or not hl then return end
    InteractESP.Highlights[target]=hl
    local part=FindAdornPart_Old(target)
    if part and not part:FindFirstChild("InteractLabel") then
        local prompt=target:FindFirstChildWhichIsA("ProximityPrompt") or (target.Parent and target.Parent:FindFirstChildWhichIsA("ProximityPrompt"))
        local txt=(prompt and (prompt.ActionText~="" and prompt.ActionText)) or "可互动"
        local bb=Instance.new("BillboardGui");bb.Name="InteractLabel";bb.Adornee=part
        bb.Size=UDim2.new(0,120,0,30);bb.StudsOffset=Vector3.new(0,3,0);bb.AlwaysOnTop=true;bb.Parent=part
        local lb=Instance.new("TextLabel");lb.Size=UDim2.new(1,0,1,0);lb.BackgroundTransparency=1
        lb.Text=txt;lb.TextColor3=InteractESP.Color;lb.TextStrokeTransparency=0.5;lb.TextStrokeColor3=Color3.new(0,0,0)
        lb.Font=Enum.Font.SourceSansBold;lb.TextSize=14;lb.Parent=bb
    end
    pcall(function()
        target.AncestryChanged:Connect(function(_,p)
            if not p and InteractESP.Highlights[target] then pcall(function() InteractESP.Highlights[target]:Destroy() end);InteractESP.Highlights[target]=nil end
        end)
    end)
end
local function RemoveInteractESP(t)
    if not t then return end
    if InteractESP.Highlights[t] then pcall(function() if InteractESP.Highlights[t].Parent then InteractESP.Highlights[t]:Destroy() end end);InteractESP.Highlights[t]=nil end
    pcall(function() for _,v in pairs(t:GetDescendants()) do if v:IsA("BillboardGui") and v.Name=="InteractLabel" then pcall(function() v:Destroy() end) end end end)
end
local function ToggleInteractESP(s)
    InteractESP.Enabled=s
    if s then
        task.spawn(function() for _,o in ipairs(workspace:GetDescendants()) do if IsInteractive_Old(o) and o.Parent then pcall(function() AddInteractESP(o.Parent) end) end end end)
        if not InteractESP.Conn then
            InteractESP.Conn=workspace.DescendantAdded:Connect(function(c)
                task.delay(1,function()
                    if c and IsInteractive_Old(c) and c.Parent then AddInteractESP(c.Parent)
                    elseif c and c:IsA("BasePart") and c.Parent then for _,d in pairs(c:GetDescendants()) do if IsInteractive_Old(d) and d.Parent then AddInteractESP(d.Parent) end end end
                end)
            end)
        end
    else
        local rm={} for t,_ in pairs(InteractESP.Highlights) do table.insert(rm,t) end
        for _,t in ipairs(rm) do RemoveInteractESP(t) end
        if InteractESP.Conn then pcall(function() InteractESP.Conn:Disconnect() end);InteractESP.Conn=nil end
    end
end
local ESP_SETTINGS={HighlightEnabled=false,TeamCheck=false,SmoothAim=false,WallCheck=false}
local AimbotTeamWhitelist={};local AimbotTeamWhitelistEnabled=false
local FOV=120;local Smoothness=0.18;local AimPart="Head";local ShowFOVCircle=true
local AimPartsList={"Head","HumanoidRootPart","UpperTorso","Torso"}
local MaxDistance=1000;local SelectedTarget=nil;local LockTargetEnabled=false
local CurrentTarget=nil;local LastSwitchTime=0;local SWITCH_DELAY=0.25;local SWITCH_THRESHOLD=0.7
local VisibilityCache={}
local function GetAimPart(ch)
    if not ch then return nil end
    local p=ch:FindFirstChild(AimPart)
    return p or ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
end
local FOVGui=new("ScreenGui",{Name="FOVCircle_UI",IgnoreGuiInset=true,ResetOnSpawn=false,Parent=PG})
local circle=new("Frame",{Name="FOVCircle",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,240,0,240),BackgroundTransparency=1,Visible=false,Parent=FOVGui})
new("UIStroke",{Thickness=2,Color=Color3.fromRGB(128,0,128),Parent=circle});corner(circle,999)
local function isVisible(p,part)
    if not CAM then return false end
    if not ESP_SETTINGS.WallCheck then return true end
    local origin=CAM.CFrame.Position
    local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Blacklist;rp.IgnoreWater=true
    local ig={LP.Character,CAM}
    local tool=LP.Character and LP.Character:FindFirstChildOfClass("Tool");if tool then table.insert(ig,tool) end
    rp.FilterDescendantsInstances=ig
    local offs={Vector3.new(0,0,0),Vector3.new(0.25,0,0),Vector3.new(-0.25,0,0),Vector3.new(0,0.25,0),Vector3.new(0,-0.25,0)}
    local vc=0
    for _,o in ipairs(offs) do
        local tp=part.Position+o;local dir=tp-origin;local co,rem=origin,dir;local hitCh=false
        for i=1,3 do
            local r=workspace:Raycast(co,rem,rp)
            if not r then hitCh=true;break end
            local h=r.Instance
            if h and h:IsDescendantOf(p.Character) then hitCh=true;break end
            if h and (h.Transparency>0.4 or h.CanCollide==false or h.Material==Enum.Material.Glass or h.Name:lower():find("scope") or h.Name:lower():find("view")) then
                co=r.Position+(rem.Unit*0.1);rem=(part.Position-co)
            else break end
        end
        if hitCh then vc+=1 end
    end
    local nv=vc>=2;local last=VisibilityCache[p]
    if last==nil then VisibilityCache[p]=nv;return nv end
    if nv~=last then VisibilityCache[p]=last;task.delay(0.03,function() VisibilityCache[p]=nv end);return last end
    VisibilityCache[p]=nv;return nv
end
local function isAlive(p) local c=p.Character;local h=c and c:FindFirstChild("Humanoid");return h and h.Health>0 end
local function shouldForceSwitch(t)
    if not t then return true end
    if not isAlive(t) then return true end
    local ch=t.Character;local part=ch and GetAimPart(ch)
    if not part then return true end
    if not isVisible(t,part) then return true end
    local pos,vis=CAM:WorldToViewportPoint(part.Position)
    if not vis then return true end
    local ctr=CAM.ViewportSize/2
    return (Vector2.new(pos.X,pos.Y)-ctr).Magnitude>FOV
end
local function getTarget()
    local now=tick();local ctr=CAM.ViewportSize/2;local bt,bd=nil,math.huge;local cands={}
    if LockTargetEnabled and SelectedTarget then table.insert(cands,SelectedTarget)
    else for _,p in ipairs(Players:GetPlayers()) do if p~=LP then table.insert(cands,p) end end end
    for _,p in ipairs(cands) do
        if p and isAlive(p) then
            if not LockTargetEnabled then
                if AimbotTeamWhitelistEnabled and next(AimbotTeamWhitelist)~=nil then
                    if not p.Team or not AimbotTeamWhitelist[p.Team.Name] then continue end
                elseif ESP_SETTINGS.TeamCheck then if p.Team==LP.Team then continue end end
            end
            local ch=p.Character;local part=ch and GetAimPart(ch)
            if part then
                local cp=CAM.CFrame.Position
                if (part.Position-cp).Magnitude>MaxDistance then continue end
                if not isVisible(p,part) then continue end
                local pos,vis=CAM:WorldToViewportPoint(part.Position)
                if not vis then continue end
                local d2=(Vector2.new(pos.X,pos.Y)-ctr).Magnitude
                if d2<=FOV and d2<bd then bd=d2;bt=p end
            end
        end
    end
    if shouldForceSwitch(CurrentTarget) then CurrentTarget=bt;LastSwitchTime=now;return bt end
    if bt then
        if now-LastSwitchTime<SWITCH_DELAY then return CurrentTarget end
        if CurrentTarget and CurrentTarget~=bt then
            local ch=CurrentTarget.Character;local part=ch and GetAimPart(ch)
            if part then
                local pos,vis=CAM:WorldToViewportPoint(part.Position)
                if vis and bd>(Vector2.new(pos.X,pos.Y)-ctr).Magnitude*SWITCH_THRESHOLD then return CurrentTarget end
            end
        end
        CurrentTarget=bt;LastSwitchTime=now;return bt
    end
    return nil
end
RunService.RenderStepped:Connect(function()
    if circle then
        local sz=FOV*2;circle.Size=UDim2.new(0,sz,0,sz)
        local sh=ESP_SETTINGS.HighlightEnabled and ShowFOVCircle
        if circle.Visible~=sh then circle.Visible=sh end
    end
    if not CAM or not ESP_SETTINGS.HighlightEnabled then return end
    local t=getTarget()
    if t and t.Character then
        local part=GetAimPart(t.Character)
        if part then
            local cp=CAM.CFrame.Position;local dir=(part.Position-cp).Unit;local ncf=CFrame.new(cp,cp+dir)
            if ESP_SETTINGS.SmoothAim then CAM.CFrame=CAM.CFrame:Lerp(ncf,Smoothness) else CAM.CFrame=ncf end
        end
    end
end)
local FlingLoop=false;local Flinging=false;local AlreadyNotified={}
local TP_Loop=false;local TP_LoopConn=nil;local TP_SelectedPlayer=nil
local function TeleportToPlayer(t)
    if not t then return end
    local ch=LP.Character;local tc=t.Character
    if not ch or not tc then return end
    local r=ch:FindFirstChild("HumanoidRootPart");local tr=tc:FindFirstChild("HumanoidRootPart")
    if r and tr then r.CFrame=tr.CFrame*CFrame.new(0,4,0) end
end
local function SpectatePlayer(t)
    if not t then return end
    local cam=workspace.CurrentCamera;if not cam then return end
    local ch=t.Character;if not ch then return end
    local h=ch:FindFirstChildOfClass("Humanoid");if not h then return end
    cam.CameraSubject=h;cam.CameraType=Enum.CameraType.Custom
end
local function StopSpectateTP()
    local cam=workspace.CurrentCamera;if not cam then return end
    local ch=LP.Character;if not ch then return end
    local h=ch:FindFirstChildOfClass("Humanoid");if h then cam.CameraSubject=h end
end
local function SkidFling(TP)
    if not TP or TP==LP or Flinging then return end
    Flinging=true
    local Ch=LP.Character;local H=Ch and Ch:FindFirstChildOfClass("Humanoid");local R=H and H.RootPart
    local TC=TP.Character
    if not (Ch and H and R and TC) then Flinging=false;return end
    local TH=TC:FindFirstChildOfClass("Humanoid");local TR=TH and TH.RootPart
    local THead=TC:FindFirstChild("Head");local Acc=TC:FindFirstChildOfClass("Accessory");local HD=Acc and Acc:FindFirstChild("Handle")
    local Cam=workspace.CurrentCamera
    local Dead=false;local DC
    DC=LP.CharacterAdded:Connect(function() Dead=true;if DC then DC:Disconnect();DC=nil end end)
    if R.Velocity.Magnitude<50 then getgenv().OldPos=R.CFrame end
    if Cam then
        if THead then Cam.CameraSubject=THead elseif HD then Cam.CameraSubject=HD elseif TH then Cam.CameraSubject=TH end
    end
    local function FPos(bp,pos,ang)
        if Dead or not bp or not bp.Parent or not R or not R.Parent then return end
        R.CFrame=CFrame.new(bp.Position)*pos*ang
        Ch:SetPrimaryPartCFrame(CFrame.new(bp.Position)*pos*ang)
        R.Velocity=Vector3.new(9e7,9e7*10,9e7);R.RotVelocity=Vector3.new(9e8,9e8,9e8)
    end
    local function SFBP(bp)
        local T=tick();local Ang=0
        repeat
            if Dead or not bp or not bp.Parent or not R or not R.Parent or not TR or not TR.Parent or not TH or TH.Health<=0 then break end
            if bp.Velocity.Magnitude>1 then
                Ang=Ang+100
                FPos(bp,CFrame.new(0,1.5,0)+TH.MoveDirection*bp.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Ang),0,0));task.wait()
                FPos(bp,CFrame.new(0,-1.5,0)+TH.MoveDirection*bp.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Ang),0,0));task.wait()
                FPos(bp,CFrame.new(2.25,1.5,-2.25)+TH.MoveDirection*bp.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Ang),0,0));task.wait()
                FPos(bp,CFrame.new(-2.25,-1.5,2.25)+TH.MoveDirection*bp.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Ang),0,0));task.wait()
                FPos(bp,CFrame.new(0,1.5,0)+TH.MoveDirection,CFrame.Angles(math.rad(Ang),0,0));task.wait()
                FPos(bp,CFrame.new(0,-1.5,0)+TH.MoveDirection,CFrame.Angles(math.rad(Ang),0,0));task.wait()
            else
                FPos(bp,CFrame.new(0,1.5,TH.WalkSpeed),CFrame.Angles(math.rad(90),0,0));task.wait()
                FPos(bp,CFrame.new(0,-1.5,-TH.WalkSpeed),CFrame.Angles(0,0,0));task.wait()
                FPos(bp,CFrame.new(0,1.5,TH.WalkSpeed),CFrame.Angles(math.rad(90),0,0));task.wait()
                FPos(bp,CFrame.new(0,1.5,TR.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0));task.wait()
                FPos(bp,CFrame.new(0,-1.5,-TR.Velocity.Magnitude/1.25),CFrame.Angles(0,0,0));task.wait()
                FPos(bp,CFrame.new(0,1.5,TR.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0));task.wait()
                FPos(bp,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(90),0,0));task.wait()
                FPos(bp,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0));task.wait()
                FPos(bp,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(-90),0,0));task.wait()
                FPos(bp,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0));task.wait()
            end
        until bp.Velocity.Magnitude>500 or not bp.Parent or Dead or tick()>T+2
    end
    local BV=Instance.new("BodyVelocity");BV.Parent=R;BV.Velocity=Vector3.new(9e8,9e8,9e8);BV.MaxForce=Vector3.new(1/0,1/0,1/0)
    H:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
    if not Dead then if TR then SFBP(TR) elseif THead then SFBP(THead) elseif HD then SFBP(HD) end end
    BV:Destroy();H:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
    if Cam then local nc=LP.Character;local nh=nc and nc:FindFirstChildOfClass("Humanoid");if nh then Cam.CameraSubject=nh end end
    if not Dead and getgenv().OldPos then
        local nc=LP.Character;local nr=nc and nc:FindFirstChild("HumanoidRootPart");local nh=nc and nc:FindFirstChildOfClass("Humanoid")
        if nr and nh then
            repeat
                nr.CFrame=getgenv().OldPos*CFrame.new(0,.5,0);nc:SetPrimaryPartCFrame(getgenv().OldPos*CFrame.new(0,.5,0));nh:ChangeState("GettingUp")
                for _,x in ipairs(nc:GetChildren()) do if x:IsA("BasePart") then x.Velocity=Vector3.zero;x.RotVelocity=Vector3.zero end end
                task.wait()
            until (nr.Position-getgenv().OldPos.Position).Magnitude<25
        end
    end
    if DC then DC:Disconnect();DC=nil end
    Flinging=false
end
local function MonitorTarget(t)
    if not t or not (TP_Loop or FlingLoop or Flinging) then return end
    if not AlreadyNotified[t] then AlreadyNotified[t]={dead=false,left=false} end
    local st=AlreadyNotified[t]
    task.spawn(function()
        while true do
            if not (TP_Loop or FlingLoop or Flinging) then break end
            if not t or not t.Parent then if not st.left then st.left=true;notify("目标失效","玩家已退出，操作已终止") end break end
            local ch=t.Character;local h=ch and ch:FindFirstChildOfClass("Humanoid")
            if not ch or not h or h.Health<=0 then
                if not st.dead then st.dead=true;notify("目标失效",t.Name.." 已死亡或消失") end
                repeat task.wait(0.5);ch=t.Character;h=ch and ch:FindFirstChildOfClass("Humanoid") until h and h.Health>0 or not t.Parent
                if h and h.Health>0 then st.dead=false end
            end
            task.wait(0.5)
        end
    end)
end
local function StartFlingLoop(t)
    if FlingLoop then return end FlingLoop=true;AlreadyNotified={}
    task.spawn(function()
        while FlingLoop do
            local sc=LP.Character;local sh=sc and sc:FindFirstChildOfClass("Humanoid")
            if not sc or not sh or sh.Health<=0 then task.wait(0.5);continue end
            if t then
                if not AlreadyNotified[t] then MonitorTarget(t) end
                local t1=tick();repeat task.wait() until not Flinging or tick()-t1>3
                SkidFling(t)
                local t2=tick();repeat task.wait() until not Flinging or tick()-t2>3
            end
            task.wait(0.2)
        end
    end)
end
local function StopFlingLoop() FlingLoop=false end
local SpinEnabled=false;local SpinSpeed=5;local SpinConn=nil;local AnimLockThread=nil
local function ApplyAnimLock(ch)
    if not ch then return end
    local h=ch:FindFirstChildOfClass("Humanoid");if h then h.AutoRotate=false end
    if AnimLockThread then task.cancel(AnimLockThread);AnimLockThread=nil end
    AnimLockThread=task.spawn(function()
        local a=ch:WaitForChild("Animate",3)
        while SpinEnabled and a and a.Parent do a.Disabled=true;task.wait(0.2) end
    end)
end
local function RemoveAnimLock(ch)
    if not ch then return end
    local h=ch:FindFirstChildOfClass("Humanoid");if h then h.AutoRotate=true end
    if AnimLockThread then task.cancel(AnimLockThread);AnimLockThread=nil end
    local a=ch:FindFirstChild("Animate");if a then a.Disabled=false end
end
local function StartSpin()
    if SpinConn then return end
    SpinConn=RunService.RenderStepped:Connect(function(dt)
        if not SpinEnabled then return end
        local ch=LP.Character;if not ch then return end
        local hrp=ch:FindFirstChild("HumanoidRootPart");if not hrp then return end
        hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(SpinSpeed)*dt*60,0)
    end)
    ApplyAnimLock(LP.Character)
end
local function StopSpin()
    SpinEnabled=false
    if SpinConn then SpinConn:Disconnect();SpinConn=nil end
    RemoveAnimLock(LP.Character)
end
LP.CharacterAdded:Connect(function(c) if SpinEnabled then task.wait(0.5);ApplyAnimLock(c);if not SpinConn then StartSpin() end end end)
local function closeAllFeatures()
    setNoclip(false);setInfiniteJump(false);setInstantInteract(false);setPromptESP(false)
    setRemoveFog(false);setNightVision(false);setHitboxEnabled(false)
    State.ESPHighlightEnabled=false;State.ESPNameEnabled=false;State.ESPHealthEnabled=false
    State.SpeedEnabled=false;State.JumpEnabled=false
    stopSpectate();stopFollow()
    StopFreecam();ToggleAntiFall(false);ToggleInteractESP(false)
    ESP_SETTINGS.HighlightEnabled=false
    StopFlingLoop();StopSpin();TP_Loop=false
    if TP_LoopConn then TP_LoopConn:Disconnect();TP_LoopConn=nil end
    local _,h=getChar();if h then h.WalkSpeed=baseSpeed;h.UseJumpPower=true;h.JumpPower=BASE_JUMP end
    clearAllESP()
end
local function onPlayerAdded(player)
    if player==LP then return end
    if State.ESPHighlightEnabled or State.ESPNameEnabled or State.ESPHealthEnabled then task.spawn(function() if player.Character then createPlayerESP(player) end end) end
    if State.HitboxEnabled then task.spawn(function() if player.Character then applyHitbox(player.Character) end end) end
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
    if h then baseSpeed=h.WalkSpeed;lastSetSpeed=baseSpeed;updateBaseSpeedLbl();h.UseJumpPower=true;h.JumpPower=State.JumpEnabled and State.CustomJump or BASE_JUMP end
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
    local scene=new("Frame",{Size=UD.fromScale(1,1),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=1,Parent=gui})
    local deepBg=new("Frame",{Size=UD.fromScale(1,1),BackgroundColor3=Color3.fromRGB(10,3,22),BorderSizePixel=0,ZIndex=1,Parent=scene})
    local deepG=grad(deepBg,Color3.fromRGB(18,6,40),Color3.fromRGB(2,0,8),90)
    deepG.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.35)})
    local galaxyRoot=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromScale(2.1,.65),BackgroundTransparency=1,BorderSizePixel=0,Rotation=-22,ZIndex=2,Parent=scene})
    local band1=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromScale(1,1),BackgroundColor3=Color3.fromRGB(90,40,180),BackgroundTransparency=0.8,BorderSizePixel=0,Parent=galaxyRoot})
    corner(band1,400)
    local band2=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromScale(.82,.5),BackgroundColor3=Color3.fromRGB(150,90,240),BackgroundTransparency=0.72,BorderSizePixel=0,Parent=galaxyRoot})
    corner(band2,400)
    local band3=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromScale(.58,.24),BackgroundColor3=Color3.fromRGB(220,190,255),BackgroundTransparency=0.7,BorderSizePixel=0,Parent=galaxyRoot})
    corner(band3,400)
    local stars={}
    for i=1,90 do
        local sz=math.random(1,3)
        local cval=math.random(180,255)
        local s=new("Frame",{Position=UD.fromOffset(math.random(0,2000),math.random(0,1200)),Size=UD.fromOffset(sz,sz),BackgroundColor3=Color3.fromRGB(cval,cval-15,255),BackgroundTransparency=math.random(20,75)/100,BorderSizePixel=0,ZIndex=3,Parent=scene})
        corner(s,sz)
        table.insert(stars,{inst=s,phase=math.random()*math.pi*2,speed=math.random(10,40)/10,baseAlpha=s.BackgroundTransparency,driftY=math.random(2,7)/10})
    end
    local planets={}
    local function addPlanet(x,y,sz,c1,c2,rotSpd,floatAmp,floatSpd)
        local p=new("Frame",{Position=UD.fromOffset(x,y),Size=UD.fromOffset(sz,sz),BackgroundColor3=c1,BorderSizePixel=0,ZIndex=3,Parent=scene})
        corner(p,sz)
        local pg=grad(p,c1,c2,45)
        stroke(p,c2,1.2,0.35)
        local moonSz=math.max(4,math.floor(sz*0.14))
        local moon=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(moonSz,moonSz),BackgroundColor3=Color3.fromRGB(230,220,255),BorderSizePixel=0,ZIndex=4,Parent=p})
        corner(moon,moonSz)
        table.insert(planets,{inst=p,grad=pg,moon=moon,baseX=x,baseY=y,floatAmp=floatAmp,floatSpd=floatSpd,rot=0,rotSpd=rotSpd,phase=math.random()*math.pi*2})
    end
    addPlanet(60,100,90,Color3.fromRGB(120,60,200),Color3.fromRGB(40,15,80),10,7,0.6)
    addPlanet(1050,530,140,Color3.fromRGB(180,80,220),Color3.fromRGB(60,20,100),-6,12,0.42)
    addPlanet(880,80,50,Color3.fromRGB(150,120,255),Color3.fromRGB(60,40,140),14,5,0.85)
    local vstars={}
    local function addVStar(x,y,sz)
        local wrap=new("Frame",{Position=UD.fromOffset(x,y),Size=UD.fromOffset(sz,sz),BackgroundTransparency=1,ZIndex=4,Parent=scene})
        local glow=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(sz*3,sz*3),BackgroundColor3=Color3.fromRGB(180,120,255),BackgroundTransparency=0.85,BorderSizePixel=0,Parent=wrap})
        corner(glow,sz*3)
        local h1=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(sz*6,1),BackgroundColor3=Color3.fromRGB(230,210,255),BackgroundTransparency=0.4,BorderSizePixel=0,Parent=wrap})
        corner(h1,1)
        local h2=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(1,sz*6),BackgroundColor3=Color3.fromRGB(230,210,255),BackgroundTransparency=0.4,BorderSizePixel=0,Parent=wrap})
        corner(h2,1)
        local core=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(sz,sz),BackgroundColor3=Color3.fromRGB(255,235,255),BorderSizePixel=0,Parent=wrap})
        corner(core,sz)
        table.insert(vstars,{inst=wrap,core=core,glow=glow,h1=h1,h2=h2,phase=math.random()*math.pi*2,speed=math.random(15,45)/10,baseSize=sz})
    end
    addVStar(240,190,4);addVStar(1380,320,5);addVStar(680,520,3);addVStar(1620,700,4)
    addVStar(320,820,3);addVStar(1020,140,3);addVStar(1500,180,2);addVStar(500,650,2)
    local animConn=RunService.RenderStepped:Connect(function(dt)
        if not gui or not gui.Parent then if animConn then animConn:Disconnect();animConn=nil end return end
        local t=os.clock()
        for _,s in ipairs(stars) do
            local inst=s.inst
            if inst and inst.Parent then
                local pulse=(math.sin(t*s.speed+s.phase)+1)*0.5
                inst.BackgroundTransparency=s.baseAlpha+(1-s.baseAlpha)*(1-pulse)*0.45
                local pos=inst.Position
                local ny=pos.Y.Offset-s.driftY*dt*40
                if ny<-20 then ny=1220 end
                inst.Position=UD.new(pos.X.Scale,pos.X.Offset,pos.Y.Scale,ny)
            end
        end
        for _,p in ipairs(planets) do
            local inst=p.inst
            if inst and inst.Parent then
                p.phase=p.phase+dt*p.floatSpd
                local fy=math.sin(p.phase)*p.floatAmp
                local fx=math.cos(p.phase*0.7)*p.floatAmp*0.6
                inst.Position=UD.new(0,p.baseX+fx,0,p.baseY+fy)
                p.rot=p.rot+dt*p.rotSpd
                p.grad.Rotation=p.rot
                if p.moon and p.moon.Parent then
                    local ang=t*p.rotSpd*math.pi/180
                    p.moon.Position=UD.new(0.5+math.cos(ang)*0.62,0,0.5+math.sin(ang)*0.62,0)
                end
            end
        end
        for _,v in ipairs(vstars) do
            local inst=v.inst
            if inst and inst.Parent then
                local pulse=(math.sin(t*v.speed+v.phase)+1)*0.5
                local sc=0.75+pulse*0.55
                if v.core and v.core.Parent then v.core.Size=UD.fromOffset(v.baseSize*sc,v.baseSize*sc) end
                if v.glow and v.glow.Parent then v.glow.Size=UD.fromOffset(v.baseSize*sc*3.4,v.baseSize*sc*3.4);v.glow.BackgroundTransparency=0.75+pulse*0.15 end
                if v.h1 and v.h1.Parent then v.h1.BackgroundTransparency=0.3+pulse*0.4;v.h1.Size=UD.fromOffset(v.baseSize*sc*7,1) end
                if v.h2 and v.h2.Parent then v.h2.BackgroundTransparency=0.3+pulse*0.4;v.h2.Size=UD.fromOffset(1,v.baseSize*sc*7) end
            end
        end
    end)
    local mask=new("Frame",{Size=UD.fromScale(1,1),BackgroundColor3=C.Void,BackgroundTransparency=0,BorderSizePixel=0,ZIndex=50,Parent=gui})
    local splash=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(260,130),BackgroundColor3=C.Bg,BorderSizePixel=0,Visible=false,ZIndex=100,Parent=gui})
    corner(splash,6);stroke(splash,C.Cyan,1,0.4);techCorners(splash,C.Cyan,12,2,0.1)
    local splashScale=new("UIScale",{Scale=0.8,Parent=splash})
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
    local root=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(340,140),BackgroundColor3=C.Bg,BorderSizePixel=0,Visible=false,ZIndex=101,Parent=gui})
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
    local okCard=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(320,110),BackgroundColor3=C.Bg,BorderSizePixel=0,Visible=false,ZIndex=101,Parent=gui})
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
        scale.Scale=0.82;tw(scale,0.55,{Scale=1},Enum.EasingStyle.Back);task.wait(0.14)
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
        tw(scale,0.32,{Scale=0.9},Enum.EasingStyle.Back);task.wait(0.34);root.Visible=false
    end
    task.wait(0.1)
    local aS=makeAlpha(splash)
    splash.Visible=true;splashScale.Scale=0.78;aS.set(1)
    tw(splashScale,0.7,{Scale=1},Enum.EasingStyle.Back)
    aS.tweenTo(0,0.7)
    task.wait(0.95)
    tw(mask,1.8,{BackgroundTransparency=0.35},Enum.EasingStyle.Quart)
    local a=0
    local sC=RunService.RenderStepped:Connect(function(dt) a=a+dt*90;oRing.Rotation=a;mRing.Rotation=-a*0.7 end)
    local t0=os.clock()
    local bC=RunService.RenderStepped:Connect(function()
        local t=math.clamp((os.clock()-t0)/1.8,0,1);sFill.Size=UD.new(1-(1-t)^2,0,1,0)
    end)
    task.wait(1.9);bC:Disconnect();sC:Disconnect()
    aS.tweenTo(1,0.42);task.wait(0.45);splash.Visible=false;splash:Destroy()
    task.wait(0.4)
    runLoader("正在注入脚本核心...","INJECT  CORE",C.Cyan,1.6)
    task.wait(0.12)
    runLoader("正在加载功能模块...","LOAD  FEATURES",C.Purple,1.4)
    task.wait(0.12)
    local aO=makeAlpha(okCard)
    okCard.Visible=true;okScale.Scale=0.8;aO.set(1)
    tw(okScale,0.6,{Scale=1},Enum.EasingStyle.Back);aO.tweenTo(0,0.6)
    local pC=RunService.RenderStepped:Connect(function(dt) pulseOuter.Rotation=pulseOuter.Rotation+dt*200 end)
    task.wait(1.6);pC:Disconnect()
    aO.tweenTo(1,0.35);task.wait(0.37)
    okCard.Visible=false;okCard:Destroy();root:Destroy()
    tw(mask,0.8,{BackgroundTransparency=1},Enum.EasingStyle.Quart)
    tw(scene,0.8,{BackgroundTransparency=1},Enum.EasingStyle.Quart)
    task.wait(0.82)
    if animConn then animConn:Disconnect();animConn=nil end
    gui:Destroy()
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
    local tabs={"主要","通用","视觉","剥削","碰撞","自瞄"}
    local tabCount=#tabs
    local tabBar=new("Frame",{Position=UD.new(0,0,0,32),Size=UD.new(1,0,0,26),BackgroundColor3=C.Panel,BackgroundTransparency=0.35,BorderSizePixel=0,Parent=main})
    new("Frame",{Position=UD.new(0,0,0,25),Size=UD.new(1,0,0,1),BackgroundColor3=C.Line,BackgroundTransparency=0.4,BorderSizePixel=0,Parent=tabBar})
    local tabBtns={}
    local tabHighlight=new("Frame",{Position=UD.fromOffset(0,23),Size=UD.new(1/tabCount,0,0,2),BackgroundColor3=C.Cyan,BorderSizePixel=0,Parent=tabBar})
    grad(tabHighlight,C.Cyan,C.Purple,0)
    for i,name in ipairs(tabs) do tabBtns[i]=new("TextButton",{Position=UD.new((i-1)/tabCount,0,0,0),Size=UD.new(1/tabCount,0,1,0),BackgroundTransparency=1,Text=name,TextColor3=(i==1) and C.Text or C.Dim,Font=Enum.Font.GothamBold,TextSize=10,AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Center,Parent=tabBar}) end
    local content=new("Frame",{Position=UD.new(0,0,0,58),Size=UD.new(1,0,1,-84),BackgroundTransparency=1,ClipsDescendants=true,Parent=main})
    local pages={}
    local pageCanvas={300,400,420,620,190,560}
    for i=1,tabCount do
        pages[i]=new("ScrollingFrame",{Position=UD.new(0,0,0,0),Size=UD.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.Cyan,CanvasSize=UD.new(0,0,0,pageCanvas[i] or 300),ScrollingDirection=Enum.ScrollingDirection.Y,Visible=(i==1),Parent=content})
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
            tw(knob,0.28,{Position=on and UD.new(0,16,.5,0) or UD.new(0,2,.5,0),BackgroundColor3=on and accent or C.Dim},Enum.EasingStyle.Back)
            ts.Color=on and accent or C.Line;ts.Transparency=on and 0.2 or 0.6
            tw(bar,0.22,{BackgroundColor3=on and accent or C.Line})
            dl.TextColor3=on and accent or C.Dim
            tw(row,0.22,{BackgroundTransparency=on and 0.3 or 0.15})
            if cb then cb(on) end
        end
        if on then knob.Position=UD.new(0,16,.5,0);knob.BackgroundColor3=accent;ts.Color=accent;ts.Transparency=0.2;bar.BackgroundColor3=accent;dl.TextColor3=accent;row.BackgroundTransparency=0.3 end
        hit.Activated:Connect(function()
            tw(knob,0.08,{Size=UD.fromOffset(15,15)},Enum.EasingStyle.Back)
            tw(knob,0.22,{Size=UD.fromOffset(12,12)},Enum.EasingStyle.Back)
            setOn(not on)
        end)
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
            tw(fill,0.14,{Size=UD.new(pp2,0,1,0)},Enum.EasingStyle.Quint)
            tw(dot,0.14,{Position=UD.new(pp2,0,.5,0)},Enum.EasingStyle.Quint)
            vb.Text=fmt(v)
            if cb then cb(v) end
        end
        hit.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                dragging=true;upd(input)
                tw(dot,0.18,{Size=UD.fromOffset(15,15)},Enum.EasingStyle.Back)
            end
        end)
        UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then upd(input) end end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                if dragging then tw(dot,0.24,{Size=UD.fromOffset(11,11)},Enum.EasingStyle.Back) end
                dragging=false
            end
        end)
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
                tw(b,0.18,{Size=UD.fromOffset(bw+3,bw+3)},Enum.EasingStyle.Back)
                tw(b,0.26,{Size=UD.fromOffset(bw,bw)},Enum.EasingStyle.Back)
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
            btn.Text=v and "关闭" or txt
            btn.BackgroundColor3=v and C.Red or accent
            btn.TextColor3=v and C.Text or C.Bg
        end
        btn.MouseEnter:Connect(function() if not active then tw(btn,0.18,{BackgroundTransparency=0.15}) end end)
        btn.MouseLeave:Connect(function() if not active then tw(btn,0.18,{BackgroundTransparency=0}) end end)
        btn.Activated:Connect(function()
            tw(btn,0.08,{Size=UD.fromOffset(56,20)},Enum.EasingStyle.Back)
            tw(btn,0.22,{Size=UD.fromOffset(60,22)},Enum.EasingStyle.Back)
            if cb then cb(setActive,active) end
        end)
        return setActive
    end
    local function showPlayerSelect(cb)
        local overlay=new("Frame",{Size=UD.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=100,Parent=gui})
        tw(overlay,0.24,{BackgroundTransparency=0.5},Enum.EasingStyle.Quart)
        local list=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(220,240),BackgroundColor3=C.Bg,BorderSizePixel=0,ZIndex=101,Parent=overlay})
        corner(list,6);stroke(list,C.Cyan,1,0.3)
        local listScale=new("UIScale",{Scale=0.82,Parent=list})
        tw(listScale,0.36,{Scale=1},Enum.EasingStyle.Back)
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
                btn.MouseEnter:Connect(function() tw(btn,0.14,{BackgroundTransparency=0.3}) end)
                btn.MouseLeave:Connect(function() tw(btn,0.14,{BackgroundTransparency=0.15}) end)
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
        rb.MouseEnter:Connect(function() tw(rb,0.16,{BackgroundColor3=C.Panel}) end)
        rb.MouseLeave:Connect(function() tw(rb,0.16,{BackgroundColor3=C.Panel2}) end)
        rb.Activated:Connect(function()
            for _,s in ipairs(resetToggles) do s(false) end
            for _,s in ipairs(resetSliders) do s.fn(s.default) end
            for _,r in ipairs(resetColors) do r() end
            closeAllFeatures()
            tw(rb,0.08,{BackgroundColor3=C.Green});tw(rb,0.24,{BackgroundColor3=C.Panel2},Enum.EasingStyle.Back)
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
        makeToggle(p,204,"屏幕防误触","LOCK  EDGE  TOUCH",C.Red,false,function(on) setGuardEnabled(on) end)
        makeSlider(p,244,"防误触范围",C.Red,0,200,GuardZones.Size," px",0,function(v) flashGuardZones(v) end)
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
        makeToggle(p,330,"防摔落伤害","ANTI FALL",C.Green,false,function(on) ToggleAntiFall(on) end)
    end
    do
        local p=pages[3]
        makeToggle(p,6,"ESP 高亮","HIGHLIGHT PLAYERS",C.Cyan,State.ESPHighlightEnabled,function(on) State.ESPHighlightEnabled=on;refreshAllESP() end)
        makeToggle(p,46,"透视名字","PLAYER NAME",C.Purple,State.ESPNameEnabled,function(on) State.ESPNameEnabled=on;refreshAllESP() end)
        makeToggle(p,86,"透视血量","PLAYER HEALTH",C.Cyan,State.ESPHealthEnabled,function(on) State.ESPHealthEnabled=on;refreshAllESP() end)
        makeToggle(p,126,"互动透视","INTERACT ESP",C.Purple,false,function(on) ToggleInteractESP(on) end)
        makeToggle(p,166,"除雾效果","NO FOG",C.Cyan,State.RemoveFogEnabled,function(on) setRemoveFog(on) end)
        makeToggle(p,206,"夜视模式","NIGHT VISION",C.Purple,State.NightVisionEnabled,function(on) setNightVision(on) end)
        makeToggle(p,246,"自由视角","FREE CAM",C.Cyan,false,function(on) if on then StartFreecam() else StopFreecam() end end)
        makeSlider(p,286,"自由视角速度",C.Cyan,1,20,2,"",1,function(v) Freecam.Speed=v end)
    end
    do
        local p=pages[4]
        local selRow=new("Frame",{Position=UD.fromOffset(10,6),Size=UD.new(1,-20,0,36),BackgroundColor3=C.Panel,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=p})
        corner(selRow,5);stroke(selRow,C.Line,1,0.5)
        local selBar=new("Frame",{Position=UD.fromOffset(0,8),Size=UD.fromOffset(2,20),BackgroundColor3=C.Cyan,BorderSizePixel=0,Parent=selRow});corner(selBar,1)
        new("TextLabel",{Position=UD.fromOffset(12,4),Size=UD.new(1,-120,0,14),BackgroundTransparency=1,Text="选择目标玩家",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=selRow})
        local selDesc=new("TextLabel",{Position=UD.fromOffset(12,19),Size=UD.new(1,-120,0,11),BackgroundTransparency=1,Text="点击选择玩家",TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,Parent=selRow})
        local selBtn=new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UD.new(1,-12,0.5,0),Size=UD.fromOffset(60,22),BackgroundColor3=C.Cyan,BorderSizePixel=0,Text="选择",TextColor3=C.Bg,Font=Enum.Font.GothamBold,TextSize=10,AutoButtonColor=false,Parent=selRow});corner(selBtn,4)
        selBtn.Activated:Connect(function()
            showPlayerSelect(function(plr) TP_SelectedPlayer=plr;selDesc.Text="已选: "..plr.Name;selDesc.TextColor3=C.Cyan end)
        end)
        makeActionBtn(p,50,"传送到玩家","传送到所选玩家",C.Cyan,"执行",function()
            if not TP_SelectedPlayer then notify("提示","请先选择玩家") return end
            TeleportToPlayer(TP_SelectedPlayer)
        end)
        makeToggle(p,90,"循环传送","持续传送到目标",C.Cyan,false,function(on)
            TP_Loop=on
            if on then
                if not TP_SelectedPlayer then notify("提示","请先选择玩家");TP_Loop=false;return end
                AlreadyNotified={}
                TP_LoopConn=RunService.Heartbeat:Connect(function()
                    if TP_SelectedPlayer then
                        if not AlreadyNotified[TP_SelectedPlayer] then MonitorTarget(TP_SelectedPlayer) end
                        TeleportToPlayer(TP_SelectedPlayer)
                    end
                end)
            else
                if TP_LoopConn then TP_LoopConn:Disconnect();TP_LoopConn=nil end
                local ch=LP.Character;if ch then local r=ch:FindFirstChild("HumanoidRootPart");if r then r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero end end
            end
        end)
        makeToggle(p,130,"观战玩家","相机跟随目标",C.Purple,false,function(on)
            if on then if not TP_SelectedPlayer then notify("提示","请先选择玩家");return end;SpectatePlayer(TP_SelectedPlayer) else StopSpectateTP() end
        end)
        makeActionBtn(p,170,"甩飞一次","对所选玩家甩飞一次",C.Red,"执行",function()
            if not TP_SelectedPlayer then notify("提示","请先选择玩家") return end
            SkidFling(TP_SelectedPlayer)
        end)
        makeToggle(p,210,"循环甩飞","持续对目标甩飞",C.Red,false,function(on)
            if on then if not TP_SelectedPlayer then notify("提示","请先选择玩家");return end;StartFlingLoop(TP_SelectedPlayer) else StopFlingLoop() end
        end)
        makeToggle(p,250,"人物自转","角色持续旋转",C.Purple,false,function(on) SpinEnabled=on;if on then StartSpin() else StopSpin() end end)
        makeSlider(p,290,"旋转速度",C.Purple,1,200,5,"",0,function(v) SpinSpeed=v end)
    end
    do
        local p=pages[5]
        local colors={{Color=Color3.fromRGB(255,215,0)},{Color=Color3.fromRGB(255,60,60)},{Color=Color3.fromRGB(60,150,255)},{Color=Color3.fromRGB(60,255,120)},{Color=Color3.fromRGB(180,80,255)},{Color=Color3.fromRGB(255,255,255)}}
        makeToggle(p,6,"启用碰撞箱","HITBOX TOGGLE",C.Green,false,function(on) setHitboxEnabled(on) end)
        makeSlider(p,46,"碰撞箱大小",C.Green,1,50,State.HitboxSize,"",0,function(v) setHitboxSize(v) end)
        makeSlider(p,86,"碰撞箱透明度",C.Green,0,1,State.HitboxTransparency,"",2,function(v) setHitboxTransparency(v) end)
        makeColorPicker(p,126,"碰撞箱颜色","点击切换",C.Green,colors,1,function(c) setHitboxColor(c) end)
    end
    do
        local p=pages[6]
        makeToggle(p,6,"自瞄开关","AIMBOT TOGGLE",C.Red,false,function(on) ESP_SETTINGS.HighlightEnabled=on end)
        makeToggle(p,46,"显示FOV圈","SHOW FOV CIRCLE",C.Cyan,true,function(on) ShowFOVCircle=on end)
        makeToggle(p,86,"队伍检测","TEAM CHECK",C.Purple,false,function(on) ESP_SETTINGS.TeamCheck=on end)
        makeToggle(p,126,"墙体检测","WALL CHECK",C.Cyan,false,function(on) ESP_SETTINGS.WallCheck=on end)
        makeSlider(p,166,"自瞄范围(FOV)",C.Red,10,700,FOV,"",0,function(v) FOV=v end)
        makeSlider(p,206,"最大距离",C.Cyan,50,6000,MaxDistance,"",0,function(v) MaxDistance=v end)
        makeToggle(p,246,"平滑自瞄","SMOOTH AIM",C.Purple,false,function(on) ESP_SETTINGS.SmoothAim=on end)
        makeSlider(p,286,"平滑度",C.Purple,0.05,1,0.18,"",2,function(v) Smoothness=v end)
        local aimRow=new("Frame",{Position=UD.fromOffset(10,326),Size=UD.new(1,-20,0,36),BackgroundColor3=C.Panel,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=p})
        corner(aimRow,5);stroke(aimRow,C.Line,1,0.5)
        local aimBar=new("Frame",{Position=UD.fromOffset(0,8),Size=UD.fromOffset(2,20),BackgroundColor3=C.Cyan,BorderSizePixel=0,Parent=aimRow});corner(aimBar,1)
        new("TextLabel",{Position=UD.fromOffset(12,4),Size=UD.new(1,-120,0,14),BackgroundTransparency=1,Text="瞄准部位",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=aimRow})
        local aimDesc=new("TextLabel",{Position=UD.fromOffset(12,19),Size=UD.new(1,-120,0,11),BackgroundTransparency=1,Text="当前: Head",TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,Parent=aimRow})
        local aimBtn=new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UD.new(1,-12,0.5,0),Size=UD.fromOffset(60,22),BackgroundColor3=C.Cyan,BorderSizePixel=0,Text="切换",TextColor3=C.Bg,Font=Enum.Font.GothamBold,TextSize=10,AutoButtonColor=false,Parent=aimRow});corner(aimBtn,4)
        local aimIdx=1
        aimBtn.Activated:Connect(function() aimIdx=aimIdx%#AimPartsList+1;AimPart=AimPartsList[aimIdx];aimDesc.Text="当前: "..AimPart end)
        makeToggle(p,366,"指定自瞄目标","LOCK TARGET",C.Purple,false,function(on) LockTargetEnabled=on end)
        local tgtRow=new("Frame",{Position=UD.fromOffset(10,406),Size=UD.new(1,-20,0,36),BackgroundColor3=C.Panel,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=p})
        corner(tgtRow,5);stroke(tgtRow,C.Line,1,0.5)
        local tgtBar=new("Frame",{Position=UD.fromOffset(0,8),Size=UD.fromOffset(2,20),BackgroundColor3=C.Purple,BorderSizePixel=0,Parent=tgtRow});corner(tgtBar,1)
        new("TextLabel",{Position=UD.fromOffset(12,4),Size=UD.new(1,-120,0,14),BackgroundTransparency=1,Text="选择自瞄目标",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=tgtRow})
        local tgtDesc=new("TextLabel",{Position=UD.fromOffset(12,19),Size=UD.new(1,-120,0,11),BackgroundTransparency=1,Text="点击选择",TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,Parent=tgtRow})
        local tgtBtn=new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UD.new(1,-12,0.5,0),Size=UD.fromOffset(60,22),BackgroundColor3=C.Purple,BorderSizePixel=0,Text="选择",TextColor3=C.Bg,Font=Enum.Font.GothamBold,TextSize=10,AutoButtonColor=false,Parent=tgtRow});corner(tgtBtn,4)
        tgtBtn.Activated:Connect(function()
            showPlayerSelect(function(plr) SelectedTarget=plr;tgtDesc.Text="已选: "..plr.Name;tgtDesc.TextColor3=C.Purple end)
        end)
        makeToggle(p,446,"启用团队白名单","TEAM WHITELIST",C.Cyan,false,function(on) AimbotTeamWhitelistEnabled=on end)
        makeActionBtn(p,486,"切换当前队伍白名单","将自己队伍加入/移出白名单",C.Green,"切换",function()
            local mt=LP.Team
            if mt then
                if AimbotTeamWhitelist[mt.Name] then AimbotTeamWhitelist[mt.Name]=nil;notify("白名单","已移出: "..mt.Name)
                else AimbotTeamWhitelist[mt.Name]=true;notify("白名单","已加入: "..mt.Name) end
            else notify("白名单","你没有队伍") end
        end)
    end
    local currentTab=1
    local function switchTab(idx)
        if idx==currentTab then return end
        tabBtns[currentTab].TextColor3=C.Dim;tabBtns[idx].TextColor3=C.Text
        local oldPage=pages[currentTab]
        local newPage=pages[idx]
        oldPage.Visible=false
        newPage.Visible=true
        newPage.Position=UD.new(0,18,0,0)
        tw(newPage,0.42,{Position=UD.new(0,0,0,0)},Enum.EasingStyle.Back)
        tw(tabHighlight,0.34,{Position=UD.fromOffset((idx-1)/tabCount*WIN_W,23)},Enum.EasingStyle.Back)
        currentTab=idx
    end
    for i,b in ipairs(tabBtns) do
        b.Activated:Connect(function() switchTab(i) end)
        b.MouseEnter:Connect(function() if i~=currentTab then tw(b,0.18,{TextColor3=C.Text}) end end)
        b.MouseLeave:Connect(function() if i~=currentTab then tw(b,0.18,{TextColor3=C.Dim}) end end)
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
    main:GetPropertyChangedSignal("Position"):Connect(function() if main.Visible then mainHomePos=main.Position end end)
    mini:GetPropertyChangedSignal("Position"):Connect(function() if mini.Visible then miniHomePos=mini.Position end end)
    makeDraggable(mini,mini,function()
        mini.Visible=false
        main.Position=mainHomePos
        main.Visible=true
        mainScale.Scale=0.72
        tw(mainScale,0.55,{Scale=1},Enum.EasingStyle.Back)
    end)
    makeDraggable(main,dragHandle)
    minBtn.Activated:Connect(function()
        tw(minBtn,0.08,{BackgroundColor3=C.Cyan});tw(minBtn,0.2,{BackgroundColor3=C.Panel2})
        main.Visible=false
        mainScale.Scale=1
        mini.Position=UD.fromOffset(CAM.ViewportSize.X-MINI-20,CAM.ViewportSize.Y*0.4)
        miniHomePos=mini.Position
        mini.Visible=true
        msc.Scale=0.3
        tw(msc,0.5,{Scale=1},Enum.EasingStyle.Back)
    end)
    closeBtn.Activated:Connect(function()
        tw(closeBtn,0.08,{BackgroundColor3=C.Red})
        tw(mainScale,0.26,{Scale=0.8},Enum.EasingStyle.Back)
        task.wait(0.28)
        mini.Visible=false;main.Visible=false
        mainScale.Scale=1
        closeAllFeatures()
        task.wait(0.05)
        gui:Destroy()
    end)
    main.Visible=true;mainScale.Scale=0.78
    tw(mainScale,0.6,{Scale=1},Enum.EasingStyle.Back)
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
