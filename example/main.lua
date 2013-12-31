require('framework/utils')
require("framework/algorithms/classification/knn")

local function main()
	trainingFile = "../luaML/example/iris2D.lmlf"
	cols,types,categories,data = read_lmlf_file(trainingFile)
	print("Training...")
	knn_train(cols,types,categories,data)
	print("Done training")
	print("Evaluating...")
	knn_evaluate()
	print("Done evaluating")
	--instance = {}
	--instance[1] = 1
	--print(knn_classify(instance))
end
main()
