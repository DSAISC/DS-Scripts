local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local StarterGui=game:GetService("StarterGui")
local Lighting=game:GetService("Lighting")
local CoreGui=game:GetService("CoreGui")
local TextService=game:GetService("TextService")

local LP=Players.LocalPlayer
local PG=LP:WaitForChild("PlayerGui")
local CAM=workspace.CurrentCamera
local UD=UDim2

if not _G.VoidConfig then _G.VoidConfig={LoadScreenEnabled=true} end

local C={Void=Color3.fromRGB(6,2,16),Bg=Color3.fromRGB(14,5,28),Panel=Color3.fromRGB(24,12,45),Panel2=Color3.fromRGB(38,20,65),Line=Color3.fromRGB(70,40,110),Cyan=Color3.fromRGB(180,100,255),Purple=Color3.fromRGB(110,50,200),Green=Color3.fromRGB(160,220,255),Red=Color3.fromRGB(255,70,120),Text=Color3.fromRGB(230,215,255),Dim=Color3.fromRGB(140,110,180),BarBg=Color3.fromRGB(30,18,50)}

local SCRIPT_START=tick()

-- ================= 公告弹窗 =================
local FILE_NAME="VoidV3Notice.txt"
local BALL_COUNT=14
local alreadyRead=false
if isfile and isfile(FILE_NAME) then alreadyRead=true end

local function CreateBall(parent)
    local ball=Instance.new("Frame")
    local size=math.random(40,90)
    ball.Size=UDim2.new(0,size,0,size)
    ball.Position=UDim2.new(math.random(-20,120)/100,0,math.random(-20,120)/100,0)
    ball.BackgroundColor3=Color3.fromRGB(255,255,255)
    ball.BackgroundTransparency=0.85
    ball.ZIndex=0
    ball.Parent=parent
    local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(1,0);corner.Parent=ball
    local gradient=Instance.new("UIGradient")
    gradient.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromHSV(math.random(),0.6,1)),
        ColorSequenceKeypoint.new(1,Color3.fromHSV(math.random(),0.6,1))
    })
    gradient.Rotation=math.random(0,360);gradient.Parent=ball
    local stroke=Instance.new("UIStroke");stroke.Thickness=2;stroke.Transparency=0.6
    stroke.Color=Color3.fromHSV(math.random(),1,1);stroke.Parent=ball
    return ball
end

local function AnimateBall(ball)
    task.spawn(function()
        while ball.Parent do
            local newPos=UDim2.new(math.random(-10,110)/100,math.random(-60,60),math.random(-10,110)/100,math.random(-60,60))
            local tween=TweenService:Create(ball,TweenInfo.new(math.random(4,8),Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Position=newPos})
            tween:Play();tween.Completed:Wait()
        end
    end)
    task.spawn(function()
        while ball.Parent do
            TweenService:Create(ball,TweenInfo.new(2),{BackgroundTransparency=0.75}):Play()
            task.wait(2)
            TweenService:Create(ball,TweenInfo.new(2),{BackgroundTransparency=0.9}):Play()
            task.wait(2)
        end
    end)
end

local function StartBalls(parent)
    for i=1,BALL_COUNT do AnimateBall(CreateBall(parent)) end
end

local noticeClicked=false
if not alreadyRead then
    local blur=Instance.new("BlurEffect");blur.Size=0;blur.Parent=Lighting
    TweenService:Create(blur,TweenInfo.new(0.25),{Size=18}):Play()

    local ScreenGui=Instance.new("ScreenGui")
    ScreenGui.Name="VoidNotice";ScreenGui.Parent=CoreGui;ScreenGui.IgnoreGuiInset=true
    StartBalls(ScreenGui)

    local Frame=Instance.new("Frame")
    Frame.Size=UDim2.new(0,280,0,150)
    Frame.AnchorPoint=Vector2.new(0.5,0.5)
    Frame.Position=UDim2.new(0.5,0,0.45,0)
    Frame.BackgroundColor3=Color3.fromRGB(18,18,18)
    Frame.BackgroundTransparency=1;Frame.ZIndex=10;Frame.Parent=ScreenGui
    local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,14);corner.Parent=Frame
    local stroke=Instance.new("UIStroke");stroke.Thickness=1;stroke.Transparency=0.7
    stroke.Color=Color3.fromRGB(255,255,255);stroke.Parent=Frame

    local TextLabel=Instance.new("TextLabel")
    TextLabel.Size=UDim2.new(1,-40,0,80);TextLabel.Position=UDim2.new(0,20,0,20)
    TextLabel.BackgroundTransparency=1;TextLabel.TextColor3=Color3.fromRGB(235,235,235)
    TextLabel.TextWrapped=true;TextLabel.TextSize=17;TextLabel.Font=Enum.Font.Gotham
    TextLabel.TextYAlignment=Enum.TextYAlignment.Top;TextLabel.TextTransparency=1
    TextLabel.ZIndex=11;TextLabel.Text="公告\n\n已更新动作功能，目前作者随缘更新"
    TextLabel.Parent=Frame

    local Button=Instance.new("TextButton")
    Button.Size=UDim2.new(0,110,0,36);Button.Position=UDim2.new(0.5,-55,1,-50)
    Button.Text="好";Button.BackgroundColor3=Color3.fromRGB(35,35,35)
    Button.TextColor3=Color3.fromRGB(255,255,255);Button.Font=Enum.Font.GothamMedium
    Button.TextScaled=true;Button.BackgroundTransparency=1;Button.ZIndex=11;Button.Parent=Frame
    local btnCorner=Instance.new("UICorner");btnCorner.CornerRadius=UDim.new(0,10);btnCorner.Parent=Button

    TweenService:Create(Frame,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,320,0,180),BackgroundTransparency=0.15}):Play()
    TweenService:Create(TextLabel,TweenInfo.new(0.3),{TextTransparency=0}):Play()
    TweenService:Create(Button,TweenInfo.new(0.3),{BackgroundTransparency=0}):Play()

    Button.MouseEnter:Connect(function() TweenService:Create(Button,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(55,55,55)}):Play() end)
    Button.MouseLeave:Connect(function() TweenService:Create(Button,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(35,35,35)}):Play() end)

    Button.MouseButton1Click:Connect(function()
        noticeClicked=true
        if writefile then writefile(FILE_NAME,"read") end
        TweenService:Create(Frame,TweenInfo.new(0.2),{BackgroundTransparency=1,Size=UDim2.new(0,280,0,150)}):Play()
        TweenService:Create(blur,TweenInfo.new(0.2),{Size=0}):Play()
        task.wait(0.2)
        ScreenGui:Destroy();blur:Destroy()
    end)

    repeat task.wait() until noticeClicked
end

-- ================= 通用函数 =================
local function new(c,p) local i=Instance.new(c);local pt;for k,v in pairs(p or {}) do if k=="Parent" then pt=v else i[k]=v end end;if pt then i.Parent=pt end;return i end
local function corner(p,r) return new("UICorner",{CornerRadius=UDim.new(0,r),Parent=p}) end
local function stroke(p,c,t,tr) return new("UIStroke",{Color=c,Thickness=t or 1,Transparency=tr or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=p}) end
local function grad(p,a,b,r) return new("UIGradient",{Color=ColorSequence.new(a,b),Rotation=r or 0,Parent=p}) end
local function tw(i,d,p,s,dr) local t=TweenService:Create(i,TweenInfo.new(d,s or Enum.EasingStyle.Quad,dr or Enum.EasingDirection.Out),p);t:Play();return t end

local function notify(title,content,duration,icon)
    pcall(function()
        StarterGui:SetCore("SendNotification",{
            Title=tostring(title or "提示"),
            Text=tostring(content or ""),
            Duration=duration or 3
        })
    end)
end

-- ================= 功能显示系统 =================
local FeatureDisplayEnabled=true
local EnabledFeatures={}
local FeatureItems={}

local FeatureGui=Instance.new("ScreenGui")
FeatureGui.Name="VoidFeatureDisplay";FeatureGui.Parent=CoreGui;FeatureGui.ResetOnSpawn=false
local Container=Instance.new("Frame")
Container.AnchorPoint=Vector2.new(1,0)
Container.Position=UDim2.new(1,-10,0,10)
Container.Size=UDim2.new(0,200,0,300)
Container.BackgroundTransparency=1;Container.Parent=FeatureGui
local UIList=Instance.new("UIListLayout")
UIList.Padding=UDim.new(0,4)
UIList.HorizontalAlignment=Enum.HorizontalAlignment.Right
UIList.Parent=Container

local function Rainbow() return Color3.fromHSV((tick()*0.25)%1,1,1) end

local function RefreshFeatureUI()
    Container.Visible=FeatureDisplayEnabled
    if not FeatureDisplayEnabled then return end
    for name,item in pairs(FeatureItems) do
        if not table.find(EnabledFeatures,name) then
            if item then
                TweenService:Create(item,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,item.Size.X.Offset,0,0),BackgroundTransparency=1}):Play()
                for _,v in pairs(item:GetChildren()) do
                    if v:IsA("TextLabel") then
                        TweenService:Create(v,TweenInfo.new(0.2),{TextTransparency=1,TextStrokeTransparency=1}):Play()
                    end
                end
                task.delay(0.25,function() if item then item:Destroy() end end)
            end
            FeatureItems[name]=nil
        end
    end
    for _,name in ipairs(EnabledFeatures) do
        if FeatureItems[name] then continue end
        local textSize=TextService:GetTextSize(name,14,Enum.Font.SourceSansBold,Vector2.new(1000,20))
        local width=textSize.X+10
        local item=Instance.new("Frame")
        item.Size=UDim2.new(0,0,0,16)
        item.BackgroundTransparency=1
        item.BackgroundColor3=Color3.new(0,0,0)
        item.BorderSizePixel=0;item.Parent=Container
        Instance.new("UICorner",item).CornerRadius=UDim.new(0,10)
        local label=Instance.new("TextLabel")
        label.Size=UDim2.new(1,-6,1,0)
        label.Position=UDim2.new(0,3,0,0)
        label.BackgroundTransparency=1
        label.Text=name
        label.Font=Enum.Font.SourceSansBold
        label.TextSize=14
        label.TextXAlignment=Enum.TextXAlignment.Center
        label.TextTransparency=1
        label.TextStrokeTransparency=1
        label.TextStrokeColor3=Color3.new(0,0,0)
        label.Parent=item
        task.spawn(function()
            while label.Parent do
                label.TextColor3=Rainbow()
                task.wait(0.05)
            end
        end)
        task.spawn(function()
            task.wait()
            TweenService:Create(item,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,width,0,20),BackgroundTransparency=0.5}):Play()
            task.wait(0.1)
            TweenService:Create(label,TweenInfo.new(0.3),{TextTransparency=0,TextStrokeTransparency=0.3}):Play()
        end)
        FeatureItems[name]=item
    end
end

local function AddFeature(name)
    if name=="Void" then
        for i,v in ipairs(EnabledFeatures) do
            if v=="Void" then table.remove(EnabledFeatures,i);break end
        end
        table.insert(EnabledFeatures,1,name)
    else
        if not table.find(EnabledFeatures,name) then table.insert(EnabledFeatures,name) end
    end
    RefreshFeatureUI()
end

local function RemoveFeature(name)
    for i,v in ipairs(EnabledFeatures) do
        if v==name then table.remove(EnabledFeatures,i);break end
    end
    RefreshFeatureUI()
end

-- ================= 管理员检测 =================
local AdminDetectEnabled=true
local flaggedAdmins={}
local function CheckAdmin(player)
    if not AdminDetectEnabled then return end
    if flaggedAdmins[player] then return end
    if not player or not player.Parent then return end
    local suspicious=false
    local reason=""
    pcall(function()
        for _,g in ipairs(player:GetGroups()) do
            if g.Rank>=200 then
                suspicious=true;reason="高Rank玩家"
            end
        end
    end)
    if suspicious then
        flaggedAdmins[player]=true
        notify("⚠️ 管理员警告",player.Name.." - "..reason,5)
    end
