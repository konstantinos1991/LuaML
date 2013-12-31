require("framework/utils")
--- -------------------------------------------------------------------------
-- This file implements the K-NN(K-Nearest Neighbour) algorithm for K = 1
-- @module knn
-- --------------------------------------------------------------------------

--local variables/names for functions
local euclidean_distance;
local read_knn_model;

--- ---------------------------------------------------------------------------------------
-- Training of knn only requires to save every example of the dataset
-- @param features are the names of the columns
-- @param types are the types of the features. Possible values are REAL_NUMBER and NOMINAL
-- @param categories are the known classes
-- @param data is a 2-dimensional matrix that contains the data
-- @function knn_train
-- ----------------------------------------------------------------------------------------
function knn_train(features,types,categories,data)
	 local counter_nominals = 0
	 local counter_reals = 0
	
	for t=1,#types do
		if types[t] == "NOMINAL" then
			counter_nominals = counter_nominals+1
		else
			counter_reals = counter_reals+1
		end
	end
	if counter_nominals >=1 and counter_reals >=1 then
		error("Error! Found NOMINAL and REAL_NUMBER types.\nK-NN can be used only with real numbers")
	end
	
	--create a directory
	os.execute("mkdir KNN_DIRECTORY")
	local knn_model = io.open("KNN_DIRECTORY/knn_model.model","w")
	--store all the categories
	for categIndex=1,#categories do
	 knn_model:write("CATEGORY "..categories[categIndex].."\n")
	 knn_model:flush()
	end
	--write the model to a file(store all examples)
	for row=1,#data do
    local dataRow = data[row]
		for col=1,#dataRow do
			if col < #dataRow then
				knn_model:write(dataRow[col]..",")
			else
				knn_model:write(dataRow[col])
			end
			knn_model:flush()
		end
		if row < #data then
		  knn_model:write("\n")
		  knn_model:flush()
		end
	end
	knn_model:close()
end

