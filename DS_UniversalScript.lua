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

if not _G.NeoBetaConfig then _G.NeoBetaConfig={LoadScreenEnabled=true} end

local C={Void=Color3.fromRGB(4,7,14),Bg=Color3.fromRGB(11,16,28),Panel=Color3.fromRGB(16,23,40),Panel2=Color3.fromRGB(24,33,56),Line=Color3.fromRGB(38,56,88),Cyan=Color3.fromRGB(0,229,255),Purple=Color3.fromRGB(123,97,255),Green=Color3.fromRGB(0,255,170),Red=Color3.fromRGB(255,70,90),Text=Color3.fromRGB(222,240,255),Dim=Color3.fromRGB(110,140,180)}

local State={NoclipEnabled=false,InfiniteJumpEnabled=false,ESPHighlightEnabled=false,ESPNameEnabled=false,ESPHealthEnabled=false,InstantInteractEnabled=false,PromptESPEnabled=false,RemoveFogEnabled=false,NightVisionEnabled=false,CustomSpeed=16,SpeedMultiplier=1,CustomJump=50,LoadScreenEnabled=_G.NeoBetaConfig.LoadScreenEnabled}

local ESPObjects={}
local PromptESPObjects={}
local infJumpConnection,instantInteractConn,promptESPConn
local SCRIPT_START_TIME=tick()

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

local function notify(title,text) pcall(function() StarterGui:SetCore("SendNotification",{Title=title,Text=text,Duration=4}) end) end
local function getCharacter() local char=LP.Character;if not char then return nil,nil end;return char,char:FindFirstChildOfClass("Humanoid") end

local function setNoclip(enabled)
    State.NoclipEnabled=enabled
    local char=LP.Character
    if not char then return end
    for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=not enabled end end
end

local function setInfiniteJump(enabled)
    State.InfiniteJumpEnabled=enabled
    if infJumpConnection then infJumpConnection:Disconnect();infJumpConnection=nil end
    if enabled then infJumpConnection=UserInputService.JumpRequest:Connect(function() local _,hum=getCharacter();if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end) end
end

local function applySpeed() local _,hum=getCharacter();if hum then hum.WalkSpeed=State.CustomSpeed*State.SpeedMultiplier end end
local function setSpeed(v) State.CustomSpeed=v;applySpeed() end
local function setSpeedMultiplier(m) State.SpeedMultiplier=m;applySpeed() end
local function setJump(v) State.CustomJump=v;local _,hum=getCharacter();if hum then hum.UseJumpPower=true;hum.JumpPower=v end end

local function setInstantInteract(enabled)
    State.InstantInteractEnabled=enabled
    if instantInteractConn then instantInteractConn:Disconnect();instantInteractConn=nil end
    if enabled then
        local function patch(p) if p:IsA("ProximityPrompt") then pcall(function() p.HoldDuration=0 end) end end
        for _,o in ipairs(workspace:GetDescendants()) do patch(o) end
        instantInteractConn=workspace.DescendantAdded:Connect(function(o) if State.InstantInteractEnabled then patch(o) end end)
    end
end

local function flyingScript() local ok,err=pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/ZBzcTm1f"))() end);if not ok then warn("飞行脚本加载失败: "..tostring(err)) end end

local function runExternalScript(url,name)
    local ok,err=pcall(function() loadstring(game:HttpGet(url))() end)
    if not ok then notify(name,"脚本加载失败: "..tostring(err)) end
end

local function clearPlayerESP(player) local d=ESPObjects[player];if not d then return end;if d.highlight then d.highlight:Destroy() end;if d.billboard then d.billboard:Destroy() end;ESPObjects[player]=nil end

local function createPlayerESP(player)
    if player==LP then return end
    local char=player.Character
    if not char then return end
    clearPlayerESP(player)
    local d={}
    if State.ESPHighlightEnabled then
        local hl=Instance.new("Highlight")
        hl.Adornee=char;hl.FillColor=Color3.fromRGB(255,80,80);hl.FillTransparency=0.4
        hl.OutlineColor=Color3.fromRGB(255,255,255);hl.OutlineTransparency=0
        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;hl.Parent=char
        d.highlight=hl
    end
    if State.ESPNameEnabled or State.ESPHealthEnabled then
        local head=char:FindFirstChild("Head")
        if head then
            local bg=Instance.new("BillboardGui")
            bg.Adornee=head;bg.Size=UDim2.new(0,200,0,50);bg.StudsOffset=Vector3.new(0,3,0)
            bg.AlwaysOnTop=true;bg.Parent=head
            local lbl=Instance.new("TextLabel")
            lbl.Size=UDim2.new(1,0,1,0);lbl.BackgroundTransparency=1
            lbl.TextColor3=Color3.fromRGB(255,255,255);lbl.TextStrokeTransparency=0
            lbl.TextStrokeColor3=Color3.fromRGB(0,0,0);lbl.Font=Enum.Font.SourceSansBold
            lbl.TextSize=16;lbl.Parent=bg
            d.billboard=bg;d.label=lbl
        end
    end
    ESPObjects[player]=d
