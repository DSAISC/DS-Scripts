local p=game:GetService("Players").LocalPlayer
local U=game:GetService("UserInputService")
local R=game:GetService("RunService")
local g=Instance.new("ScreenGui",p:WaitForChild("PlayerGui"))
g.ResetOnSpawn=false

-- Main
local m=Instance.new("Frame",g)
m.BackgroundColor3=Color3.fromRGB(24,24,24)
m.Size=UDim2.new(0,300,0,0)
m.AutomaticSize=Enum.AutomaticSize.Y
m.Position=UDim2.new(.5,-150,.1,0)
m.BorderSizePixel=0
Instance.new("UICorner",m).CornerRadius=UDim.new(0,10)
local l=Instance.new("UIListLayout",m)
l.Padding=UDim.new(0,8)
l.HorizontalAlignment=Enum.HorizontalAlignment.Center
l.SortOrder=Enum.SortOrder.LayoutOrder

-- Titlebar
local t=Instance.new("Frame",m)
t.BackgroundColor3=Color3.fromRGB(35,35,35)
t.Size=UDim2.new(1,-20,0,40)
t.BorderSizePixel=0
t.LayoutOrder=0
Instance.new("UICorner",t).CornerRadius=UDim.new(0,8)
local dr=Instance.new("TextButton",t)
dr.BackgroundTransparency=1
dr.Size=UDim2.new(1,0,1,0)
dr.Text=""
dr.ZIndex=0
local ti=Instance.new("TextButton",t)
ti.Text="DS通用脚本"
ti.TextColor3=Color3.fromRGB(255,255,255)
ti.BackgroundTransparency=1
ti.Size=UDim2.new(0,130,1,0)
ti.Position=UDim2.new(0,8,0,0)
ti.Font=Enum.Font.GothamBold
ti.TextSize=16
ti.TextXAlignment=Enum.TextXAlignment.Left
ti.ZIndex=2
local minB=Instance.new("TextButton",t)
minB.Text="—"
minB.TextColor3=Color3.fromRGB(255,255,255)
minB.BackgroundColor3=Color3.fromRGB(55,55,55)
minB.Font=Enum.Font.GothamBold
minB.TextSize=16
minB.Size=UDim2.new(0,30,0,28)
minB.Position=UDim2.new(1,-70,.5,-14)
minB.ZIndex=2
minB.BorderSizePixel=0
Instance.new("UICorner",minB).CornerRadius=UDim.new(0,4)
local clsB=Instance.new("TextButton",t)
clsB.Text="✕"
clsB.TextColor3=Color3.fromRGB(255,255,255)
clsB.BackgroundColor3=Color3.fromRGB(180,50,50)
clsB.Font=Enum.Font.GothamBold
clsB.TextSize=14
clsB.Size=UDim2.new(0,30,0,28)
clsB.Position=UDim2.new(1,-34,.5,-14)
clsB.ZIndex=2
clsB.BorderSizePixel=0
Instance.new("UICorner",clsB).CornerRadius=UDim.new(0,4)

-- Info popup
local inf=Instance.new("Frame",t)
inf.BackgroundColor3=Color3.fromRGB(45,45,45)
inf.Size=UDim2.new(0,240,0,64)
inf.Position=UDim2.new(0,10,1,6)
inf.Visible=false
inf.ZIndex=10
inf.BorderSizePixel=0
Instance.new("UICorner",inf).CornerRadius=UDim.new(0,6)
Instance.new("UIStroke",inf).Color=Color3.fromRGB(80,80,80)
local itx=Instance.new("TextLabel",inf)
itx.Text="本脚本为DeepSeek AI生成，所以名称为DS"
itx.TextColor3=Color3.fromRGB(230,230,230)
itx.BackgroundTransparency=1
itx.Size=UDim2.new(1,-16,0,36)
itx.Position=UDim2.new(0,8,0,8)
itx.Font=Enum.Font.GothamMedium
itx.TextSize=14
itx.TextWrapped=true
itx.ZIndex=10
local cib=Instance.new("TextButton",inf)
cib.Text="关闭"
cib.TextColor3=Color3.fromRGB(255,255,255)
cib.BackgroundColor3=Color3.fromRGB(70,70,70)
cib.Font=Enum.Font.GothamBold
cib.TextSize=12
cib.Size=UDim2.new(0,46,0,22)
cib.Position=UDim2.new(1,-54,1,-28)
cib.ZIndex=11
cib.BorderSizePixel=0
Instance.new("UICorner",cib).CornerRadius=UDim.new(0,4)

