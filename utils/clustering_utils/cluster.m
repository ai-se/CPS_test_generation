% function sneakClusters implements the SNEAK algorithms
function t = cluster(tv, cat, enough, t, node)
    % if number of data points in the rest set exceed the enough, then
    % perfrom split and recursively apply SNEAK
    if size(tv, 1) > enough
        [east, west, east_item, west_item] = split(tv, cat);
        
        % add east items and west items to the tree
        [t, node1] = t.addnode(node, {east_item, 0});
        [t, node2] = t.addnode(node, {west_item, 0});
        
        t = cluster(east_item, cat, enough, t, node1);
        t = cluster(west_item, cat, enough, t, node2);
    end
end