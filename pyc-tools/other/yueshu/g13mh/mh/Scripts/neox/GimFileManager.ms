
	global gim_names
	global gim_sets

	
	local strfpGimPath = "NeoX_AutoExport_GimPath"
	local strfpGimCount = "NeoX_AutoExport_GimCount"
	local strfpGimFile = "NeoX_AutoExport_Gim_"
	local strBlankGim = "newfile_"                                    ----����ֻ�ܲ�ѯӢ������ ��֧������
	local ActiveGimFile = 0

	--�йس����ļ��ı���
	local IsExpScn = false
	local strfpScnPath = "NeoX_AutoExport_ScnPath"
	local strfpScnIsExp = "NeoX_AutoExport_IsExp"
	local stream
	local pathvector = #()          --�洢·������
	
	function sub_string str1 str2 =                           -- return str1 - str2
	(
	   trimleft str1 
	   trimleft str2
	   trimright str1
	   trimright str2
	   i = str2.count + 1
	   s = substring str1 i str1.count
	   --messagebox(s)
	   return s
	)
	
	function get_file_prop name defvalue = 
	(
		pi = fileProperties.findProperty #custom name
		if pi == 0 then
		(
			fileProperties.addProperty #custom name defvalue
			pi = fileProperties.findProperty #custom name
		)
		v = fileProperties.getPropertyValue #custom pi
		return v
	)
	
	function set_file_prop name value = 
	(
		fileProperties.deleteProperty #custom name
		fileProperties.addProperty #custom name value
	)
	
	function get_gim_info =
	(
		gim_count = get_file_prop strfpGimCount 0
		gim_names = #()
		gim_sets = #()
		
		for i = 1 to gim_count do
		(
			strfp = strfpGimFile + (formattedPrint i format:"03d")
			pi = fileProperties.findProperty #custom strfp
			if pi != 0 then
			(
				str = fileProperties.getPropertyValue #custom pi
				p = findString str "="
				append gim_names (substring str 1 (p-1))
				append gim_sets (substring str (p+1) (str.count-p))
			)
		)
		if gim_count != gim_names.count then
		(
			set_file_prop strfpGimCount gim_names.count
		)
	)

	function set_gim_info i =
	(
		str = gim_names[i] + "=" + gim_sets[i]
		strfp = strfpGimFile + (formattedPrint i format:"03d")
		set_file_prop strfp str
	)

	function set_all_gim_info =
	(
		for i = 1 to gim_names.count do
		(
			set_gim_info i
		)
		set_file_prop strfpGimCount gim_names.count
	)

	rollout NeoXGimFilesRollout "Gim Files"  
	(
		group  "�Զ���������"
		(
			label lblGimPath "ģ��·��:" align:#left enabled:true
			edittext editGimPath "" text:"" align:#left width:160 enabled:true
			button btnPickPath "..." width:64 enabled:true
			dropdownlist ddlGimFiles "ģ���ļ�(0/0):" align:#left enabled:false height:10
			label lblGimFilename "��ǰģ���ļ���:" align:#left enabled:false
			edittext editGimFilename "" text:strBlankGim align:#left width:132 enabled:false
			dropdownlist ddlSelSets "��Ӧѡ��:" align:#left enabled:false height:10
			button btnCreate "�½��ļ�" width:120 enabled:true
			button btnDestroy "ɾ���ļ�" width:120 enabled:false
			button btnImportFromSS "��Maxѡ�񼯵���" width:120 enabled:true
			button btnDoExport "�Զ�����" width:120 enabled:true
			checkbox btnSelScn "ѡ�񵼳������ļ�scn" widht: 150
			label lblScnPath "����·��:" align: #left enabled:false
			edittext editScnPath "" text:"" align: #left width:160 enabled:false
			button btnPickScnPath "..." width:64 enabled:false
			button btnExE "�򿪳����༭��" width:120 enabled:false
		)

		function GetSelSetIdx text =
		(
			for i = 2 to ddlSelSets.items.count do
			(
				if text == ddlSelSets.items[i] then
					return i
			)
			return 1
		)
		
		function UpdateGimFilesUI =
		(
			print "Updating GimFiles UI..."

			editGimPath.text = get_file_prop strfpGimPath ""

			if gim_names.count == 0 then
			(
				ActiveGimFile = 0
			)
			else
			(
				if ActiveGimFile < 1 or ActiveGimFile > gim_names.count do
				(
					ActiveGimFile = 1
				)
				
				print "ActiveGimFile:"
				print gim_names[ActiveGimFile]
			)
			
			list = #()
			for i = 1 to gim_names.count do
			(
				gimname = gim_names[i]
				if gimname != undefined do
				(
					append list gimname
				)
			)
			ddlGimFiles.items = list

			list = #("(��)")
			for i = 1 to selectionSets.count do
			(
				append list selectionSets[i].name
			)
			ddlSelSets.items = list

			if ActiveGimFile != 0 do
			(
				lblGimFilename.enabled = true
				editGimFilename.enabled = true
				editGimFilename.text = gim_names[ActiveGimFile]
				gimCount = gim_names.count
				gimIndex = ActiveGimFile
				strGimCount = "ģ���ļ�(" + gimIndex as string + "/" + gimCount as string + "):"
				ddlGimFiles.text = strGimCount
				btnDestroy.enabled = true 
				ddlGimFiles.enabled = true
				ddlGimFiles.selection = gimIndex
				ddlSelSets.enabled = true
				ddlSelSets.selection = (GetSelSetIdx gim_sets[gimIndex])
			)
			if ActiveGimFile == 0 do
			(
				lblGimFilename.enabled = false
				editGimFilename.enabled = false
				editGimFilename.text = ""
				gimCount = 0
				gimIndex = 0
				strGimCount = "ģ���ļ�(" + gimIndex as string + "/" + gimCount as string + "):"
				ddlGimFiles.text = strGimCount
				btnDestroy.enabled = false 
				ddlGimFiles.enabled = false
				ddlSelSets.enabled = false
			)
			
			--�����ӵĴ��� �Ա����Ϣ��������
			IsExpScn = get_file_prop strfpScnIsExp false
			btnSelScn.state = IsExpScn
			lblScnPath.enabled = IsExpScn
			editScnPath.enabled = IsExpScn
			btnPickScnPath.enabled = IsExpScn
			btnExE.enabled = IsExpScn

			editScnPath.text = get_file_prop strfpScnPath ""
		)
		
		on btnViewNodes pressed do
		(
			if ActiveGimFile != 0 then
			(
				clearSelection()
				for i = 1 to gim_nodes[ActiveGimFile].count do
				(
					selectMore gim_nodes[ActiveGimFile][i]
				)
			)
		)
		on btnSelScn changed theState do
		(
		    set_file_prop strfpScnIsExp btnSelScn.state
		    IsExpScn = get_file_prop strfpScnIsExp false
			lblScnPath.enabled = IsExpScn
			editScnPath.enabled = IsExpScn
			btnPickScnPath.enabled = IsExpScn
			btnExE.enabled = IsExpScn

			editScnPath.text = get_file_prop strfpScnPath ""
		)
		
		on btnImportFromSS pressed do
		(
			gim_names = #()
			gim_sets = #()
			for i = 1 to selectionSets.count do
			(
				append gim_names (selectionSets[i].name + ".gim")
				append gim_sets selectionSets[i].name
			)
			UpdateGimFilesUI()
			set_all_gim_info()
		)
		
		on NeoXGimFilesRollout open do
		(
			get_gim_info()
			UpdateGimFilesUI()
		)
		
		on ddlGimFiles selected num do
		(
			ActiveGimFile = num
			UpdateGimFilesUI()
		) 

		on ddlSelSets selected num do
		(
			if num == 1 then
				gim_sets[ActiveGimFile] = ""
			else
				gim_sets[ActiveGimFile] = ddlSelSets.selected
			set_gim_info ActiveGimFile
			UpdateGimFilesUI()
		) 
		
		function change_filename new_name =
		(
			strfp = strfpGimFile + (formattedPrint ActiveGimFile format:"03d")
			fileProperties.deleteProperty #custom strfp

			ddlGimFiles.selected = new_name
			gim_names[ActiveGimFile] = new_name
			set_gim_info ActiveGimFile
		)
		
		on btnPickPath pressed do
		(
			local f = getSavePath caption:"Select gim path:" initialDir:editGimPath.text
			
			try
			(
				filename = f + ""			
				editGimPath.text = filename
				set_file_prop strfpGimPath editGimPath.text
			)
			catch()
		)

		on editGimPath changed text do
		(
			set_file_prop strfpGimPath text
		)
		
		
		on editGimFilename changed text do
		(
			if ActiveGimFile == undefined or ActiveGimFile == 0 then return true

			gname = gim_names[ActiveGimFile]
			if gname == text then return true
			
			change_filename(text)
		)

		on btnCreate pressed do
		(
			i = 0
			do
			(
				i += 1
				str = strBlankGim + (i as string) + ".gim"
				p = findItem gim_names str
			)
			while p != 0
			append gim_names str
			append gim_sets ""
			
			ActiveGimFile = gim_names.count
			set_gim_info ActiveGimFile
			set_file_prop strfpGimCount gim_names.count

			UpdateGimFilesUI()
		)
		
		on btnDestroy pressed do
		(
			strfp = strfpGimFile + (formattedPrint ActiveGimFile format:"03d")
			fileProperties.deleteProperty #custom strfp

			deleteItem gim_names ActiveGimFile
			deleteItem gim_sets ActiveGimFile
			if ActiveGimFile > gim_names.count then
				ActiveGimFile = gim_names.count

			set_file_prop strfpGimCount gim_names.count

			UpdateGimFilesUI()
		)
		
		---������������ļ�
		
		function write_light bstream =
		(
			WriteLong bstream 0  #unsigned
		)
		
		function write_fog bstream = 
		(
		    --int mode; int type;neox::math3d::Color32 color;Float start;Float end;Float density;
			WriteLong bstream 0
			WriteLong bstream 0
			
			WriteByte bstream 255  #unsigned
			WriteByte bstream 255  #unsigned
			WriteByte bstream 255  #unsigned
			WriteByte bstream 255  #unsigned
			WriteFloat bstream 0
			WriteFloat bstream 0
			WriteFloat bstream 0
		)
		
		function write_model bstream =
		(
		     --�����Ǹ����û����趨��ѡ�񼯽��е���
			 --д���ļ�������
			 WriteLong bstream pathvector.count  #unsigned
			 --ȡ��������Դ�ļ���
			 for i = 1 to pathvector.count do         --��������
			 (
			     num = pathvector[i].count + 1
			     WriteLong bstream num #unsigned	  --д��·�����ĳ���				 
				 WriteString bstream pathvector[i]
			 )
			 
			 --������count  npc_count fx_count
			 WriteLong bstream pathvector.count     #unsigned      --���忴c++����
			 WriteLong bstream 0                    #unsigned
			 WriteLong bstream 0                    #unsigned
			 
			 id = 0
			 for i = 1 to pathvector.count do                 --��������
			 (
			    WriteLong bstream id   #unsigned              --д��ģ�͵�id  ��0��ʼ����

				WriteLong bstream 6146   #unsigned            --д��ģ�͵�flag   ��c++��������õ� 6146
	
				num = i - 1  
				WriteLong bstream num   #unsigned             --д��ʵ���Ӧ����Դ�ļ������  ���ǵ�c++�������Ǵ�0��ʼ
				temp = id + 100
				WriteLong bstream temp #unsigned                 
				id += 1     
				
				--ʵ������ ����·���� ������Ҳ���Ǿ���·��
				num = pathvector[i].count + 1
				WriteLong bstream num  #unsigned      
				WriteString bstream pathvector[i]
				
				 --дʵ��Ŀռ�����
		         --�������� ��ѡ�������ģ�Ͷ�Ū��Group Ȼ��õ���ռ�����
				 --���б����ļ������� ͬ ѡ�񼯵�������һһ��Ӧ�� 
				 ---group_name = "Groupmjken"
				 --Group selectionSets[i] name: "Groupmjken"    								   
				 
                                        			   	       --�ռ�λ��
				--�����3dsmax�������������ԭ���λ��
                --��Ϊ�ؼ���һ���ռ�����
                --ǰ����ģ���Ѿ����ó��˶���ֲ����굼����ʽ 
                WriteFloat bstream  0.0
                WriteFloat bstream  0.0
                WriteFloat bstream  0.0
				
                									           --scale����
                WriteFloat bstream 1.0
				WriteFloat bstream 1.0
				WriteFloat bstream 1.0
				                                               --��ת����
				--1 0 0 0
                --0 1 0 0
                --0 0 1 0
                --0 0 0 1
                for i = 1 to 4 do
                (
                    for j = 1 to 4 do
                    (
                        if i != j  then
                        (
                            WriteFloat bstream 0
                        )
                        else
                        (
                            WriteFloat bstream 1 
                        )
                    )--for
                )--for													   						   
				--unGroup selectionSets[i]           --ȡ������	

                                                     --д��billboardType���� Ĭ�ϵ�ֵΪ0
                WriteLong bstream 0                  --��ʾNone
                                                     --�������� Ĭ��Ϊ0
                WriteLong bstream 0		#unsigned									
															   
															   
			) -- for
		)
		
		
		function write_bsp bstream =
		(
		                                    --����Ĭ��ֵwall_count = 0
			WriteLong bstream 0
		)
		
		on btnDoExport pressed do
		(
		    pathvector = #()
			path = get_file_prop strfpGimPath ""
		    index = 1
			for i = 1 to gim_names.count do
			(
				sets = selectionSets[gim_sets[i]]
				clearSelection()
				for j = 1 to sets.count do
				(
					selectMore sets[j]
				)
				print ("exporting... " + path + "\\" + gim_names[i])
			   
			    --�������Դ��Ŀ¼���б�Ҫ�Ĳ��� 
				str = path + "\\" + gim_names[i]  --ddlGimFiles.items[i] 
				str1 = GetDir #scripts   
		        str1 = str1 + "\\set.ini"
		        str1 = GetINISetting str1 "Resource Path" "Path"
				str = sub_string str str1
				
				if pathvector.count != 0 then
				(
				   flag = false
				   for i = 1 to pathvector.count do   --����
				   (
				      if pathvector[i] == str then    --��ȵĻ� ��ô������ ������ǰ
					  (
					    flag = true
					  )
				   ) --for
				   
				   if flag == false do
				   (
				       pathvector[index] = str
					   index += 1
				   )
				)
				else
				(
				   pathvector[index] = str
				   index += 1
				)
				
				exportFile (path + "\\" + gim_names[i]) #noPrompt using:NeoX_Mesh_Export
			) -- for
			

		    if IsExpScn do
		    (	

           	strScnPathFile = get_file_prop strfpScnPath ""
			stream = fopen strScnPathFile "wb"
		     --д���ļ��İ汾��
			 WriteLong stream 1313035090  #unsigned
			 WriteLong stream 66541       #unsigned
			 --д������������
			 WriteByte stream 56   #unsigned
			 WriteByte stream 56   #unsigned
			 WriteByte stream 56   #unsigned
			 WriteByte stream 0    #unsigned
			 --д�������ĵƹ�Ч��
			 write_light stream 
			 --д����������Ч��
			 write_fog stream 
			 --д������ģ����Ϣ
			 write_model stream 
			 -- д��bsptree����Ϣ
			 write_bsp stream 
			 
			 fclose stream
			   
		    ) --if
		)--��������ģ��

	    on  btnPickScnPath pressed do
	    (     
		   local f = getSaveFileName caption: "Open the SCN file" filename:"D:\mjken.scn"\
                     types: "SCN(*SCN)|*.SCN"
		   try
		   (
		    filename = f + ""
			editScnPath.text = filename
			set_file_prop strfpScnPath editScnPath.text
		   )
		   catch()
	    )
		
		on editScnPath changed text do
		(
		  set_file_prop strfpScnPath text
		)

		on btnExE pressed do
		(
		   str = GetDir #scripts   
		   str = str + "\\set.ini"
		   str = GetINISetting str "EXE Path" "Path"	
           shellLaunch str editScnPath.text		   
		)
)
	

	