ti.MouseButton1Click:Connect(function()inf.Visible=not inf.Visible end)
cib.MouseButton1Click:Connect(function()inf.Visible=false end)
clsB.MouseButton1Click:Connect(function()g:Destroy()end)
local mRest=Instance.new("TextButton",g)
mRest.Text="DS"
mRest.TextColor3=Color3.fromRGB(255,255,255)
mRest.BackgroundColor3=Color3.fromRGB(35,35,35)
mRest.Font=Enum.Font.GothamBold
mRest.TextSize=14
mRest.Size=UDim2.new(0,44,0,44)
mRest.Position=UDim2.new(1,-54,.5,-22)
mRest.Visible=false
mRest.BorderSizePixel=0
Instance.new("UICorner",mRest).CornerRadius=UDim.new(1,0)
minB.MouseButton1Click:Connect(function()m.Visible=false;mRest.Visible=true end)
mRest.MouseButton1Click:Connect(function()m.Visible=true;mRest.Visible=false end)

-- Drag
local drag,ds,fs=false,nil,nil
dr.InputBegan:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
		drag=true;ds=inp.Position;fs=m.Position
		inp.Changed:Connect(function()
			if inp.UserInputState==Enum.UserInputState.End then drag=false;ds=nil;fs=nil end
		end)
	end
end)
U.InputChanged:Connect(function(inp)
	if drag and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
		local d=inp.Position-ds
		m.Position=UDim2.new(fs.X.Scale,fs.X.Offset+d.X,fs.Y.Scale,fs.Y.Offset+d.Y)
	end
end)

-- States
local s={
	walkspeed=false,walkspeedValue=50,
	jumppower=false,jumppowerValue=100,
	noclip=false,
	esp=false,espShowName=true,espHighlight=true,
}

-- ESP
local eb,eh,ec={},{},{}
local function uesp(pl)
	local ch=pl.Character
	if not ch or pl==p then return end
	if eb[pl]then eb[pl]:Destroy();eb[pl]=nil end
	if eh[pl]then eh[pl]:Destroy();eh[pl]=nil end
	if not s.esp then return end
	if s.espShowName then
		local rp=ch:FindFirstChild("HumanoidRootPart")
		if rp then
			local b=Instance.new("BillboardGui",ch)
			b.Adornee=rp;b.Size=UDim2.new(0,100,0,40);b.StudsOffset=Vector3.new(0,3,0)
			b.AlwaysOnTop=true;b.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
			local la=Instance.new("TextLabel",b)
			la.Size=UDim2.new(1,0,1,0);la.BackgroundTransparency=1
			la.TextColor3=Color3.fromRGB(0,255,0);la.TextStrokeTransparency=0
			la.TextStrokeColor3=Color3.fromRGB(0,0,0);la.Text=pl.Name
			la.Font=Enum.Font.GothamBold;la.TextSize=14;la.TextScaled=true;la.BorderSizePixel=0
			eb[pl]=b
		end
	end
	if s.espHighlight then
		local hl=Instance.new("Highlight",ch)
		hl.Name="ESP";hl.Adornee=ch
		hl.FillColor=Color3.fromRGB(255,255,0);hl.OutlineColor=Color3.fromRGB(255,255,255)
		hl.FillTransparency=.5;hl.OutlineTransparency=0;hl.Enabled=true
		eh[pl]=hl
	end
