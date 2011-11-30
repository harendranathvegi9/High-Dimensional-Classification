clear All; close All;
runExperiments = 0;
%Todo: make sure data is z-scored
%figure out how to automaticAlly select which lambda value to use in glmnet
paths = getLocalPaths();
addpath(paths.matlab);
addpath(paths.glmnet);
outdatadir = paths.outdatadir;

[All_lab All] = load_uci(paths.data);
All_lab = All_lab + 1;
%partition into train and test
r = randperm(length(All_lab));
All = All(r,:);
All_lab = All_lab(r);
xTrain = All(1:4000,:);
yTrain = All_lab(1:4000,:);
xTest = All(4001:end,:);
yTest = All_lab(4001:end,:);

numfolds = 1;
noreduce = @deal;
PCA = @pca;

classifiers =        struct('svm',struct('function',@libsvmWrapper,'reduce',noreduce,'options', '-t 0'), ...
                     'ridge',struct('function',@glmnetWrapper,'reduce',noreduce,'options', struct('family','binomial','alpha',0,'type','')),...
                     'lasso',struct('function',@glmnetWrapper,'reduce',noreduce,'options', struct('family','binomial','alpha',1,'type','')),...
                     'elnet',struct('function',@glmnetWrapper,'reduce',noreduce,'options', struct('family','binomial','alpha',.5,'type','')),...
                     'naivebayes_nosmooth',  struct('function',@naiveBayesWrapper,'reduce',noreduce,'options', 'diagLinear'),...
                     'naivebayes_nosmooth_pca',  struct('function',@naiveBayesWrapper,'reduce',PCA,'options', 'diagLinear'),...
                     'lasso_pca',struct('function',@glmnetWrapper,'reduce',PCA,'options', struct('family','binomial','alpha',1,'type','')),...
                    'quad_analysis',struct('function',@matlabclassifierWrapper,'reduce',noreduce,'options', 'diagLinear'));


Techniques = {'naivebayes_nosmooth_pca','ridge'};%,'lasso','lasso_pca'};
%Techniques = {'naivebayes_nosmooth'};

%Techniques = {'naivebayes_nosmooth','svm','ridge','lasso'};
nT = length(Techniques);
rate = zeros(1,nT);
%train_set_sizes = [23 1200 ];

train_set_sizes = floor(linspace(1000,4000,10));%[1000 1200 1500 2000 2300 2700 3000];
if(runExperiments == 1)
for train_set_size = train_set_sizes
for Ti = 1:nT
    technique = Techniques{Ti};
    disp(['using technique: ' technique ' with train set size ' int2str(train_set_size)]);
    T = getfield(classifiers,technique);
    classifier = T.function;
    options = T.options;
    reduce = T.reduce;
    out = zeros(1,numfolds);
    for i = 1:numfolds
        out(i) = subsample_and_reduce_and_classify(train_set_size,classifier,reduce,xTrain,yTrain,xTest,yTest,options);
        disp(['finished iteration ' i]);
    end

    savefile = [outdatadir technique '.' int2str(train_set_size) '.mat'];
    save(savefile,'out');
end
end
end
nT = length(Techniques);
data = zeros(nT,length(train_set_sizes),numfolds);
for ii = 1:length(train_set_sizes);
    train_set_size = train_set_sizes(ii);
    for Ti = 1:nT
        technique = Techniques{Ti};
        infile = [outdatadir technique '.' int2str(train_set_size) '.mat'];
        S = load(infile);
        data(Ti,ii,:) = S.out;
    end
end
figure(1);
colors = {'red','blue','green','cyan','black','yellow','purple','cyan'};
hold on;
for Ti = 1:nT
    E = std(data(Ti,:,:),0,3);
    M = mean(data(Ti,:,:),3);
    errorbar(train_set_sizes,M,E,'color',colors{Ti})
end
hold off;