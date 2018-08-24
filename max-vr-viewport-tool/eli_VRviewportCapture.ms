struct ViewportControl (cfg = "set", bg = 1, safe = #(0, 0, 0, 0, 0, 0, 0), stat = 0)
global captureVC = ViewportControl cfg:"get"
global off_VC = ViewportControl cfg:"set" bg:2 safe:#(0, 0, 0, 0, 0, 0, 1) stat:0
global origin_VC

try(destroyDialog vrViewportCaptureRoll )catch()

rollout vrViewportCaptureRoll "VR Viewport Capture" width:200
(
	--UI Layout--
	dropdownlist ddl_camera "Camera To Capture:"
	button btn_refreshcam "Refresh" align:#right
	edittext text_savepath "Path:" text:"c:\\" offset:[0, 20]
	button btn_getpath "Browse" align:#right
	edittext text_savename "Filename:" text:"preview_" offset:[0, 20]
	checkbox chk_resize "Resize" offset:[0, 25]
	dropdownlist ddl_resize items:#("1024x512", "2048x1024", "4096x2048") selection:2 enabled:false
	slider sld_quality "JPEG Quality: 90" range:[1, 100, 90] type:#integer offset:[0, 20]
	checkbox chk_rendermp4 "Export MP4" checked:true
	radiobuttons rbt_quality labels:#("Low", "Medium", "High") default:2
	checkbox chk_keepjpg "Perserve JPG sequence" offset:[15, 0]
	checkbox chk_show "Capture Geometry Only" checked:true offset:[0, 10]
	spinner spn_start "Start" range:[-99999, 99999, animationrange.start.frame] type:#integer offset:[0, 20] align:#left width:75
	spinner spn_end "End" range:[-99999, 99999, animationrange.end.frame] type:#integer offset:[0, -21] align:#right width:75
	button btn_execute "Start Capture" offset:[0, 20] width:140 height:40
	button btn_setting "..." align:#right offset:[12, -10] width:20 border:false
	rollout vrViewportSettingRoll "VR Viewport Setting" width:250
	(
		label lbl_path "Application path"
		edittext text_path width:200
		button btn_browse "..." align:#right offset:[8, -23]
		button btn_ok "OK" width:40 align:#right offset:[-50, 10]
		button btn_cancel "Cancel" width:40 align:#right offset:[0, -26]
		
		local main_r
		
		on btn_browse pressed do
		(
			gpath = getSavePath()
			if gpath != undefined then text_path.text = gpath
		)
		
		on btn_ok pressed do
		(
			thepath = text_path.text
			if (substring thepath (thepath.count-1) 2) != "\\" then thepath += "\\"
			main_r.exe_path = thepath
			destroyDialog vrViewportSettingRoll
		)
		
		on btn_cancel pressed do
		(
			destroyDialog vrViewportSettingRoll
		)
		
		on vrViewportSettingRoll open do
		(
			main_r = vrViewportCaptureRoll
			print main_r
			p_size = GetDialogSize vrViewportCaptureRoll
			p_pos = GetDialogPos vrViewportCaptureRoll
			c_size = GetDialogSize vrViewportSettingRoll
			posx = p_pos.x + p_size.x/2 - c_size.x/2
			posy = p_pos.y + p_size.y/2 - c_size.y/2
			SetDialogPos vrViewportSettingRoll [posx, posy]
			text_path.text = main_r.exe_path
		)
	)
	
	
	--Declare Variable--
	local exe_path = "S:\\Script\\3DsMax\\eli_VRviewportCapture\\"
	local file_list = #("_f", "_l", "_b", "_r", "_u", "_d")
	local save_path
	local save_name
	local save_quality
	local resize_toggle
	local resize_size
	local resize_list = #(326, 652, 1304)
	local capture_camera
	local frame_start
	local frame_end
	local isRendermp4
	local mp4_quality
	local mp4_qualitylist = #(4, 2, 1)
	local isKeepjpg
	local isGeoonly
	local hideset
	struct VRsetting (rendersize, isLayoutChanged, originLayout, originType, originCamera)
	local vrset = VRsetting()
	struct Shadsetting (mode, lightopt, lightmode, flwcamera, shadows, ao)
	local shadset = Shadsetting()

	
	--Functions--
	fn setViewport = 
	(
		tab_bg_index = 1
		tab_safe_index = 3
		tab_stat_index = 6
		
		tab_bg_list = #( "Use Customize User Interface Gradient Colors", "Use Customize User Interface Solid Color ", "Use Environment Background", "Use Files:" )
		tab_safe_list = #( "Live Area", "Region (when Region Rendering)", "Action Safe", "Title Safe", "User Safe", "12-Field Grid", "Show Safe Frames in Active View")
		tab_stat_list = #( "Show Statistics in Active View" )
		
		win = DialogMonitorOPS.GetWindowHandle()
		
		fn focusTab win tab =
		(
			for win_child in (UIAccessor.GetChildWindows win) where ((UIAccessor.GetWindowClassName win_child) == "SysTabControl32") do
			(
				UIAccessor.SendMessage win_child 0x1330 tab 0 
			)
		)
		
		fn getCheck win str =
		(
			for win_child in (UIAccessor.GetChildWindows win) where (UIAccessor.GetWindowText win_child) == str do
			(
				return windows.SendMessage win_child 0x00F0 0 0
			)
		)
		
		fn setCheck win str bool =
		(
			for win_child in (UIAccessor.GetChildWindows win) where (UIAccessor.GetWindowText win_child) == str do
			(
				UIAccessor.SendMessage win_child 0x00F1 bool 0 
			)
		)
		
		fn setBg win sel =
		(
			buttons = #("Use Customize User Interface Gradient Colors", "Use Customize User Interface Solid Color ", "Use Environment Background", "Use Files:")
			for win_child in (UIAccessor.GetChildWindows win) where (UIAccessor.GetWindowText win_child) == buttons[sel] do
			(
				UIAccessor.PressButton win_child
			)
		)
		
		if captureVC.cfg == "get" then
		(
			focusTab win tab_bg_index
			for btn_bg in tab_bg_list do
			(
				if (getCheck win btn_bg) == 1 then captureVC.bg = findItem tab_bg_list btn_bg
			)
			
			captureVC.safe = #()
			focusTab win tab_safe_index
			for chk_sf in tab_safe_list do
			(
				append captureVC.safe (getCheck win chk_sf)
			)
			
			focusTab win tab_stat_index
			captureVC.stat = getCheck win tab_stat_list[1]
			
		)else if captureVC.cfg == "set" then(
			focusTab win tab_bg_index
			setBg win captureVC.bg
			
			focusTab win tab_safe_index
			for i = 1 to tab_safe_list.count do
			(
				setCheck win tab_safe_list[i] captureVC.safe[i]
			)
			
			focusTab win tab_stat_index
			setCheck win tab_stat_list[1] captureVC.stat
		)
		
		UIAccessor.SendMessageID win #IDOK
	)

	fn runSetViewport =
	(
		DialogMonitorOPS.RegisterNotification setViewport id:#PokeViewportConfigure
		DialogMonitorOPS.Enabled = true		
		max vptconfig
		DialogMonitorOPS.unRegisterNotification id:#PokeViewportConfigure
		DialogMonitorOPS.Enabled = false
	)


	fn getViewportSafeframeDib =
	(
		local x = y = 0, v
		local s = getViewSize()
		local k = getRendImageAspect()

		if k < (s.x/s.y) then
		(
			v = [s.y*k,s.y]
			x = (s.x-v.x)/2 + 1
		)else(
			v = [s.x, s.x/k]
			y = (s.y-v.y)/2 + 1
		)
		
		bmp = bitmap v.x v.y
		pasteBitmap (gw.getViewportDib()) bmp (box2 x y v.x v.y) [0,0]
			
		return bmp
	)

	fn cubeToSphere arg =
	(
		local pic_list, framenum, save_path, save_name, save_quality, isEnd
		
		if classof arg == Array then
		(
			pic_list = arg[1]
			framenum = arg[2]
			save_path = arg[3]
			save_name = arg[4]
			save_quality = arg[5] as string
			isEnd = arg[6]
		)else(
			pic_list = arg.Argument[1]
			framenum = arg.Argument[2]
			save_path = arg.Argument[3]
			save_name = arg.Argument[4]
			save_quality = arg.Argument[5] as string
			isEnd = arg.Argument[6]
		)
		
		cubes = " "

		for pic in pic_list do
		(
			cubes += (pic + " ")
		)

		HiddenDOSCommand ("kcube2sphere " + cubes + " -o=" + save_name + framenum + ".jpg -jpegquality=" + save_quality) startpath:save_path

		for pic in pic_list do
		(
			deleteFile pic
		)
		
		if isEnd do HiddenDOSCommand "del /A:H kcube2sphere.exe krpanotools.license" startpath:save_path
	)
	
	fn replaceSetting = 
	(		
		--vr setting
		vrset.rendersize = [renderWidth, renderHeight]
		renderWidth = 512
		renderHeight = 512
		
		v_layout = viewport.getLayout()
		if v_layout != #layout_1 then
		(
			vrset.originLayout = v_layout
			viewport.setLayout #layout_1
			vrset.isLayoutChanged = true
		)
		vrset.originType = viewport.getType()
		if vrset.originType == #view_camera then
		(
			vrset.originCamera = viewport.getCamera()
		)
		
		--viewport setting
		captureVC.cfg = "get"
		runSetViewport()
		origin_VC = captureVC
		captureVC = off_VC
		runSetViewport()
		
		--nitrous setting
		ng_set = NitrousGraphicsManager.GetActiveViewportSetting()
		shadset.mode = ng_set.VisualStyleMode
		ng_set.VisualStyleMode = #Shaded
		shadset.lightopt = ng_set.LightOption
		ng_set.LightOption = #DefaultLight
		shadset.lightmode = ng_set.DefaultLightMode
		ng_set.DefaultLightMode = #TwoLights
		shadset.flwcamera = ng_set.DefaultLightsFollowCamera
		ng_set.DefaultLightsFollowCamera = false
		shadset.shadows = ng_set.ShadowsEnabled
		ng_set.ShadowsEnabled = false
		shadset.ao = ng_set.AmbientOcclusionEnabled
		ng_set.AmbientOcclusionEnabled = false
		
		--show setting
		if isGeoonly == true then
		(
			hideset = #()
			append hideset hideByCategory.geometry
			append hideset hideByCategory.shapes
			append hideset hideByCategory.lights
			append hideset hideByCategory.cameras
			append hideset hideByCategory.helpers
			append hideset hideByCategory.spacewarps
			append hideset hideByCategory.particles
			append hideset hideByCategory.bones 
			hideByCategory.all()
			hideByCategory.geometry = false
			hideByCategory.particles = false
		)
		
		--getsize
		if resize_toggle == false then
		(
			gvs = getViewSize()
			gvs_min = amin #(gvs.x, gvs.y)
			resize_size = gvs_min as integer
		)
	)
	
	fn restoreSetting =
	(
		--show setiing
		if isGeoonly == true then
		(
			hideByCategory.geometry = hideset[1]
			hideByCategory.shapes = hideset[2]
			hideByCategory.lights = hideset[3]
			hideByCategory.cameras = hideset[4]
			hideByCategory.helpers = hideset[5]
			hideByCategory.spacewarps = hideset[6]
			hideByCategory.particles = hideset[7]
			hideByCategory.bones  = hideset[8]
		)
		
		--nitrous setting
		ng_set = NitrousGraphicsManager.GetActiveViewportSetting()
		ng_set.VisualStyleMode = shadset.mode
		ng_set.LightOption = shadset.lightopt
		ng_set.DefaultLightMode = shadset.lightmode
		ng_set.DefaultLightsFollowCamera = shadset.flwcamera
		ng_set.ShadowsEnabled = shadset.shadows
		ng_set.AmbientOcclusionEnabled = shadset.ao
		
		--viewport setting
		captureVC = origin_VC
		captureVC.cfg = "set"
		runSetViewport()
		
		--vr setting
		renderWidth = vrset.rendersize.x
		renderHeight = vrset.rendersize.y
		
		if vrset.originType == #view_camera then
		(
			viewport.setCamera vrset.originCamera
		)else(
			viewport.setType vrset.originType
			actionMan.executeAction 0 "310"
		)
		if vrset.isLayoutChanged == true then viewport.setLayout vrset.originLayout
	)
	
	fn renderMp4 =
	(
		if isRendermp4 == true then
		(
			bitrate = ((pow resize_size 2)/(pow 652 2) * 8000 / mp4_quality) as string
			HiddenDOSCommand ( exe_path + "ffmpeg -y -framerate " + (framerate as string) + " -start_number " + (frame_start as string) + " -i " + save_name + "%04d.jpg -pix_fmt yuv420p -b:v " + bitrate + "k " + save_name + "video.mp4") startpath:save_path
			if isKeepjpg == false then HiddenDOSCommand ("del " + save_name + "*.jpg") startpath:save_path
		)
	)

	fn startCapture =
	(		
		--Make Camera--
		camera_name = #("front", "left", "back", "right", "top", "bottom")
		camera_sets = #()
		camera_rot = #((eulerAngles 0 0 0), (eulerAngles 0 90 0), (eulerAngles 0 180 0), (eulerAngles 0 270 0), (eulerAngles 90 0 0), (eulerAngles -90 0 0))
		for i = 1 to 6 do
		(
			newCam = freecamera fov:90 name:("vr_"+camera_name[i]) transform:capture_camera.transform
			in coordsys newCam
			(
				rotate newCam camera_rot[i]
			)
			newCam.parent = capture_camera
			append camera_sets newCam
		)
		hide camera_sets


		--Progress Start--
		progressStart "Capture VR Viewport ..."

		captureDone = false
		thread_list = #()
		clearSelection()
		
		replaceSetting()
		
		HiddenDOSCommand "del /A:H temp_*.jpg" startpath:save_path
		HiddenDOSCommand ("robocopy " + exe_path + " " + save_path + " kcube2sphere.exe krpanotools.license & attrib +h kcube2sphere.exe & attrib +h krpanotools.license") startpath:save_path

		for t = frame_start to frame_end do(

			--Progress Cancel--
			if not progressUpdate( 100. * (t-frame_start+1) / (frame_end-frame_start+1) ) then
			(
				HiddenDOSCommand "del /A:H kcube2sphere.exe krpanotools.license" startpath:save_path
				
				isRender = queryBox "Still Encode MP4?" title:"Cancel Capture"
				if isRender == true then renderMp4()
				exit
			)
			
			sliderTime = t
			framenum = formattedPrint t format:"04d"

			pic_list = #()

			for i =1 to 6 do
			(
				viewport.setCamera camera_sets[i]
				completeredraw()
				
				snap_map = getViewportSafeframeDib()
				
				if resize_toggle then
				(
					resize_map = bitmap resize_size resize_size
					copy snap_map resize_map
				)else(
					resize_map = snap_map
				)
				
				resize_map.filename = save_path + "temp_" + framenum + file_list[i] + ".jpg"
				append pic_list resize_map.filename
				save resize_map
				HiddenDOSCommand ("attrib +h " + resize_map.filename)
				close resize_map
				gc()
				freeSceneBitmaps()
			)
			
			index = t+(1-frame_start)
			isEnd = t == frame_end
			cts_arg = #(pic_list, framenum, save_path, save_name, save_quality, isEnd)
			
			if isEnd == true then
			(
				cubeToSphere( cts_arg )
				renderMp4()
				captureDone = true
			)else(			
			thread_list[index] = dotNetObject "system.componentModel.backgroundWorker"
			dotnet.addEventHandler thread_list[index] "DoWork" cubeToSphere
			thread_list[index].runWorkerAsync( cts_arg )
			)
			
		)
		
		gc()
		freeSceneBitmaps()
		
		restoreSetting()
		
		delete camera_sets

		if captureDone then
		(
			openFolder = queryBox "Complete!\nOpen save folder?" title:"Capture Done"
			if openFolder do shellLaunch "explorer.exe" save_path
		)

		progressEnd()
	)
	
	
	--UI Feedback--
	fn refreshCamera =(
		cam_list = #()
		for cam in cameras do
		(
			if classof cam != Targetobject then append cam_list cam.name
		)
		ddl_camera.items = cam_list
	)
	
	on btn_refreshcam pressed do
	(
		refreshCamera()
	)
	
	on btn_getpath pressed do
	(
		thepath = getSavePath()
		if thepath != undefined then text_savepath.text = thepath
	)
	
	on chk_resize changed bool do
	(
		ddl_resize.enabled = bool
	)
	
	on sld_quality changed val do
	(
		sld_quality.caption = "JPEG Quality: " + ((val as integer) as string)
	)
	
	on chk_rendermp4 changed bool do
	(
		rbt_quality.enabled = bool
		chk_keepjpg.enabled = bool
	)
	
	on btn_execute pressed do
	(
		if (execute ("$"+ddl_camera.selected)) == undefined then
		(
			messageBox "Camera is not valid." title:"Capture Failure"
		)else if DoesFileExist text_savepath.text == false then(
			messageBox "Path is not valid." title:"Capture Failure"
		)else(
			--Variable Mapping--
			save_path = text_savepath.text
			if (substring save_path (save_path.count-1) 2) != "\\" then save_path += "\\"
			save_name = text_savename.text
			save_quality = sld_quality.value as integer
			resize_toggle = chk_resize.checked
			resize_size = resize_list[ddl_resize.selection]
			capture_camera = execute ("$"+ddl_camera.selected)
			frame_start = spn_start.value as integer
			frame_end = spn_end.value as integer
			isRendermp4 = chk_rendermp4.checked
			mp4_quality = mp4_qualitylist[rbt_quality.state]
			isKeepjpg = chk_keepjpg.checked
			isGeoonly = chk_show.checked
			
			--start--
			startCapture()
		)
		

	)
	
	on btn_setting pressed do
	(
		createDialog vrViewportSettingRoll modal:true parent:vrViewportCaptureRoll.hwnd
	)
	
	on vrViewportCaptureRoll open do
	(
		refreshCamera()
		if (getAppData rootNode 0) == "true" then
		(
			exe_path = getappdata rootnode 1
			text_savepath.text = getappdata rootnode 2
			text_savename.text = getappdata rootnode 3
			spn_start.value = (getappdata rootnode 4 as integer)
			spn_end.value = (getappdata rootnode 5 as integer)
		)
	)
	
	on vrViewportCaptureRoll close do
	(
		setappdata rootnode 0 "true"
		setappdata rootnode 1 exe_path
		setappdata rootnode 2 text_savepath.text
		setappdata rootnode 3 text_savename.text
		setappdata rootnode 4 (spn_start.value as string)
		setappdata rootnode 5 (spn_end.value as string)
	)
)

createDialog vrViewportCaptureRoll