end
local function aesp(pl)
	if pl==p then return end
	if ec[pl]then ec[pl]:Disconnect()end
	uesp(pl)
	ec[pl]=pl.CharacterAdded:Connect(function()uesp(pl)end)
end
local function resp(pl)
	if ec[pl]then ec[pl]:Disconnect();ec[pl]=nil end
	if eb[pl]then eb[pl]:Destroy();eb[pl]=nil end
	if eh[pl]then eh[pl]:Destroy();eh[pl]=nil end
end
local function raesp()
	for _,v in ipairs(game:GetService("Players"):GetPlayers())do
		if v~=p then uesp(v)end
	end
end
game:GetService("Players").PlayerAdded:Connect(function(pl)
	if s.esp and pl~=p then aesp(pl)end
end)
game:GetService("Players").PlayerRemoving:Connect(resp)

-- UI builders
local function adjRow(nm,k,def,ord)
	local r=Instance.new("Frame",m)
	r.BackgroundColor3=Color3.fromRGB(35,35,35);r.Size=UDim2.new(1,-20,0,44)
	r.LayoutOrder=ord;r.BorderSizePixel=0
	Instance.new("UICorner",r).CornerRadius=UDim.new(0,8)
	local lb=Instance.new("TextLabel",r)
	lb.Text=nm;lb.TextColor3=Color3.fromRGB(210,210,210);lb.BackgroundTransparency=1
	lb.Size=UDim2.new(0,75,1,0);lb.Position=UDim2.new(0,10,0,0)
	lb.Font=Enum.Font.GothamMedium;lb.TextSize=13;lb.TextXAlignment=Enum.TextXAlignment.Left
	local vb=Instance.new("TextBox",r)
	vb.Text=tostring(def);vb.BackgroundColor3=Color3.fromRGB(50,50,50)
	vb.TextColor3=Color3.fromRGB(255,255,255);vb.Font=Enum.Font.GothamMedium;vb.TextSize=13
	vb.Size=UDim2.new(0,48,0,26);vb.Position=UDim2.new(0,90,.5,-13)
	vb.ClearTextOnFocus=false;vb.TextEditable=true;vb.BorderSizePixel=0
	Instance.new("UICorner",vb).CornerRadius=UDim.new(0,4)
	local tb=Instance.new("TextButton",r)
	tb.Text="关";tb.BackgroundColor3=Color3.fromRGB(180,35,35)
	tb.TextColor3=Color3.fromRGB(255,255,255);tb.Font=Enum.Font.GothamBold;tb.TextSize=13
	tb.Size=UDim2.new(0,50,0,28);tb.Position=UDim2.new(1,-58,.5,-14);tb.BorderSizePixel=0
	Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)
	local function uv(a)
		tb.Text=a and"开"or"关"
		tb.BackgroundColor3=a and Color3.fromRGB(30,150,30)or Color3.fromRGB(180,35,35)
	end
	vb.FocusLost:Connect(function()
		local n=tonumber(vb.Text)
		if n and n>0 then s[k.."Value"]=n else vb.Text=tostring(s[k.."Value"])end
	end)
	tb.MouseButton1Click:Connect(function()
		s[k]=not s[k];uv(s[k])
	end)
	s[k.."Value"]=def
