/*--scripted by ElishaHung--*/
/*--  http://elishahung.com/  --*/

disableSceneRedraw() 
try (destroyDialog UI_roll) catch()

/*----------環境變數----------*/
global UI_roll
global debug_roll
global gameScore = 0
global gameLevel = 1
global bigMap = #()
global sqRender = #()
global sqMain
global sqSet
global buttonAllow = false
global skip = false
global cleanSet = #()
global toggleT = true
global nextMap


/*----------屬性構成----------*/
struct sqStyle (name,map,color,pivot,width,rot,pos)
sqI = sqStyle name:"I-block" map:#(#(0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0),#(0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0)) color:(color 49 199 239) pivot:5 width:4
sqO = sqStyle name:"O-block" map:#(#(1,1,1,1)) color:(color 247 211 8) pivot:6 width:2
sqT = sqStyle name:"T-block" map:#(#(0,1,0,1,1,1,0,0,0),#(0,1,0,1,1,0,0,1,0),#(0,0,0,1,1,1,0,1,0),#(0,1,0,0,1,1,0,1,0)) color:(color 173 77 156) pivot:5 width:3
sqJ = sqStyle name:"J-block" map:#(#(0,0,1,1,1,1,0,0,0),#(1,1,0,0,1,0,0,1,0),#(0,0,0,1,1,1,1,0,0),#(0,1,0,0,1,0,0,1,1)) color:(color 33 33 185) pivot:5 width:3
sqL = sqStyle name:"L-block" map:#(#(1,0,0,1,1,1,0,0,0),#(0,1,0,0,1,0,1,1,0),#(0,0,0,1,1,1,0,0,1),#(0,1,1,0,1,0,0,1,0)) color:(color 239 121 33) pivot:5 width:3
sqS = sqStyle name:"S-block" map:#(#(1,1,0,0,1,1,0,0,0),#(0,0,1,0,1,1,0,1,0)) color:(color 32 209 32) pivot:5 width:3
sqZ = sqStyle name:"Z-block" map:#(#(0,1,1,1,1,0,0,0,0),#(0,1,0,0,1,1,0,0,1)) color:(color 201 39 39) pivot:5 width:3
sqSet = #(sqI,sqT,sqO,sqJ,sqL,sqS,sqZ)

	
/*----------指令編寫----------*/ㄍ

fn previewSQ = --預覽位置
(
	if toggleT == true do
	(
		delete $psq_*
		result = 0
		for i = 0 to 22 do
		(
			for y = 1 to sqMain.width do
			(
				for x = 1 to sqMain.width do
				(
					if sqMain.pos.y+(y-1)-i <= 0 do continue --避免最底層偵測
					if sqMain.pos.x == 0 and x <= 2 do continue --避免I在最左層偵測
					targetF = bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-1)-i)]
					curF = bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-1))]
					if targetF+curF >= 3 and curF == 1 do (result = i; exit) --判斷是否碰撞
				)
				if result > 0 do exit
			)
			if result > 0 do exit
		)
		--生成預覽方塊
		for x = 1 to sqMain.width do
		(
			for y = 1 to sqMain.width do
			(
				a = sqMain.pos.x+(x-1)
				b = sqMain.pos.y+(y-1)-result+1
				if a <= 1 or a >= 12 or b <= 1 or b >= 22 do continue
				if sqMain.map[sqMain.rot][x+(y-1)*sqMain.width] == 1 do Box name:("psq_" + (a) as string + "_" + (b) as string) length:10 width:10 height:10 wirecolor:(sqMain.color*(color 1 1 1)) pos:[10*a-5,20,10*b-10] pivot:[10*a-5,20,10*b-5] showFrozenInGray:false castShadows:false receiveshadows:false
			)
		)
	)
	clearselection()
	select $psq_*
	freeze selection
	clearselection()
)

