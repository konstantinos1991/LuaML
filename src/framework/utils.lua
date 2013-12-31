
--- --------------------------
-- contains useful functions
-- @module utils
-- ---------------------------

--- ------------------------------------------------------------------------------
-- the split function takes 2 parameters
-- the 's' parameter is a string that we want to split
-- and the 'where' parameter is the character on which we should split the string
-- the function returns into an array the splitted string
-- @param s is the string that we will split
-- @param where is the character on which s will be split
-- @function split
-- --------------------------------------------------------------------------------
function split(s,where)
	local arrayToReturn = {} -- will contain the non-empty strings
	local buffer = "" --will keep characters till we see the 'where' character
	local j = 1 -- the starting index for arrayToReturn
	
	for i=1,string.len(s) do
		local aChar = string.char(string.byte(s,i)) --get a character from string s
		if aChar ~= where then
			buffer = buffer..aChar -- append the character to the buffer variable
		else
			arrayToReturn[j] = buffer
			j = j+1
			buffer = ""
		end
	end
	arrayToReturn[j] = buffer
	return arrayToReturn
end

--- ------------------------------------------
-- reads a file in .lmlf format
-- @param filename is the file to read
-- @function read_lmlf_file
-- -------------------------------------------
function read_lmlf_file(filename)

	local columns_names  = {} -- the names of the columns
	local columns_types = {} --the types of the columns()
	local categories = {} --the categories
	local data = {} -- the data , a 2D array
		
	local numOfcolumns = 1 -- number of columns/features
	local numOfcategories = 1 -- number of categories
	local numOfData = 1 -- how many lines of data
	
	for line in io.lines(filename) do
		if string.find(line,"COLUMN") then
			local column_comp = split(line," ") --split line in " "
			--error checking
			if #column_comp ~= 3 then
			 error("ERROR!!!\nFound: "..line.."\nSyntax must be COLUMN <name> <type> without the <>",-1)
			end
			local feature_name = column_comp[2]
			--error checking
			if (feature_name == "NOMINAL") or (feature_name == "REAL_NUMBER") then
				error(feature_name.." is a reserved keyword!\nTherefore you cannot use it to name a feature",-1)
			end
			columns_names[numOfcolumns] = feature_name --add the name of the column to the 'column_names' table
			local feature_type = column_comp[3]
			--error checking
			if (feature_type ~= "NOMINAL") and (feature_type ~= "REAL_NUMBER") then
				error("Type "..feature_type.." is invalid!!!\nPlease edit your .lmlf file to correct the error",-1)
			end
			columns_types[numOfcolumns] = feature_type --add the type of the column to the 'column_types' table
			numOfcolumns = numOfcolumns+1
		elseif string.find(line,"CATEGORY") then
			local category_comp = split(line," ")
			if #category_comp ~= 2 then
			 error("ERROR!!!\nFound: "..line.."\nSyntax must be CATEGORY <name> without the <>",-1)
			end
			categories[numOfcategories] = category_comp[2]
			numOfcategories = numOfcategories+1
		else
			local data_comp = split(line,",") --split line in ","
			local dataRow = {} --create a new row
			for i=1,#data_comp do
				dataRow[i] = data_comp[i]
			end
			data[numOfData] = dataRow
			numOfData = numOfData+1
		end
	end
	return columns_names,columns_types,categories,data
end