end
local function espRow(ord)
	local r=Instance.new("Frame",m)
	r.BackgroundColor3=Color3.fromRGB(35,35,35);r.Size=UDim2.new(1,-20,0,0)
	r.AutomaticSize=Enum.AutomaticSize.Y;r.LayoutOrder=ord;r.BorderSizePixel=0
	Instance.new("UICorner",r).CornerRadius=UDim.new(0,8)
	local rl=Instance.new("UIListLayout",r)
	rl.Padding=UDim.new(0,4);rl.HorizontalAlignment=Enum.HorizontalAlignment.Center;rl.SortOrder=Enum.SortOrder.LayoutOrder
	local top=Instance.new("Frame",r)
	top.BackgroundTransparency=1;top.Size=UDim2.new(1,0,0,44);top.LayoutOrder=0
	local lb=Instance.new("TextLabel",top)
	lb.Text="玩家透视";lb.TextColor3=Color3.fromRGB(210,210,210);lb.BackgroundTransparency=1
	lb.Size=UDim2.new(0,75,1,0);lb.Position=UDim2.new(0,10,0,0)
	lb.Font=Enum.Font.GothamMedium;lb.TextSize=13;lb.TextXAlignment=Enum.TextXAlignment.Left
	local ex=Instance.new("TextButton",top)
	ex.Text="▼";ex.BackgroundColor3=Color3.fromRGB(55,55,55)
	ex.TextColor3=Color3.fromRGB(255,255,255);ex.Font=Enum.Font.GothamBold;ex.TextSize=12
	ex.Size=UDim2.new(0,28,0,28);ex.Position=UDim2.new(0,92,.5,-14);ex.BorderSizePixel=0
	Instance.new("UICorner",ex).CornerRadius=UDim.new(0,4)
	local tb=Instance.new("TextButton",top)
	tb.Text="关";tb.BackgroundColor3=Color3.fromRGB(180,35,35)
	tb.TextColor3=Color3.fromRGB(255,255,255);tb.Font=Enum.Font.GothamBold;tb.TextSize=13
	tb.Size=UDim2.new(0,50,0,28);tb.Position=UDim2.new(1,-58,.5,-14);tb.BorderSizePixel=0
	Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)
	local sf=Instance.new("Frame",r)
	sf.BackgroundTransparency=1;sf.Size=UDim2.new(1,-16,0,0)
	sf.AutomaticSize=Enum.AutomaticSize.Y;sf.Visible=false;sf.LayoutOrder=1
	local sl=Instance.new("UIListLayout",sf)
	sl.Padding=UDim.new(0,4);sl.HorizontalAlignment=Enum.HorizontalAlignment.Center;sl.SortOrder=Enum.SortOrder.LayoutOrder
	local function stoggle(nm,k,so)
		local sr=Instance.new("Frame",sf)
		sr.BackgroundColor3=Color3.fromRGB(40,40,40);sr.Size=UDim2.new(1,0,0,32)
		sr.LayoutOrder=so;sr.BorderSizePixel=0
		Instance.new("UICorner",sr).CornerRadius=UDim.new(0,4)
		local slb=Instance.new("TextLabel",sr)
		slb.Text="  "..nm;slb.TextColor3=Color3.fromRGB(200,200,200);slb.BackgroundTransparency=1
		slb.Size=UDim2.new(1,-60,1,0);slb.Font=Enum.Font.GothamMedium;slb.TextSize=12;slb.TextXAlignment=Enum.TextXAlignment.Left
		local stb=Instance.new("TextButton",sr)
		stb.Text="关";stb.BackgroundColor3=Color3.fromRGB(150,40,40)
		stb.TextColor3=Color3.fromRGB(255,255,255);stb.Font=Enum.Font.GothamBold;stb.TextSize=11
		stb.Size=UDim2.new(0,42,0,22);stb.Position=UDim2.new(1,-50,.5,-11);stb.BorderSizePixel=0
		Instance.new("UICorner",stb).CornerRadius=UDim.new(0,4)
		local function suv(v)
			stb.Text=v and"开"or"关"
			stb.BackgroundColor3=v and Color3.fromRGB(40,130,40)or Color3.fromRGB(150,40,40)
		end
		stb.MouseButton1Click:Connect(function()
			s[k]=not s[k];suv(s[k]);if s.esp then raesp()end
		end)
		suv(s[k])
	end
	stoggle("显示名字","espShowName",1)
	stoggle("高亮玩家","espHighlight",2)
	local exp=false
	ex.MouseButton1Click:Connect(function()
		exp=not exp;ex.Text=exp and"▲"or"▼";sf.Visible=exp
	end)
	local function umv(a)
		tb.Text=a and"开"or"关"
		tb.BackgroundColor3=a and Color3.fromRGB(30,150,30)or Color3.fromRGB(180,35,35)
	end
	tb.MouseButton1Click:Connect(function()
		s.esp=not s.esp;umv(s.esp)
		if s.esp then for _,v in ipairs(game:GetService("Players"):GetPlayers())do if v~=p then aesp(v)end end
		else for _,v in ipairs(game:GetService("Players"):GetPlayers())do resp(v)end end
	end)
