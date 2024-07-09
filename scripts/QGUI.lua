---@diagnostic disable

local utf8=require("utf8")
local uts={}

function uts.lower(str)
	local str=str:lower()
	str=str:gsub("А","а")
	str=str:gsub("Б","б")
	str=str:gsub("В","в")
	str=str:gsub("Г","г")
	str=str:gsub("Д","д")
	str=str:gsub("Е","е")
	str=str:gsub("Ё","ё")
	str=str:gsub("Ж","ж")
	str=str:gsub("З","з")
	str=str:gsub("И","и")
	str=str:gsub("Й","й")
	str=str:gsub("К","к")
	str=str:gsub("Л","л")
	str=str:gsub("М","м")
	str=str:gsub("Н","н")
	str=str:gsub("О","о")
	str=str:gsub("П","п")
	str=str:gsub("Р","р")
	str=str:gsub("С","с")
	str=str:gsub("Т","т")
	str=str:gsub("У","у")
	str=str:gsub("Ф","ф")
	str=str:gsub("Х","х")
	str=str:gsub("Ц","ц")
	str=str:gsub("Ч","ч")
	str=str:gsub("Ш","ш")
	str=str:gsub("Щ","щ")
	str=str:gsub("Ъ","ъ")
	str=str:gsub("Ы","ы")
	str=str:gsub("Ь","ь")
	str=str:gsub("Э","э")
	str=str:gsub("Ю","ю")
	str=str:gsub("Я","я")
	return str
end

local oldOffset=utf8.offset

function utf8.offset(str,symb)
	if symb>utf8.len(str) then
		return #str+1
	else
		return oldOffset(str,symb)
	end
end

local function insert(tbl,el)
	local ind = #tbl+1
	tbl[ind]=el
	return ind
end

