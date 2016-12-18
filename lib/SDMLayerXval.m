% SDMLayerXval - Performs parameter selection with golden search for SDM training.
%
% (C)opyright 2016, Ashton Fagg

function [param, cost] = SDMLayerXval(model, trainData, evalData,  a, b)
tau = (sqrt(5)-1)/2;
x1 = a + (1-tau)*(b-a);
x2 = a + tau*(b-a);


iteration = 1;
while (iteration<=50 && abs(x1-x2)>1e-5)
    
    Rc = SDMSolve(trainData.FFt, trainData.DFt, 10^x1);
    Rd = SDMSolve(trainData.FFt, trainData.DFt, 10^x2);
    perfC = objective(Rc, 10^x1, evalData);
    perfD = objective(Rd, 10^x2, evalData);
    
    fprintf('Iteration %d, Param 1: %f Cost: %f, Param 2: %f Cost: %f, diff: %f\n', iteration, x1, perfC, x2, perfD, abs(x1-x2));
    
    if (perfC<perfD)
        b = x2;
        x2 = x1;
        x1 = a + (1-tau)*(b-a);
    else
        a = x1;
        x1 = x2;
        x2 = a + tau*(b-a);
    end
    iteration = iteration + 1;
end


param = (a+b)/2;
Rtest = SDMSolve(trainData.FFt, trainData.DFt, 10^param);
cost = objective(Rtest, 10^param, evalData);
fprintf('Param final: %f, Cost: %f\n', param, cost);
end



function cost = objective(R, reg, data)
   cost = trace(data.DDt) + trace(R*data.FFt*R') - 2 * trace(R'*data.DFt);    
   nrm = data.nExamples * (size(data.DDt, 1));
   cost = sqrt(cost/nrm);
   if (isnan(cost))
       cost = 1e99;
       return;
   end
end