end

local function updateESPLabels()
    for player,d in pairs(ESPObjects) do
        if d.label and d.label.Parent then
            local parts={}
            if State.ESPNameEnabled then table.insert(parts,player.Name) end
            if State.ESPHealthEnabled then
                local char=player.Character
                if char then local hum=char:FindFirstChildOfClass("Humanoid");if hum then table.insert(parts,string.format("❤ %d/%d",math.floor(hum.Health),math.floor(hum.MaxHealth))) end end
            end
            d.label.Text=table.concat(parts,"  ")
        end
    end
end

local function refreshAllESP() for _,p in ipairs(Players:GetPlayers()) do if p~=LP then createPlayerESP(p) end end end
local function clearAllESP() for player,_ in pairs(ESPObjects) do clearPlayerESP(player) end;ESPObjects={} end

local function createPromptESP(prompt)
    if PromptESPObjects[prompt] then return end
    local parent=prompt.Parent
    if not parent or not parent:IsA("BasePart") then return end
    local bg=Instance.new("BillboardGui")
    bg.Adornee=parent;bg.Size=UDim2.new(0,200,0,40);bg.StudsOffset=Vector3.new(0,2.5,0)
    bg.AlwaysOnTop=true;bg.Parent=parent
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,1,0);lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(100,255,100);lbl.TextStrokeTransparency=0
    lbl.TextStrokeColor3=Color3.fromRGB(0,0,0);lbl.Font=Enum.Font.SourceSansBold
    lbl.TextSize=14;lbl.Parent=bg
    PromptESPObjects[prompt]={gui=bg,label=lbl}
    task.spawn(function()
        local raw=prompt.ObjectText
        if raw=="" or raw==nil then raw=prompt.ActionText end
        if raw=="" or raw==nil then raw=prompt.Name end
        if lbl.Parent then lbl.Text="🔧 "..(raw or "Interact") end
    end)
end

local function clearPromptESP(prompt) local d=PromptESPObjects[prompt];if d and d.gui then d.gui:Destroy() end;PromptESPObjects[prompt]=nil end

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
    if promptESPConn then promptESPConn:Disconnect();promptESPConn=nil end
    if enabled then
        refreshPromptESP()
        promptESPConn=workspace.DescendantAdded:Connect(function(o) if State.PromptESPEnabled and o:IsA("ProximityPrompt") then createPromptESP(o) end end)
    else
        for prompt,_ in pairs(PromptESPObjects) do clearPromptESP(prompt) end
    end
end

local fogOriginal,atmoOriginal=nil,nil
local function setRemoveFog(enabled)
    State.RemoveFogEnabled=enabled
    local atmo=Lighting:FindFirstChildOfClass("Atmosphere")
    if enabled then
        if fogOriginal==nil then fogOriginal={FogStart=Lighting.FogStart,FogEnd=Lighting.FogEnd,FogColor=Lighting.FogColor} end
        Lighting.FogStart=0;Lighting.FogEnd=1000000;Lighting.FogColor=Color3.fromRGB(255,255,255)
        if atmo then if atmoOriginal==nil then atmoOriginal={Density=atmo.Density,Offset=atmo.Offset} end;atmo.Density=0;atmo.Offset=0 end
    else
        if fogOriginal then Lighting.FogStart=fogOriginal.FogStart;Lighting.FogEnd=fogOriginal.FogEnd;Lighting.FogColor=fogOriginal.FogColor;fogOriginal=nil end
        if atmoOriginal and atmo then atmo.Density=atmoOriginal.Density;atmo.Offset=atmoOriginal.Offset;atmoOriginal=nil end
    end
end