--方塊渲染
fn renderSQ =
(
	for obj in sqRender do
	(
		axis = filterstring obj.name "_" --命名轉換座標
		if bigMap[(axis[2] as integer)][(axis[3] as integer)] == 0 then (obj.visibility = false; obj.wirecolor = black) else obj.visibility = true --判斷是否隱形
		if bigMap[(axis[2] as integer)][(axis[3] as integer)] == 1 then obj.wirecolor = sqMain.color --控制方塊上色
	)
	redrawViews()
)

--預告方塊
fn rollnextMap var =
(
	nextMap = var
	delete $nsq_*
	nextMap.rot = random 1 nextMap.map.count
	nextMap.pos = [18,4]
	for x = 1 to nextMap.width do
	(
		for y = 1 to nextMap.width do
		(
			a = nextMap.pos.x+(x-1)
			b = nextMap.pos.y+(y-1)
			if nextMap.map[nextMap.rot][x+(y-1)*nextMap.width] == 1 do ChamferBox name:("nsq_" + (x) as string + "_" + (y) as string) length:10 width:10 height:10 fillet:1.5 Fillet_Segments:1 smooth:0 wirecolor:nextMap.color pos:[10*a-5,10,10*b-10] pivot:[10*a-5,10,10*b-5] showFrozenInGray:false 
		)
	)
	--置中對齊
	clearselection()
	select $nsq_*
	move $ ([185,10,40]-$.center)
	freeze selection
	clearselection()
)

--起始方塊製作
fn createMainSq =
(
	sqMain = nextMap
	rollnextMap sqSet[(random 1 sqSet.count)]
	sqMain.pos = [sqMain.pivot,21]
	
	for x = 1 to sqMain.width do --增加起始方塊
	(
		for y = 1 to sqMain.width do
		(
		bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-1))] = sqMain.map[sqMain.rot][x+(y-1)*sqMain.width] as integer
		)
	)
	previewSQ()
	renderSQ()
	buttonAllow = true
	
)

--總結生成
fn collideMake =
(
	--碰撞轉換屬性顏色
	for x = 1 to sqMain.width do
	(
		for y = 1 to sqMain.width do
		(
			if sqMain.pos.x == 0 and x <= 2 do continue
			if sqMain.pos.x == 1 and x == 1 and sqMain.map != sqI.map[2] do continue
			if (sqMain.pos.x+sqMain.width-1) == 12 and x == sqMain.width do continue
			if bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-1))] == 1 do
			(
				if (sqMain.pos.y+(y-1)) < 22 then execute ("$sq_" + ((sqMain.pos.x+(x-1)) as integer) as string + "_" + ((sqMain.pos.y+(y-1)) as integer) as string  + ".wirecolor *= color 125 125 125") --只轉換框內顏色
				bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-1))] = 2 --改成固態屬性
			)
		)
	)
	
	--消除行列判斷
	for y = 2 to 21 do
	(
		xall2 = true
		for x = 2 to 11 do
		(
			if bigMap[x][y] != 2 do (xall2 = false; exit)
		)
		if xall2 == true do
		(
			cleanSet = append cleanSet y
		)
	)
	
	--消除行列或繼續遊戲結束偵測
	if cleanSet.count > 0 then
	(
		UI_roll.timeClean.active = true
		delete $psq_*
	)
	else
	(
		gameOver = false
		for x = 1 to 12 do --遊戲結束偵測
		(
			if bigMap[x][21] == 2 then (gameOver = true; $sq_*.wirecolor *= (color 100 100 100);redrawViews();messagebox ("Your Score is "+(gameScore as integer) as string) title:"Game Over";destroyDialog UI_roll;exit)
		)
		
		if gameOver == false do createMainSq()
	)
)