end
Players.PlayerAdded:Connect(function(p) task.wait(1);CheckAdmin(p) end)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(function() CheckAdmin(p) end) end
task.spawn(function()
    while true do
        if AdminDetectEnabled then
            for _,p in ipairs(Players:GetPlayers()) do CheckAdmin(p) end
        end
        task.wait(2)
    end
end)
Players.PlayerRemoving:Connect(function(p) flaggedAdmins[p]=nil end)

-- ================= 强制第三人称 =================
local ThirdPersonUnlock={Enabled=false,Connection=nil}
local function ApplyUnlock()
    pcall(function()
        if LP.CameraMode~=Enum.CameraMode.Classic then LP.CameraMode=Enum.CameraMode.Classic end
        LP.CameraMinZoomDistance=0.5
        LP.CameraMaxZoomDistance=50
    end)
end
local function EnableUnlock()
    if ThirdPersonUnlock.Connection then return end
    ThirdPersonUnlock.Enabled=true
    ApplyUnlock()
    ThirdPersonUnlock.Connection=RunService.RenderStepped:Connect(function()
        if not ThirdPersonUnlock.Enabled then return end
        ApplyUnlock()
    end)
end
local function DisableUnlock()
    ThirdPersonUnlock.Enabled=false
    if ThirdPersonUnlock.Connection then
        ThirdPersonUnlock.Connection:Disconnect()
        ThirdPersonUnlock.Connection=nil
    end
end
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if ThirdPersonUnlock.Enabled then ApplyUnlock() end
end)

-- ================= 自身血量显示 =================
local HealthPosFile="VoidHealthPos.txt"
local HealthDisplay={Enabled=true,Position="LeftTop",Label=nil}
pcall(function()
    if isfile and isfile(HealthPosFile) then
        local saved=readfile(HealthPosFile)
        if saved and saved~="" then HealthDisplay.Position=saved end
    end
end)
local HealthGui=Instance.new("ScreenGui")
HealthGui.Name="VoidHealthDisplay";HealthGui.ResetOnSpawn=false;HealthGui.Parent=CoreGui
local function CreateHealthUI()
    if HealthDisplay.Label then HealthDisplay.Label:Destroy() end
    local label=Instance.new("TextLabel")
    label.Size=UDim2.new(0,140,0,20)
    label.BackgroundTransparency=1
    label.TextStrokeTransparency=0.5
    label.Font=Enum.Font.SourceSansBold
    label.TextSize=14
    label.Text="HP: -- / --"
    label.Parent=HealthGui
    HealthDisplay.Label=label
end
local function UpdateHealthPosition()
    local label=HealthDisplay.Label
    if not label then return end
    if HealthDisplay.Position=="LeftTop" then
        label.Position=UDim2.new(0,10,0,10);label.TextXAlignment=Enum.TextXAlignment.Left
    elseif HealthDisplay.Position=="RightTop" then
        label.Position=UDim2.new(1,-150,0,10);label.TextXAlignment=Enum.TextXAlignment.Right
    elseif HealthDisplay.Position=="LeftBottom" then
        label.Position=UDim2.new(0,10,1,-30);label.TextXAlignment=Enum.TextXAlignment.Left
    elseif HealthDisplay.Position=="RightBottom" then
        label.Position=UDim2.new(1,-150,1,-30);label.TextXAlignment=Enum.TextXAlignment.Right
    end
end
CreateHealthUI();UpdateHealthPosition()
task.spawn(function()
    while true do
        if HealthDisplay.Enabled then
            local label=HealthDisplay.Label
            if label then
                local char=LP.Character
                if char then
                    local hum=char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local current=math.floor(hum.Health)
                        local max=math.floor(hum.MaxHealth)
                        if max<=0 then max=1 end
                        local percent=current/max
                        local color
                        if percent>0.6 then color=Color3.fromRGB(0,255,0)
                        elseif percent>0.3 then color=Color3.fromRGB(255,170,0)
                        else color=Color3.fromRGB(255,0,0) end
                        label.TextColor3=color
                        label.Text="HP: "..current.." / "..max
                        label.Visible=true
                    end
                end
            end
        else
            if HealthDisplay.Label then HealthDisplay.Label.Visible=false end
        end
        task.wait(0)
    end
end)
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    CreateHealthUI();UpdateHealthPosition()
end)

-- ================= FOV圈 =================
local FOVCircleGui=Instance.new("ScreenGui")
FOVCircleGui.Name="VoidFOVCircle";FOVCircleGui.IgnoreGuiInset=true;FOVCircleGui.ResetOnSpawn=false
FOVCircleGui.Parent=CoreGui
local fovCircle=Instance.new("Frame")
fovCircle.AnchorPoint=Vector2.new(0.5,0.5)
fovCircle.Position=UDim2.new(0.5,0,0.5,0)
fovCircle.Size=UDim2.new(0,240,0,240)
fovCircle.BackgroundTransparency=1
fovCircle.Parent=FOVCircleGui
fovCircle.Visible=false
local fovStroke=Instance.new("UIStroke")
fovStroke.Thickness=2
fovStroke.Color=Color3.fromRGB(128,0,128)
fovStroke.Parent=fovCircle
local fovCorner=Instance.new("UICorner")
fovCorner.CornerRadius=UDim.new(1,0)
fovCorner.Parent=fovCircle

-- ================= 自瞄参数 =================
local ESP_SETTINGS={HighlightEnabled=false,TeamCheck=false,SmoothAim=false,DistanceCheck=false,WallCheck=false}
local AimbotTeamWhitelist={}
local AimbotTeamWhitelistEnabled=false
local PLAYER_ESP={Enabled=false,HighlightEnabled=false,BoxEnabled=false,TeamCheck=false,ShowName=false,ShowHealth=false,ShowDist=false}
local FOV=120
local Smoothness=0.18
local AimPart="Head"
local ShowFOVCircle=true
local AimPartsList={"Head","HumanoidRootPart","UpperTorso","Torso"}
local MaxDistance=1000

local function GetAimPart(char)
    if not char then return nil end
    local part=char:FindFirstChild(AimPart)
    if not part then
        part=char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    end
    return part
end

local AimbotConnection=nil
local LockTargetEnabled=false
local SelectedTarget=nil
local PlayerList={}

-- ================= 玩家ESP =================
local function ClearPlayerESP()
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj.Name=="PlayerESP_Highlight" or obj.Name=="PlayerESP_Info" or obj.Name=="PlayerESP_Box" then
            obj:Destroy()
        end
    end
end

local function UpdatePlayerESP()
    if not PLAYER_ESP.Enabled then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local char=p.Character
            local hum=char:FindFirstChild("Humanoid")
            local head=char:FindFirstChild("Head")
            local root=char:FindFirstChild("HumanoidRootPart")
            if hum and head and root and hum.Health>-500 then
                local isTeam=(p.Team==LP.Team)
                local filtered=PLAYER_ESP.TeamCheck and isTeam
                local color=p.TeamColor.Color
                local high=char:FindFirstChild("PlayerESP_Highlight")
                if PLAYER_ESP.HighlightEnabled then
                    if not high then
                        high=Instance.new("Highlight",char)
                        high.Name="PlayerESP_Highlight"
                    end
                    high.FillColor=color
                    high.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                elseif high then high:Destroy() end
                local box=char:FindFirstChild("PlayerESP_Box")
                if PLAYER_ESP.BoxEnabled and not filtered then
                    if not box then
                        box=Instance.new("BillboardGui",char)
                        box.Name="PlayerESP_Box"
                        box.Size=UDim2.new(4.5,0,6,0)
                        box.AlwaysOnTop=true
                        box.Adornee=root
                        local f=Instance.new("Frame",box)
                        f.Size=UDim2.new(1,0,1,0)
                        f.BackgroundTransparency=1
                        local s=Instance.new("UIStroke",f)
                        s.Thickness=1.5
                    end
                    box.Frame.UIStroke.Color=color
                elseif box then box:Destroy() end
                local info=char:FindFirstChild("PlayerESP_Info")
                if not filtered then
                    if not info then
                        info=Instance.new("BillboardGui",char)
                        info.Name="PlayerESP_Info"
                        info.Size=UDim2.new(0,200,0,50)
                        info.AlwaysOnTop=true
                        info.Adornee=head
                        info.ExtentsOffset=Vector3.new(0,3.5,0)
                        local txt=Instance.new("TextLabel",info)
                        txt.Name="Label"
                        txt.Size=UDim2.new(1,0,1,0)
                        txt.BackgroundTransparency=1
                        txt.RichText=true
                        txt.TextStrokeTransparency=0.5
                        txt.Font=Enum.Font.GothamMedium
                    end
                    local text=""
                    if PLAYER_ESP.ShowName then
                        text="<font color='#ffffff'><b>"..p.DisplayName.."</b></font>\n"
                    end
                    if PLAYER_ESP.ShowHealth then
                        local hp=math.floor(hum.Health)
                        local hpColor=(hp>50 and "#55ff55" or "#ff5555")
                        text=text.."<font color='"..hpColor.."'>HP: "..hp.."</font> "
                    end
                    if PLAYER_ESP.ShowDist then
                        local dist=math.floor((CAM.CFrame.Position-root.Position).Magnitude)
                        text=text.."<font color='#ffffff'>| "..dist.."m</font>"
                    end
                    info.Label.Text=text
                elseif info then info:Destroy() end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if PLAYER_ESP.Enabled then UpdatePlayerESP() end
end)

-- ================= NPC透视 =================
local NPCESP={Enabled=false,Color=Color3.fromRGB(0,162,255),Highlights={}}
local Connections={}

local function GetNPCPart(model)
    if not model then return nil end
    if model:FindFirstChild("HumanoidRootPart") then return model.HumanoidRootPart end
    for _,part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then return part end
    end
    return nil
end

local function AddNPCESP(model)
    if not model then return end
    local existing=NPCESP.Highlights[model]
    if existing then
        if existing.Parent then return else NPCESP.Highlights[model]=nil end
    end
    if not model:FindFirstChildWhichIsA("Humanoid") then return end
    if Players:GetPlayerFromCharacter(model) then return end
    local part=GetNPCPart(model)
    if not part then return end
    local success,hl=pcall(function()
        local h=Instance.new("Highlight")
        h.Name="NPCESP"
        task.defer(function() if model and model.Parent then h.Adornee=model end end)
        h.FillColor=NPCESP.Color
        h.OutlineColor=Color3.fromRGB(255,255,255)
        h.FillTransparency=0.4
        h.OutlineTransparency=0
        h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent=CoreGui
        return h
    end)
    if success and hl then
        NPCESP.Highlights[model]=hl
        task.delay(1,function()
            if hl and hl.Parent and (not hl.Adornee or hl.Adornee~=model) then
                pcall(function() hl.Adornee=model end)
            end
        end)
        pcall(function()
            hl.AncestryChanged:Connect(function(_,parent)
                if not parent then
                    pcall(function() hl:Destroy() end)
                    NPCESP.Highlights[model]=nil
                end
            end)
        end)
    end
end

local function RemoveNPCESP(model)
    if not model then return end
    if NPCESP.Highlights[model] then
        pcall(function()
            if NPCESP.Highlights[model] and NPCESP.Highlights[model].Parent then
                NPCESP.Highlights[model]:Destroy()
            end
        end)
        NPCESP.Highlights[model]=nil
    end
end

local function ToggleNPCESP(state)
    NPCESP.Enabled=state
    if state then
        task.spawn(function()
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") then task.spawn(AddNPCESP,obj) end
            end
        end)
        if not Connections.NPC then
            Connections.NPC=workspace.DescendantAdded:Connect(function(child)
                task.delay(0.5,function()
                    if child and child:IsA("Model") then AddNPCESP(child)
                    elseif child and child:IsA("Humanoid") and child.Parent then AddNPCESP(child.Parent) end
                end)
            end)
        end
        task.spawn(function()
            while NPCESP.Enabled do
                for model,hl in pairs(NPCESP.Highlights) do
                    if not model or not model.Parent or not hl or not hl.Parent then
                        NPCESP.Highlights[model]=nil
                    end
                end
                for _,obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") then AddNPCESP(obj) end
                end
                task.wait(2)
            end
        end)
    else
        local toRemove={}
        for model,_ in pairs(NPCESP.Highlights) do table.insert(toRemove,model) end
        for _,model in ipairs(toRemove) do RemoveNPCESP(model) end
        if Connections.NPC then
            pcall(function() Connections.NPC:Disconnect() end)
            Connections.NPC=nil
        end
    end
