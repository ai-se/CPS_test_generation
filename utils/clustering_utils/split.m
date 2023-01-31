% split function implements continous space Fastmap for bin chop on data
function [east, west, east_items, west_items] = split(tv, cat)
    n_tests = size(tv, 1);
    
    % if not all inputs are categorical data, normalize values and perform
    % numeric split
    if size(cat, 2) ~= size(tv, 2)
        % first find the min/max value for each column for normalization later
        [min_v, max_v] = find_minmax(tv, cat);
        
        tv_n = normalize(tv, min_v, max_v);
    
        % random select one row as the pivot
        % pivot = random.choice(tv)
        rng('shuffle');
        rand_int = randi([1, n_tests], 1, 1);
        pivot = tv_n(rand_int:rand_int, :);

        % find the east candidate which has the most distance to the pivot
        % east = most_distance(tv, pivot)
        [east_idx, east] = most_distance(tv_n, pivot);

        % find the west candidate which has the most distance to the east
        % west = most_distance(tv, east)
        [west_idx, west] = most_distance(tv_n, east);
        
        % calculate c: the distance from east to west
        c = distance(east, west);
        
        % for each data point, calculate distance by cosine rule
        % x = (a^2 + c^2 - b^2) / (2*c)
        known_size = size(tv, 2);
        for i = 1:size(tv,1)
            cur_point = tv_n(i:i, :);
            
            a = distance(cur_point, east);
            b = distance(cur_point, west);
            tv(i,known_size+1) = (a^2+c^2-b^2)/(2*c);
        end
        
        % sort data points by the distance value
        tv_new = sortrows(tv, size(tv,2));
        
        % integral division
        split_point = floor(size(tv,1)/2);
        
        % split east items and west items
        east_items = tv_new(1:split_point, 1:size(tv_new, 2)-1);
        west_items = tv_new(split_point+1:size(tv,1), 1:size(tv_new, 2)-1);
    % if all inputs are categorical data, then perform binary split (#TODO)
    else
        % random select one row as the pivot
        rng('shuffle');
        rand_int = randi([1, n_tests], 1, 1);
        pivot = tv(rand_int:rand_int, :);
        
        % for normalization later, record minimum r and maximum r.
        min_r = 1/0;
        max_r = log(0);
        
        know_size = size(tv, 2);
        for i = 1:size(tv, 1)
            % calculate r = sum all the "1" values
            cur_r = sum(tv(i:i,1:know_size));
            
            % update min_r and max_r based on cur_r
            if cur_r < min_r
                min_r = cur_r;
            end
            
            if cur_r > max_r
                max_r = cur_r;
            end
            
            % save r to the new column know_size+1
            tv(i,know_size+1) = cur_r;
            
            % calculate d = distance(tv(i), pivot) and save to the new
            % column know_size+2
            tv(i,know_size+2) = distance(tv(i:i, 1:know_size), pivot);
        end
        
        % now normalize x.r
        for i = 1:size(tv, 1)
            tv(i,know_size+1) = (tv(i,know_size+1)-min_r)/(max_r-min_r);
        end
        
        % collect all possible radius
        R = unique(tv(:, know_size+1:know_size+1));
        
        % for each possible radius, equally distribute the candidates with
        % k-radius into the concentric-circle
        for i = 1:size(R, 2)
            count = 1;
            for j = 1:size(tv, 1)
                if tv(j,know_size+1) == R(i)
                    g(count:count,:) = tv(j:j,:);
                    count = count + 1;
                end
            end
        end
    end
end