--- -------------------------------------------------------------------
-- takes as a parameter an array(instance is an array)
-- @param instance , is the instance to be classified
-- @function knn_classify
-- -------------------------------------------------------------------
function knn_classify(instance)
	--first the model must be loaded
	local modelDATA,categories = read_knn_model()
	--distances = {} -- will store the distances between the instance(to be classified) an the data
	--initialize the minimum distance to the first training example
	local minDistanceIndex = 1
	local minDistance = euclidean_distance(instance,modelDATA[1])
	for i=2,#modelDATA do
	 local distance = euclidean_distance(instance,modelDATA[i])
	 if distance < minDistance then
	   minDistance = distance
	   minDistanceIndex = i
	 end
	end
	--minDistanceIndex contains the index of the training example that had the smallest distance from the instance we want to classify
	--the instance is assigned the category of the example that exists in minDistanceIndex
	local trainingExample = modelDATA[minDistanceIndex] --get the training example
	return trainingExample[#trainingExample] --get its category
end

--- --------------------------------------------------------------------
-- use this function to evaluate the model of the classifier
-- @function knn_evaluate
-- --------------------------------------------------------------------
function knn_evaluate()
  --load the model
  local modelDATA,categories = read_knn_model()
  --on average
  local average_recall = 0
  local average_precission = 0
  local average_fMeasure = 0
  
  --counters for correctly and incorrectly classified instances
  local m_correctlyClassified = 0 
  local m_incorrectlyClassified = 0
  for i=1,#modelDATA do
    local m_trainingExample = modelDATA[i]
    local m_trueCategory = m_trainingExample[#m_trainingExample]
    local m_predictedCategory = knn_classify(m_trainingExample)
    if m_trueCategory == m_predictedCategory then
      m_correctlyClassified = m_correctlyClassified+1
    end
  end
  m_incorrectlyClassified = #modelDATA - m_correctlyClassified
  --create a file to write statistics
  local knn_evaluation = io.open("KNN_DIRECTORY/knn_evaluation.txt","w")
  knn_evaluation:write("=============================================== GENERAL ======================================================\n")
  --knn_evaluation:write("All instances:\t"..#modelDATA.."\n")
  knn_evaluation:write(string.format("%s\t%d\n","All instances:",#modelDATA))
  --knn_evaluation:write("Correctly classified instances:\t"..m_correctlyClassified.."("..(m_correctlyClassified*100)/#modelDATA.."%)\n")
  local temp = (m_correctlyClassified*100)/#modelDATA
  knn_evaluation:write(string.format("%s\t%d (%f /100)\n","Correctly classified instances:",m_correctlyClassified,temp))
  --knn_evaluation:write("Incorrectly classified instances:\t"..m_incorrectlyClassified.."("..(m_incorrectlyClassified*100)/#modelDATA.."%)\n")
  temp = (m_incorrectlyClassified*100)/#modelDATA
  knn_evaluation:write(string.format("%s\t%d (%f /100)\n","Incorrectly classified instances:",m_incorrectlyClassified,temp))
  knn_evaluation:write("===============================================================================================================\n")
  knn_evaluation:write("=============================================== IN DETAIL =====================================================\n")
  knn_evaluation:write("1st column shows the number of True Positives\n")
  knn_evaluation:write("2nd column shows the number of False Positives\n")
  knn_evaluation:write("3rd column shows the Recall\n")
  knn_evaluation:write("4th column shows the Precision\n")
  knn_evaluation:write("5th column shows the F-measure\n")
  knn_evaluation:write("6th column shows the Class\n\n")
  for c=1,#categories do
    local m_category = categories[c] --the category/class to test
    local m_true = 0 --how many training instances of class m_category are predicted as m_category
    local m_false = 0 --how many training instances of a different class are predicted as m_category
    local n = 0 -- the number of the training instances that belong to category 'm_category'
    local m = 0 --the number of training instances that the classifier put as 'm_category'
    local recall = 0
    local precission = 0
    local fMeasure = 0
    
    for i=1,#modelDATA do
      local m_trainingExample = modelDATA[i]
      local m_trueCategory = m_trainingExample[#m_trainingExample]
      local m_predictedCategory = knn_classify(m_trainingExample)
      if m_predictedCategory == m_category then
        if m_trueCategory == m_predictedCategory then
          m_true = m_true+1
        else
          m_false = m_false+1
        end 
      end
     if m_trueCategory == m_category then
      n = n+1
     end
    end --end for all training examples
    m = m_true+m_false
    recall = m_true/n
    precission = m_true/m
    fMeasure = 2*((precission*recall)/(precission+recall))
    
    average_recall = average_recall+recall
    average_precission = average_precission+precission
    average_fMeasure = average_fMeasure+fMeasure
    
    knn_evaluation:write(string.format("%d\t%d\t%f\t%f\t%f\t%s\n",m_true,m_false,recall,precission,fMeasure,m_category))
    --knn_evaluation:write(m_true.."\t"..m_false.."\t"..recall.."\t"..precission.."\t"..m_category.."\n")
    knn_evaluation:flush()
  end --end for all categories 
  average_precission = average_precission/#categories
  average_recall = average_recall/#categories
  average_fMeasure = average_fMeasure/#categories
  
  knn_evaluation:write("\nOn average\n")
  knn_evaluation:write("1st column shows the Recall\n")
  knn_evaluation:write("2nd column shows the Precision\n")
  knn_evaluation:write("3rd column shows the F-measure\n")
  knn_evaluation:write(string.format("%f\t%f\t%f\n",average_recall,average_precission,average_fMeasure))
  knn_evaluation:write("=================================================================================================================\n")
  knn_evaluation:flush()
  
  knn_evaluation:close()
end

--- --------------------------------------------------------------
-- Euclidean distance between vectors a(to be classified) and b
-- @param a is a vector
-- @param b is a vector
-- @function euclidean_distance
-- ---------------------------------------------------------------
euclidean_distance = function(a,b)
  local sum = 0.0
  for dimensions=1,(#b - 1) do
    sum = sum + math.pow((a[dimensions]-b[dimensions]),2)
  end
  return math.sqrt(sum)
end


--- -----------------------------------------------------------
-- reads the model
-- @function knn_model
-- ------------------------------------------------------------
read_knn_model = function() 
  local modelDATA = {} -- the data
  local dataNum = 1 --number of data lines
  local categories = {} -- the categories of our dataset
  local categoiesNum = 1 --the number of categories
  
  for line in io.lines("KNN_DIRECTORY/knn_model.model") do
    if string.find(line,"CATEGORY") then
      local categoryComponents = split(line," ")
      categories[categoiesNum] = categoryComponents[2]
      categoiesNum = categoiesNum+1
    else
      --create a row of data after splitting data
      local dataRow = split(line,",")
      if #dataRow == 0 then
        --found empty line so ignore it
      else
        --add the row to the matrix modelDATA
        modelDATA[dataNum] = dataRow
        dataNum = dataNum+1
      end
    end  -- end if(line starts with category)
  end --end for
  return modelDATA,categories
end