end

-- ================= 互动透视（旧版） =================
local InteractESP={Enabled=false,Color=Color3.fromRGB(0,255,0),Highlights={}}
local function IsInteractive_Old(obj) return obj and (obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")) end
local function FindAdornPart_Old(target)
    if not target then return nil end
    if target:IsA("BasePart") then return target end
    if target:IsA("Model") then
        if target.PrimaryPart then return target.PrimaryPart end
        for _,c in pairs(target:GetChildren()) do if c:IsA("BasePart") then return c end end
    end
    return nil
end
local function AddInteractESP(target)
    if not target then return end
    if InteractESP.Highlights[target] then return end
    if not (target:IsA("BasePart") or target:IsA("Model")) then return end
    local ok,hl=pcall(function()
        local h=Instance.new("Highlight")
        h.Name="InteractESP"
        h.Adornee=target
        h.FillColor=InteractESP.Color
        h.OutlineColor=Color3.fromRGB(255,255,255)
        h.FillTransparency=0.5
        h.OutlineTransparency=0
        h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent=target
        return h
    end)
    if not ok then return end
    InteractESP.Highlights[target]=hl
    local adornPart=FindAdornPart_Old(target)
    if adornPart then
        if adornPart:FindFirstChild("InteractLabel") then return end
        local prompt=target:FindFirstChildWhichIsA("ProximityPrompt") or (target.Parent and target.Parent:FindFirstChildWhichIsA("ProximityPrompt"))
        local text=(prompt and (prompt.ActionText~="" and prompt.ActionText)) or "可互动"
        local bb=Instance.new("BillboardGui")
        bb.Name="InteractLabel";bb.Adornee=adornPart
        bb.Size=UDim2.new(0,120,0,30)
        bb.StudsOffset=Vector3.new(0,3,0)
        bb.AlwaysOnTop=true;bb.Parent=adornPart
        local label=Instance.new("TextLabel")
        label.Size=UDim2.new(1,0,1,0)
        label.BackgroundTransparency=1;label.Text=text
        label.TextColor3=InteractESP.Color
        label.TextStrokeTransparency=0.5
        label.TextStrokeColor3=Color3.new(0,0,0)
        label.Font=Enum.Font.SourceSansBold
        label.TextSize=14;label.Parent=bb
    end
    pcall(function()
        target.AncestryChanged:Connect(function(_,parent)
            if not parent and InteractESP.Highlights[target] then
                pcall(function() InteractESP.Highlights[target]:Destroy() end)
                InteractESP.Highlights[target]=nil
            end
        end)
    end)
end
local function RemoveInteractESP(target)
    if not target then return end
    if InteractESP.Highlights[target] then
        pcall(function() if InteractESP.Highlights[target] and InteractESP.Highlights[target].Parent then InteractESP.Highlights[target]:Destroy() end end)
        InteractESP.Highlights[target]=nil
    end
end
local function ToggleInteractESP(state)
    InteractESP.Enabled=state
    if state then
        task.spawn(function()
            for _,obj in ipairs(workspace:GetDescendants()) do
                if IsInteractive_Old(obj) and obj.Parent then pcall(function() AddInteractESP(obj.Parent) end) end
            end
        end)
        if not Connections.Interact then
            Connections.Interact=workspace.DescendantAdded:Connect(function(child)
                task.delay(1,function()
                    if child and IsInteractive_Old(child) and child.Parent then AddInteractESP(child.Parent)
                    elseif child and child:IsA("BasePart") and child.Parent then
                        for _,c in pairs(child:GetDescendants()) do
                            if IsInteractive_Old(c) and c.Parent then AddInteractESP(c.Parent) end
                        end
                    end
                end)
            end)
        end
    else
        local toRemove={}
        for target,_ in pairs(InteractESP.Highlights) do table.insert(toRemove,target) end
        for _,target in ipairs(toRemove) do RemoveInteractESP(target) end
        if Connections.Interact then pcall(function() Connections.Interact:Disconnect() end) Connections.Interact=nil end
    end
end

-- ================= 互动透视（新版） =================
local NewInteractESP={Enabled=false,Color=Color3.fromRGB(0,255,0),Highlights={}}
local function IsInteractive_New(o) return o and (o:IsA("ProximityPrompt") or o:IsA("ClickDetector")) end
local function GetInteractiveTarget(node)
    local p=node
    while p do if p:IsA("BasePart") or p:IsA("Model") then return p end p=p.Parent end
    return nil
end
local function FindAdornPart_New(t)
    if not t then return nil end
    if t:IsA("BasePart") then return t end
    if t:IsA("Model") then
        if t.PrimaryPart then return t.PrimaryPart end
        for _,c in pairs(t:GetChildren()) do if c:IsA("BasePart") then return c end end
    end
    return nil
end
local function AddNewInteractESP(target)
    if not target then return end
    if NewInteractESP.Highlights[target] then return end
    local ok,h=pcall(function()
        local hl=Instance.new("Highlight")
        hl.Name="NewInteractESP";hl.Adornee=target
        hl.FillColor=NewInteractESP.Color
        hl.OutlineColor=Color3.new(1,1,1)
        hl.FillTransparency=0.5;hl.OutlineTransparency=0
        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent=target
        return hl
    end)
    if not ok or not h then return end
    NewInteractESP.Highlights[target]=h
    local part=FindAdornPart_New(target)
    if part and not part:FindFirstChild("NewInteractLabel") then
        pcall(function()
            local bb=Instance.new("BillboardGui")
            bb.Name="NewInteractLabel";bb.Adornee=part
            bb.Size=UDim2.new(0,120,0,30)
            bb.StudsOffset=Vector3.new(0,3,0)
            bb.AlwaysOnTop=true;bb.Parent=part
            local label=Instance.new("TextLabel")
            label.Size=UDim2.new(1,0,1,0)
            label.BackgroundTransparency=1
            label.TextStrokeTransparency=0.4
            label.TextStrokeColor3=Color3.new(0,0,0)
            label.Font=Enum.Font.SourceSansBold
            label.TextSize=14
            label.TextColor3=NewInteractESP.Color
            label.Parent=bb
            local displayName=target.Name or ""
            if displayName=="" or displayName=="Part" or displayName=="Model" or displayName=="BasePart" then
                label.Text="可互动"
            else
                label.Text=displayName
            end
        end)
    end
end
local function ToggleNewInteractESP(state)
    NewInteractESP.Enabled=state
    if state then
        task.spawn(function()
            for _,v in ipairs(workspace:GetDescendants()) do
                if IsInteractive_New(v) then local t=GetInteractiveTarget(v) if t then AddNewInteractESP(t) end end
            end
        end)
        if not Connections.NewInteract then
            Connections.NewInteract=workspace.DescendantAdded:Connect(function(c)
                task.delay(0.05,function()
                    if c and c.GetDescendants then
                        for _,d in pairs(c:GetDescendants()) do
                            if IsInteractive_New(d) then local t=GetInteractiveTarget(d) if t then AddNewInteractESP(t) end end
                        end
                    end
                    if IsInteractive_New(c) then local t=GetInteractiveTarget(c) if t then AddNewInteractESP(t) end end
                end)
            end)
        end
    else
        for t,h in pairs(NewInteractESP.Highlights) do pcall(function() h:Destroy() end) end
        NewInteractESP.Highlights={}
        pcall(function()
            for _,obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BillboardGui") and obj.Name=="NewInteractLabel" then pcall(function() obj:Destroy() end) end
            end
        end)
        if Connections.NewInteract then pcall(function() Connections.NewInteract:Disconnect() end) Connections.NewInteract=nil end
    end
end

-- ================= 作者检测 =================
local DevESP={Enabled=true,Targets={["ylt351"]=true,["ylt410"]=true},Objects={}}
local function RainbowColor(t) return Color3.fromHSV((tick()*0.2+t)%1,1,1) end
local function AddDevESP(player)
    if player==LP then return end
    if not DevESP.Enabled then return end
    if not DevESP.Targets[player.Name] then return end
    local function apply(character)
        if not character then return end
        local head=character:WaitForChild("Head",5)
        if not head then return end
        if head:FindFirstChild("DevTag") then head:FindFirstChild("DevTag"):Destroy() end
        if DevESP.Objects[player] then
            pcall(function() DevESP.Objects[player].Billboard:Destroy() end)
            DevESP.Objects[player]=nil
        end
        local bb=Instance.new("BillboardGui")
        bb.Name="DevTag";bb.Adornee=head
        bb.Size=UDim2.new(0,140,0,28)
        bb.StudsOffset=Vector3.new(0,3,0)
        bb.AlwaysOnTop=true;bb.Parent=head
        local bg=Instance.new("Frame")
        bg.Size=UDim2.new(1,0,1,0)
        bg.BackgroundTransparency=0.2
        bg.BorderSizePixel=0;bg.Parent=bb
        local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,8);c.Parent=bg
        local gradient=Instance.new("UIGradient")
        gradient.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.2,Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.4,Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.6,Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.8,Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,255))
        })
        gradient.Parent=bg
        local txt=Instance.new("TextLabel")
        txt.Size=UDim2.new(1,-10,1,-6)
        txt.Position=UDim2.new(0,5,0,3)
        txt.BackgroundTransparency=1
        txt.Text="Void开发者"
        txt.TextScaled=false;txt.TextSize=13
        txt.Font=Enum.Font.SourceSansBold
        txt.TextStrokeTransparency=0.4
        txt.TextColor3=Color3.new(1,1,1)
        txt.Parent=bg
        DevESP.Objects[player]={Billboard=bb,Text=txt}
        task.spawn(function()
            while DevESP.Objects[player] and txt.Parent do
                local cc=RainbowColor(0)
                pcall(function() txt.TextColor3=cc end)
                task.wait(0.1)
            end
        end)
    end
    if player.Character then apply(player.Character) end
    player.CharacterAdded:Connect(function(char) task.wait(1);apply(char) end)
end
for _,plr in ipairs(Players:GetPlayers()) do AddDevESP(plr) end
Players.PlayerAdded:Connect(AddDevESP)

-- ================= 视觉模块（夜视/去雾） =================
local OriginalLighting={
    Brightness=Lighting.Brightness,
    Ambient=Lighting.Ambient,
    OutdoorAmbient=Lighting.OutdoorAmbient,
    FogStart=Lighting.FogStart,
    FogEnd=Lighting.FogEnd,
    FogColor=Lighting.FogColor,
    ClockTime=Lighting.ClockTime,
    GlobalShadows=Lighting.GlobalShadows,
    EnvironmentDiffuseScale=Lighting.EnvironmentDiffuseScale or 1,
    EnvironmentSpecularScale=Lighting.EnvironmentSpecularScale or 0,
    ColorShift_Top=Lighting.ColorShift_Top,
    ColorShift_Bottom=Lighting.ColorShift_Bottom,
    ExposureCompensation=Lighting.ExposureCompensation
}
local OriginalAtmosphere={}
local VisualModule={NormalNightVision=false,SuperNightVision=false,NoFog=false}

local function ApplyNormalNightVision(enable)
    VisualModule.NormalNightVision=enable
    if enable then
        Lighting.Brightness=10
        Lighting.Ambient=Color3.fromRGB(220,220,220)
        Lighting.OutdoorAmbient=Color3.fromRGB(220,220,220)
        Lighting.EnvironmentDiffuseScale=1
        Lighting.EnvironmentSpecularScale=1
        Lighting.GlobalShadows=false
        Lighting.ClockTime=8
        Lighting.ColorShift_Top=Color3.new(0,0,0)
        Lighting.ColorShift_Bottom=Color3.new(0,0,0)
        notify("普通夜视开启","成功",2)
    else
        for k,v in pairs(OriginalLighting) do pcall(function() Lighting[k]=v end) end
        notify("普通夜视关闭","成功",2)
    end
end

local function ApplySuperNightVision(enable)
    VisualModule.SuperNightVision=enable
    if enable then
        Lighting.Brightness=70
        Lighting.Ambient=Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
        Lighting.GlobalShadows=false
        Lighting.ClockTime=12
        Lighting.FogEnd=100000
        Lighting.EnvironmentDiffuseScale=1
        notify("超级夜视开启","成功",2)
    else
        for k,v in pairs(OriginalLighting) do pcall(function() Lighting[k]=v end) end
        notify("超级夜视关闭","成功",2)
    end