local tbl={
	--CONFIG
	reportMissingParameters=false,

	basButtonHLMultiplier=1.5,
	basButtonFillOpac=0.2,
	basButtonFont=love.graphics.getFont(),

	textFrameColorMultiplier=0.5,
	textDefaultFont=love.graphics.getFont(),
	textXoffset=5,
	textYoffset=5,

	dropdownXoffset=5,
	dropdownSliderWidth=3,
	dropdownArrowOffset=10,
	dropdownMinSliderSize=20,

	--dropdownSearch,

	onelineDefaultShadow={0,0,0},
	onelineDefaultBolding={0,0,0},
	onelineDefaultFrame={255,255,0},
	onelineBoldingRange=3,
	onelineUnderlineYOffset=0,
	onelineLineHeight=2,

	progressCircleInsideCircleRMulti=0.6,

	checkBoxPreCheckColorMulti=0.8,
	checkBoxCheckMulti=0.6,

	--INIT
	blockMain=false,
	focusKeyboard=0,
	curcur="arrow",

	hl=0,
	hlTable={},
	heldID={0,0,0,0,0,0,0},

	queue={},
	assocQueue={},

	constructors={
		button = function(obj, tbl)--Button constructor

			obj.hlColor = obj.hlColor or {obj.color[1]*tbl.basButtonHLMultiplier, obj.color[2]*tbl.basButtonHLMultiplier, obj.color[3]*tbl.basButtonHLMultiplier}

			local _,wrapped=obj.font:getWrap(obj.text,obj.w - tbl.textXoffset*2)

			obj.textY = math.floor( obj.y + obj.h/2 - obj.font:getHeight()/2*#wrapped )

			obj.upd = tbl.default.objectHl

			obj.draw = function(obj)
				love.graphics.setFont(obj.font)
				love.graphics.setColor(tbl.hl ~= tbl.assocQueue[obj.name] and obj.color or obj.hlColor)
				love.graphics.rectangle("line", obj.x, obj.y, obj.w, obj.h)

				if obj.fill then local clr={love.graphics.getColor()} clr[4]=clr[4]*tbl.basButtonFillOpac love.graphics.setColor(clr); love.graphics.rectangle("fill", obj.x, obj.y, obj.w, obj.h) end

				love.graphics.setColor(obj.textColor)
				love.graphics.printf(obj.text, obj.x, obj.textY, obj.w,"center")
			end

			return obj 
		end,
		buttonAdv = function(obj,tbl)
			--//TODO
		end,
		textArea = function(obj,tbl)
			obj.frameColor=obj.frameColor or {obj.color[1]*tbl.textFrameColorMultiplier, obj.color[2]*tbl.textFrameColorMultiplier, obj.color[3]*tbl.textFrameColorMultiplier}
			obj.fontH=obj.font:getHeight()
			obj.yoffset=0

			obj.currentPos=utf8.len(obj.text)
			obj.rektX,obj.rektY=0,0

			obj.textDisplay=obj.text
			obj.displayStartOffset=1
			obj.finisher=1

			obj.textinput=function(key)
				obj.text=obj.text:sub(1,utf8.offset(obj.text,obj.currentPos+1)-1)..key..obj.text:sub(utf8.offset(obj.text,obj.currentPos+1),-1)
				if obj.updateCarette(1,0) then local offset=utf8.offset(obj.text,utf8.len(obj.text)); obj.text=obj.text:sub(1,offset-1); obj.updateCarette(-1,0) end
			end

			if obj.h-tbl.textYoffset*2-obj.fontH<0 then--Invalid text area

				obj.keypressed=function() end; obj.textinput=function() end
				obj.text="Invalid text area"
				obj.textColor={255,0,0}
				obj.color={255,255,255,255}

			elseif obj.h-tbl.textYoffset*2-obj.fontH*2<0 then--One line text area keypressed FNC
				obj.oneline=true

				if not obj.returnFnc then obj.returnFnc=function() end; print("No return function defined for one-line text area \""..obj.name.."\'") end
				obj.yoffset=math.floor(obj.h/2-obj.fontH/2-tbl.textYoffset)
				obj.keypressed=function(key)
					if key=="backspace" then
						if obj.currentPos~=0 then
							local offsetS=utf8.offset(obj.text,obj.currentPos)-1
							local offsetF=utf8.offset(obj.text,obj.currentPos+1)
							obj.text=obj.text:sub(1,offsetS)..obj.text:sub(offsetF,-1)
							obj.updateCarette(-1,0,true)
						end
					elseif key=="return" then
						obj.returnFnc(obj.text, obj)
					elseif key=="left" then
						obj.updateCarette(-1,0)
					elseif key=="right" then
						obj.updateCarette(1,0)
					end
				end

			else
				obj.maxLines=math.floor((obj.h-tbl.textYoffset)/obj.fontH)

				obj.keypressed=function(key)--Multiline text area keypressed FNC
					if key=="backspace" then
						if obj.currentPos~=0 then
							local offsetS=utf8.offset(obj.text,obj.currentPos)-1
							local offsetF=utf8.offset(obj.text,obj.currentPos+1)
							obj.text=obj.text:sub(1,offsetS)..obj.text:sub(offsetF,-1)
							obj.updateCarette(-1,0)
						end
					elseif key=="return" then
						obj.text=obj.text:sub(1,utf8.offset(obj.text,obj.currentPos+1)-1).."\n"..obj.text:sub(utf8.offset(obj.text,obj.currentPos+1),-1)
						obj.updateCarette(1,0,true)
					elseif key=="left" then
						obj.updateCarette(-1,0)
					elseif key=="right" then
						obj.updateCarette(1,0)
					elseif key=="up" then
						obj.updateCarette(0,-1)
					elseif key=="down" then
						obj.updateCarette(0,1)
					end
				end
			end

			obj.updateCarette=function(moveX,moveY,backspace)

				local moveY=moveY~=0 and moveY
				local oldTarget=obj.targetPos

				local _,wrapped=obj.font:getWrap(obj.text,obj.w - tbl.textXoffset*2)
				wrapped[1]=wrapped[1] or ""
				if obj.text:sub(-1,-1)=="\n" then
					insert(wrapped,"")
				end

				--Восстановление переводов строки
				local duplicate=""
				for i=1,#wrapped do
					duplicate=duplicate..wrapped[i]
					if obj.text:sub(#duplicate+1,#duplicate+1)=="\n" then
						wrapped[i]=wrapped[i].."\n"
						duplicate=duplicate.."\n"
					end
				end
				duplicate=nil
				--

				--Движение стрелочками влево и вправо
				if moveX then
					if moveX>0 then
						if obj.currentPos~=utf8.len(obj.text) then
							obj.currentPos=obj.currentPos+1
							obj.targetPos=nil
						end
					elseif moveX<0 then
						if obj.currentPos~=0 then
							obj.currentPos=obj.currentPos-1
							obj.targetPos=nil
						end
					end
				end

				--Движение стрелочками вверх и вниз

				local carreteLine

				if moveY then

					--Лишний пересчёт
					local sum=0
					for i=1,#wrapped do
						carreteLine=i
						if obj.currentPos<sum+utf8.len(wrapped[i]) then
							break
						elseif obj.currentPos==sum+utf8.len(wrapped[i]) and obj.text:sub(utf8.offset(obj.text,sum+utf8.len(wrapped[i])),utf8.offset(obj.text,sum+utf8.len(wrapped[i])))=="\n" then
							carreteLine=carreteLine+1
							break
						else
							sum=sum+utf8.len(wrapped[i])
						end
					end

					if moveY>0 then
						if wrapped[carreteLine+1] then
							carreteLine=carreteLine+1
						else
							obj.currentPos=utf8.len(obj.text)
							obj.targetPos=utf8.len(wrapped[#wrapped])
						end
					else
						carreteLine=carreteLine-1
					end

					if carreteLine~=0 then
						local sum=0
						for i=1,carreteLine-1 do
							sum=sum+utf8.len(wrapped[i])
						end

						local lineLength=utf8.len(wrapped[carreteLine])

						if lineLength-1>=obj.targetPos then
							sum=sum+obj.targetPos
						else
							if lineLength~=0 then
								if wrapped[carreteLine]:sub(-1,-1)=="\n" then
									sum=sum+lineLength-1
								else
									sum=sum+lineLength
								end
							end
						end
						obj.currentPos=sum
					else
						obj.currentPos=0
						obj.targetPos=0
					end
				end

				--
				local carretePos

				local sum=0
				for i=1,#wrapped do
					carreteLine=i
					if obj.currentPos<=sum+utf8.len(wrapped[i]) then
						break
					else
						sum=sum+utf8.len(wrapped[i])
					end
				end

				carretePos=obj.currentPos-sum

				if carretePos==utf8.len(wrapped[carreteLine]) and wrapped[carreteLine]:sub(-1,-1)=="\n" then
					carretePos=0
					carreteLine=carreteLine+1
				end
				obj.targetPos=obj.targetPos or carretePos

				obj.carreteX=carretePos
				obj.carreteY=carreteLine

				obj.rektY=(carreteLine-1)*obj.fontH
				obj.rektX=obj.font:getWidth(wrapped[carreteLine]:sub(1,utf8.offset(wrapped[carreteLine],carretePos+1)-1))

				obj:updateTextOffset(backspace)
			end

			function obj:updateTextOffset(backspace)

				self.textDisplay=self.text

				if self.oneline then--Горизонтальный сдвиг при oneline
					local maxW=self.w-tbl.textXoffset*2
					local move

					if self.displayStartOffset~=1 and backspace then
						self.displayStartOffset=self.displayStartOffset-1
						move=true
					end

					if self.displayStartOffset<=self.currentPos+1 then--Если курсор справа от начала строки
						local zeroToPosWidth=self.font:getWidth(self.text:sub(1,utf8.offset(self.text,self.currentPos +1)-1))
						local zeroToOffsetWidth=self.font:getWidth(self.text:sub(1,utf8.offset(self.text,self.displayStartOffset-1 +1)-1))

						while zeroToPosWidth-zeroToOffsetWidth>maxW do
							move=true
							self.displayStartOffset=self.displayStartOffset+1
							zeroToOffsetWidth=self.font:getWidth(self.text:sub(1,utf8.offset(self.text,self.displayStartOffset-1 +1)-1))
						end

						--Окончательное переопределение позиции каретки
						self.rektX=zeroToPosWidth-zeroToOffsetWidth
						self.rektY=0--Защита от некорректно работающей при oneline функции updateCarette
						--

						if move then
							self.finisher=self.currentPos
							while self.font:getWidth(self.text:sub(utf8.offset(self.text,self.displayStartOffset),utf8.offset(self.text,self.finisher+1 +1)-1))<maxW do
								if self.finisher~=utf8.len(self.text) then
									self.finisher=self.finisher+1
								else
									break
								end
							end
						elseif self.font:getWidth(self.text)<=maxW then
							self.finisher=utf8.len(self.text)
						end

						self.textDisplay=self.text:sub(utf8.offset(self.text,self.displayStartOffset),utf8.offset(self.text,self.finisher+1)-1)

					else--Если курсор перед началом строки

							self.displayStartOffset=self.displayStartOffset-1

							--Каретку в начало строки
							self.rektX=self.rektX-self.font:getWidth(self.text:sub(1,utf8.offset(self.text,self.currentPos +1)-1))
							self.rektY=0
							--

							self.textDisplay=self.text:sub(utf8.offset(self.text,self.displayStartOffset),utf8.offset(self.text,self.finisher+1 +1)-1)

							if self.font:getWidth(self.textDisplay)>maxW then
								self.finisher=self.finisher-1
								self.textDisplay=self.text:sub(utf8.offset(self.text,self.displayStartOffset),utf8.offset(self.text,self.finisher+1)-1)
							end

					end
				else--Вертикальный сдвиг //TODO

					if backspace and self.finisher+1<self.maxLines then
						self.finisher=self.finisher+1
					end

					if self.carreteY>self.finisher then
						self.displayStartOffset=self.displayStartOffset+1
						self.finisher=self.finisher+1
					elseif self.carreteY<self.displayStartOffset then
						self.displayStartOffset=self.displayStartOffset-1
						self.finisher=self.finisher-1
					end

					local _,wrapped=obj.font:getWrap(obj.text,obj.w - tbl.textXoffset*2)
					wrapped[1]=wrapped[1] or ""
					if obj.text:sub(-1,-1)=="\n" then
						insert(wrapped,"")
					end

					local positions={[0]=0}

					local duplicate=""
					for i=1,#wrapped do
						duplicate=duplicate..wrapped[i]
						if self.text:sub(#duplicate+1,#duplicate+1)=="\n" then
							wrapped[i]=wrapped[i].."\n"
							duplicate=duplicate.."\n"
						end
						positions[i]=positions[i-1]+#wrapped[i]
					end
					duplicate=nil

					self.textDisplay=self.text:sub(positions[self.displayStartOffset-1]+1,positions[self.finisher])
					self.rektY=self.rektY-(self.displayStartOffset-1)*self.fontH
				end
			end

			obj.upd=tbl.default.objectHl

			obj.draw=function(obj)
				love.graphics.setColor(obj.color)
				love.graphics.rectangle("fill",obj.x, obj.y, obj.w, obj.h)

				love.graphics.setColor(obj.frameColor)
				love.graphics.rectangle("line",obj.x, obj.y, obj.w, obj.h)

				love.graphics.setColor(obj.textColor)
				love.graphics.setFont(obj.font)
				love.graphics.printf(obj.textDisplay, obj.x+tbl.textXoffset, obj.y+tbl.textYoffset+obj.yoffset, obj.w - tbl.textXoffset*2,"left")

				if tbl.focusKeyboard==tbl.assocQueue[obj.name] then love.graphics.rectangle("fill",obj.x+tbl.textXoffset+obj.rektX,obj.y+tbl.textYoffset+obj.rektY+obj.yoffset,1,obj.fontH) end
			end

			return obj
		end,
		wheelSwitch=function(obj,tbl)
			obj.hlColor = obj.hlColor or {obj.color[1]*tbl.basButtonHLMultiplier, obj.color[2]*tbl.basButtonHLMultiplier, obj.color[3]*tbl.basButtonHLMultiplier}
			obj.textY = obj.y + obj.h/2 - obj.font:getHeight()/2
			obj.activated = true

			obj.fnc = not obj.activatable and function() end or function(obj,x,y,but)
				if but==1 then obj.activated=not obj.activated end
			end

			obj.fncRelease=function() end

			obj.upd = function(obj, i, x, y, dt)
				if x >= obj.x and x <= obj.x+obj.w and y >= obj.y and y <= obj.y+obj.h then
					tbl.hl = i
					tbl.focusWheel = i
				end
			end

			obj.draw = function(obj)
				love.graphics.setFont(obj.font)
				if not obj.activatable then
					love.graphics.setColor(tbl.hl ~= tbl.assocQueue[obj.name] and obj.color or obj.hlColor)
				else
					obj.activated = obj.activated and tbl.hl == tbl.assocQueue[obj.name] or false
					love.graphics.setColor(obj.activated and obj.hlColor or obj.color)
				end
				love.graphics.rectangle("line", obj.x, obj.y, obj.w, obj.h)

				if obj.fill then love.graphics.setColor({ [4]=tbl.basButtonFillOpac, love.graphics.getColor() }); love.graphics.rectangle("fill", obj.x, obj.y, obj.w, obj.h) end

				love.graphics.setColor(obj.textColor)
				love.graphics.printf(obj.text, obj.x, obj.textY, obj.w,"center")
			end

			obj.wheelmoved = function(x,y)
				if obj.activated then
					if y>0 then
						obj.cur = obj.cur + obj.step
						if obj.cur>obj.max then obj.cur=obj.max end
					elseif y<0 then
						obj.cur = obj.cur - obj.step
						if obj.cur<obj.min then obj.cur=obj.min end
					end
				end
			end

			return obj 
		end,
		dropdown=function(obj,tbl)

			obj.frameColor=obj.frameColor or {obj.color[1]*tbl.textFrameColorMultiplier, obj.color[2]*tbl.textFrameColorMultiplier, obj.color[3]*tbl.textFrameColorMultiplier}
			obj.open=false
			obj.elemOffset=0
			local preselect=0
			local mpressed

			if obj.selected~=0 then
				obj.elemOffset=(obj.selected+obj.maxElements-1<=#obj.elements) and obj.selected-1 or #obj.elements>=obj.maxElements and #obj.elements-obj.maxElements or 0
			end

			obj.maxH=obj.elementH*obj.maxElements
			obj.sliderX=obj.x+obj.w-tbl.dropdownSliderWidth

			obj.arrowVerticles={obj.x+obj.w-obj.elementH,obj.y+tbl.dropdownArrowOffset,obj.x+obj.w-tbl.dropdownArrowOffset,obj.y+tbl.dropdownArrowOffset,obj.x+obj.w-(obj.elementH+tbl.dropdownArrowOffset)/2,obj.y-tbl.dropdownArrowOffset+obj.elementH}

			obj.updateHeight=function(_, i, x, y, dt)
				if obj.open then
					local elems=#obj.elements
					local count=elems<=obj.maxElements and elems or obj.maxElements 
					obj.h=count~=0 and (count+1)*obj.elementH or obj.elementH

					obj.sliderSize=obj.maxH*obj.maxElements/#obj.elements
					if obj.sliderSize<tbl.dropdownMinSliderSize then
						obj.sliderSize=tbl.dropdownMinSliderSize
					end
					obj.sliderPos=(obj.maxH-obj.sliderSize)*obj.elemOffset/(#obj.elements-obj.maxElements)+obj.elementH
					if not tbl.default.objectHl(obj,i,love.mouse.getX(),love.mouse.getY(),0) then
						preselect=0
					end
				else
					obj.h=obj.elementH
					preselect=0
				end
			end
			obj.updateHeight()

			obj.upd=function(obj, i, x, y, dt)
				if tbl.default.objectHl(obj, i, x, y, dt) then
					if y>obj.y+obj.elementH then
						for i = 2,obj.maxElements+1 do
							if y<=obj.y+obj.elementH*i then
								preselect=i-1
								break
							end
						end
					end
					tbl.focusWheel=i
				else
					if obj.open then
						local pressedOut=love.mouse.isDown(1) or love.mouse.isDown(2)
						if pressedOut and not mpressed then
							obj.open=false
							obj.updateHeight()
						end
					end
				end
			end

			obj.fnc=function(obj,x,y,but)
				mpressed=true
				if not obj.open then
					obj.open=true
					obj.updateHeight(obj, i, x, y, dt)
					preselect=obj.selected-obj.elemOffset
				else
					obj.open=false
					obj.updateHeight(obj, i, x, y, dt)
					if y>obj.y+obj.elementH then
						for i = 2,obj.maxElements+1 do
							if y<=obj.y+obj.elementH*i then
								obj.selected=i-1+obj.elemOffset
								obj.returnFnc(obj,obj.selected,obj.elements[obj.selected])
								break
							end
						end
					end
				end
			end

			obj.fncRelease=function(obj,x,y,but)
				if obj then
					if obj.quickSelect then
						if y>=obj.y+obj.elementH then
							for i = 2,obj.maxElements+1 do
								if y<=obj.y+obj.elementH*i then
									obj.selected=i-1+obj.elemOffset
									obj.open=false
									obj.updateHeight()
									break
								end
							end
						end
					end
				end
				mpressed=false
			end

			obj.wheelmoved=function(x,y)
				if y>0 then
					if obj.open then
						if obj.elemOffset~=0 then obj.elemOffset=obj.elemOffset-1 end
						obj.sliderPos=(obj.maxH-obj.sliderSize)*obj.elemOffset/(#obj.elements-obj.maxElements)+obj.elementH
					else
						if obj.selected~=1 then 
							obj.selected=obj.selected-1
							obj.elemOffset=(obj.selected+obj.maxElements-1<=#obj.elements) and obj.selected-1 or #obj.elements>=obj.maxElements and #obj.elements-obj.maxElements or 0
						end
					end
				elseif y<0 then
					if obj.open then
						if #obj.elements-obj.elemOffset>obj.maxElements then
							obj.elemOffset=obj.elemOffset+1
							obj.sliderPos=(obj.maxH-obj.sliderSize)*obj.elemOffset/(#obj.elements-obj.maxElements)+obj.elementH
						end
					else
						if #obj.elements~=obj.selected then
							obj.selected=obj.selected+1
							obj.elemOffset=(obj.selected+obj.maxElements-1<=#obj.elements) and obj.selected-1 or #obj.elements>=obj.maxElements and #obj.elements-obj.maxElements or 0
						end
					end
				end
			end

			local yOffset=math.floor((obj.elementH-obj.font:getHeight())/2)

			obj.draw=function()
				love.graphics.setFont(obj.font)

				love.graphics.setColor(obj.color)
				love.graphics.rectangle("fill",obj.x,obj.y,obj.w,obj.h)

				love.graphics.setColor(obj.frameColor)
				love.graphics.rectangle("line",obj.x,obj.y,obj.w,obj.h)
				love.graphics.rectangle("line",obj.x,obj.y,obj.w,obj.elementH)

				if obj.open then
					if preselect~=0 then
						love.graphics.setColor(obj.hlColor)
						love.graphics.rectangle("fill",obj.x,obj.y+preselect*obj.elementH,obj.w,obj.elementH)
					end

					love.graphics.setColor(obj.textColor)
					local elemCount=#obj.elements
					local hi=elemCount<=obj.maxElements and elemCount or obj.maxElements
					for i = 1,hi do
						love.graphics.print(obj.elements[i+obj.elemOffset],obj.x+tbl.dropdownXoffset,obj.elementH*i+obj.y+yOffset)
					end

					if #obj.elements>obj.maxElements then
						love.graphics.setColor(obj.frameColor)
						love.graphics.rectangle("fill",obj.sliderX,obj.y+obj.sliderPos,tbl.dropdownSliderWidth,obj.sliderSize)
					end
				else
					love.graphics.polygon("fill",obj.arrowVerticles)
				end

				love.graphics.setColor(obj.textColor)
				love.graphics.print(obj.elements[obj.selected] or "",obj.x+tbl.dropdownXoffset,obj.y+yOffset)
			end

			return obj
		end,
		dropdownSearch=function(obj,tbl)
			local oobj=obj

			obj[1],obj[2]=obj.name.."_dropdown","dropdown"

			local listItems=obj.elements
			local resultIndex={}

			local dropdownName = tbl.new(obj)
			local searchbarName = tbl.new{
				obj.name.."_searchbar",
				"textArea",
				x=obj.x,
				y=obj.y,
				w=obj.w,
				h=obj.elementH,
				font=obj.font,
				color={255,255,255,255},
				textColor={0,0,0,255},
				returnFnc=function() end
			}

			local complexObject={name=obj.name,type=obj.type,upd=function()end,draw=function()end,fnc=function()end,complex={dropdownName,searchbarName},lastSearch=""}

			local dropdownObject=tbl.getObject(dropdownName)
			local searchbarObject=tbl.getObject(searchbarName)

			local origFnc=searchbarObject.fnc
			searchbarObject.fnc=function(obj,x,y,but)
				origFnc(obj,x,y,but)
				dropdownObject.open=true
				dropdownObject.updateHeight()
			end

			local origListUpd=dropdownObject.upd
			dropdownObject.upd=function(obj, i, x, y, dt)
				local barText=uts.lower(tbl.getValue(searchbarName))
				if complexObject.lastSearch~=barText then
					local searchResults={}
					resultIndex={}
					for i,val in pairs(listItems) do
						if type(val)~="table" then
							if string.find(uts.lower(tostring(val)),barText) then
								insert(searchResults,val)
								insert(resultIndex,i)
							end
						else
							for u,item in pairs(val) do
								if type(item)=="string" then
									if string.find(uts.lower(item),barText) then
										insert(searchResults,val)
										insert(resultIndex,i)
										break
									end
								end
							end
						end
					end

					obj.elements=searchResults
					obj.updateHeight()

					complexObject.lastSearch=barText
				end

				if not obj.open then
					searchbarObject.color={0,0,0,0}
					searchbarObject.textColor={0,0,0,0}
					--//TODO Внедрить функцию ui.setText()
					if searchbarObject.text~="" then
						obj.selected=resultIndex[obj.selected]
						obj.elements=listItems
						if obj.selected then
							oobj.selectFnc(obj,listItems[obj.selected],obj.selected,complexObject)
						end

						searchbarObject.text=""
						searchbarObject.currentPos=0
						searchbarObject.targetPos=0
						searchbarObject.updateCarette()
						obj.selected=0
					elseif obj.selected~=0 then
						oobj.selectFnc(obj,listItems[obj.selected],obj.selected,complexObject)
						obj.selected=0
					end
				else
					searchbarObject.color={255,255,255,255}
					searchbarObject.textColor={0,0,0,255}
				end

				origListUpd(obj, i, x, y, dt)
			end

			return complexObject
		end,
		onelineText=function(obj,tbl)
			obj.fnc=function() end
			obj.upd=function() end

			local fontHeight=obj.font:getHeight()
			obj.textWidth=obj.font:getWidth(obj.text)
			obj.textXPos=obj.x+(obj.align=="center" and math.floor((obj.w-obj.textWidth)/2) or obj.align=="right" and obj.w-obj.textWidth or 0)

			if obj.textWidth>obj.w then error("Text is too big to be one-line in this object") end

			if not obj.h then 
				obj.h=fontHeight
				obj.yOffset=0
			else
				obj.yOffset=math.floor((obj.h-fontHeight)/2)
			end

			--Attributes init
			if obj.shadow then
				if type(obj.shadow)~="table" then
					obj.shadow=tbl.onelineDefaultShadow
				end
			end
			if obj.bolding then
				if type(obj.bolding)~="table" then
					obj.bolding=tbl.onelineDefaultBolding
				end
			end
			if obj.frame then
				if type(obj.frame)~="table" then
					obj.frame=tbl.onelineDefaultFrame
				end
			end
			if obj.underline then
				if type(obj.underline)~="table" then
					obj.underline=obj.textColor
				end
			end
			if obj.cross then
				if type(obj.cross)~="table" then
					obj.cross=obj.textColor
				end
			end

			obj.draw=function(obj)
				--testo
				obj.textWidth=obj.font:getWidth(obj.text)
				obj.textXPos=obj.x+(obj.align=="center" and math.floor((obj.w-obj.textWidth)/2) or obj.align=="right" and obj.w-obj.textWidth or 0)
				--
				love.graphics.setFont(obj.font)
				if obj.shadow then
					love.graphics.setColor(obj.shadow)
					for i = 0,obj.shadowOffset,obj.shadowOffset>0 and 1 or -1 do
						love.graphics.printf(obj.text, obj.x+i, obj.y+obj.yOffset+i, obj.w,obj.align)
					end
				end
				if obj.bolding then
					love.graphics.setColor(obj.bolding)
					for i = -tbl.onelineBoldingRange,tbl.onelineBoldingRange do
						for u = -tbl.onelineBoldingRange,tbl.onelineBoldingRange do
							love.graphics.printf(obj.text, obj.x+i, obj.y+obj.yOffset+u, obj.w,obj.align)
						end
					end
				end
				if obj.frame then
					love.graphics.setColor(obj.frame)
					love.graphics.rectangle("line",obj.x-1,obj.y-1,obj.w+2,obj.h+2)
				end
				if obj.underline then
					love.graphics.setColor(obj.underline)
					love.graphics.rectangle("fill",obj.textXPos,obj.y+obj.yOffset+fontHeight+tbl.onelineUnderlineYOffset,obj.textWidth,tbl.onelineLineHeight)
				end

				love.graphics.setColor(obj.textColor)
				love.graphics.printf(obj.text, obj.x, obj.y+obj.yOffset, obj.w,obj.align)

				if obj.cross then
					love.graphics.setColor(obj.cross)
					love.graphics.rectangle("fill",obj.textXPos,obj.y+obj.yOffset+fontHeight/2,obj.textWidth,tbl.onelineLineHeight)
				end
			end

			return obj
		end,
		progressBar=function(obj,tbl)

			obj.finish=false
			
			obj.fnc=function() end

			obj.upd=function(obj,i,x,y,dt) 
				if not obj.finish then
					obj.currentValue=obj.valueUpdate(obj,dt) or obj.currentValue
					if obj.currentValue>=1 then
						obj.finish=true
						obj.currentValue=1
						obj.finishFnc(obj)
					end
				end
			end

			
			if obj.fillMode==1 then--Fill mode 1
				obj.draw=function()
					love.graphics.setColor(obj.bgColor)
					love.graphics.rectangle("fill",obj.x,obj.y,obj.w,obj.h)

					love.graphics.setColor(obj.color)
					--
					love.graphics.rectangle("fill",obj.x,obj.y,obj.w*obj.currentValue,obj.h)
					--

					love.graphics.setColor(obj.frameColor)
					love.graphics.rectangle("line",obj.x,obj.y,obj.w,obj.h)
				end
			
			elseif obj.fillMode==2 then--Fill mode 2
				obj.draw=function()
					love.graphics.setColor(obj.bgColor)
					love.graphics.rectangle("fill",obj.x,obj.y,obj.w,obj.h)

					love.graphics.setColor(obj.color)
					--
					love.graphics.rectangle("fill",obj.x,obj.y+obj.h-obj.h*obj.currentValue,obj.w,obj.h*obj.currentValue)
					--

					love.graphics.setColor(obj.frameColor)
					love.graphics.rectangle("line",obj.x,obj.y,obj.w,obj.h)
				end
			
			elseif obj.fillMode==3 then--Fill mode 3
				obj.draw=function()
					love.graphics.setColor(obj.bgColor)
					love.graphics.rectangle("fill",obj.x,obj.y,obj.w,obj.h)

					love.graphics.setColor(obj.color)
					--
					love.graphics.rectangle("fill",obj.x+obj.w-obj.w*obj.currentValue,obj.y,obj.w*obj.currentValue,obj.h)
					--

					love.graphics.setColor(obj.frameColor)
					love.graphics.rectangle("line",obj.x,obj.y,obj.w,obj.h)
				end

			elseif obj.fillMode==4 then--Fill mode 4
				obj.draw=function()
					love.graphics.setColor(obj.bgColor)
					love.graphics.rectangle("fill",obj.x,obj.y,obj.w,obj.h)

					love.graphics.setColor(obj.color)
					--
					love.graphics.rectangle("fill",obj.x,obj.y,obj.w,obj.h*obj.currentValue)
					--

					love.graphics.setColor(obj.frameColor)
					love.graphics.rectangle("line",obj.x,obj.y,obj.w,obj.h)
				end
			end

			return obj
		end,
		progressCircle=function(obj,tbl)

			obj.finish=false
			obj.fillMulti=obj.fillMode==1 and 1 or obj.fillMode==2 and -1 or 0
			
			obj.fnc=function() end

			obj.upd=function(obj,i,x,y,dt) 
				if not obj.finish then
					obj.currentValue=obj.valueUpdate(obj,dt) or obj.currentValue
					if obj.currentValue>=1 then
						obj.finish=true
						obj.currentValue=1
						obj.finishFnc(obj)
					end
				end
			end

			
			obj.draw=function()
				love.graphics.setColor(obj.bgColor)
				love.graphics.circle("fill",obj.x,obj.y,obj.r)

				love.graphics.setColor(obj.color)
				--
				love.graphics.arc("fill",obj.x,obj.y,obj.r,-math.pi/2,obj.fillMulti*math.pi*2*obj.currentValue-math.pi/2)
				--

				love.graphics.setColor(obj.insideColor)
				love.graphics.circle("fill",obj.x,obj.y,obj.r*tbl.progressCircleInsideCircleRMulti)

				love.graphics.setColor(obj.frameColor)
				love.graphics.circle("line",obj.x,obj.y,obj.r)
			end

			return obj
		end,
		checkBox=function(obj,tbl)
			local curBgColor=obj.bgColor
			local mode,params
			local held

			if obj.checkShape==1 then
				mode="checkBoxSquare"
				params={obj.x+obj.w-obj.w*tbl.checkBoxCheckMulti-obj.w*(1-tbl.checkBoxCheckMulti)/2,obj.y+obj.h-obj.h*tbl.checkBoxCheckMulti-obj.h*(1-tbl.checkBoxCheckMulti)/2,obj.w*tbl.checkBoxCheckMulti,obj.h*tbl.checkBoxCheckMulti}
			elseif obj.checkShape==2 then
				mode="checkBoxCircle"
				params={obj.x+obj.w/2,obj.y+obj.h/2,(obj.w<=obj.h and obj.w or obj.h)/2*tbl.checkBoxCheckMulti}
			end

			obj.fnc = function(obj,x,y,but)
				if but==1 then
					curBgColor={obj.bgColor[1]*tbl.checkBoxPreCheckColorMulti,obj.bgColor[2]*tbl.checkBoxPreCheckColorMulti,obj.bgColor[3]*tbl.checkBoxPreCheckColorMulti}
					held=true
				end
			end

			obj.fncRelease= function(objR,x,y,but)
				if but==1 then
					if objR then
						obj.check=not obj.check
					end
					curBgColor=obj.bgColor
					held=false
				end
			end

			obj.upd = function(obj,i,x,y,dt) 
				tbl.default.objectHl(obj,i,x,y,dt)
				if held then
					if not love.mouse.isDown(1) then
						held=false
						curBgColor=obj.bgColor
					end
				end
			end

			obj.draw = function(obj)
				
				love.graphics.setColor(curBgColor)
				love.graphics.rectangle("fill", obj.x, obj.y, obj.w, obj.h)

				if obj.checkShape==1 then
						mode="checkBoxSquare"
						params={obj.x+obj.w-obj.w*tbl.checkBoxCheckMulti-obj.w*(1-tbl.checkBoxCheckMulti)/2,obj.y+obj.h-obj.h*tbl.checkBoxCheckMulti-obj.h*(1-tbl.checkBoxCheckMulti)/2,obj.w*tbl.checkBoxCheckMulti,obj.h*tbl.checkBoxCheckMulti}
					elseif obj.checkShape==2 then
						mode="checkBoxCircle"
						params={obj.x+obj.w/2,obj.y+obj.h/2,(obj.w<=obj.h and obj.w or obj.h)/2*tbl.checkBoxCheckMulti}
					end

				if obj.check then
					love.graphics.setColor(obj.color)
				else
					love.graphics.setColor({0.5, 0, 0, 1})
				end

				tbl.drawFunc[mode](0,0,params)

				love.graphics.setColor(tbl.hl ~= tbl.assocQueue[obj.name] and obj.frameColor or obj.hlColor)
				love.graphics.rectangle("line", obj.x, obj.y, obj.w, obj.h)
			end

			return obj
		end,
		softSwitch=function(obj,tbl)
			if obj.current>1 then obj.current=0 end

			local switchY=obj.y+obj.h/2-obj.switchSize/2
			local held

			local mode,params
			if obj.switchShape==1 then
				mode="softSwitchSquare"
				params={obj.switchColor,obj.switchFrameColor,obj.switchSize,switchY}
			elseif obj.switchShape==2 then
				mode="softSwitchCircle"
				params={obj.switchColor,obj.switchFrameColor,obj.switchSize/2,switchY+obj.switchSize/2}
			end

			obj.upd=function(obj,i,x,y,dt)
				local hl=tbl.default.objectHl(obj,i,x,y,dt)
				if held then
					if x>=obj.x and x<=obj.x+obj.w then
						obj.current=(x-obj.x)/obj.w
					elseif x<obj.x then
						obj.current=0
					else
						obj.current=1
					end
				end
			end

			obj.fnc=function(obj,x,y,but)
				if but==1 then
					held=true
				end
			end

			obj.fncRelease=function(obj,x,y,but)
				if but==1 then
					held=false
				end
			end

			obj.draw=function()
				love.graphics.setColor(obj.color)
				love.graphics.rectangle("fill",obj.x,obj.y,obj.w,obj.h)
				love.graphics.setColor(obj.frameColor)
				love.graphics.rectangle("line",obj.x,obj.y,obj.w,obj.h)

				tbl.drawFunc[mode](obj.x+obj.w*obj.current,0,params)

			end

			return obj
		end,
		slideList=function(obj,tbl)

			obj.frameColor=obj.frameColor or {obj.color[1]*tbl.textFrameColorMultiplier, obj.color[2]*tbl.textFrameColorMultiplier, obj.color[3]*tbl.textFrameColorMultiplier}
			obj.elemOffset=0

			local preselect=0
			local mpressed

			obj.maxH=obj.elementH*obj.maxElements
			obj.sliderX=obj.x+obj.w-tbl.dropdownSliderWidth

			obj.updateHeight=function()
				local elems=#obj.elements
				local count=elems<=obj.maxElements and elems or obj.maxElements 
				obj.h=obj.drawEmpty and obj.maxH or count~=0 and count*obj.elementH or obj.elementH

				obj.sliderSize=obj.maxH*obj.maxElements/#obj.elements
				if obj.sliderSize<tbl.dropdownMinSliderSize then
					obj.sliderSize=tbl.dropdownMinSliderSize
				end
				obj.sliderPos=(obj.maxH-obj.sliderSize)*obj.elemOffset/(#obj.elements-obj.maxElements)
			end
			obj.updateHeight()

			obj.upd=function(obj, i, x, y, dt)
				if tbl.default.objectHl(obj, i, x, y, dt) then
					for i = 1,obj.maxElements+1 do
						if y<=obj.y+obj.elementH*i then
							if obj.elements[i+obj.elemOffset] then
								preselect=i-1
								break
							else
								preselect=-1
							end
						end
					end
					tbl.focusWheel=i
				else
					preselect=-1
				end
			end

			obj.fnc=function(obj,x,y,but)
				mpressed=true
				for i = 1,obj.maxElements+1 do
					if y<=obj.y+obj.elementH*i then
						if obj.elements[i+obj.elemOffset] then
							obj.returnFnc(i+obj.elemOffset,obj.elements[i+obj.elemOffset],obj,but)
						end
						break
					end
				end
			end

			obj.fncRelease=function(obj,x,y,but)
				mpressed=false
			end

			obj.wheelmoved=function(x,y)
				if y>0 then
					if obj.elemOffset~=0 then obj.elemOffset=obj.elemOffset-1 end
					obj.sliderPos=(obj.maxH-obj.sliderSize)*obj.elemOffset/(#obj.elements-obj.maxElements)
				elseif y<0 then
					if #obj.elements-obj.elemOffset>obj.maxElements then
						obj.elemOffset=obj.elemOffset+1
						obj.sliderPos=(obj.maxH-obj.sliderSize)*obj.elemOffset/(#obj.elements-obj.maxElements)
					end
				end
			end

			local yOffset=math.floor((obj.elementH-obj.font:getHeight())/2)

			obj.draw=function()
				love.graphics.setFont(obj.font)

				love.graphics.setColor(obj.color)
				love.graphics.rectangle("fill",obj.x,obj.y,obj.w,obj.h)

				love.graphics.setColor(obj.frameColor)
				love.graphics.rectangle("line",obj.x,obj.y,obj.w,obj.h)

				if preselect~=-1 then
					love.graphics.setColor(obj.hlColor)
					love.graphics.rectangle("fill",obj.x,obj.y+preselect*obj.elementH,obj.w,obj.elementH)
				end

				love.graphics.setColor(obj.textColor)
				local elemCount=#obj.elements
				local hi=elemCount<=obj.maxElements and elemCount or obj.maxElements
				for i = 1,hi do
					love.graphics.print(obj.elements[i+obj.elemOffset],obj.x+tbl.dropdownXoffset,obj.elementH*(i-1)+obj.y+yOffset)
				end

				if #obj.elements>obj.maxElements then
					love.graphics.setColor(obj.frameColor)
					love.graphics.rectangle("fill",obj.sliderX,obj.y+obj.sliderPos,tbl.dropdownSliderWidth,obj.sliderSize)
				end
			end

			return obj
		end,
		screen=function(obj,tbl)
			obj.upd=function(obj, i, x, y, dt)
				tbl.default.objectHl(obj, i, x, y, dt)
			end
			obj.draw=function()
				love.graphics.setColor(obj.color)
				love.graphics.rectangle("fill",obj.x,obj.y,obj.w,obj.h)
			end

			return obj
		end
	},
}

tbl.default={
	objectHl = function(obj, i, x, y, dt)
		if x >= obj.x and x <= obj.x+obj.w and y >= obj.y and y <= obj.y+obj.h then
			tbl.hl = i
			return true
		end
	end,
	textAreaFnc = function(obj, x, y, but) tbl.focusKeyboard=tbl.assocQueue[obj.name] end,
	progressValueUpdate=function(obj,dt) return obj.currentValue+dt*0.5 end,
}

tbl.types={
	button={
		x=0, 
		y=0, 
		color={0, 144/255, 0, 255/255}, 
		w=150, 
		h=50, 
		font=tbl.basButtonFont,
		text="Button", 
		textColor={1,1,1,1}, 
		fill=false, 
		fnc=function() print("Button pressed") end, 
		fncRelease=function() end, 
		cursor="hand"
	}, textArea={
		x=0,
		y=0,
		w=200,
		h=200,
		color={255,255,255,255}, 
		textColor={0,0,0,255}, 
		text="", 
		font=tbl.textDefaultFont, 
		fnc=tbl.default.textAreaFnc, 
		fncRelease=function() end, 
		cursor="ibeam",
		returnFnc=false
	}, wheelSwitch={
		x=0,
		y=0,
		w=100,
		h=100,
		color={255,255,255,255},
		textColor={0,0,0,255},
		text="",
		font=tbl.textDefaultFont, 
		cursor="sizens",
		activatable=false,
		min=0,
		max=100,
		cur=10,
		step=1
	}, dropdown={
		x=0,
		y=0,
		w=150,
		elementH=30,
		maxElements=5,
		elements={},
		color={255,255,255,255},
		textColor={0,0,0,255},
		hlColor={200,200,200,255},
		frameColor={144,144,144,255},
		selected=0,
		font=tbl.textDefaultFont,
		quickSelect=false,
		returnFnc=function() end,
		cursor="arrow"
	}, dropdownSearch={
		x=0,
		y=0,
		w=150,
		elementH=30,
		maxElements=5,
		elements={},
		color={255,255,255,255},
		textColor={0,0,0,255},
		hlColor={200,200,200,255},
		frameColor={144,144,144,255},
		selected=0,
		font=tbl.textDefaultFont,
		cursor="arrow",
		selectFnc=function(obj,el,ind) print("Selected search result element "..el..", index "..ind) end
	}, onelineText={
		x=0,
		y=0,
		w=300,
		h=false,
		text="Text panel",
		font=tbl.textDefaultFont,
		align="center",
		textColor={255,255,255},
		shadow=false,
		shadowOffset=2,
		bolding=false,
		frame=false,
		underline=false,
		cross=false
	}, progressBar={
		x=0,
		y=0,
		w=200,
		h=40,
		color={255,200,100},
		frameColor={144,144,144},
		bgColor={0,0,0},
		fillMode=1,
		currentValue=0,
		valueUpdate=function(obj,dt) return obj.currentValue+dt*0.5 end,
		finishFnc=function(obj) end
	}, progressCircle={
		x=0,
		y=0,
		r=25,
		color={255,200,100},
		frameColor={144,144,144}, 
		bgColor={100,100,100},
		insideColor={144,144,144},
		fillMode=1,
		currentValue=0,
		valueUpdate=function(obj,dt) return obj.currentValue+dt*0.5 end,
		finishFnc=function(obj) end
	}, checkBox={
		x=0, 
		y=0, 
		w=20,
		h=20, 
		color={0, 0.5, 0, 1}, 
		hlColor={0.75,0.75,0.4},
		frameColor={0.5,0.5,0.5,1}, 
		bgColor={1,1,1,1}, 
		checkShape=1, 
		check=false
	}, softSwitch={
		x=0, 
		y=0, 
		w=200, 
		h=15, 
		color={0, 144, 0,144}, 
		frameColor={0,144,0,200}, 
		switchColor={0, 144, 0,255}, 
		switchFrameColor={0,144,0,255},
		min=0,
		max=100,
		current=0,
		switchShape=1,
		switchSize=20,
		cursor = false
	}, slideList={
		x=0,
		y=0,
		w=150,
		elementH=30,
		maxElements=5,
		elements={},
		color={255,255,255,255},
		textColor={0,0,0,255},
		hlColor={200,200,200,255},
		frameColor={144,144,144,255},
		font=tbl.textDefaultFont,
		returnFnc=function(id,val) print("Clicked element "..tostring(val)) end,
		cursor="arrow",
		drawEmpty=true
	}, screen={
		x=0,
		y=0,
		w=100,
		h=100,
		color={0,0,0,144},
		cursor="arrow",
		fnc=function()end,
	}
}

tbl.drawFunc={
	checkBoxSquare=function(x,y,params)
		love.graphics.rectangle("fill",params[1],params[2],params[3],params[4])
	end,
	checkBoxCircle=function(x,y,params)
		love.graphics.circle("fill",params[1],params[2],params[3])
	end,
	softSwitchSquare=function(x,y,params)
		love.graphics.setColor(params[1])
		love.graphics.rectangle("fill",x-params[3]/2,params[4],params[3],params[3])

		love.graphics.setColor(params[2])
		love.graphics.rectangle("fill",x-params[3]/2,params[4],params[3],params[3])
	end,
	softSwitchCircle=function(x,y,params)
		love.graphics.setColor(params[1])
		love.graphics.circle("fill",x,params[4],params[3])

		love.graphics.setColor(params[2])
		love.graphics.circle("line",x,params[4],params[3])
	end,
}

local cursors={
	["arrow"]=love.mouse.getSystemCursor("arrow")
}
setmetatable(cursors,{__index=function(self, key) self[key]=love.mouse.getSystemCursor(key) return self[key] end})

love.keyboard.setKeyRepeat(true)

local function setCursor()
	local curToSet = tbl.hl == 0 and "arrow" or tbl.queue[tbl.hl].cursor

	if curcur==curToSet then
	else
		love.mouse.setCursor(cursors[curToSet])
	end
end

function tbl.new(args)
	local object={name=args[1],type=args[2]}

	for i,val in pairs(tbl.types[object.type]) do
		if type(args[i])~="nil" then
			object[i]=args[i]
		else
			if type(val)~=nil then
				if tbl.reportMissingParameters then
					print("Missing element \""..i.."\" in "..object.type.." \""..object.name.."\". Replacing with defaults.")
				end
				object[i]=val
			else
				error("Missing mandatory element \""..i.."\" in "..object.type.." \""..object.name.."\".")
			end
		end
	end

	object = tbl.constructors[object.type](object,tbl)

	local ind=insert(tbl.queue,object)
	tbl.assocQueue[object.name]=ind

	return object.name

end

function tbl.remove(name)
	if type(name)=="string" then
		if tbl.assocQueue[name] then
			if tbl.queue[tbl.assocQueue[name]].complex then
				tbl.remove(tbl.assocQueue[name].complex)
			end
			tbl.queue[tbl.assocQueue[name]]=nil
			tbl.assocQueue[name]=nil
			tbl.resetFocus()
		else
			print("No such element in queue: "..name)
		end
	elseif type(name)=="table" then
		for i,val in pairs(name) do
			if tbl.assocQueue[val] then
				if tbl.queue[tbl.assocQueue[val]].complex then
					for u,item in pairs(tbl.queue[tbl.assocQueue[val]].complex) do
						tbl.remove(item)
					end
				end
				tbl.queue[tbl.assocQueue[val]]=nil
				tbl.assocQueue[val]=nil
			else
				print("No such element in queue: "..val)
			end
		end
		tbl.resetFocus()
	end
end

local clearExe

function tbl.executeUponClear(fnc)
	clearExe=fnc
end

function tbl.clear()
	tbl.queue={}
	tbl.assocQueue={}
	tbl.resetFocus()
	if clearExe then clearExe(); clearExe=nil end
end

function tbl.getObject(name)
	return tbl.queue[tbl.assocQueue[name]]
end

function tbl.getTextAreaText(nameOrNum)

	local id = type(nameOrNum)=="number" and nameOrNum or tbl.assocQueue[nameOrNum]

	if id then
		if tbl.queue[id].type=="textArea" then
			return tbl.queue[id].text
		else
			error("Object \""..nameOrNum.."\" is innoparative type for fetching text out")
		end
	else
		error("No such element in graphics queue \""..nameOrNum.."\"")
	end

end

function tbl.getValue(nameOrNum)

	local id = type(nameOrNum)=="number" and nameOrNum or tbl.assocQueue[nameOrNum]

	if id then
		if tbl.queue[id].type=="wheelSwitch" then
			return tbl.queue[id].cur
		elseif tbl.queue[id].type=="dropdown" then
			return tbl.queue[id].elements[tbl.queue[id].selected],tbl.queue[id].selected
		elseif tbl.queue[id].type=="checkBox" then
			return tbl.queue[id].check
		elseif tbl.queue[id].type=="softSwitch" then
			return (tbl.queue[id].max-tbl.queue[id].min)*tbl.queue[id].current+tbl.queue[id].min
		elseif tbl.queue[id].type=="textArea" then
			return tbl.getTextAreaText(id)
		else
			error("Object \""..nameOrNum.."\" is innoparative type for fetching out changable value")
		end
	else
		error("No such element in graphics queue \""..nameOrNum.."\"")
	end

end

function tbl.setAttributes(nameOrNum, x, y, w, h)
	local id = type(nameOrNum)=="number" and nameOrNum or tbl.assocQueue[nameOrNum]

	if id then
		local w, h = w or tbl.queue[id].w, h or tbl.queue[id].h
		tbl.queue[id].x,tbl.queue[id].y,tbl.queue[id].w,tbl.queue[id].h=x,y,w,h

	else
		error("No such element in graphics queue \""..nameOrNum.."\"")
	end
end

function tbl.editColorScheme(nameOrNum,scheme,newScheme)
	local id = type(nameOrNum)=="number" and nameOrNum or tbl.assocQueue[nameOrNum]

	if id then
		tbl.queue[id][scheme]=newScheme
	else
		error("No such element in graphics queue \""..nameOrNum.."\"")
	end
end

function tbl.updateList(nameOrNum,newList)
	local id = type(nameOrNum)=="number" and nameOrNum or tbl.assocQueue[nameOrNum]

	if id then
		if tbl.queue[id].type=="dropdown" then
			tbl.queue[id].elements=newList
			tbl.queue[id].updateHeight()
		elseif tbl.queue[id].type=="slideList" then
			tbl.queue[id].elements=newList
			tbl.queue[id].updateHeight()
		end
	else
		error("No such element in graphics queue \""..nameOrNum.."\"")
	end
end

function tbl.resetFocus()
	tbl.hl,tbl.focusWheel,tbl.focusKeyboard=0,0,0
end

--hooks

function tbl.update(dt)
	local x,y=love.mouse.getX(),love.mouse.getY()
	tbl.hl,tbl.focusWheel=0,0
	for i,val in pairs(tbl.queue) do
		val.upd(val,i,x,y,dt)
	end
	setCursor()
end

function tbl.draw()
	for i,val in pairs(tbl.queue) do
		val.draw(val)
	end
end

function tbl.hook()

	local oldDraw=love.draw
	function love.draw()
		oldDraw()
		local fonto,clr=love.graphics.getFont(),{love.graphics.getColor()}
		tbl.draw()
		love.graphics.setFont(fonto)
		love.graphics.setColor(clr)
	end

	local oldUpdate=love.update
	function love.update(dt)
		oldUpdate(dt)
		tbl.update(dt)
	end

	local oldMousepressed=love.mousepressed or function() end
	function love.mousepressed(x,y,but)
		if not tbl.blockMain then oldMousepressed(x,y,but) end
		tbl.focusKeyboard=0
		if tbl.hl~=0 then tbl.heldID[but]=tbl.hl; tbl.queue[tbl.hl].fnc(tbl.queue[tbl.hl],x,y,but) end
	end

	local oldMousereleased=love.mousereleased or function() end
	function love.mousereleased(x,y,but)
		if not tbl.blockMain then oldMousereleased(x,y,but) end
		if tbl.heldID[but]~=0 then ((tbl.queue[tbl.heldID[but]] or {})["fncRelease"] or function() end)(tbl.hl==tbl.heldID[but] and tbl.queue[tbl.hl] or nil,x,y,but,tbl.queue[tbl.heldID[but]]); tbl.heldID[but]=0 end
	end

	local oldTextinput=love.textinput or function() end
	function love.textinput(key)
		if tbl.focusKeyboard==0 then
			if not tbl.blockMain then
				oldTextinput(key)
			end
		else
			tbl.queue[tbl.focusKeyboard].textinput(key)
		end
	end

	local oldKeypressed=love.keypressed or function() end
	function love.keypressed(key)
		if tbl.focusKeyboard==0 then
			if not tbl.blockMain then
				oldKeypressed(key)
			end
		else
			tbl.queue[tbl.focusKeyboard].keypressed(key)
		end
	end

	local oldWheel=love.wheelmoved or function() end
	function love.wheelmoved(x,y)
		if tbl.focusWheel==0 then
			if not tbl.blockMain then
				oldWheel(x,y)
			end
		else
			tbl.queue[tbl.focusWheel].wheelmoved(x,y)
		end
	end

	print("QGUI hook succcess")
end

return tbl