--消除方塊和積分設定
fn moveDownAll =
(
	for x = 2 to 11 do --消除方塊
	(
		for y = 2 to 21 do
		(
			if (findItem cleanSet y == 0) do continue
			bigMap[x][y] = 0 --只轉換框內顏色
		)
	)
	
	endLine = cleanSet[1] --設定偵測底線
	for y = cleanSet[1]+1 to 21 do
	(
		if findItem cleanSet y == 0 do --判斷是否不是消除的行列
		(
			for x = 2 to 11 do
			(
				bigMap[x][endLine] = bigMap[x][y] --獲取屬性
				execute ("$sq_" + x as string + "_" + endLine as string  + ".wirecolor = " + "$sq_" + x as string + "_" + y as string  + ".wirecolor") --獲取顏色
				bigMap[x][y] = 0				
			)
			
			endLine += 1 --底線進一步
		)
	)
	
	gameScore += (100+150*(cleanSet.count-1))*(1+(gameLevel-1)*0.8) --設定分數
	$txt_score_t.text = (gameScore as integer) as string
	if gameScore > (400*gameLevel+((exp ((gameLevel-1)*0.5))-1)*1000) do (gameLevel += 1; $txt_level_t.text = gameLevel as string; UI_roll.timeStep.interval /= 1.3)
	
	
	cleanSet = #()
)

--碰撞偵測
fn chkDown = --向下偵測
(
	result = false
	for x = 1 to sqMain.width do
	(
		for y = 1 to sqMain.width do
		(
			if sqMain.pos.y == 1 and y == 1 do continue --避免最底層偵測
			if sqMain.pos.x == 0 and x <= 2 do continue --避免I在最左層偵測
			curF = bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-2))]
			lastF = bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-1))]
			if curF+lastF >= 3 and lastF == 1 do (result = true; exit) --判斷是否碰撞
		)
		if result == true do exit
	)
	result
)

fn chkLeft = --向左偵測
(
	result = false
	for x = 1 to sqMain.width do
	(
		for y = 1 to sqMain.width do
		(
			if sqMain.pos.x == 1 and x == 1 and sqMain.map != sqI.map[2] do continue --除了I 二型，避免最左層偵測
			if sqMain.pos.x == 0 and x <= 2 do continue --避免I在最左層偵測
			curF = bigMap[(sqMain.pos.x+(x-2))][(sqMain.pos.y+(y-1))]
			lastF = bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-1))]
			if curF+lastF >= 3 and lastF == 1 do (result = true; exit) --判斷是否碰撞
		)
		if result == true do exit
	)
	result
)

fn chkRight = --向右偵測
(
	result = false
	for x = 1 to sqMain.width do
	(
		for y = 1 to sqMain.width do
		(
			if (sqMain.pos.x+sqMain.width-1) == 12 and x == sqMain.width do continue --避免最右層偵測
			if sqMain.pos.x == 0 and x <= 2 do continue --避免I在最左層偵測
			curF = bigMap[(sqMain.pos.x+x)][(sqMain.pos.y+(y-1))]
			lastF = bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-1))]
			if curF+lastF >= 3 and lastF == 1 do (result = true; exit) --判斷是否碰撞
		)
		if result == true do exit
	)
	result
)

--旋轉偵測
fn chkRotate var =
(
	result = false
	nextRot = case of
	(
		(sqMain.rot+var > sqMain.map.count): 1
		(sqMain.rot+var == 0): sqMain.map.count
		default: sqMain.rot+var
	)
	
	for x = 1 to sqMain.width do
	(
		for y = 1 to sqMain.width do
		(
			if sqMain.pos.x == 0 and x == 1 do continue --避免I在最左層偵測
			if bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-1))] >= 2 and sqMain.map[nextRot][x+(y-1)*sqMain.width] == 1 then (result = true; exit)
		)
		if result == true do exit
	)
	
	result
)

--移動方塊
fn moveDown = --向下移動
(
	for x = 1 to sqMain.width do
	(
		for y = 1 to (sqMain.width+1) do
		(
			if sqMain.pos.y == 1 and y == 1 do continue --避免最底層偵測
			if sqMain.pos.x == 0 and x <= 2 do continue --避免I在最左層偵測
			curF = bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-2))]
			lastF = bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-1))]
			
			bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-2))] = case of
			(
				(curF <= 1): if lastF == 1 then 1 else 0 --不管自己是0還1，上面有1就是1，沒有就是0
				default: curF
			)
		)
	)
	sqMain.pos -= [0,1] --中心點往下移一格
	
	if skip == false do renderSQ() --偵測是否快轉
)