end
local function toggleRow(nm,k,ord)
	local r=Instance.new("Frame",m)
	r.BackgroundColor3=Color3.fromRGB(35,35,35);r.Size=UDim2.new(1,-20,0,44)
	r.LayoutOrder=ord;r.BorderSizePixel=0
	Instance.new("UICorner",r).CornerRadius=UDim.new(0,8)
	local lb=Instance.new("TextLabel",r)
	lb.Text=nm;lb.TextColor3=Color3.fromRGB(210,210,210);lb.BackgroundTransparency=1
	lb.Size=UDim2.new(1,-70,1,0);lb.Position=UDim2.new(0,10,0,0)
	lb.Font=Enum.Font.GothamMedium;lb.TextSize=13;lb.TextXAlignment=Enum.TextXAlignment.Left
	local tb=Instance.new("TextButton",r)
	tb.Text="关";tb.BackgroundColor3=Color3.fromRGB(180,35,35)
	tb.TextColor3=Color3.fromRGB(255,255,255);tb.Font=Enum.Font.GothamBold;tb.TextSize=13
	tb.Size=UDim2.new(0,50,0,28);tb.Position=UDim2.new(1,-58,.5,-14);tb.BorderSizePixel=0
	Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)
	tb.MouseButton1Click:Connect(function()
		s[k]=not s[k];tb.Text=s[k]and"开"or"关"
		tb.BackgroundColor3=s[k]and Color3.fromRGB(30,150,30)or Color3.fromRGB(180,35,35)
	end)
end

-- Fly window
local flyActive=false;local vert=0;local flyW,flyRest
local function destroyFly()
	flyActive=false;vert=0
	if flyW then flyW:Destroy();flyW=nil end
	if flyRest then flyRest:Destroy();flyRest=nil end
	local ch=p.Character;if ch then local h=ch:FindFirstChildOfClass("Humanoid")if h then h.PlatformStand=false end end
