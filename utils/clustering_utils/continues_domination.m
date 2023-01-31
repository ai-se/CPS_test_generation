% continues domination
function status = continues_domination(ind1, ind2)
    s1 = 0;
    s2 = 0;
    n = size(ind1,1);
    
    % 4 anti-patterns, all maximize, create weight array
    % w = 1 for maximize, o.w. w = -1
    weight_array = [1 1 1 1];
    
    for i = 1:size(ind1, 1)
        w = weight_array(i);
        
        a = ind1(i);
        b = ind2(i);
        s1 = s1 - exp(w*(a-b)/n);
        s2 = s2 - exp(w*(b-a)/n);
    end
    
    if s1/n < s2/n
        status = 1;
    else
        status = 0;
    end
end