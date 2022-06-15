#install.packages("R.matlab")
library(R.matlab)
library(RNifti)
mask=readNifti("C:\\Users\\livio\\Downloads\\FoodNoFood-main\\FoodNoFood-main\\mask\\mask_group.nii.gz")
mask=which(mask==1)
maxTorig=readNifti("C:\\Users\\livio\\Downloads\\FoodNoFood-main\\FoodNoFood-main\\T_max/sub-17T_max_value_abs_1_32.nii")

subjs=dir("C:\\Users\\livio\\Downloads\\FoodNoFood-main\\FoodNoFood-main\\sign",pattern = "sign\\.mat",full.names = TRUE)
#mask=which(!is.na(unlist(readMat("./sub-28.mat"))))

# Tmax5=readNifti("C:\\Users\\livio\\Downloads\\FoodNoFood-main\\FoodNoFood-main\\T_max\\sub-05T_max_value_abs_1_32.nii")
# str(Tmax5)
# temp=which(!is.na(Tmax5[dim(Tmax5)[1]:1,dim(Tmax5)[2]:1,dim(Tmax5)[3]:1]))
# head(temp)
# head(mask)

#empty=readNifti("C:\\Users\\livio\\Downloads\\FoodNoFood-main\\FoodNoFood-main\\mask\\mask_group.nii.gz")
empty=maxTorig
empty[is.na(empty)]=0

D=sapply(subjs,function(id){ 
  D4=readMat(gsub("_sign","",id))[[1]]
  # D=matrix(D4,prod(dim(D4)[1:3]),dim(D4)[4])
  # D=D[empty>0,]
  maxT0=apply(D4,1:3,function(x) {
    if(any(is.na(x))) return(NA) else  x[which.max(abs(x))]}  )
  # maxT=array(unlist(maxT0),dim(D4)[1:3])
  maxT0[is.na(maxT0)]=0
  
  maxT=maxT0[dim(maxT0)[1]:1,,]
  
  writeNifti(image = maxT,template = maxTorig,file = gsub("\\.mat","\\.nii",id))
  writeNifti(image = abs(maxT),template = maxTorig,file = gsub("/sub-","/ABS_sub-",gsub("\\.mat",".nii",id)))
  })
summary((D))
str(D)

# sapply(1:dim(D4)[4],function(i){
#   temp=empty
#   temp[temp==1]=D4[,,,i]
#   writeNifti(image = temp,template = empty,file = paste0("prova_s10_",i,".nii"))
#   })


# library(pecora)
# Stat=pecora::oneSample(D)
#devtools::install_github("annavesely/splitFlip")
# library(splitFlip)
#p.adj=splitFlip::maxT(Stat)

# if (!require("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install("multtest")

#D=D[1:300000,]
ids=cbind(1:ncol(D),(1:ncol(D))+ncol(D))
ids=as.vector(t(ids))
D=cbind(D,array(0,dim = dim(D)))
D=D[,ids]
library("multtest")
res=multtest::mt.maxT(D,classlabel = rep(0:1,ncol(D)/2),test="pairt")
summary(res$adjp)
sum(res$adjp<.05)
mean(res$adjp<.05)

summary(res$rawp)
sum(res$rawp<.05)
mean(res$rawp<.05)
plot.ecdf(res$rawp)

# install.packages("writeNIfTI")
#library(writeNIfTI)
d=readMat(subjs[1])
d$Tmax.sign[!is.na(d$Tmax.sign)]=res$adjp
#writeMat(filename, A = A, B = B, C = C)
empty=readNifti("C:\\Users\\livio\\Downloads\\FoodNoFood-main\\FoodNoFood-main\\mask\\mask_group.nii.gz")
empty[empty==1]=res$adjp

writeNifti(image = empty,template = empty,file = "map_adj.nii")