local nightVisionOriginal,nightColorCorrection=nil,nil
local function setNightVision(enabled)
    State.NightVisionEnabled=enabled
    if enabled then
        if nightVisionOriginal==nil then nightVisionOriginal={Brightness=Lighting.Brightness,Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient,GlobalShadows=Lighting.GlobalShadows,ClockTime=Lighting.ClockTime} end
        Lighting.Brightness=3;Lighting.Ambient=Color3.fromRGB(140,140,140);Lighting.OutdoorAmbient=Color3.fromRGB(160,160,160);Lighting.GlobalShadows=false
        if not nightColorCorrection then
            local cc=Instance.new("ColorCorrectionEffect")
            cc.Name="NeoBetaNightVision";cc.Brightness=0.15;cc.Contrast=0.05;cc.Saturation=0
            cc.Parent=Lighting;nightColorCorrection=cc
        end
    else
        if nightVisionOriginal then Lighting.Brightness=nightVisionOriginal.Brightness;Lighting.Ambient=nightVisionOriginal.Ambient;Lighting.OutdoorAmbient=nightVisionOriginal.OutdoorAmbient;Lighting.GlobalShadows=nightVisionOriginal.GlobalShadows;Lighting.ClockTime=nightVisionOriginal.ClockTime;nightVisionOriginal=nil end
        if nightColorCorrection then nightColorCorrection:Destroy();nightColorCorrection=nil end
    end
end

local function closeAllFeatures()
    setNoclip(false);setInfiniteJump(false);setInstantInteract(false);setPromptESP(false)
    setRemoveFog(false);setNightVision(false)
    State.ESPHighlightEnabled=false;State.ESPNameEnabled=false;State.ESPHealthEnabled=false
    clearAllESP()
end

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if State.NoclipEnabled then setNoclip(true) end
    local _,hum=getCharacter()
    if hum then hum.WalkSpeed=State.CustomSpeed*State.SpeedMultiplier;hum.UseJumpPower=true;hum.JumpPower=State.CustomJump end
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then task.defer(createPlayerESP,p) end end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if State.ESPHighlightEnabled or State.ESPNameEnabled or State.ESPHealthEnabled then createPlayerESP(player) end
    end)
end)
Players.PlayerRemoving:Connect(function(player) clearPlayerESP(player) end)

task.spawn(function()
    while task.wait(0.2) do
        if State.ESPNameEnabled or State.ESPHealthEnabled then updateESPLabels() end
        if State.PromptESPEnabled then
            updatePromptESPLabels()
            for prompt,d in pairs(PromptESPObjects) do if not prompt.Parent or not d.gui.Parent then clearPromptESP(prompt) end end
        end
    end
end)

local function runLoadScreen()
    local gui=new("ScreenGui",{Name="NeoBetaLoad",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=9999,Parent=PG})
    local mask=new("Frame",{Size=UD.fromScale(1,1),BackgroundColor3=C.Void,BackgroundTransparency=1,BorderSizePixel=0,Parent=gui})
    local splash=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(260,130),BackgroundColor3=C.Bg,BorderSizePixel=0,Visible=false,Parent=gui})
    corner(splash,6);stroke(splash,C.Cyan,1,0.4);techCorners(splash,C.Cyan,12,2,0.1)
    local splashScale=new("UIScale",{Scale=0.88,Parent=splash})
    local logoBox=new("Frame",{AnchorPoint=Vector2.new(.5,0),Position=UD.new(.5,0,0,16),Size=UD.fromOffset(44,44),BackgroundTransparency=1,Parent=splash})
    local oRing=ring(logoBox,44,C.Cyan,1.5,0.25)
    local mRing=ring(logoBox,32,C.Purple,1.2,0.35)
    local dCore=diamond(logoBox,12,12,20,C.Cyan,0);grad(dCore,C.Cyan,C.Purple,45)
    diamond(logoBox,17,17,10,C.Bg,0)
    new("TextLabel",{Position=UD.new(0,0,0,68),Size=UD.new(1,0,0,16),BackgroundTransparency=1,Text="N E O   B E T A",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=14,Parent=splash})
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
    new("TextLabel",{Position=UD.fromOffset(26,0),Size=UD.new(1,-90,1,0),BackgroundTransparency=1,Text="NEO  BETA  //  INJECTION",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=header})
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
    uidLbl.Text="UID "..tostring(LP.UserId)
    local okCard=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(320,110),BackgroundColor3=C.Bg,BorderSizePixel=0,Visible=false,Parent=gui})
    corner(okCard,6);stroke(okCard,C.Green,1,0.35);techCorners(okCard,C.Green,12,2,0.15)
    local okScale=new("UIScale",{Scale=0.9,Parent=okCard})
    local pulseOuter=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromOffset(46,42),Size=UD.fromOffset(42,42),BackgroundTransparency=1,Parent=okCard})
    corner(pulseOuter,21);stroke(pulseOuter,C.Green,1.2,0.7)
    local checkBox=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromOffset(46,42),Size=UD.fromOffset(22,22),BackgroundTransparency=1,Parent=okCard})
    local cb1=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromOffset(7,12),Size=UD.fromOffset(9,2.5),Rotation=45,BackgroundColor3=C.Green,BorderSizePixel=0,Parent=checkBox})
    corner(cb1,1.5)
    local cb2=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromOffset(14,9),Size=UD.fromOffset(15,2.5),Rotation=-48,BackgroundColor3=C.Green,BorderSizePixel=0,Parent=checkBox})
    corner(cb2,1.5)
    new("TextLabel",{Position=UD.fromOffset(80,26),Size=UD.new(1,-90,0,16),BackgroundTransparency=1,Text="脚本加载成功",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=okCard})
    new("TextLabel",{Position=UD.fromOffset(80,46),Size=UD.new(1,-90,0,32),BackgroundTransparency=1,Text="网络延迟可能导致脚本加载时间大幅度延长",TextColor3=C.Dim,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,Parent=okCard})
    local function runLoader(title,sub,accent,dur)
        root.Visible=true;titleLbl.Text=title;subLbl.Text=sub
        local s=root:FindFirstChildOfClass("UIStroke");s.Color=accent;pctLbl.TextColor3=accent
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

