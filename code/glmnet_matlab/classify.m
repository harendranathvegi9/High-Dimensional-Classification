clear all;
%load data in sparse format
[all_lab all] = load_sparse('/courses/cs600/cs689/dbbelang/fp/data/all.dat');
all_lab = full(all_lab);
all = full(all);
L = length(all_lab);
ntrain = L - 600;
trainlab = all_lab(1:ntrain);
testlab = all_lab((ntrain+1):end);
train = all(1:ntrain,:);
test = all((1+1):end,:);


fit = glmnet(train,trainlab);
glmnetPrint(fit);
glmnetCoef(fit,0.01); % extract coefficients at a single value of lambda
glmnetPredict(fit,'response',test,testlab); % make predictions