fn moveLeft = --向左移動
(
	for y = 1 to sqMain.width do
	(
		for x = 1 to (sqMain.width+1) do
		(
			if sqMain.pos.x == 1 and x == 1 and sqMain.map != sqI.map[2] do continue --除了I 二型，避免最左層偵測
			if sqMain.pos.x == 0 and x <= 2 do continue --避免I在最左層偵測
			if (sqMain.pos.x+sqMain.width-1) == 12 and x == (sqMain.width+1) do continue --避免最右層偵測
			curF = bigMap[(sqMain.pos.x+(x-2))][(sqMain.pos.y+(y-1))]
			lastF = bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-1))]
			
			bigMap[(sqMain.pos.x+(x-2))][(sqMain.pos.y+(y-1))] = case of
			(
				(curF <= 1): if lastF == 1 then 1 else 0 --不管自己是0還1，上面有1就是1，沒有就是0
				default: curF
			)
		)
	)
	sqMain.pos -= [1,0] --中心點往左移一格
	
	renderSQ()
	
)

fn moveRight = --向右移動
(
	for y = 1 to sqMain.width do
	(
		for x = 1 to (sqMain.width+1) do
		(
			if (sqMain.pos.x+sqMain.width-1) == 12 and x == sqMain.width do continue --避免最右層偵測
			if sqMain.pos.x <= 1 and x == sqMain.width+1 do continue  --避免最左層偵測
			if sqMain.pos.x == 0 and x >= sqMain.width do continue --避免I在最左層偵測
			curF = bigMap[(sqMain.pos.x+sqMain.width+1-x)][(sqMain.pos.y+(y-1))]
			lastF = bigMap[(sqMain.pos.x+sqMain.width+1-x-1)][(sqMain.pos.y+(y-1))]
			
			bigMap[(sqMain.pos.x+sqMain.width+1-x)][(sqMain.pos.y+(y-1))] = case of
			(
				(curF <= 1): if lastF == 1 then 1 else 0 --不管自己是0還1，上面有1就是1，沒有就是0
				default: curF
			)
		)
	)
	sqMain.pos += [1,0] --中心點往右移一格
	
	renderSQ()
	
)

--旋轉方塊
fn rotateSq var = 
(
	nextRot = case of
	(
		(sqMain.rot+var > sqMain.map.count): 1
		(sqMain.rot+var == 0): sqMain.map.count
		default: sqMain.rot+var
	)
	
	for x = 1 to sqMain.width do
	(
		for y = 1 to sqMain.width do
		(
			if sqMain.pos.x == 1 and x == 1 and sqMain.map != sqI.map[2] do continue --除了I 二型，避免最左層偵測
			if sqMain.pos.x == 0 and x <= 2 do continue --避免I在最左層偵測
			if (sqMain.pos.x+sqMain.width-1) == 12 and x == sqMain.width do continue --避免最右層偵測
			if bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-1))] <= 1 do bigMap[(sqMain.pos.x+(x-1))][(sqMain.pos.y+(y-1))] = sqMain.map[nextRot][x+(y-1)*sqMain.width]
		)
	)
	
	sqMain.rot = nextRot
	renderSQ()
	
)