local function buildNeoBetaUI()
    local gui=new("ScreenGui",{Name="NeoBetaUI",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=9999,Parent=PG})
    local WIN_W,WIN_H=320,340
    local mainHomePos=UD.fromOffset(math.max(8,(CAM.ViewportSize.X-WIN_W)/2),math.max(8,(CAM.ViewportSize.Y-WIN_H)/2))
    local main=new("Frame",{Position=mainHomePos,Size=UD.fromOffset(WIN_W,WIN_H),BackgroundColor3=C.Bg,BorderSizePixel=0,Visible=true,Parent=gui})
    corner(main,8)
    local mainStroke=stroke(main,C.Cyan,1,0.5)
    techCorners(main,C.Cyan,14,2,0.1)
    local mainScale=fitScale(main,WIN_W,30,0.75)
    local mTopGrad=grad(new("Frame",{Size=UD.new(1,-24,0,2),Position=UD.new(0,12,0,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Parent=main}),C.Cyan,C.Purple,0)
    mTopGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,0),NumberSequenceKeypoint.new(1,1)})
    local titleBar=new("Frame",{Size=UD.new(1,0,0,32),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=main})
    corner(titleBar,8)
    new("Frame",{Position=UD.new(0,0,0,24),Size=UD.new(1,0,0,8),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=main})
    local dragHandle=new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=1,Parent=titleBar})
    local logoMini=new("Frame",{Position=UD.fromOffset(10,9),Size=UD.fromOffset(14,14),BackgroundTransparency=1,Parent=titleBar})
    local lmR=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(14,14),BackgroundTransparency=1,Parent=logoMini})
    corner(lmR,7);stroke(lmR,C.Cyan,1.2,0.3)
    local lmD=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(7,7),BackgroundColor3=C.Cyan,BorderSizePixel=0,Rotation=45,Parent=logoMini})
    corner(lmD,1.5);grad(lmD,C.Cyan,C.Purple,45)
    new("TextLabel",{Position=UD.fromOffset(30,0),Size=UD.new(1,-140,1,0),BackgroundTransparency=1,Text="NEO BETA",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=titleBar})
    new("TextLabel",{Position=UD.fromOffset(98,0),Size=UD.fromOffset(60,32),BackgroundTransparency=1,Text="V1 正式版",TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=titleBar})
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

    local tabs={"主要","战斗","视觉","甩飞","其他"}
    local tabCount=#tabs
    local tabBar=new("Frame",{Position=UD.new(0,0,0,32),Size=UD.new(1,0,0,26),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=main})
    new("Frame",{Position=UD.new(0,0,0,25),Size=UD.new(1,0,0,1),BackgroundColor3=C.Line,BackgroundTransparency=0.4,BorderSizePixel=0,Parent=tabBar})
    local tabBtns={}
    local tabHighlight=new("Frame",{Position=UD.fromOffset(0,23),Size=UD.new(1/tabCount,0,0,2),BackgroundColor3=C.Cyan,BorderSizePixel=0,Parent=tabBar})
    grad(tabHighlight,C.Cyan,C.Purple,0)
    for i,name in ipairs(tabs) do tabBtns[i]=new("TextButton",{Position=UD.new((i-1)/tabCount,0,0,0),Size=UD.new(1/tabCount,0,1,0),BackgroundTransparency=1,Text=name,TextColor3=(i==1) and C.Text or C.Dim,Font=Enum.Font.GothamBold,TextSize=10,AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Center,Parent=tabBar}) end

    local content=new("Frame",{Position=UD.new(0,0,0,58),Size=UD.new(1,0,1,-84),BackgroundTransparency=1,Parent=main})
    local pages={}
    for i=1,tabCount do pages[i]=new("Frame",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Visible=(i==1),Parent=content}) end
    local resetToggleSetters={}
    local resetSliderSetters={}

    local function makeToggle(parent,y,label,desc,accent,default,callback,noReset)
        local row=new("Frame",{Position=UD.fromOffset(10,y),Size=UD.new(1,-20,0,36),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=parent})
        corner(row,5);stroke(row,C.Line,1,0.5)
        local bar=new("Frame",{Position=UD.fromOffset(0,8),Size=UD.fromOffset(2,20),BackgroundColor3=C.Line,BorderSizePixel=0,Parent=row})
        corner(bar,1)
        new("TextLabel",{Position=UD.fromOffset(12,4),Size=UD.new(1,-90,0,14),BackgroundTransparency=1,Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local descLbl=new("TextLabel",{Position=UD.fromOffset(12,19),Size=UD.new(1,-90,0,11),BackgroundTransparency=1,Text=desc,TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local track=new("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-12,.5,0),Size=UD.fromOffset(30,16),BackgroundColor3=C.Panel2,BorderSizePixel=0,Parent=row})
        corner(track,8)
        local tStroke=stroke(track,C.Line,1,0.2)
        local knob=new("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,2,.5,0),Size=UD.fromOffset(12,12),BackgroundColor3=C.Dim,BorderSizePixel=0,Parent=track})
        corner(knob,6)
        local hit=new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=row})
        local on=default or false
        local function setOn(newOn)
            on=newOn
            tw(knob,0.18,{Position=on and UD.new(0,16,.5,0) or UD.new(0,2,.5,0),BackgroundColor3=on and accent or C.Dim},Enum.EasingStyle.Back)
            tStroke.Color=on and accent or C.Line;tStroke.Transparency=on and 0.2 or 0.6
            tw(bar,0.15,{BackgroundColor3=on and accent or C.Line})
            descLbl.TextColor3=on and accent or C.Dim
            tw(row,0.15,{BackgroundColor3=on and C.Panel2 or C.Panel})
            if callback then callback(on) end
        end
        if on then
            knob.Position=UD.new(0,16,.5,0);knob.BackgroundColor3=accent
            tStroke.Color=accent;tStroke.Transparency=0.2
            bar.BackgroundColor3=accent;descLbl.TextColor3=accent;row.BackgroundColor3=C.Panel2
        end
        hit.Activated:Connect(function() setOn(not on) end)
        if not noReset then table.insert(resetToggleSetters,setOn) end
        return setOn
    end

    local function makeSlider(parent,y,label,accent,minVal,maxVal,defaultVal,suffix,callback)
        local row=new("Frame",{Position=UD.fromOffset(10,y),Size=UD.new(1,-20,0,38),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=parent})
        corner(row,5);stroke(row,C.Line,1,0.5)
        new("TextLabel",{Position=UD.fromOffset(12,4),Size=UD.new(1,-130,0,14),BackgroundTransparency=1,Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local valBox=new("TextBox",{Position=UD.new(1,-92,0,4),Size=UD.fromOffset(80,16),BackgroundColor3=C.Panel2,BorderSizePixel=0,Text=tostring(defaultVal)..(suffix or ""),TextColor3=accent,Font=Enum.Font.Code,TextSize=10,TextXAlignment=Enum.TextXAlignment.Center,ClearTextOnFocus=false,Parent=row})
        corner(valBox,3);stroke(valBox,C.Line,1,0.4)
        local pct=(defaultVal-minVal)/(maxVal-minVal)
        local track=new("Frame",{Position=UD.fromOffset(12,26),Size=UD.new(1,-24,0,5),BackgroundColor3=C.Panel2,BorderSizePixel=0,Parent=row})
        corner(track,2.5)
        local fill=new("Frame",{Size=UD.new(pct,0,1,0),BackgroundColor3=accent,BorderSizePixel=0,Parent=track})
        corner(fill,2.5);grad(fill,accent,C.Purple,0)
        local dot=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.new(pct,0,.5,0),Size=UD.fromOffset(11,11),BackgroundColor3=accent,BorderSizePixel=0,Parent=track})
        corner(dot,5.5);stroke(dot,C.Bg,2,0)
        local hit=new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=track})
        local dragging=false
        local function setValInternal(v,fireCallback)
            v=math.clamp(math.floor(v+0.5),minVal,maxVal)
            local p=(v-minVal)/(maxVal-minVal)
            fill.Size=UD.new(p,0,1,0);dot.Position=UD.new(p,0,.5,0)
            valBox.Text=tostring(v)..(suffix or "")
            if fireCallback and callback then callback(v) end
        end
        local function setVal(v) setValInternal(v,true) end
        local function update(input)
            local p=math.clamp((input.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            local v=math.floor(minVal+p*(maxVal-minVal)+0.5)
            fill.Size=UD.new(p,0,1,0);dot.Position=UD.new(p,0,.5,0)
            valBox.Text=tostring(v)..(suffix or "")
            if callback then callback(v) end
        end
        hit.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true;update(input) end end)
        UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then update(input) end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
        valBox.FocusLost:Connect(function()
            local cleaned=valBox.Text:gsub("[^%d%.%-]","")
            local num=tonumber(cleaned)
            if num then setValInternal(num,true) else setValInternal(defaultVal,false) end
        end)
        table.insert(resetSliderSetters,{fn=setVal,default=defaultVal})
        return setVal
    end

    local function makeActionButton(parent,y,label,desc,accent,btnText,callback)
        local row=new("Frame",{Position=UD.fromOffset(10,y),Size=UD.new(1,-20,0,36),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=parent})
        corner(row,5);stroke(row,C.Line,1,0.5)
        local bar=new("Frame",{Position=UD.fromOffset(0,8),Size=UD.fromOffset(2,20),BackgroundColor3=accent,BorderSizePixel=0,Parent=row})
        corner(bar,1)
        new("TextLabel",{Position=UD.fromOffset(12,4),Size=UD.new(1,-120,0,14),BackgroundTransparency=1,Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        new("TextLabel",{Position=UD.fromOffset(12,19),Size=UD.new(1,-120,0,11),BackgroundTransparency=1,Text=desc,TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local btn=new("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-12,.5,0),Size=UD.fromOffset(60,22),BackgroundColor3=accent,BorderSizePixel=0,Text=btnText or "执行",TextColor3=C.Bg,Font=Enum.Font.GothamBold,TextSize=10,AutoButtonColor=false,Parent=row})
        corner(btn,4)
        btn.MouseEnter:Connect(function() tw(btn,0.15,{BackgroundTransparency=0.15}) end)
        btn.MouseLeave:Connect(function() tw(btn,0.15,{BackgroundTransparency=0}) end)
        btn.Activated:Connect(function()
            tw(btn,0.06,{Size=UD.fromOffset(56,20)});tw(btn,0.14,{Size=UD.fromOffset(60,22)})
            if callback then callback() end
        end)
    end

    local function makeBigButton(parent,y,text,accent,callback)
        local btn=new("TextButton",{Position=UD.fromOffset(10,y),Size=UD.new(1,-20,0,50),BackgroundColor3=C.Panel,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=parent})
        corner(btn,6);stroke(btn,accent,1,0.35)
        local bar=new("Frame",{Position=UD.fromOffset(0,10),Size=UD.fromOffset(3,30),BackgroundColor3=accent,BorderSizePixel=0,Parent=btn})
        corner(bar,1.5)
        new("TextLabel",{Position=UD.fromOffset(14,0),Size=UD.new(1,-20,1,0),BackgroundTransparency=1,Text=text,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=btn})
        btn.MouseEnter:Connect(function() tw(btn,0.15,{BackgroundColor3=C.Panel2}) end)
        btn.MouseLeave:Connect(function() tw(btn,0.15,{BackgroundColor3=C.Panel}) end)
        btn.Activated:Connect(function()
            tw(btn,0.08,{BackgroundColor3=accent})
            task.wait(0.1)
            tw(btn,0.2,{BackgroundColor3=C.Panel})
            if callback then callback() end
        end)
    end

    do
        local p=pages[1]
        local resetBtn,timerLbl
        local statusCard=new("Frame",{Position=UD.fromOffset(10,6),Size=UD.new(1,-20,0,66),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=p})
        corner(statusCard,5);stroke(statusCard,C.Line,1,0.5)
        local av2=new("Frame",{Position=UD.fromOffset(10,8),Size=UD.fromOffset(36,36),BackgroundTransparency=1,Parent=statusCard})
        local av2R=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(36,36),BackgroundTransparency=1,Parent=av2})
        corner(av2R,18);stroke(av2R,C.Cyan,1.2,0.3)
        local av2Img=new("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(30,30),BackgroundColor3=C.Panel2,BorderSizePixel=0,Parent=av2})
        corner(av2Img,15)
        task.spawn(function() local ok,th=pcall(function() return Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end);if ok and th then av2Img.Image=th end end)
        new("TextLabel",{Position=UD.fromOffset(54,8),Size=UD.new(1,-64,0,14),BackgroundTransparency=1,Text=LP.Name,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=statusCard})
        new("TextLabel",{Position=UD.fromOffset(54,24),Size=UD.new(1,-64,0,11),BackgroundTransparency=1,Text="UID  "..tostring(LP.UserId),TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=statusCard})
        new("TextLabel",{Position=UD.fromOffset(54,36),Size=UD.new(1,-64,0,11),BackgroundTransparency=1,Text="AGE  "..LP.AccountAge.."D   |   ONLINE",TextColor3=C.Green,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=statusCard})
        timerLbl=new("TextLabel",{Position=UD.fromOffset(54,50),Size=UD.new(1,-64,0,12),BackgroundTransparency=1,Text="已使用  00:00:00",TextColor3=C.Cyan,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=statusCard})
        task.spawn(function()
            while timerLbl.Parent do
                local elapsed=math.floor(tick()-SCRIPT_START_TIME)
                local h=math.floor(elapsed/3600);local m=math.floor((elapsed%3600)/60);local s=elapsed%60
                timerLbl.Text=string.format("已使用  %02d:%02d:%02d",h,m,s)
                task.wait(1)
            end
        end)
        resetBtn=new("TextButton",{Position=UD.fromOffset(10,80),Size=UD.new(1,-20,0,26),BackgroundColor3=C.Panel2,BorderSizePixel=0,Text="重置所有功能",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,AutoButtonColor=false,Parent=p})
        corner(resetBtn,5);stroke(resetBtn,C.Line,1,0.5)
        resetBtn.MouseEnter:Connect(function() tw(resetBtn,0.15,{BackgroundColor3=C.Panel}) end)
        resetBtn.MouseLeave:Connect(function() tw(resetBtn,0.15,{BackgroundColor3=C.Panel2}) end)
        resetBtn.Activated:Connect(function()
            for _,setter in ipairs(resetToggleSetters) do setter(false) end
            for _,s in ipairs(resetSliderSetters) do s.fn(s.default) end
            closeAllFeatures()
            tw(resetBtn,0.08,{BackgroundColor3=C.Green});tw(resetBtn,0.2,{BackgroundColor3=C.Panel2})
        end)
        makeToggle(p,116,"启动加载界面","LOAD SCREEN",C.Cyan,State.LoadScreenEnabled,function(on) State.LoadScreenEnabled=on;_G.NeoBetaConfig.LoadScreenEnabled=on end,true)
        makeActionButton(p,160,"TX Script","全自动翻译",C.Green,"启动",function()
            TX = "TX Script"
            Script = "全自动翻译"
            local ok,err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Auto-language"))()
            end)
            if not ok then notify("TX Script","加载失败: "..tostring(err)) end
        end)
    end

    do
        local p=pages[2]
        makeSlider(p,6,"移动速度",C.Cyan,16,300,State.CustomSpeed,"",function(v) setSpeed(v) end)
        makeSlider(p,50,"速度倍数",C.Purple,1,20,State.SpeedMultiplier,"x",function(v) setSpeedMultiplier(v) end)
        makeToggle(p,94,"无限跳跃","INFINITE JUMP",C.Cyan,State.InfiniteJumpEnabled,function(on) setInfiniteJump(on) end)
        makeSlider(p,136,"跳跃高度",C.Purple,50,300,State.CustomJump,"",function(v) setJump(v) end)
        makeActionButton(p,180,"飞行模式","FLY MODE",C.Cyan,"启动",flyingScript)
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
        makeBigButton(p,10,"通用甩飞  建议开启翻译",C.Red,function()
            runExternalScript("https://rawscripts.net/raw/Universal-Script-redzzyg's-fling-system-228233","甩飞")
        end)
        makeBigButton(p,70,"走路无旋转甩飞  建议开启翻译",C.Purple,function()
            runExternalScript("https://rawscripts.net/raw/Universal-Script-Fling-Gui-230233","甩飞")
        end)
    end

    do
        local p=pages[5]
        makeToggle(p,6,"穿墙模式","NOCLIP",C.Cyan,State.NoclipEnabled,function(on) setNoclip(on) end)
        makeToggle(p,46,"秒互动","INSTANT INTERACT",C.Purple,State.InstantInteractEnabled,function(on) setInstantInteract(on) end)
    end

    local currentTab=1
    local function switchTab(idx)
        if idx==currentTab then return end
        tabBtns[currentTab].TextColor3=C.Dim;tabBtns[idx].TextColor3=C.Text
        pages[currentTab].Visible=false;pages[idx].Visible=true
        pages[idx].Position=UD.fromOffset(idx>currentTab and 20 or -20,0)
        tw(pages[idx],0.22,{Position=UD.fromOffset(0,0)})
        tw(tabHighlight,0.22,{Position=UD.fromOffset((idx-1)/tabCount*WIN_W,23)})
        currentTab=idx
    end
    for i,b in ipairs(tabBtns) do
        b.Activated:Connect(function() switchTab(i) end)
        b.MouseEnter:Connect(function() if i~=currentTab then tw(b,0.15,{TextColor3=C.Text}) end end)
        b.MouseLeave:Connect(function() if i~=currentTab then tw(b,0.15,{TextColor3=C.Dim}) end end)
    end

    local statusBar=new("Frame",{Position=UD.new(0,1,-24),Size=UD.new(1,0,0,24),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=main})
    corner(statusBar,8)
    new("Frame",{Position=UD.new(0,0,0,0),Size=UD.new(1,0,0,8),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=statusBar})
    new("Frame",{Position=UD.new(0,0,0,0),Size=UD.new(1,0,0,1),BackgroundColor3=C.Line,BackgroundTransparency=0.4,BorderSizePixel=0,Parent=statusBar})
    local sBlink=new("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,10,.5,0),Size=UD.fromOffset(5,5),BackgroundColor3=C.Green,BorderSizePixel=0,Parent=statusBar})
    corner(sBlink,2.5)
    new("TextLabel",{Position=UD.fromOffset(20,0),Size=UD.fromOffset(90,24),BackgroundTransparency=1,Text="READY",TextColor3=C.Green,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=statusBar})
    local pingLbl=new("TextLabel",{Position=UD.new(1,-90,0,0),Size=UD.fromOffset(80,24),BackgroundTransparency=1,Text="PING 12ms",TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Right,Parent=statusBar})

    local MINI=46
    local miniHomePos=UD.fromOffset(CAM.ViewportSize.X-MINI-20,CAM.ViewportSize.Y*0.4)
    local mini=new("TextButton",{Position=miniHomePos,Size=UD.fromOffset(MINI,MINI),BackgroundColor3=C.Bg,BorderSizePixel=0,Text="",AutoButtonColor=false,Visible=false,Parent=gui})
    corner(mini,MINI/2);stroke(mini,C.Cyan,1.4,0.2)
    local miniScale=new("UIScale",{Scale=1,Parent=mini})
    local orbit=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(30,30),BackgroundTransparency=1,Parent=mini})
    local orbitDot=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.new(1,0,.5,0),Size=UD.fromOffset(4,4),BackgroundColor3=C.Cyan,BorderSizePixel=0,Parent=orbit})
    corner(orbitDot,2)
    local miniCore=diamond(mini,15,15,16,C.Cyan,0)
    grad(miniCore,C.Cyan,C.Purple,45)
    diamond(mini,19,19,8,C.Bg,0)
    RunService.RenderStepped:Connect(function(dt)
        if not mini.Visible then return end
        orbit.Rotation=orbit.Rotation+dt*140
        local p2=(math.sin(os.clock()*3)+1)/2
        miniScale.Scale=1+p2*0.04
    end)
    main:GetPropertyChangedSignal("Position"):Connect(function() if main.Visible then mainHomePos=main.Position end end)
    mini:GetPropertyChangedSignal("Position"):Connect(function() if mini.Visible then miniHomePos=mini.Position end end)
    makeDraggable(mini,mini,function()
        mini.Visible=false;main.Position=mainHomePos;main.Visible=true
        mainScale.Scale=0.86;tw(mainScale,0.3,{Scale=1},Enum.EasingStyle.Back)
    end)
    makeDraggable(main,dragHandle)
    minBtn.Activated:Connect(function()
        tw(minBtn,0.08,{BackgroundColor3=C.Cyan});tw(minBtn,0.15,{BackgroundColor3=C.Panel2})
        main.Visible=false;mini.Position=miniHomePos;mini.Visible=true
        miniScale.Scale=0.4;tw(miniScale,0.35,{Scale=1},Enum.EasingStyle.Back)
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
            sBlink.BackgroundTransparency=p2*0.4
            pingLbl.Text="PING "..math.random(10,18).."ms"
            task.wait(0.8)
        end
    end)
end

buildNeoBetaUI()