end

local function ApplyNoFog(enable)
    VisualModule.NoFog=enable
    if enable then
        Lighting.FogStart=0
        Lighting.FogEnd=math.huge
        Lighting.FogColor=Color3.fromRGB(200,200,220)
        for _,obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("Atmosphere") then
                if not OriginalAtmosphere[obj] then
                    OriginalAtmosphere[obj]={Density=obj.Density,Offset=obj.Offset,Glare=obj.Glare,Haze=obj.Haze}
                end
                pcall(function() obj.Density=0 obj.Offset=0 obj.Glare=0 obj.Haze=0 end)
            end
        end
        notify("去雾开启","成功",2)
    else
        Lighting.FogStart=OriginalLighting.FogStart
        Lighting.FogEnd=OriginalLighting.FogEnd
        Lighting.FogColor=OriginalLighting.FogColor
        for obj,props in pairs(OriginalAtmosphere) do
            if obj and obj.Parent then
                pcall(function()
                    obj.Density=props.Density;obj.Offset=props.Offset
                    obj.Glare=props.Glare;obj.Haze=props.Haze
                end)
            end
        end
        OriginalAtmosphere={}
        notify("去雾关闭","成功",2)
    end
end

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if VisualModule.NormalNightVision then ApplyNormalNightVision(true) end
    if VisualModule.SuperNightVision then ApplySuperNightVision(true) end
    if VisualModule.NoFog then ApplyNoFog(true) end
end)

-- ================= 防摔落 =================
local AntiFallEnabled=false
local AntiFallConnection=nil
local function StartAntiFall(character)
    local root=character:WaitForChild("HumanoidRootPart")
    if AntiFallConnection then AntiFallConnection:Disconnect();AntiFallConnection=nil end
    AntiFallConnection=RunService.Heartbeat:Connect(function()
        if not AntiFallEnabled then return end
        if not root or not root.Parent then return end
        local velocity=root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity=Vector3.zero
        RunService.RenderStepped:Wait()
        root.AssemblyLinearVelocity=velocity
    end)
end
local function ToggleAntiFall(state)
    AntiFallEnabled=state
    if state then
        local char=LP.Character
        if char then StartAntiFall(char) end
        notify("防摔落伤害","已开启",1)
    else
        if AntiFallConnection then AntiFallConnection:Disconnect();AntiFallConnection=nil end
        notify("防摔落伤害","已关闭",1)
    end
end
LP.CharacterAdded:Connect(function(char) if AntiFallEnabled then StartAntiFall(char) end end)

local AntiFall2Enabled=false
local AntiFall2Connection=nil
local function StartAntiFall2(character)
    if AntiFall2Connection then AntiFall2Connection:Disconnect();AntiFall2Connection=nil end
    local root=character:WaitForChild("HumanoidRootPart")
    local lastY=root.Position.Y
    local CHECK_INTERVAL=14
    AntiFall2Connection=RunService.Heartbeat:Connect(function()
        if not AntiFall2Enabled then return end
        if not character.Parent then return end
        local currentPosition=root.Position
        local fallDistance=lastY-currentPosition.Y
        if fallDistance>=CHECK_INTERVAL then
            local currentVel=root.AssemblyLinearVelocity
            root.CFrame=root.CFrame*CFrame.new(0,-0.5,0)
            root.AssemblyLinearVelocity=Vector3.new(currentVel.X,-10,currentVel.Z)
            lastY=root.Position.Y
        end
        if currentPosition.Y>lastY then lastY=currentPosition.Y end
    end)
end
LP.CharacterAdded:Connect(function(char) task.wait(0.5);StartAntiFall2(char) end)
if LP.Character then StartAntiFall2(LP.Character) end

-- ================= 自由视角 =================
local Freecam={
    Speed=2,Sensitivity=0.01,Enabled=false,Rig=nil,Loop=nil,Yaw=0,Pitch=0,
    MoveInput=Vector2.zero,Connections={},Touch={Move=nil,Look=nil,MoveStart=nil}
}

local function InitFreecamInput()
    if Freecam._InputInited then return end
    Freecam._InputInited=true
    table.insert(Freecam.Connections,UserInputService.TouchStarted:Connect(function(t)
        if not Freecam.Enabled then return end
        local half=CAM.ViewportSize.X/2
        if t.Position.X<half then
            if not Freecam.Touch.Move then
                Freecam.Touch.Move=t
                Freecam.Touch.MoveStart=t.Position
                Freecam.MoveInput=Vector2.zero
            end
        else
            if not Freecam.Touch.Look then Freecam.Touch.Look=t end
        end
    end))
    table.insert(Freecam.Connections,UserInputService.TouchMoved:Connect(function(t)
        if not Freecam.Enabled then return end
        if t==Freecam.Touch.Move and Freecam.Touch.MoveStart then
            local delta=t.Position-Freecam.Touch.MoveStart
            Freecam.MoveInput=Vector2.new(math.clamp(delta.X/80,-1,1),math.clamp(-delta.Y/80,-1,1))
        elseif t==Freecam.Touch.Look then
            local d=t.Delta
            Freecam.Yaw-=d.X*Freecam.Sensitivity
            Freecam.Pitch=math.clamp(Freecam.Pitch-d.Y*Freecam.Sensitivity,math.rad(-85),math.rad(85))
        end
    end))
    table.insert(Freecam.Connections,UserInputService.TouchEnded:Connect(function(t)
        if t==Freecam.Touch.Move then
            Freecam.Touch.Move=nil
            Freecam.Touch.MoveStart=nil
            Freecam.MoveInput=Vector2.zero
        end
        if t==Freecam.Touch.Look then Freecam.Touch.Look=nil end
    end))
end

local function StartFreecam()
    if Freecam.Enabled then return end
    Freecam.Enabled=true
    InitFreecamInput()
    local char=LP.Character
    if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    if not Freecam.Rig then
        Freecam.Rig=Instance.new("Part")
        Freecam.Rig.Anchored=true
        Freecam.Rig.CanCollide=false
        Freecam.Rig.Transparency=1
        Freecam.Rig.Size=Vector3.new(1,1,1)
        Freecam.Rig.Parent=workspace
    end
    Freecam.Rig.CFrame=CAM.CFrame
    root.Anchored=true
    hum.AutoRotate=false
    hum.PlatformStand=true
    CAM.CameraType=Enum.CameraType.Scriptable
    local x,y=CAM.CFrame:ToEulerAnglesYXZ()
    Freecam.Yaw=y
    Freecam.Pitch=x
    Freecam.Loop=RunService.RenderStepped:Connect(function()
        local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyLinearVelocity=Vector3.zero
            root.AssemblyAngularVelocity=Vector3.zero
        end
        local rotCF=CFrame.Angles(0,Freecam.Yaw,0)*CFrame.Angles(Freecam.Pitch,0,0)
        local cf=CFrame.new(Freecam.Rig.Position)*rotCF
        local move=(cf.RightVector*Freecam.MoveInput.X)+(cf.LookVector*Freecam.MoveInput.Y)
        Freecam.Rig.CFrame=CFrame.new(Freecam.Rig.Position+move*Freecam.Speed)*rotCF
        CAM.CFrame=Freecam.Rig.CFrame
    end)
end

local function StopFreecam()
    if not Freecam.Enabled then return end
    Freecam.Enabled=false
    if Freecam.Loop then Freecam.Loop:Disconnect();Freecam.Loop=nil end
    for _,conn in pairs(Freecam.Connections) do pcall(function() conn:Disconnect() end) end
    Freecam.Connections={}
    Freecam._InputInited=false
    Freecam.MoveInput=Vector2.zero
    Freecam.Touch.Move=nil
    Freecam.Touch.Look=nil
    local char=LP.Character
    if char then
        local root=char:FindFirstChild("HumanoidRootPart")
        local hum=char:FindFirstChildOfClass("Humanoid")
        if root then root.Anchored=false end
        if hum then hum.AutoRotate=true;hum.PlatformStand=false end
    end
    CAM.CameraType=Enum.CameraType.Custom
end

-- ================= 甩飞核心 =================
local FlingLoop=false
local Flinging=false
local AlreadyNotified={}
local TP_Loop=false

local function SkidFling(TargetPlayer)
    if not TargetPlayer or TargetPlayer==LP then return end
    if Flinging then return end
    Flinging=true
    local Player=LP
    local Character=Player.Character
    local Humanoid=Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart=Humanoid and Humanoid.RootPart
    local TCharacter=TargetPlayer.Character
    if not (Character and Humanoid and RootPart and TCharacter) then Flinging=false;return end
    local THumanoid=TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart=THumanoid and THumanoid.RootPart
    local THead=TCharacter:FindFirstChild("Head")
    local Accessory=TCharacter:FindFirstChildOfClass("Accessory")
    local Handle=Accessory and Accessory:FindFirstChild("Handle")
    local Camera=workspace.CurrentCamera
    local Dead=false
    local DeadConn
    DeadConn=Player.CharacterAdded:Connect(function()
        Dead=true
        if DeadConn then DeadConn:Disconnect();DeadConn=nil end
    end)
    if RootPart.Velocity.Magnitude<50 then getgenv().OldPos=RootPart.CFrame end
    if Camera then
        if THead then Camera.CameraSubject=THead
        elseif Handle then Camera.CameraSubject=Handle
        elseif THumanoid then Camera.CameraSubject=THumanoid end
    end
    local function FPos(BasePart,Pos,Ang)
        if Dead then return end
        if not BasePart or not BasePart.Parent then return end
        if not RootPart or not RootPart.Parent then return end
        RootPart.CFrame=CFrame.new(BasePart.Position)*Pos*Ang
        Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position)*Pos*Ang)
        RootPart.Velocity=Vector3.new(9e7,9e7*10,9e7)
        RootPart.RotVelocity=Vector3.new(9e8,9e8,9e8)
    end
    local function SFBasePart(BasePart)
        local TimeToWait=2
        local Time=tick()
        local Angle=0
        repeat
            if Dead then break end
            if not BasePart or not BasePart.Parent then break end
            if not RootPart or not RootPart.Parent then break end
            if not TRootPart or not TRootPart.Parent then break end
            if not THumanoid or THumanoid.Health<=0 then break end
            if BasePart.Velocity.Magnitude>1 then
                Angle=Angle+100
                FPos(BasePart,CFrame.new(0,1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0));task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0));task.wait()
                FPos(BasePart,CFrame.new(2.25,1.5,-2.25)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0));task.wait()
                FPos(BasePart,CFrame.new(-2.25,-1.5,2.25)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0));task.wait()
                FPos(BasePart,CFrame.new(0,1.5,0)+THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle),0,0));task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,0)+THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle),0,0));task.wait()
            else
                FPos(BasePart,CFrame.new(0,1.5,THumanoid.WalkSpeed),CFrame.Angles(math.rad(90),0,0));task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,-THumanoid.WalkSpeed),CFrame.Angles(0,0,0));task.wait()
                FPos(BasePart,CFrame.new(0,1.5,THumanoid.WalkSpeed),CFrame.Angles(math.rad(90),0,0));task.wait()
                FPos(BasePart,CFrame.new(0,1.5,TRootPart.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0));task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,-TRootPart.Velocity.Magnitude/1.25),CFrame.Angles(0,0,0));task.wait()
                FPos(BasePart,CFrame.new(0,1.5,TRootPart.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0));task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(90),0,0));task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0));task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(-90),0,0));task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0));task.wait()
            end
        until BasePart.Velocity.Magnitude>500 or not BasePart.Parent or Dead or tick()>Time+TimeToWait
    end
    local BV=Instance.new("BodyVelocity")
    BV.Parent=RootPart
    BV.Velocity=Vector3.new(9e8,9e8,9e8)
    BV.MaxForce=Vector3.new(1/0,1/0,1/0)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
    if not Dead then
        if TRootPart then SFBasePart(TRootPart)
        elseif THead then SFBasePart(THead)
        elseif Handle then SFBasePart(Handle) end
    end
    BV:Destroy()
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
    if Camera then
        local newChar=Player.Character
        local newHum=newChar and newChar:FindFirstChildOfClass("Humanoid")
        if newHum then Camera.CameraSubject=newHum end
    end
    if not Dead and getgenv().OldPos then
        local newChar=Player.Character
        local newRoot=newChar and newChar:FindFirstChild("HumanoidRootPart")
        local newHum=newChar and newChar:FindFirstChildOfClass("Humanoid")
        if newRoot and newHum then
            repeat
                newRoot.CFrame=getgenv().OldPos*CFrame.new(0,.5,0)
                newChar:SetPrimaryPartCFrame(getgenv().OldPos*CFrame.new(0,.5,0))
                newHum:ChangeState("GettingUp")
                for _,x in ipairs(newChar:GetChildren()) do
                    if x:IsA("BasePart") then
                        x.Velocity=Vector3.zero
                        x.RotVelocity=Vector3.zero
                    end
                end
                task.wait()
            until (newRoot.Position-getgenv().OldPos.Position).Magnitude<25
        end
    end
    if DeadConn then DeadConn:Disconnect();DeadConn=nil end
    Flinging=false