end
local function showFly()
	if flyW then return end
	flyW=Instance.new("Frame",g)
	flyW.BackgroundColor3=Color3.fromRGB(28,28,28);flyW.Size=UDim2.new(0,210,0,210)
	flyW.Position=UDim2.new(.5,-105,.3,0);flyW.BorderSizePixel=0
	Instance.new("UICorner",flyW).CornerRadius=UDim.new(0,8)
	local ft=Instance.new("Frame",flyW)
	ft.BackgroundColor3=Color3.fromRGB(38,38,38);ft.Size=UDim2.new(1,-16,0,36)
	ft.Position=UDim2.new(0,8,0,6);ft.BorderSizePixel=0
	Instance.new("UICorner",ft).CornerRadius=UDim.new(0,6)
	local fti=Instance.new("TextLabel",ft)
	fti.Text="ds飞行";fti.TextColor3=Color3.fromRGB(255,255,255);fti.BackgroundTransparency=1
	fti.Size=UDim2.new(1,-60,1,0);fti.Position=UDim2.new(0,10,0,0)
	fti.Font=Enum.Font.GothamBold;fti.TextSize=16;fti.TextXAlignment=Enum.TextXAlignment.Left
	local fmin=Instance.new("TextButton",ft)
	fmin.Text="—";fmin.TextColor3=Color3.fromRGB(255,255,255);fmin.BackgroundColor3=Color3.fromRGB(55,55,55)
	fmin.Font=Enum.Font.GothamBold;fmin.TextSize=16;fmin.Size=UDim2.new(0,28,0,28)
	fmin.Position=UDim2.new(1,-58,.5,-14);fmin.BorderSizePixel=0
	Instance.new("UICorner",fmin).CornerRadius=UDim.new(0,4)
	local fcls=Instance.new("TextButton",ft)
	fcls.Text="✕";fcls.TextColor3=Color3.fromRGB(255,255,255);fcls.BackgroundColor3=Color3.fromRGB(180,50,50)
	fcls.Font=Enum.Font.GothamBold;fcls.TextSize=14;fcls.Size=UDim2.new(0,28,0,28)
	fcls.Position=UDim2.new(1,-28,.5,-14);fcls.BorderSizePixel=0
	Instance.new("UICorner",fcls).CornerRadius=UDim.new(0,4)
	local fdr=Instance.new("TextButton",ft)
	fdr.BackgroundTransparency=1;fdr.Size=UDim2.new(1,0,1,0);fdr.Text="";fdr.ZIndex=0
	local fdrg,fds,ffs=false,nil,nil
	fdr.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
			fdrg=true;fds=inp.Position;ffs=flyW.Position
			inp.Changed:Connect(function()
				if inp.UserInputState==Enum.UserInputState.End then fdrg=false;fds=nil;ffs=nil end
			end)
		end
	end)
	U.InputChanged:Connect(function(inp)
		if fdrg and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
			local d=inp.Position-fds
			flyW.Position=UDim2.new(ffs.X.Scale,ffs.X.Offset+d.X,ffs.Y.Scale,ffs.Y.Offset+d.Y)
		end
	end)

	-- Toggle fly on/off
	local flyToggle=Instance.new("TextButton",flyW)
	flyToggle.Text="开启飞行";flyToggle.TextColor3=Color3.fromRGB(255,255,255)
	flyToggle.BackgroundColor3=Color3.fromRGB(40,130,220);flyToggle.Font=Enum.Font.GothamBold;flyToggle.TextSize=14
	flyToggle.Size=UDim2.new(1,-40,0,36);flyToggle.Position=UDim2.new(0,20,0,54)
	flyToggle.BorderSizePixel=0
	Instance.new("UICorner",flyToggle).CornerRadius=UDim.new(0,6)
	flyToggle.MouseButton1Click:Connect(function()
		flyActive=not flyActive
		flyToggle.Text=flyActive and"关闭飞行"or"开启飞行"
		flyToggle.BackgroundColor3=flyActive and Color3.fromRGB(180,50,50)or Color3.fromRGB(40,130,220)
		if not flyActive then vert=0 end
		local ch=p.Character;if ch then local h=ch:FindFirstChildOfClass("Humanoid")if h and not flyActive then h.PlatformStand=false end end
	end)

	-- Up button
	local up=Instance.new("TextButton",flyW)
	up.Text="▲ 向上飞";up.TextColor3=Color3.fromRGB(255,255,255)
	up.BackgroundColor3=Color3.fromRGB(40,140,40);up.Font=Enum.Font.GothamBold;up.TextSize=16
	up.Size=UDim2.new(1,-40,0,40);up.Position=UDim2.new(0,20,0,102)
	up.BorderSizePixel=0
	Instance.new("UICorner",up).CornerRadius=UDim.new(0,6)
	up.MouseButton1Down:Connect(function()if flyActive then vert=1 end end)
	up.MouseButton1Up:Connect(function()if vert==1 then vert=0 end end)
	up.MouseLeave:Connect(function()if vert==1 then vert=0 end end)

	-- Down button
	local dn=Instance.new("TextButton",flyW)
	dn.Text="▼ 向下飞";dn.TextColor3=Color3.fromRGB(255,255,255)
	dn.BackgroundColor3=Color3.fromRGB(40,100,180);dn.Font=Enum.Font.GothamBold;dn.TextSize=16
	dn.Size=UDim2.new(1,-40,0,40);dn.Position=UDim2.new(0,20,0,152)
	dn.BorderSizePixel=0
	Instance.new("UICorner",dn).CornerRadius=UDim.new(0,6)
	dn.MouseButton1Down:Connect(function()if flyActive then vert=-1 end end)
	dn.MouseButton1Up:Connect(function()if vert==-1 then vert=0 end end)
	dn.MouseLeave:Connect(function()if vert==-1 then vert=0 end end)

	-- Restore button
	flyRest=Instance.new("TextButton",g)
	flyRest.Text="飞";flyRest.TextColor3=Color3.fromRGB(255,255,255)
	flyRest.BackgroundColor3=Color3.fromRGB(40,130,220);flyRest.Font=Enum.Font.GothamBold;flyRest.TextSize=16
	flyRest.Size=UDim2.new(0,44,0,44);flyRest.Position=UDim2.new(1,-54,.5,80)
	flyRest.Visible=false;flyRest.BorderSizePixel=0
	Instance.new("UICorner",flyRest).CornerRadius=UDim.new(1,0)
	fmin.MouseButton1Click:Connect(function()flyW.Visible=false;flyRest.Visible=true end)
	fcls.MouseButton1Click:Connect(function()destroyFly()end)
	flyRest.MouseButton1Click:Connect(function()flyW.Visible=true;flyRest.Visible=false end)