--地圖畫面架構
(
--視覺版面設定
try (viewport.setLayout #layout_1) catch()
try (actionMan.executeAction 0 "614") catch()
try (actionMan.executeAction 0 "40060") catch()
try (actionMan.executeAction 0 "40077") catch()
try (ViewCubeOps.Visibility = false) catch()

if rootScene[#Populate].Populate.controller.realWorldScale != 0.393701 then rootScene[#Populate].Populate.controller.realWorldScale = 0.393701

--視覺設定1
text name:"txt_score" text:"SCORE" font:"Arial Bold" size:20 wirecolor:(color 225 198 87) rotation:(quat 0.707107 0 0 0.707107) pos:[185,10,190] showFrozenInGray:false
text name:"txt_score_t" text:"0" font:"Arial Bold" size:20 wirecolor:white rotation:(quat 0.707107 0 0 0.707107) pos:[185,10,170] showFrozenInGray:false
text name:"txt_level" text:"LEVEL" font:"Arial Bold" size:20 wirecolor:(color 225 198 87) rotation:(quat 0.707107 0 0 0.707107) pos:[185,10,127] showFrozenInGray:false
text name:"txt_level_t" text:"1" font:"Arial Bold" size:20 wirecolor:white rotation:(quat 0.707107 0 0 0.707107) pos:[185,10,107] showFrozenInGray:false
text name:"txt_next" text:"NEXT" font:"Arial Bold" size:20 wirecolor:(color 225 198 87) rotation:(quat 0.707107 0 0 0.707107) pos:[185,10,67] showFrozenInGray:false
text name:"txt_move" text:"MOVE" font:"Arial Bold" size:20 wirecolor:(color 87 225 87) rotation:(quat 0.707107 0 0 0.707107) pos:[-72,10,174] showFrozenInGray:false
text name:"txt_asd" text:"A / S / D" font:"Arial Bold" size:20 wirecolor:white rotation:(quat 0.707107 0 0 0.707107) pos:[-72,10,154] showFrozenInGray:false
text name:"txt_rotate" text:"ROTATE" font:"Arial Bold" size:20 wirecolor:(color 87 225 87) rotation:(quat 0.707107 0 0 0.707107) pos:[-72,10,115] showFrozenInGray:false
text name:"txt_qe" text:"Q / E" font:"Arial Bold" size:20 wirecolor:white rotation:(quat 0.707107 0 0 0.707107) pos:[-72,10,95] showFrozenInGray:false
text name:"txt_fall" text:"FALL" font:"Arial Bold" size:20 wirecolor:(color 87 225 87) rotation:(quat 0.707107 0 0 0.707107) pos:[-72,10,56] showFrozenInGray:false
text name:"txt_space" text:"Space" font:"Arial Bold" size:20 wirecolor:white rotation:(quat 0.707107 0 0 0.707107) pos:[-72,10,36] showFrozenInGray:false
text name:"txt_exit" text:"Press L to exit" font:"Arial Bold" size:20 wirecolor:(color 135 6 6) rotation:(quat 0.707107 0 0 0.707107) pos:[191.5,10,-9.5] showFrozenInGray:false
for obj in $txt_* do
(
	addmodifier obj (Extrude ())
	obj.modifiers[#Extrude].amount = if obj.name == "txt_exit" then 0 else 5
	freeze obj
)
clearselection()

for x = 1 to 12 do --主畫面製作
(
	bigMap[x] = #()
	for y = 1 to 26 do
	(
		if x<2 or x >11 or y<2 or y>21 then
		(
			--製造外牆方塊
			if y<23 then ChamferBox name:((if y>21 then "sky_" else "wall_") + (x) as string + "_" + (y) as string) length:10 width:10 height:10 fillet:1.5 Fillet_Segments:1 smooth:0 wirecolor:(color 115 115 115) pos:[10*(x)-5,10,10*y-10] pivot:[10*(x)-5,10,10*y-5] showFrozenInGray:false
			if y>21 then
			(
				bigMap[x] = append bigMap[x] 0
			)
			else
			(
				bigMap[x] = append bigMap[x] 5
			)
		)
		else
		(
			bigMap[x] = append bigMap[x] 0
			--製造內部渲染方塊
			sqbox = ChamferBox name:("sq_" + (x) as string + "_" + (y) as string) length:10 width:10 height:10 fillet:1.5 Fillet_Segments:1 smooth:0 wirecolor:(color 115 115 115) pos:[10*(x)-5,10,10*y-10] pivot:[10*(x)-5,10,10*y-5] showFrozenInGray:false
			selectmore sqbox
			sqRender += sqbox --給渲染陣列
		)
	)
)

--視覺設定2
max zoomext sel
actionMan.executeAction 0 "40182"
selectmore $sky_*
selectmore $wall_*
max freeze selection
clearselection()
displaySafeFrames = true
renderHeight = (renderWidth/16*10) as integer
renderSQ()
enableSceneRedraw()
)


/*----------控制面板----------*/

rollout UI_roll "Tetris" width:50 height:50 --主介面
(
	--介面設置
	
	timer timeStep interval:750 active:false --階段時間設置
	timer timeClean interval:15 active:false  --消除特效
	timer timeInput interval:15 active:true
	
	dotNetControl dnControl "System.Windows.Forms.Control" pos:[0,5000]
	
	local dnKeyboard = DotNetClass "System.Windows.Forms.Keys"
	local step = 0
	
	--初始設定
	on UI_roll open do
	(
		setDialogpos UI_roll [(getDialogpos UI_roll).x*1.8,(getDialogpos UI_roll).y]
		timeStep.active = true
		rollnextMap sqSet[(random 1 sqSet.count)]
		createMainSq()
	)
	
	--場復
	on UI_roll close do
	(
		disableSceneRedraw() 
		delete $sq_*
		delete $wall_*
		delete $sky_*
		delete $psq_*
		delete $nsq_*
		delete $txt_*
		displaySafeFrames = false
		actionMan.executeAction 0 "40182"
		actionMan.executeAction 0 "550"
		actionMan.executeAction 0 "40077"
		max zoomext sel
		ViewCubeOps.Visibility = true
		enableSceneRedraw()
		redrawViews()		
	)
	
	--時間設定
	on timeStep tick do
	(
		betime = timestamp()
		buttonAllow = false
		if step ==0 and skip == false do
		(
			if chkDown() == true then (collideMake(); renderSQ()) else (buttonAllow = true; moveDown())
		)
		
	)
	
	on timeClean tick do --消除動畫
	(
		step += 1		
		if step > timeStep.interval/timeClean.interval/2 then
		(
			timeClean.active = false
			step = 0
			moveDownAll()
			createMainSq()
		)
		else
		(
			colorRand = random black white
			for x = 2 to 11 do
			(
				for y = 2 to 21 do
				(
					if (findItem cleanSet y == 0) do continue
					execute ("$sq_" + x as string + "_" + y as string  + ".wirecolor = " + colorRand as string) --只轉換框內顏色
				)
			)
			renderSQ()
		)
	)
	
	on timeInput tick do
	(
		dnControl.focus()
	)
	
	on dnControl KeyDown senderArg keyPressEventArgs do --鍵盤操作
	(
		case keyPressEventArgs.keyCode of
		(
			(keyPressEventArgs.keyCode.A): if chkLeft() == false and buttonAllow == true then (moveLeft() ; previewSQ())
			(keyPressEventArgs.keyCode.D): if chkRight() == false and buttonAllow == true then (moveRight() ; previewSQ())
			(keyPressEventArgs.keyCode.S): if chkDown() == false and buttonAllow == true then (moveDown() ; previewSQ())
			(keyPressEventArgs.keyCode.Q): if chkRotate -1 == false and buttonAllow == true then (rotateSq -1 ; previewSQ())
			(keyPressEventArgs.keyCode.E): if chkRotate 1 == false and buttonAllow == true then (rotateSq 1 ; previewSQ())
			(keyPressEventArgs.keyCode.T): if toggleT == true then (delete $psq_* ; toggleT = false) else (toggleT = true; previewSQ())
			(keyPressEventArgs.keyCode.L): if toggleT == true do destroyDialog UI_roll
			(keyPressEventArgs.keyCode.Space): (if buttonAllow == true do (skip = true; buttonAllow = false; for i=1 to 22 while (chkDown() == false) do (moveDown()); renderSQ(); collideMake();  skip = false))
		)
		keyPressEventArgs.SuppressKeyPress = true
	)
)

createDialog UI_roll pos:[0,-300]