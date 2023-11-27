function [pred_x_range, pred_y_range, bestFitParams] = fit_ev_psychometric_function(x,y,weight)

shift = 100; % required as it doesn't deal with -ves
shifted_x = x+shift;

clear bestFitParams
[bestFitParams] = fitWeibull(shifted_x, y, weight);

clear ypred
pred_x_range = [min(shifted_x):0.1:max(shifted_x)];

for idx = 1:length(pred_x_range)
    i = pred_x_range(idx);
    pred_y_range(idx) = bestFitParams(3) - ((exp(-((i./bestFitParams(1)).^bestFitParams(2))))....
        *(bestFitParams(3)-bestFitParams(4)));
end

pred_x_range = pred_x_range-shift;