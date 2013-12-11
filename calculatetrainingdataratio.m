%training data cube size
total = 1024*768*7552;
dts = [49,66,48,56,49,49,61,51,56,56,52,64,56,52,56,55,61,46]
v = sum(dts.*dts.*dts)
v = v +(512*384*128)
trainingdataratio =v/total*100