end

local function MonitorTarget(target)
    if not target then return end
    if not (TP_Loop or FlingLoop or Flinging) then return end
    if not AlreadyNotified[target] then AlreadyNotified[target]={dead=false,left=false} end
    local state=AlreadyNotified[target]
    task.spawn(function()
        while true do
            if not (TP_Loop or FlingLoop or Flinging) then break end
            if not target or not target.Parent then
                if not state.left then
                    state.left=true
                    local msg="玩家已退出，操作已终止"
                    if TP_Loop then msg="目标退出，无法继续传送"
                    elseif FlingLoop or Flinging then msg="目标退出，无法继续甩飞" end
                    notify("目标失效",msg,3)
                end
                break
            end
            local char=target.Character
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum or hum.Health<=0 then
                if not state.dead then
                    state.dead=true
                    local msg=target.Name.." 已死亡或消失"
                    if TP_Loop then msg=target.Name.." 已死亡或不存在，无法继续传送"
                    elseif FlingLoop or Flinging then msg=target.Name.." 已死亡或不存在，无法继续甩飞" end
                    notify("目标失效",msg,3)
                end
                repeat
                    task.wait(0.5)
                    char=target.Character
                    hum=char and char:FindFirstChildOfClass("Humanoid")
                until hum and hum.Health>0 or not target.Parent
                if hum and hum.Health>0 then state.dead=false end
            end
            task.wait(0.5)
        end
    end)
end

local function StartFlingLoop()
    if FlingLoop then return end
    FlingLoop=true
    AlreadyNotified={}
    task.spawn(function()
        while FlingLoop do
            local selfChar=LP.Character
            local selfHum=selfChar and selfChar:FindFirstChildOfClass("Humanoid")
            local selfRoot=selfChar and selfChar:FindFirstChild("HumanoidRootPart")
            if not selfChar or not selfHum or not selfRoot or selfHum.Health<=0 then
                task.wait(0.5)
                continue
            end
            if TP_SelectedPlayer=="ALL" then
                for _,p in ipairs(Players:GetPlayers()) do
                    if not FlingLoop then break end
                    local c=LP.Character
                    local h=c and c:FindFirstChildOfClass("Humanoid")
                    if not c or not h or h.Health<=0 then break end
                    if p~=LP then
                        local char=p.Character
                        local hum=char and char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health>0 then
                            if not AlreadyNotified[p] then MonitorTarget(p) end
                            local t1=tick()
                            repeat task.wait() until not Flinging or tick()-t1>3
                            SkidFling(p)
                            local t2=tick()
                            repeat task.wait() until not Flinging or tick()-t2>3
                            task.wait(0.1)
                        end
                    end
                end
            else
                local target=(TP_SelectedPlayer~="ALL") and (TP_SelectedPlayer or SelectedTarget) or nil
                if target then
                    if not AlreadyNotified[target] then MonitorTarget(target) end
                    local t1=tick()
                    repeat task.wait() until not Flinging or tick()-t1>3
                    SkidFling(target)
                    local t2=tick()
                    repeat task.wait() until not Flinging or tick()-t2>3
                end
            end
            task.wait(0.2)
        end
    end)
end

local function StopFlingLoop() FlingLoop=false end

-- ================= 旋转模块 =================
local SpinEnabled=false
local SpinSpeed=5
local SpinConnection=nil
local AnimationLockThread=nil

local function ApplyAnimationLock(char)
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate=false end
    if AnimationLockThread then task.cancel(AnimationLockThread);AnimationLockThread=nil end
    AnimationLockThread=task.spawn(function()
        local animate=char:WaitForChild("Animate",3)
        while SpinEnabled and animate and animate.Parent do
            animate.Disabled=true
            task.wait(0.2)
        end
    end)
end

local function RemoveAnimationLock(char)
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate=true end
    if AnimationLockThread then task.cancel(AnimationLockThread);AnimationLockThread=nil end
    local animate=char:FindFirstChild("Animate")
    if animate then animate.Disabled=false end
end

local function StartSpin()
    if SpinConnection then return end
    SpinConnection=RunService.RenderStepped:Connect(function(dt)
        if not SpinEnabled then return end
        local char=LP.Character
        if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(SpinSpeed)*dt*60,0)
    end)
    ApplyAnimationLock(LP.Character)
end

local function StopSpin()
    SpinEnabled=false
    if SpinConnection then SpinConnection:Disconnect();SpinConnection=nil end
    RemoveAnimationLock(LP.Character)
end

LP.CharacterAdded:Connect(function(char)
    if SpinEnabled then
        task.wait(0.5)
        ApplyAnimationLock(char)
        if not SpinConnection then StartSpin() end
    end
end)

-- ================= 传送/观战 =================
local function TeleportToPlayer(target)
    if not target then return end
    local char=LP.Character
    local tChar=target.Character
    if not char or not tChar then return end
    local root=char:FindFirstChild("HumanoidRootPart")
    local tRoot=tChar:FindFirstChild("HumanoidRootPart")
    if root and tRoot then root.CFrame=tRoot.CFrame*CFrame.new(0,4,0) end
end

local Spectating=false
local function SpectatePlayer(target)
    if not target then return end
    local cam=workspace.CurrentCamera
    if not cam then return end
    local char=target.Character
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    cam.CameraSubject=hum
    cam.CameraType=Enum.CameraType.Custom
    Spectating=true
end

local function StopSpectate()
    local cam=workspace.CurrentCamera
    if not cam then return end
    local char=LP.Character
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then cam.CameraSubject=hum end
    Spectating=false
end

-- ================= 自瞄核心 =================
local VisibilityCache={}
local function isVisible(p,part)
    if not CAM then return false end
    if not ESP_SETTINGS.WallCheck then return true end
    local origin=CAM.CFrame.Position
    local rayParams=RaycastParams.new()
    rayParams.FilterType=Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater=true
    local ignoreList={LP.Character,CAM}
    local tool=LP.Character and LP.Character:FindFirstChildOfClass("Tool")
    if tool then table.insert(ignoreList,tool) end
    rayParams.FilterDescendantsInstances=ignoreList
    local offsets={Vector3.new(0,0,0),Vector3.new(0.25,0,0),Vector3.new(-0.25,0,0),Vector3.new(0,0.25,0),Vector3.new(0,-0.25,0)}
    local visibleCount=0
    for _,offset in ipairs(offsets) do
        local targetPos=part.Position+offset
        local direction=targetPos-origin
        local currentOrigin=origin
        local remaining=direction
        local hitCharacter=false
        for i=1,3 do
            local result=workspace:Raycast(currentOrigin,remaining,rayParams)
            if not result then hitCharacter=true;break end
            local hit=result.Instance
            if hit and hit:IsDescendantOf(p.Character) then hitCharacter=true;break end
            if hit and (hit.Transparency>0.4 or hit.CanCollide==false or hit.Material==Enum.Material.Glass or hit.Name:lower():find("scope") or hit.Name:lower():find("view")) then
                currentOrigin=result.Position+(remaining.Unit*0.1)
                remaining=(part.Position-currentOrigin)
            else
                break
            end
        end
        if hitCharacter then visibleCount+=1 end
    end
    local isNowVisible=visibleCount>=2
    local last=VisibilityCache[p]
    if last==nil then VisibilityCache[p]=isNowVisible;return isNowVisible end
    if isNowVisible~=last then
        VisibilityCache[p]=last
        task.delay(0.03,function() VisibilityCache[p]=isNowVisible end)
        return last
    end
    VisibilityCache[p]=isNowVisible
    return isNowVisible
end

local function isAlive(p)
    local c=p.Character
    local h=c and c:FindFirstChild("Humanoid")
    return h and h.Health>0
end

local CurrentTarget=nil
local LastSwitchTime=0
local SWITCH_DELAY=0.25
local SWITCH_THRESHOLD=0.7

local function shouldForceSwitch(target)
    if not target then return true end
    if not isAlive(target) then return true end
    local char=target.Character
    local part=char and GetAimPart(char)
    if not part then return true end
    if not isVisible(target,part) then return true end
    local pos,visible=CAM:WorldToViewportPoint(part.Position)
    if not visible then return true end
    local center=CAM.ViewportSize/2
    local dist=(Vector2.new(pos.X,pos.Y)-center).Magnitude
    if dist>FOV then return true end
    return false
end

local function getTarget()
    local now=tick()
    local center=CAM.ViewportSize/2
    local bestTarget=nil
    local bestDist=math.huge
    local candidates={}
    if LockTargetEnabled and SelectedTarget then
        table.insert(candidates,SelectedTarget)
    else
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then table.insert(candidates,p) end
        end
    end
    for _,p in ipairs(candidates) do
        if p and isAlive(p) then
            if not LockTargetEnabled then
                if AimbotTeamWhitelistEnabled and next(AimbotTeamWhitelist)~=nil then
                    if not p.Team or not AimbotTeamWhitelist[p.Team.Name] then continue end
                elseif ESP_SETTINGS.TeamCheck then
                    if p.Team==LP.Team then continue end
                end
            end
            local char=p.Character
            local part=char and GetAimPart(char)
            if part then
                local camPos=CAM.CFrame.Position
                local dist3D=(part.Position-camPos).Magnitude
                if dist3D>MaxDistance then continue end
                if not isVisible(p,part) then continue end
                local pos,visible=CAM:WorldToViewportPoint(part.Position)
                if not visible then continue end
                local dist2D=(Vector2.new(pos.X,pos.Y)-center).Magnitude
                if dist2D<=FOV and dist2D<bestDist then
                    bestDist=dist2D
                    bestTarget=p
                end
            end
        end
    end
    if shouldForceSwitch(CurrentTarget) then
        CurrentTarget=bestTarget
        LastSwitchTime=now
        return bestTarget
    end
    if bestTarget then
        if now-LastSwitchTime<SWITCH_DELAY then return CurrentTarget end
        if CurrentTarget and CurrentTarget~=bestTarget then
            local char=CurrentTarget.Character
            local part=char and GetAimPart(char)
            if part then
                local pos,visible=CAM:WorldToViewportPoint(part.Position)
                if visible then
                    local currentDist=(Vector2.new(pos.X,pos.Y)-center).Magnitude
                    if bestDist>currentDist*SWITCH_THRESHOLD then return CurrentTarget end
                end
            end
        end
        CurrentTarget=bestTarget
        LastSwitchTime=now
        return bestTarget
    end
    return nil
end

-- ================= 速度/跳跃 =================
local baseSpeed,lastSetSpeed=16,16
local SpeedEnabled=false
local TargetWalkSpeed=16
local CustomJumpEnabled=false
local CustomJumpValue=50
local OriginalJump=50
local InfiniteJumpEnabled=false
local speedToggleDesc

local function updateBaseSpeedLbl()
    if speedToggleDesc and speedToggleDesc.Parent then
        speedToggleDesc.Text="原始移速: "..math.floor(baseSpeed+0.5)
    end
end

task.spawn(function()
    local char=LP.Character or LP.CharacterAdded:Wait()
    local hum=char:WaitForChild("Humanoid")
    baseSpeed=hum.WalkSpeed
    TargetWalkSpeed=baseSpeed
    OriginalJump=(hum.JumpPower>0) and hum.JumpPower or hum.JumpHeight
end)

