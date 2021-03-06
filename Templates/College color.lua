--
-- This module implements {{CollegePrimaryHex}}, {{CollegePrimaryStyle}},
-- {{CollegePrimaryColorLink}}, {{CollegeSecondaryHex}},
-- {{CollegeSecondaryStyle}}, {{CollegeSecondaryColorLink}}, and {{NCAA color}}
--
local p = {}

local data_module = "Module:College color/data"

local function stripwhitespace(text)
	return text:match("^%s*(.-)%s*$")
end
local function ucfirst(s)
	local first = s:sub(1, 1)
	local others = s:sub(2, -1)
	return first:upper() .. others
end
local function bordercss(c, w)
	local s = 'inset ' .. w .. 'px ' .. w .. 'px 0 ' .. c 
		.. ', inset -' .. w .. 'px -' .. w .. 'px 0 ' .. c
	return 'box-shadow: ' .. s .. ';'
end
local function sRGB ( v )
	if (v <= 0.03928) then
		v = v / 12.92
	else
		v = math.pow((v+0.055)/1.055, 2.4)
	end
	return v
end
local function color2lum( origc )
	local c = stripwhitespace(origc or ''):lower()

	-- remove leading # (if there is one)
	c = mw.ustring.match(c, '^[#]*([a-f0-9]*)$')

	-- split into rgb
	local cs = mw.text.split(c or '', '')
	if( #cs == 6 ) then
		local R = sRGB( (16*tonumber('0x' .. cs[1]) + tonumber('0x' .. cs[2]))/255 )
		local G = sRGB( (16*tonumber('0x' .. cs[3]) + tonumber('0x' .. cs[4]))/255 )
		local B = sRGB( (16*tonumber('0x' .. cs[5]) + tonumber('0x' .. cs[6]))/255 )

		return 0.2126 * R + 0.7152 * G + 0.0722 * B
	elseif ( #cs == 3 ) then
		local R = sRGB( (16*tonumber('0x' .. cs[1]) + tonumber('0x' .. cs[1]))/255 )
		local G = sRGB( (16*tonumber('0x' .. cs[2]) + tonumber('0x' .. cs[2]))/255 )
		local B = sRGB( (16*tonumber('0x' .. cs[3]) + tonumber('0x' .. cs[3]))/255 )

		return 0.2126 * R + 0.7152 * G + 0.0722 * B
	end

	-- failure
	error('Invalid hex color ' .. origc, 2)
end

local function remove_sport(team)
	team = mw.ustring.gsub(team, "%s*<[Bb][Rr][^<>]*>%s*", ' ');
	team = mw.ustring.gsub(team, " [Tt]eam$", '')
	team = mw.ustring.gsub(team, " [Bb]asketball$", '')
	team = mw.ustring.gsub(team, " [Bb]aseball$", '')
	team = mw.ustring.gsub(team, " [Cc]ross [Cc]ountry$", '')
	team = mw.ustring.gsub(team, " [Ff]ield [Hh]ockey$", '')
	team = mw.ustring.gsub(team, " [Ff]ootball$", '')
	team = mw.ustring.gsub(team, " [Gg]olf$", '')
	team = mw.ustring.gsub(team, " [Gg]ymnastics$", '')
	team = mw.ustring.gsub(team, " [Ii]ce [Hh]ockey$", '')
	team = mw.ustring.gsub(team, " [Ll]acrosse$", '')
	team = mw.ustring.gsub(team, " [Rr]owing$", '')
	team = mw.ustring.gsub(team, " [Ss]ki$", '')
	team = mw.ustring.gsub(team, " [Ss]occer$", '')
	team = mw.ustring.gsub(team, " [Ss]oftball$", '')
	team = mw.ustring.gsub(team, " [Ss]wim$", '')
	team = mw.ustring.gsub(team, " [Tt]ennis$", '')
	team = mw.ustring.gsub(team, " [Tt]rack [Aa]nd [Ff]ield$", '')
	team = mw.ustring.gsub(team, " [Vv]olleyball$", '')
	team = mw.ustring.gsub(team, " [Ww]restling$", '')
	team = mw.ustring.gsub(team, " [Ww]omen's$", '')
	team = mw.ustring.gsub(team, " [Mm]en's$", '')

	return team
end
local function get_colors(team, unknown)
	team = stripwhitespace(team or '')
	unknown = unknown or {"DCDCDC", "000000"}

	local use_default = {
		[""] = 1,
		["retired"] = 1,
		["free agent"] = 1,
	}

	local colors = nil

	if ( team and use_default[team:lower()] ) then
		colors = {"DCDCDC", "000000"}
	else
		local all_colors = mw.loadData(data_module)
		colors = all_colors[team]
		if ( colors and type(colors) == 'string' ) then
			colors = all_colors[colors]
		end
	end

	return colors or unknown
end

local function team_color(team, num, num2)
	local colors = get_colors(team, nil)

	num = tonumber(num:match('[1-3]') or '0')
	num2 = tonumber(num2:match('[1-3]') or '0')
	if ( num ) then
		return colors[num] or colors[num2] or ''
	else
		return ''
	end
end

local function team_style1(team, borderwidth, fontcolor)
	local colors = get_colors(team, nil)

	local color = '#' .. (colors[3] or colors[2] or '')
	local style = 'background-color:#' .. (colors[1] or '') .. ';color:' .. (fontcolor or color) .. ';'
	-- remove the border if it's nearly white
	if ((1 + 0.05)/(color2lum(color) + 0.05) < 1.25) then
		borderwidth = '0'
	end
	borderwidth = tonumber(borderwidth or '2') or 0
	if (borderwidth > 0 and color ~= '#FFFFFF') then
		style = style .. bordercss(color, borderwidth)
	end

	return style
end

local function team_style2(team, borderwidth, fontcolor)
	local colors = get_colors(team, nil)

	local color = '#' .. (colors[1] or '')
	local style = 'background-color:#' .. (colors[3] or colors[2] or '') .. ';color:' .. (fontcolor or color) .. ';'
	-- remove the border if it's nearly white
	if ((1 + 0.05)/(color2lum(color) + 0.05) < 1.25) then
		borderwidth = '0'
	end
	borderwidth = tonumber(borderwidth or '2') or 0
	if (borderwidth > 0 and color ~= '#FFFFFF') then
		style = style .. bordercss(color, borderwidth)
	end

	return style
end

local function team_header1(team, borderwidth)
	local colors = get_colors(team, nil)
	-- set the default background
	local background = (colors[1] or 'FFFFFF'):upper()
	-- set background to white if it's nearly white
	if ((1 + 0.05)/(color2lum(background) + 0.05) < 1.25) then
		background = 'FFFFFF'
	end
	-- now pick a font color
	local fontcolor = '000000'
	-- compute the luminosity of the background
	local lum = color2lum(background)
	-- compute the contrast with white and black
	local wcontrast = (1 + 0.05)/(lum + 0.05)
	local bcontrast = (lum + 0.05)/(0 + 0.05)
	-- select the text color with the best contrast
	if( bcontrast > wcontrast + 1.25 ) then
		fontcolor = '000000'
	else
		fontcolor = 'FFFFFF'
	end

	local style
	if( background == 'FFFFFF' ) then
		style = 'background-color:none;color:#' .. fontcolor .. ';'
	else
		style = 'background-color:#' .. background .. ';color:#' .. fontcolor .. ';'
	end

	if borderwidth then
		borderwidth = tonumber(borderwidth or '2') or 0
		local bordercolor = (colors[3] or colors[2] or 'FFFFFF'):upper()
		if (borderwidth > 0 and bordercolor ~= 'FFFFFF') then
			-- do not add a border if it's nearly white
			if ((1 + 0.05)/(color2lum(bordercolor) + 0.05) >= 1.25) then
				style = style .. bordercss('#' .. bordercolor, borderwidth)
			end
		end
	end
	return style
end

local function team_header2(team)
	local colors = get_colors(team, nil)
	-- set the default background
	local background = (colors[3] or colors[2] or 'FFFFFF'):upper()
	-- set background to white if it's nearly white
	if ((1 + 0.05)/(color2lum(background) + 0.05) < 1.25) then
		background = 'FFFFFF'
	end
	-- if the background is white, then use the primary background instead
	if( background == 'FFFFFF' ) then
		background = (colors[1] or 'FFFFFF'):upper()
	end
	-- now pick a font color
	local fontcolor = '000000'
	-- compute the luminosity of the background
	local lum = color2lum(background)
	-- compute the contrast with white and black
	local wcontrast = (1 + 0.05)/(lum + 0.05)
	local bcontrast = (lum + 0.05)/(0 + 0.05)
	-- select the text color with the best contrast
	if( bcontrast > wcontrast + 1.25 ) then
		fontcolor = '000000'
	else
		fontcolor = 'FFFFFF'
	end
	if( background == 'FFFFFF' ) then
		return 'background-color:none;color:#' .. fontcolor .. ';'
	else
		return 'background-color:#' .. background .. ';color:#' .. fontcolor .. ';'
	end
end

local function team_table_head(args, team, ctype)
	local colors = get_colors(team, nil)
	local borderwidth = tonumber(args['border']) or 0
	-- set the default background
	local background = (ctype == 'p') and
		(colors[1] or 'FFFFFF'):upper() or
		(colors[3] or colors[2] or 'FFFFFF'):upper()
	-- now pick a font color
	local fontcolor = ''
	-- compute the luminosity of the background
	local lum = color2lum(background)
	-- compute the contrast with white and black
	local wcontrast = (1 + 0.05)/(lum + 0.05)
	local bcontrast = (lum + 0.05)/(0 + 0.05)
	-- select the text color with the best contrast
	if( bcontrast > wcontrast + 1.25 ) then
		fontcolor = '#000000'
	else
		fontcolor = '#FFFFFF'
	end
	local s = 'background-color:#' .. background .. ';color:' .. (args['color'] or fontcolor) .. ';'
	if borderwidth > 0 then
		local bc = (ctype == 'p') and 
		(colors[3] or colors[2] or '') or (colors[1] or '')
		if bc ~= 'FFFFFF' then
			s = s .. bordercss('#' .. bc, borderwidth)
		end
	end

	local res = '|-\n'
	for i=1,50 do
		if( args[i] ~= nil ) then
			local cstyle = 'scope="col" style="' .. s .. '"'
			if args['col' .. i .. 'span'] ~= nil then
				cstyle = cstyle .. ' colspan=' .. args['col' .. i .. 'span']
			end
			if args['class' .. i ] ~= nil then
				cstyle = cstyle .. ' class="' .. args['class' .. i] .. '"'
			end
			res = res .. '! ' .. cstyle .. ' |' .. args[i] .. '\n'
		else
			return res .. '|-\n'
		end
	end
	return res .. '<span class="error">Error!</span>\n|-\n'

end

local function team_stripe1(team, borderwidth)
	local colors = get_colors(team, nil)

	-- set the default scheme
	local background = colors[1] or ''
	local fontcolor = colors[2] or ''
	local bordercolor = (colors[3] or colors[2] or ''):upper()
	borderwidth = tonumber(borderwidth or '3') or 0

	-- if there is no tertiary color, then pick a font color
	if (colors[3] == nil) then
		-- compute the luminosity of the background
		local lum = color2lum(colors[1])
		-- compute the contrast with white and black
		local wcontrast = (1 + 0.05)/(lum + 0.05)
		local bcontrast = (lum + 0.05)/(0 + 0.05)
		-- select the text color with the best contrast
		if( bcontrast > wcontrast + 1.25 ) then
			fontcolor = '000000'
		else
			fontcolor = 'FFFFFF'
		end
	end

	-- finally build the style string
	local style = ''
	if (borderwidth > 0) then
		-- use the primary as the border if the border is white or close to white
		local bordercontrast = (1 + 0.05)/(color2lum(bordercolor) + 0.05)
		if (bordercontrast < 1.25) then
			bordercolor = background
			local fontcontrast = (1 + 0.05)/(color2lum(colors[2] or 'FFFFFF') + 0.05)
			if (fontcontrast < 1.25) then
				fontcolor = colors[2] or 'FFFFFF'
			end
		end
		style = style .. ' border:' .. borderwidth .. 'px solid #' .. bordercolor .. ';'
		style = style .. ' border-left: none; border-right: none;'
		style = style .. ' box-shadow: inset 0 2px 0 #FEFEFE, inset 0 -2px 0 #FEFEFE;'
	end
	style = 'background-color:#' .. background .. ';color:#' .. fontcolor .. ';' .. style

	return style
end

local function team_boxes(frame, team, order, sep)
	local function colorbox( h )
		local r = mw.html.create('')
		r:tag('span')
			:css('background-color', '#' .. (h or ''))
			:css('border', '1px solid #000')
			:wikitext('&nbsp;&nbsp;&nbsp;&nbsp;')
		return tostring(r)
	end

	local colors = get_colors(team, 'unknown')

	if type(colors) ~= 'table' then
		return ''
	end

	local colorboxes = {}
	local colororder = {'1','2','3','4','5'}
	local namecheck = 0
	if order == '' then
		order = colors['order'] or ''
		namecheck = 1
	end
	if order ~= '' then
		colororder = mw.text.split(order, '')
	end
	for k,v in pairs(colororder) do
		local i = tonumber(v) or 0
		if(	namecheck == 0 or colors['name' .. i]) then
			if colors[i] then
				table.insert(colorboxes,colorbox(colors[i]))
			end
		end
	end

	if (#colorboxes > 0) then
		return table.concat(colorboxes, sep)
	end

	return ''
end

local function team_list(frame, team, num1, num2, num3, num4, num5, sep)
	local function colorbox( h )
		local r = mw.html.create('')
		r:tag('span')
			:css('background-color', '#' .. (h or ''))
			:css('border', '1px solid #000')
			:wikitext('&nbsp;&nbsp;&nbsp;&nbsp;')
		return tostring(r)
	end

	local colors = get_colors(team, 'unknown')

	if type(colors) ~= 'table' then
		return ''
	end

	local nums = {
		tonumber(num1:match('[1-5]') or '0') or 0,
		tonumber(num2:match('[1-5]') or '0') or 0,
		tonumber(num3:match('[1-5]') or '0') or 0,
		tonumber(num4:match('[1-5]') or '0') or 0,
		tonumber(num5:match('[1-5]') or '0') or 0}

	local colorboxes = {}
	local colornames = {}
	local colororder = {'1','2','3','4','5'}
	local order = colors['order'] or ''
	if(order ~= '') then
		colororder = mw.text.split(order, '')
	end
	for k,v in pairs(colororder) do
		local i = tonumber(v) or 0
		if ( nums[i] > 0 ) then
			if(	colors['name' .. nums[i]]) then
				table.insert(colornames,colors['name' .. nums[i]])
				table.insert(colorboxes,colorbox(colors[nums[i]] or ''))
			end
		end
	end

	local res = ''
	if (#colornames > 0) then
		colornames[1] = ucfirst(colornames[1])
	end
	
	res = mw.text.listToText(
		colornames,
		',&nbsp;',
		#colornames == 2 and '&nbsp;and&nbsp;' or ',&nbsp;and&nbsp;'
	)

	if (colors['cite']) then
		res = res .. frame:preprocess('<ref>' .. colors['cite'] .. '</ref>')
	end
	if (colors['ref']) then
		res = res .. '[' .. colors['ref'] .. ']'
	end
	if (colors['ref2']) then
		res = res .. '[' .. colors['ref2'] .. ']'
	end

	if (#colornames > 0) then
		res = res .. sep
	end

	if (#colorboxes > 0) then
		res = res .. table.concat(colorboxes, '&nbsp;')
	end

	return res
end

local function team_check(team, unknown)
	local colors = get_colors(team, unknown)
	if type(colors) == 'table' then
		return 'known'
	else
		return unknown
	end
end

function p.color(frame)
	local args = (frame.args[1] ~= nil) and frame.args or frame:getParent().args
	return team_color(remove_sport(args[1] or ''), args[2] or '', args[3] or '')
end

function p.color1(frame)
	local args = (frame.args[1] ~= nil) and frame.args or frame:getParent().args
	return team_color(remove_sport(args[1] or ''), '1', '')
end

function p.color32(frame)
	local args = (frame.args[1] ~= nil) and frame.args or frame:getParent().args
	return team_color(remove_sport(args[1] or ''), '3', '2')
end

function p.style1(frame)
	local args = (frame.args[1] ~= nil) and frame.args or frame:getParent().args
	return team_style1(remove_sport(args[1] or ''), args['border'], args['color'])
end

function p.style2(frame)
	local args = (frame.args[1] ~= nil) and frame.args or frame:getParent().args
	return team_style2(remove_sport(args[1] or ''), args['border'], args['color'])
end

function p.header1(frame)
	local args = (frame.args[1] ~= nil) and frame.args or frame:getParent().args
	return team_header1(remove_sport(args[1] or ''), args['border'])
end

function p.header2(frame)
	local args = (frame.args[1] ~= nil) and frame.args or frame:getParent().args
	return team_header2(remove_sport(args[1] or ''))
end

function p.tablehead1(frame)
	local args = (frame.args[1] ~= nil) and frame.args or frame:getParent().args
	return team_table_head(args, remove_sport(args['team'] or ''), 'p')
end

function p.tablehead2(frame)
	local args = (frame.args[1] ~= nil) and frame.args or frame:getParent().args
	return team_table_head(args, remove_sport(args['team'] or ''), 's')
end

function p.stripe1(frame)
	local args = (frame.args[1] ~= nil) and frame.args or frame:getParent().args
	return team_stripe1(remove_sport(args[1] or ''), args['border'])
end

function p.boxes(frame)
	local args = (frame.args[1] ~= nil) and frame.args or frame:getParent().args
	return team_boxes(frame, remove_sport(args[1] or ''),
		args['order'] or '', args['sep'] or '&nbsp;')
end

function p.list(frame)
	local args = (frame.args[1] ~= nil) and frame.args or frame:getParent().args
	return team_list(frame, remove_sport(args[1] or ''),
		args[2] or '1', args[3] or '2', args[4] or '3', args[5] or '4', args[6] or '5', args['sep'] or '')
end

function p.check(frame)
	local args = (frame.args[1] ~= nil) and frame.args or frame:getParent().args
	return team_check(remove_sport(args[1] or ''), args[2] or '')
end

function p.check_data()
	-- In a sandbox, preview {{#invoke:college color|check_data}}
	local results = {'Problems in [[Module:College color/data]]:'}
	local function problems(msg)
		if msg then
			table.insert(results, msg)
		elseif results[2] then
			return table.concat(results, '\n*')
		else
			return 'No problems detected.'
		end
	end
	local data = require(data_module)
	local keys = {}
	for k, _ in pairs(data) do
		table.insert(keys, k)
	end
	table.sort(keys)
	for _, key in ipairs(keys) do
		local val = data[key]
		if not (type(key) == 'string' and (type(val) == 'table' or type(val) == 'string')) then
			problems('Invalid type for "' .. tostring(key) .. '"')
		end
		if type(val) == 'table' then
			if not (2 <= #val and #val <= 4) then
				problems('Invalid number of numbered parameters for "' .. tostring(key) .. '"')
			end
			for i, v in ipairs(val) do
				if not tostring(v):match('^%x%x%x%x%x%x$') then
					problems('Parameter [' .. i .. '] should be a 6-hex-digit color but is "' .. tostring(v) .. '" for "' .. tostring(key) .. '"')
				end
			end
			for k, v in pairs(val) do
				if type(k) == 'number' then
					if not (1 <= k and k <= 4) then
						problems('Invalid numbered parameter for "' .. tostring(key) .. '"')
					end
				elseif type(k) == 'string' then
					if not (
							k:match('^name[1-4]$') or
							k:match('^cite2?$') or
							k:match('^order$')
							) then
						problems('Unexpected key in table for "' .. tostring(key) .. '"')
					end
				else
					problems('Invalid key type in table for "' .. tostring(key) .. '"')
				end
			end
		elseif data[val] == nil then
			problems('Undefined alias for "' .. tostring(key) .. '"')
		elseif type(data[val]) ~= 'table' then
			problems('Alias is not a table for "' .. tostring(key) .. '"')
		end
	end
	return problems()
end

function p.testtable(frame)
	local contrasttable_mod = require("Module:College color/contrast")
	return contrasttable_mod._testtable(frame.args)
end

return p
