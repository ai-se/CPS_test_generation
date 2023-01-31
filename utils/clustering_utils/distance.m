% function distance calculate the distance between 2 points.
function d = distance(y, x)
    d = 0;
    
    if size(y, 2) ~= size(x, 2)
        d = log(0);
    else
        % calculate Eculidean distance sum((x-y)^2)^0.5
        for i = 1:size(x, 2)           
            d = d + (x(i) - y(i))^2;
        end
        
        d = d^0.5;
end