RunService.RenderStepped:Connect(function()
    if SpeedEnabled then
        local char=LP.Character
        if char then
            local hum=char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed~=TargetWalkSpeed then
                hum.WalkSpeed=TargetWalkSpeed
            end
        end
    end
end)

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if SpeedEnabled then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=TargetWalkSpeed end
    end
end)

RunService.RenderStepped:Connect(function()
    if CustomJumpEnabled then
        local char=LP.Character
        if char then
            local hum=char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower=true
                hum.JumpPower=CustomJumpValue
                hum.JumpHeight=CustomJumpValue*(7.2/50)
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local character=LP.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

-- ================= UI框架 =================
local function fitScale(g,bw,pd,mn)
    local s=g:FindFirstChildOfClass("UIScale") or new("UIScale",{Scale=1,Parent=g})
    local function u() s.Scale=math.clamp((CAM.ViewportSize.X-(pd or 40))/bw,mn or .6,1) end
    u();CAM:GetPropertyChangedSignal("ViewportSize"):Connect(u)
    return s
end

local function makeDraggable(t,h,onClick)
    h=h or t
    local dg,ds,sp,mv=false,nil,nil,false
    h.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dg,mv=true,false;ds=input.Position;sp=t.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dg then return end
        if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
            local d=input.Position-ds
            if d.Magnitude>4 then mv=true end
            local vp=CAM.ViewportSize
            t.Position=UD.new(0,math.clamp(sp.X.Offset+d.X,-t.AbsoluteSize.X+60,vp.X-60),0,math.clamp(sp.Y.Offset+d.Y,0,vp.Y-30))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if not dg then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dg=false
            if not mv and onClick then task.defer(onClick) end
        end
    end)
end

-- ================= 构建UI =================
local PG2=PG