end

-- Fly button row
local function flyBtnRow(ord)
	local r=Instance.new("Frame",m)
	r.BackgroundColor3=Color3.fromRGB(35,35,35);r.Size=UDim2.new(1,-20,0,44)
	r.LayoutOrder=ord;r.BorderSizePixel=0
	Instance.new("UICorner",r).CornerRadius=UDim.new(0,8)
	local btn=Instance.new("TextButton",r)
	btn.Text="开启飞行面板";btn.TextColor3=Color3.fromRGB(255,255,255)
	btn.BackgroundColor3=Color3.fromRGB(40,130,220);btn.Font=Enum.Font.GothamBold;btn.TextSize=14
	btn.Size=UDim2.new(1,-16,0,34);btn.Position=UDim2.new(0,8,.5,-17)
	btn.BorderSizePixel=0
	Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
	btn.MouseButton1Click:Connect(function()
		if flyW then destroyFly() else showFly() end
	end)
end

-- Rows
adjRow("移动加速","walkspeed",50,1)
adjRow("跳跃高度","jumppower",100,2)
toggleRow("穿墙模式","noclip",3)
espRow(4)
flyBtnRow(5)

-- Heartbeat
local lh=nil;local dws=16;local djp=50
R.Heartbeat:Connect(function(dt)
	local c=p.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local r=c and c:FindFirstChild("HumanoidRootPart")
	if h then
		if h~=lh then dws=h.WalkSpeed;djp=h.JumpPower;lh=h end
		if s.walkspeed then h.WalkSpeed=math.max(1,s.walkspeedValue)else h.WalkSpeed=dws end
		if s.jumppower then h.JumpPower=math.max(1,s.jumppowerValue)else h.JumpPower=djp end
	else lh=nil end
	if c and s.noclip then for _,v in ipairs(c:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=false end end end
	if flyActive and r and h then
		h.PlatformStand=true
		local md=h.MoveDirection;if md.Magnitude>0 then md=md.Unit else md=Vector3.zero end
		local sp=50;local mv=md*sp*dt
		if vert==1 then mv=mv+Vector3.new(0,sp*dt,0)elseif vert==-1 then mv=mv+Vector3.new(0,-sp*dt,0)end
		r.CFrame=r.CFrame+mv;r.Velocity=Vector3.zero;r.RotVelocity=Vector3.zero
	else
		if h and not flyActive then h.PlatformStand=false end
	end
end)
