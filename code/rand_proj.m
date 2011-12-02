function [OTrain ODev OTest] = rand_proj(Train,Dev,Test,opt)
    k = opt.dim; % Dimentions to project to
    
    d = size(Train, 2); % Orginal dimentionality of data
    
    R_temp = rand(d, k);
    R = zeros(d, k);

    R(find (R_temp < 2/6)) = sqrt(3);
    R(find (R_temp < 1/6)) = -sqrt(3);
    R(find (R_temp >= 2/6)) = 0;

    OTrain = (1/sqrt(k))*Train*R;
    ODev = (1/sqrt(k))*Dev*R;
    OTest = (1/sqrt(k))*Test*R;