local function buildUI()
    local gui=new("ScreenGui",{Name="VoidUI",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=9999,Parent=PG2})
    local WIN_W,WIN_H=340,420
    local mainHomePos=UD.fromOffset(math.max(8,(CAM.ViewportSize.X-WIN_W)/2),math.max(8,(CAM.ViewportSize.Y-WIN_H)/2))
    local main=new("Frame",{Position=mainHomePos,Size=UD.fromOffset(WIN_W,WIN_H),BackgroundColor3=C.Bg,BorderSizePixel=0,Visible=true,Parent=gui})
    corner(main,8)
    local mainStroke=stroke(main,C.Cyan,1,0.5)
    local mainScale=fitScale(main,WIN_W,30,0.75)

    local titleBar=new("Frame",{Size=UD.new(1,0,0,32),BackgroundColor3=C.Panel,BackgroundTransparency=0.35,BorderSizePixel=0,Parent=main})
    corner(titleBar,8)
    new("Frame",{Position=UD.new(0,0,0,24),Size=UD.new(1,0,0,8),BackgroundColor3=C.Panel,BackgroundTransparency=0.35,BorderSizePixel=0,Parent=main})
    local dragHandle=new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=1,Parent=titleBar})
    new("TextLabel",{Position=UD.fromOffset(12,0),Size=UD.new(1,-140,1,0),BackgroundTransparency=1,Text="VOID  V3",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=titleBar})
    new("TextLabel",{Position=UD.fromOffset(80,0),Size=UD.fromOffset(60,32),BackgroundTransparency=1,Text="测试版",TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=titleBar})

    local minBtn=new("TextButton",{Position=UD.new(1,-38,0,7),Size=UD.fromOffset(14,14),BackgroundColor3=C.Panel2,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=5,Parent=titleBar})
    corner(minBtn,3);stroke(minBtn,C.Line,1,0.4)
    new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(6,1.5),BackgroundColor3=C.Dim,BorderSizePixel=0,Parent=minBtn})
    local closeBtn=new("TextButton",{Position=UD.new(1,-22,0,7),Size=UD.fromOffset(14,14),BackgroundColor3=C.Panel2,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=5,Parent=titleBar})
    corner(closeBtn,3);stroke(closeBtn,C.Line,1,0.4)
    new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(6,1.5),Rotation=45,BackgroundColor3=C.Dim,BorderSizePixel=0,Parent=closeBtn})
    new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),Size=UD.fromOffset(6,1.5),Rotation=-45,BackgroundColor3=C.Dim,BorderSizePixel=0,Parent=closeBtn})

    local tabs={"主要","玩家","通用","透视","视觉","自瞄","传送","服务器","动作","终止","配置"}
    local tabCount=#tabs
    local tabBar=new("Frame",{Position=UD.new(0,0,0,32),Size=UD.new(1,0,0,26),BackgroundColor3=C.Panel,BackgroundTransparency=0.35,BorderSizePixel=0,Parent=main})
    new("Frame",{Position=UD.new(0,0,0,25),Size=UD.new(1,0,0,1),BackgroundColor3=C.Line,BackgroundTransparency=0.4,BorderSizePixel=0,Parent=tabBar})
    local tabBtns={}
    local tabHighlight=new("Frame",{Position=UD.fromOffset(0,23),Size=UD.new(1/tabCount,0,0,2),BackgroundColor3=C.Cyan,BorderSizePixel=0,Parent=tabBar})
    grad(tabHighlight,C.Cyan,C.Purple,0)
    for i,name in ipairs(tabs) do
        tabBtns[i]=new("TextButton",{Position=UD.new((i-1)/tabCount,0,0,0),Size=UD.new(1/tabCount,0,1,0),BackgroundTransparency=1,Text=name,TextColor3=(i==1) and C.Text or C.Dim,Font=Enum.Font.GothamBold,TextSize=9,AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Center,Parent=tabBar})
    end

    local content=new("Frame",{Position=UD.new(0,0,0,58),Size=UD.new(1,0,1,-84),BackgroundTransparency=1,Parent=main})
    local pages={}
    local pageCanvas={300,340,420,300,320,400,420,340,420,200,260}
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

    -- ========== UI组件 ==========
    local function makeToggle(parent,y,label,desc,accent,default,cb)
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
            if cb then cb(on) end
        end
        if on then
            knob.Position=UD.new(0,16,.5,0);knob.BackgroundColor3=accent
            ts.Color=accent;ts.Transparency=0.2
            bar.BackgroundColor3=accent;dl.TextColor3=accent
        end
        hit.Activated:Connect(function() setOn(not on) end)
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
        return setV
    end

    local function makeActionBtn(parent,y,label,desc,accent,btnText,cb)
        local row=new("Frame",{Position=UD.fromOffset(10,y),Size=UD.new(1,-20,0,36),BackgroundColor3=C.Panel,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=parent})
        corner(row,5);stroke(row,C.Line,1,0.5)
        local bar=new("Frame",{Position=UD.fromOffset(0,8),Size=UD.fromOffset(2,20),BackgroundColor3=accent,BorderSizePixel=0,Parent=row})
        corner(bar,1)
        new("TextLabel",{Position=UD.fromOffset(12,4),Size=UD.new(1,-120,0,14),BackgroundTransparency=1,Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        new("TextLabel",{Position=UD.fromOffset(12,19),Size=UD.new(1,-120,0,11),BackgroundTransparency=1,Text=desc,TextColor3=C.Dim,Font=Enum.Font.Code,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local txt=btnText or "执行"
        local btn=new("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-12,.5,0),Size=UD.fromOffset(70,22),BackgroundColor3=accent,BorderSizePixel=0,Text=txt,TextColor3=C.Bg,Font=Enum.Font.GothamBold,TextSize=10,AutoButtonColor=false,Parent=row})
        corner(btn,4)
        local active=false
        local function setActive(v)
            active=v
            btn.Text=v and "关闭" or txt
            btn.BackgroundColor3=v and C.Red or accent
            btn.TextColor3=v and C.Text or C.Bg
        end
        btn.MouseEnter:Connect(function() if not active then tw(btn,0.15,{BackgroundTransparency=0.15}) end end)
        btn.MouseLeave:Connect(function() if not active then tw(btn,0.15,{BackgroundTransparency=0}) end end)
        btn.Activated:Connect(function()
            tw(btn,0.06,{Size=UD.fromOffset(66,20)});tw(btn,0.14,{Size=UD.fromOffset(70,22)})
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

    local function makeParagraph(parent,y,title,desc)
        local row=new("Frame",{Position=UD.fromOffset(10,y),Size=UD.new(1,-20,0,60),BackgroundColor3=C.Panel,BackgroundTransparency=0.3,BorderSizePixel=0,Parent=parent})
        corner(row,5);stroke(row,C.Line,1,0.5)
        new("TextLabel",{Position=UD.fromOffset(10,6),Size=UD.new(1,-20,0,14),BackgroundTransparency=1,Text=title,TextColor3=C.Cyan,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        new("TextLabel",{Position=UD.fromOffset(10,22),Size=UD.new(1,-20,0,32),BackgroundTransparency=1,Text=desc,TextColor3=C.Dim,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,Parent=row})
    end

    local function makeDropdown(parent,y,label,values,default,cb)
        local row=new("Frame",{Position=UD.fromOffset(10,y),Size=UD.new(1,-20,0,36),BackgroundColor3=C.Panel,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=parent})
        corner(row,5);stroke(row,C.Line,1,0.5)
        new("TextLabel",{Position=UD.fromOffset(12,4),Size=UD.new(1,-120,0,14),BackgroundTransparency=1,Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local curVal=default or values[1] or ""
        local valLbl=new("TextLabel",{Position=UD.fromOffset(12,19),Size=UD.new(1,-120,0,11),BackgroundTransparency=1,Text=tostring(curVal),TextColor3=C.Cyan,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
        local btn=new("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-12,.5,0),Size=UD.fromOffset(30,22),BackgroundColor3=C.Panel2,BorderSizePixel=0,Text="▼",TextColor3=C.Cyan,Font=Enum.Font.GothamBold,TextSize=11,AutoButtonColor=false,Parent=row})
        corner(btn,4);stroke(btn,C.Line,1,0.4)

        local menuOpen=false
        local menu
        btn.Activated:Connect(function()
            if menuOpen then
                if menu then menu:Destroy() end
                menuOpen=false
                return
            end
            menuOpen=true
            menu=new("Frame",{Position=UD.fromOffset(10,y+38),Size=UD.new(1,-20,0,math.min(#values*22+8,140)),BackgroundColor3=C.Bg,BorderSizePixel=0,ZIndex=50,Parent=parent})
            corner(menu,5);stroke(menu,C.Cyan,1,0.4)
            local scroll=new("ScrollingFrame",{Size=UD.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.Cyan,CanvasSize=UD.new(0,0,0,#values*22+8),ZIndex=51,Parent=menu})
            for i,v in ipairs(values) do
                local vb=new("TextButton",{Position=UD.fromOffset(4,i*22-18),Size=UD.new(1,-8,0,20),BackgroundColor3=C.Panel,BackgroundTransparency=0.15,BorderSizePixel=0,Text=tostring(v),TextColor3=C.Text,Font=Enum.Font.Gotham,TextSize=10,AutoButtonColor=false,ZIndex=52,Parent=scroll})
                corner(vb,3)
                vb.Activated:Connect(function()
                    curVal=v
                    valLbl.Text=tostring(v)
                    if menu then menu:Destroy() end
                    menuOpen=false
                    if cb then cb(v) end
                end)
            end
        end)

        local api={}
        function api:Refresh(newValues,newDefault)
            values=newValues
            if newDefault then curVal=newDefault;valLbl.Text=tostring(newDefault) end
        end
        return api
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
                btn.Activated:Connect(function() cb(plr);overlay:Destroy() end)
            end
        end
        scroll.CanvasSize=UD.new(0,0,0,layout.AbsoluteContentSize.Y+10)
        xBtn.Activated:Connect(function() overlay:Destroy() end)
    end

    -- ========== 页面1：主要 ==========
    do
        local p=pages[1]
        makeParagraph(p,6,"Void V3","夜脚本功能整合版")
        makeParagraph(p,72,"主群","1081045774")
        makeActionBtn(p,140,"复制QQ群","1081045774",C.Cyan,"复制",function()
            if setclipboard then setclipboard("1081045774");notify("复制成功","已复制QQ群",2) end
        end)
        makeParagraph(p,182,"V3 版本更新","整合夜脚本全部功能\n保留 Void 原UI框架\n包含自瞄/透视/甩飞/传送等全套功能")
    end

    -- ========== 页面2：玩家 ==========
    do
        local p=pages[2]
        local _,dl=makeToggle(p,6,"开启速度修改","原始移速: "..math.floor(baseSpeed+0.5),C.Cyan,false,function(v)
            SpeedEnabled=v
            local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if v then
                    hum.WalkSpeed=TargetWalkSpeed
                    AddFeature("速度修改")
                else
                    hum.WalkSpeed=baseSpeed
                    RemoveFeature("速度修改")
                end
            end
        end)
        speedToggleDesc=dl
        makeSlider(p,46,"速度数值",C.Cyan,0,400,TargetWalkSpeed,"",0,function(v)
            TargetWalkSpeed=v
            if SpeedEnabled then
                local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed=v end
            end
        end)
        makeToggle(p,88,"开启跳跃修改","自定义跳跃",C.Purple,false,function(v)
            CustomJumpEnabled=v
            local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if v then
                    hum.UseJumpPower=true
                    hum.JumpPower=CustomJumpValue
                    AddFeature("跳跃修改")
                else
                    hum.JumpPower=OriginalJump
                    RemoveFeature("跳跃修改")
                end
            end
        end)
        makeSlider(p,128,"跳跃高度",C.Purple,50,600,CustomJumpValue,"",0,function(v)
            CustomJumpValue=v
            if CustomJumpEnabled then
                local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.UseJumpPower=true;hum.JumpPower=v end
            end
        end)
        makeToggle(p,170,"无限跳跃","INFINITE JUMP",C.Cyan,false,function(v)
            InfiniteJumpEnabled=v
            if v then AddFeature("无限跳") else RemoveFeature("无限跳") end
        end)
        makeToggle(p,210,"开启快速跑步","FAST RUN",C.Green,false,function(enabled)
            if enabled then
                if _G._voidFastRun then _G._voidFastRun:Disconnect() end
                _G._voidFastRun=RunService.Heartbeat:Connect(function()
                    local lp=LP
                    if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.MoveDirection.Magnitude>0 then
                        lp.Character:TranslateBy(lp.Character.Humanoid.MoveDirection*(_G._voidFastRunSpeed or 50)/0.5)
                    end
                end)
                AddFeature("快速跑步")
            else
                if _G._voidFastRun then _G._voidFastRun:Disconnect();_G._voidFastRun=nil end
                RemoveFeature("快速跑步")
            end
        end)
        makeSlider(p,250,"快速跑步强度",C.Green,0,200,50,"",0,function(v)
            _G._voidFastRunSpeed=v
        end)
    end

    -- ========== 页面3：通用 ==========
    do
        local p=pages[3]
        makeActionBtn(p,6,"一键飞行","flyab.lua",C.Cyan,"启动",function()
            local ok,err=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/flyab.lua"))() end)
            if ok then notify("成功","飞行已加载",2) else notify("错误",tostring(err),3) end
        end)
        makeActionBtn(p,46,"枪械飞行","fly",C.Cyan,"启动",function()
            local ok,err=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/fly"))() end)
            if ok then notify("成功","枪械飞行已加载",2) else notify("错误",tostring(err),3) end
        end)
        makeToggle(p,86,"穿墙","NOCLIP",C.Cyan,false,function(enabled)
            if enabled then
                if not _G._voidNoclip then
                    _G._voidNoclip=RunService.Stepped:Connect(function()
                        local char=LP.Character
                        if not char then return end
                        for _,part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide=false end
                        end
                    end)
                end
                AddFeature("穿墙")
            else
                if _G._voidNoclip then _G._voidNoclip:Disconnect();_G._voidNoclip=nil end
                local char=LP.Character
                if char then
                    for _,part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then part.CanCollide=true end
                    end
                end
                RemoveFeature("穿墙")
            end
        end)
        makeToggle(p,126,"自由视角","FREECAM",C.Cyan,false,function(v)
            if v then
                StartFreecam();notify("自由视角","已开启",2);AddFeature("自由视角")
            else
                StopFreecam();notify("自由视角","已关闭",2);RemoveFeature("自由视角")
            end
        end)
        makeSlider(p,166,"自由视角速度",C.Cyan,1,20,2,"",1,function(v) Freecam.Speed=v end)
        makeToggle(p,206,"防摔落伤害","ANTI FALL",C.Green,false,function(v)
            ToggleAntiFall(v)
            if v then AddFeature("防摔") else RemoveFeature("防摔") end
        end)
        makeToggle(p,246,"防摔落伤害2","备用",C.Green,false,function(v)
            AntiFall2Enabled=v
            if v then notify("防摔2","已开启",3);AddFeature("防摔2") else notify("防摔2","已关闭",3);RemoveFeature("防摔2") end
        end)
        makeToggle(p,286,"强制第三人称","THIRD PERSON",C.Purple,false,function(v)
            if v then EnableUnlock();AddFeature("第三人称") else DisableUnlock();RemoveFeature("第三人称") end
        end)
        makeActionBtn(p,326,"闪电尖兵大招","瞬移UI",C.Purple,"启动",function(setActive,active)
            if active then DisableTPUI();else EnableTPUI();end
        end)
        makeToggle(p,366,"杀死光环","KILL AURA",C.Red,false,function(v)
            if v then AddFeature("光环(未实现)") else RemoveFeature("光环(未实现)") end
        end)
    end

    -- ========== 页面4：透视 ==========
    do
        local p=pages[4]
        makeParagraph(p,6,"提示","旧互动少但中文，新版更多但英文")
        makeToggle(p,72,"NPC透视","NPC ESP",C.Cyan,false,function(v)
            ToggleNPCESP(v)
            if v then AddFeature("NPC透视") else RemoveFeature("NPC透视") end
        end)
        makeToggle(p,112,"旧版互动透视","INTERACT ESP",C.Green,false,function(v)
            ToggleInteractESP(v)
            if v then AddFeature("互动透视") else RemoveFeature("互动透视") end
        end)
        makeToggle(p,152,"新版互动透视","NEW INTERACT ESP",C.Green,false,function(v)
            ToggleNewInteractESP(v)
            if v then AddFeature("新版互动透视") else RemoveFeature("新版互动透视") end
        end)
        makeActionBtn(p,192,"刷新新版ESP","",C.Cyan,"刷新",function()
            ToggleNewInteractESP(false);task.wait(0.2);ToggleNewInteractESP(true)
        end)
        makeToggle(p,232,"玩家透视","PLAYER ESP",C.Cyan,false,function(v)
            PLAYER_ESP.Enabled=v
            if not v then ClearPlayerESP() end
            if v then AddFeature("玩家透视") else RemoveFeature("玩家透视") end
        end)
        makeToggle(p,272,"高亮","HIGHLIGHT",C.Cyan,false,function(v) PLAYER_ESP.HighlightEnabled=v end)
        makeToggle(p,312,"方框","BOX",C.Cyan,false,function(v) PLAYER_ESP.BoxEnabled=v end)
        makeToggle(p,352,"名字","NAME",C.Cyan,false,function(v) PLAYER_ESP.ShowName=v end)
        makeToggle(p,392,"血量","HEALTH",C.Cyan,false,function(v) PLAYER_ESP.ShowHealth=v end)
        makeToggle(p,432,"距离","DISTANCE",C.Cyan,false,function(v) PLAYER_ESP.ShowDist=v end)
        makeToggle(p,472,"队伍检测","TEAM CHECK",C.Purple,false,function(v) PLAYER_ESP.TeamCheck=v end)
    end

    -- ========== 页面5：视觉 ==========
    do
        local p=pages[5]
        makeToggle(p,6,"普通夜视","NORMAL NIGHT",C.Cyan,false,function(v)
            ApplyNormalNightVision(v)
            if v then AddFeature("夜视") else RemoveFeature("夜视") end
        end)
        makeToggle(p,46,"超级夜视","SUPER NIGHT",C.Purple,false,function(v)
            ApplySuperNightVision(v)
            if v then AddFeature("超级夜视") else RemoveFeature("超级夜视") end
        end)
        makeToggle(p,86,"彻底去雾","NO FOG",C.Cyan,false,function(v)
            ApplyNoFog(v)
            if v then AddFeature("去雾") else RemoveFeature("去雾") end
        end)
        makeActionBtn(p,126,"关闭所有夜视/去雾","",C.Red,"关闭",function()
            ApplyNormalNightVision(false);ApplySuperNightVision(false);ApplyNoFog(false)
        end)
        makeToggle(p,166,"功能列表显示","FEATURE DISPLAY",C.Cyan,true,function(v)
            FeatureDisplayEnabled=v
            if v then
                for _,item in pairs(FeatureItems) do if item then item:Destroy() end end
                FeatureItems={}
                task.wait(0.05)
                AddFeature("Void")
                RefreshFeatureUI()
            else
                RemoveFeature("Void")
                RefreshFeatureUI()
            end
        end)
        makeToggle(p,206,"自身血量显示","HEALTH DISPLAY",C.Green,true,function(v)
            HealthDisplay.Enabled=v
            if HealthDisplay.Label then HealthDisplay.Label.Visible=v end
        end)
        makeActionBtn(p,246,"血量位置切换","循环切换",C.Green,"切换",function()
            local order={"LeftTop","RightTop","LeftBottom","RightBottom"}
            local idx=table.find(order,HealthDisplay.Position) or 1
            idx=(idx%#order)+1
            HealthDisplay.Position=order[idx]
            pcall(function() if writefile then writefile(HealthPosFile,HealthDisplay.Position) end end)
            UpdateHealthPosition()
        end)
    end

    -- ========== 页面6：自瞄 ==========
    do
        local p=pages[6]
        makeToggle(p,6,"自瞄开关","AIMBOT TOGGLE",C.Red,false,function(v)
            ESP_SETTINGS.HighlightEnabled=v
            if fovCircle then fovCircle.Visible=v end
            if v then AddFeature("自瞄") else RemoveFeature("自瞄") end
        end)
        makeToggle(p,46,"显示FOV圈","SHOW FOV",C.Cyan,true,function(v) ShowFOVCircle=v end)
        makeToggle(p,86,"队伍检测","TEAM CHECK",C.Purple,false,function(v) ESP_SETTINGS.TeamCheck=v end)
        makeToggle(p,126,"墙体检测","WALL CHECK",C.Purple,false,function(v) ESP_SETTINGS.WallCheck=v end)
        makeSlider(p,166,"自瞄范围(FOV)",C.Cyan,10,700,FOV,"",0,function(v) FOV=v end)
        makeSlider(p,206,"最大距离",C.Cyan,50,6000,MaxDistance,"",0,function(v) MaxDistance=v end)
        makeToggle(p,246,"平滑自瞄","SMOOTH AIM",C.Cyan,false,function(v) ESP_SETTINGS.SmoothAim=v end)
        makeActionBtn(p,286,"瞄准部位: Head","点击切换",C.Cyan,"切换",function()
            local order={"Head","HumanoidRootPart","UpperTorso","Torso"}
            local idx=table.find(order,AimPart) or 1
            AimPart=order[(idx%#order)+1]
            notify("瞄准部位","当前: "..AimPart,2)
        end)
        makeToggle(p,326,"指定自瞄目标","LOCK TARGET",C.Red,false,function(v) LockTargetEnabled=v end)
        makeActionBtn(p,366,"选择自瞄玩家","点击选择",C.Cyan,"选择",function()
            showPlayerSelect(function(plr)
                SelectedTarget=plr
                notify("自瞄目标",plr.Name,2)
            end)
        end)
        makeToggle(p,406,"启用团队白名单","TEAM WHITELIST",C.Purple,false,function(v) AimbotTeamWhitelistEnabled=v end)
        makeActionBtn(p,446,"清空白名单","TEAM CLEAR",C.Red,"清除",function()
            AimbotTeamWhitelist={}
            notify("白名单","已清空",2)
        end)
    end

    -- ========== 页面7：传送与甩飞 ==========
    do
        local p=pages[7]
        makeParagraph(p,6,"警告","循环甩飞时不要手动重生")
        makeActionBtn(p,72,"选择目标玩家","TP Target",C.Cyan,"选择",function()
            showPlayerSelect(function(plr)
                TP_SelectedPlayer=plr
                SelectedTarget=plr
                notify("目标",plr.Name,2)
            end)
        end)
        makeActionBtn(p,112,"选择所有人","ALL",C.Purple,"选择",function()
            TP_SelectedPlayer="ALL"
            notify("目标","所有人",2)
        end)
        makeActionBtn(p,152,"传送到玩家","TELEPORT",C.Cyan,"执行",function()
            local target=TP_SelectedPlayer
            if target then TeleportToPlayer(target) end
        end)
        makeToggle(p,192,"循环传送","LOOP TP",C.Cyan,false,function(v)
            TP_Loop=v
            if v then
                AlreadyNotified={}
                _G._voidTPLoop=RunService.Heartbeat:Connect(function()
                    local target=TP_SelectedPlayer or SelectedTarget
                    if target then
                        if not AlreadyNotified[target] then MonitorTarget(target) end
                        TeleportToPlayer(target)
                    end
                end)
                AddFeature("循环传送")
            else
                if _G._voidTPLoop then _G._voidTPLoop:Disconnect();_G._voidTPLoop=nil end
                RemoveFeature("循环传送")
            end
        end)
        makeToggle(p,232,"观战玩家","SPECTATE",C.Purple,false,function(v)
            if v then
                local target=TP_SelectedPlayer or SelectedTarget
                if target then SpectatePlayer(target);AddFeature("观战") end
            else
                StopSpectate();RemoveFeature("观战")
            end
        end)
        makeActionBtn(p,272,"甩飞一次","FLING ONCE",C.Red,"执行",function()
            if TP_SelectedPlayer=="ALL" then
                for _,pl in ipairs(Players:GetPlayers()) do
                    if pl~=LP then
                        SkidFling(pl)
                        repeat task.wait() until not Flinging
                        task.wait(0.1)
                    end
                end
            else
                local target=TP_SelectedPlayer or SelectedTarget
                if target then SkidFling(target) end
            end
        end)
        makeToggle(p,312,"循环甩飞","LOOP FLING",C.Red,false,function(v)
            if v then StartFlingLoop();AddFeature("循环甩飞")
            else StopFlingLoop();RemoveFeature("循环甩飞") end
        end)
        makeToggle(p,352,"人物自转","SPIN",C.Purple,false,function(v)
            SpinEnabled=v
            if v then StartSpin();AddFeature("自转")
            else StopSpin();RemoveFeature("自转") end
        end)
        makeSlider(p,392,"旋转速度",C.Purple,1,200,SpinSpeed,"",0,function(v) SpinSpeed=v end)
    end

    -- ========== 页面8：服务器功能 ==========
    do
        local p=pages[8]
        makeParagraph(p,6,"免责声明","以下脚本来自网络，如有异议请联系删除")
        local links={
            {"竞争对手（伊散）","https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/weiifnrnfj"},
            {"最强战场（凌乱）","https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/最强战场"},
            {"墨水游戏（Rb）","https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/ink"},
            {"终极战场（kanl）","https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/终极战场"},
            {"战争大亨（alienx）","https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/战争大亨"},
            {"99夜（Rb）","https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/99夜"},
            {"狙击竞技场（YG）","https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/yg狙击竞技场"},
            {"L&C","https://raw.githubusercontent.com/XOTRXONY/AUREATE/main/lc.lua"},
            {"子弹追踪","https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/子追"},
        }
        local yy=72
        for _,info in ipairs(links) do
            local nm,u=info[1],info[2]
            makeBigBtn(p,yy,nm,C.Red,function()
                notify("加载中","正在加载 "..nm,2)
                local ok,err=pcall(function() loadstring(game:HttpGet(u))() end)
                if ok then notify("成功",nm.." 已加载",2)
                else notify("错误",nm.." 加载失败",3) end
            end)
            yy=yy+60
        end
    end

    -- ========== 页面9：动作功能 ==========
    do
        local p=pages[9]
        makeParagraph(p,6,"提示","动作别人可见，新玩家需重开")
        local player2=LP
        local currentTrack=nil
        player2.CharacterAdded:Connect(function() currentTrack=nil end)
        local function GetAnimator()
            local character=player2.Character or player2.CharacterAdded:Wait()
            local humanoid=character:WaitForChild("Humanoid")
            local animator=humanoid:FindFirstChildOfClass("Animator")
            if not animator then animator=Instance.new("Animator");animator.Parent=humanoid end
            return animator
        end
        local function PlayAnim(animId)
            local animator=GetAnimator()
            if currentTrack then currentTrack:Stop();currentTrack:Destroy();currentTrack=nil end
            local anim=Instance.new("Animation")
            anim.AnimationId=animId
            local track=animator:LoadAnimation(anim)
            anim:Destroy()
            track.Priority=Enum.AnimationPriority.Action
            track.Looped=true
            track:Play()
            currentTrack=track
        end
        local function StopAllAnim()
            if currentTrack then currentTrack:Stop();currentTrack:Destroy();currentTrack=nil end
            local character=player2.Character
            if character then
                local humanoid=character:FindFirstChild("Humanoid")
                if humanoid then
                    local animator=humanoid:FindFirstChildOfClass("Animator")
                    if animator then
                        for _,track in pairs(animator:GetPlayingAnimationTracks()) do
                            track:Stop()
                        end
                    end
                end
            end
        end
        makeBigBtn(p,72,"关闭所有动作",C.Red,StopAllAnim)
        local anims={
            {"环绕身体动作","rbxassetid://109873544976020"},
            {"无头","rbxassetid://78837807518622"},
            {"直升机","rbxassetid://95301257497525"},
            {"飞机","rbxassetid://82135680487389"},
            {"坦克","rbxassetid://94915612757079"},
            {"假死","rbxassetid://88130117312312"},
            {"投降","rbxassetid://100537772865440"},
        }
        local yy=132
        for _,info in ipairs(anims) do
            makeBigBtn(p,yy,info[1],C.Purple,function() PlayAnim(info[2]) end)
            yy=yy+60
        end
    end

    -- ========== 页面10：终止 ==========
    do
        local p=pages[10]
        makeBigBtn(p,10,"强制退出",C.Red,function()
            local ok,err=pcall(function() game:Shutdown() end)
            if ok then notify("退出","成功",4) else notify("踢出失败",tostring(err),5) end
        end)
        makeBigBtn(p,70,"自杀（重生）",C.Red,function()
            local char=LP.Character
            if char then
                local hum=char:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health=0;notify("已自杀","角色已重生",2)
                else notify("失败","未找到Humanoid",2) end
            else notify("失败","角色未加载",2) end
        end)
    end

    -- ========== 页面11：配置 ==========
    do
        local p=pages[11]
        makeToggle(p,6,"管理员检测","ADMIN DETECT",C.Cyan,true,function(v) AdminDetectEnabled=v end)
        makeActionBtn(p,46,"重新进入服务器","REJOIN",C.Purple,"执行",function()
            notify("正在重进","请稍候...",3)
            local TeleportService=game:GetService("TeleportService")
            TeleportService:Teleport(game.PlaceId,LP)
        end)
        makeActionBtn(p,86,"绕过群组检测","BYPASS",C.Red,"执行",function()
            local ok=pcall(function()
                local Speaker=LP
                local OldNameCall
                OldNameCall=hookmetamethod(game,"__namecall",function(self,...)
                    if self~=Speaker or getnamecallmethod()~="IsInGroup" then
                        return OldNameCall(self,...)
                    end
                    return true
                end)
                hookfunction(Speaker.IsInGroup,function(self,...) return true end)
            end)
            if ok then notify("成功","已绕过",2) else notify("错误","失败",3) end
        end)
    end

    -- ========== Tab切换 ==========
    local currentTab=1
    local function switchTab(idx)
        if idx==currentTab then return end
        tabBtns[currentTab].TextColor3=C.Dim
        tabBtns[idx].TextColor3=C.Text
        pages[currentTab].Visible=false
        pages[idx].Visible=true
        tw(tabHighlight,0.22,{Position=UD.fromOffset((idx-1)/tabCount*WIN_W,23)})
        currentTab=idx
    end
    for i,b in ipairs(tabBtns) do
        b.Activated:Connect(function() switchTab(i) end)
    end

    -- ========== 底部状态栏 ==========
    local sb=new("Frame",{Position=UD.new(0,1,-24),Size=UD.new(1,0,0,24),BackgroundColor3=C.Panel,BackgroundTransparency=0.35,BorderSizePixel=0,Parent=main})
    corner(sb,8)
    new("Frame",{Position=UD.new(0,0,0,0),Size=UD.new(1,0,0,8),BackgroundColor3=C.Panel,BackgroundTransparency=0.35,BorderSizePixel=0,Parent=sb})
    new("Frame",{Position=UD.new(0,0,0,0),Size=UD.new(1,0,0,1),BackgroundColor3=C.Line,BackgroundTransparency=0.4,BorderSizePixel=0,Parent=sb})
    new("TextLabel",{Position=UD.fromOffset(20,0),Size=UD.fromOffset(90,24),BackgroundTransparency=1,Text="VOID V3",TextColor3=C.Green,Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=sb})

    -- ========== 最小化按钮 ==========
    local MINI=46
    local miniHomePos=UD.fromOffset(CAM.ViewportSize.X-MINI-20,CAM.ViewportSize.Y*0.4)
    local mini=new("TextButton",{Position=miniHomePos,Size=UD.fromOffset(MINI,MINI),BackgroundColor3=C.Bg,BorderSizePixel=0,Text="",AutoButtonColor=false,Visible=false,Parent=gui})
    corner(mini,MINI/2);stroke(mini,C.Cyan,1.4,0.2)
    local msc=new("UIScale",{Scale=1,Parent=mini})
    new("TextLabel",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="V",TextColor3=C.Cyan,Font=Enum.Font.GothamBold,TextSize=20,Parent=mini})

    main:GetPropertyChangedSignal("Position"):Connect(function() if main.Visible then mainHomePos=main.Position end end)
    makeDraggable(mini,mini,function()
        mini.Visible=false
        main.Position=mainHomePos
        main.Visible=true
        mainScale.Scale=0.86
        tw(mainScale,0.3,{Scale=1},Enum.EasingStyle.Back)
    end)
    makeDraggable(main,dragHandle)

    minBtn.Activated:Connect(function()
        main.Visible=false
        mini.Position=UD.fromOffset(CAM.ViewportSize.X-MINI-20,CAM.ViewportSize.Y*0.4)
        mini.Visible=true
        msc.Scale=0.4
        tw(msc,0.35,{Scale=1},Enum.EasingStyle.Back)
    end)
    closeBtn.Activated:Connect(function()
        main.Visible=false
        mini.Visible=false
        gui:Destroy()
    end)

    main.Visible=true
    mainScale.Scale=0.86
    tw(mainScale,0.38,{Scale=1},Enum.EasingStyle.Back)
end

buildUI()

-- ================= 初始化功能列表 =================
task.spawn(function()
    for _,item in pairs(FeatureItems) do if item then item:Destroy() end end
    FeatureItems={}
    task.wait(0.05)
    AddFeature("Void")
    RefreshFeatureUI()
end)

-- ================= 自瞄主循环 =================
AimbotConnection=RunService.RenderStepped:Connect(function()
    if fovCircle then
        local size=FOV*2
        fovCircle.Size=UDim2.new(0,size,0,size)
        local shouldShow=ESP_SETTINGS.HighlightEnabled and ShowFOVCircle
        if fovCircle.Visible~=shouldShow then fovCircle.Visible=shouldShow end
    end
    if not CAM then return end
    if not ESP_SETTINGS.HighlightEnabled then return end
    local target=getTarget()
    if target and target.Character then
        local part=GetAimPart(target.Character)
        if part then
            local camPos=CAM.CFrame.Position
            local direction=(part.Position-camPos).Unit
            local newCF=CFrame.new(camPos,camPos+direction)
            if ESP_SETTINGS.SmoothAim then
                CAM.CFrame=CAM.CFrame:Lerp(newCF,Smoothness)
            else
                CAM.CFrame=newCF
            end
        end
    end
end)

notify("脚本加载成功","感谢使用 Void V3",3)
