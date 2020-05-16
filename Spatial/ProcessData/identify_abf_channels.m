function channels = identify_abf_channels(d,si)

if size(d,2) == 5
    for ii = 1:size(d,2)
        thisSignal = d(:,ii);
        risingEdges = find_rising_edge(d(:,ii),0.5,2);
        fallingEdges = find_falling_edge(d(:,ii),-0.5,2);
        edges(ii,1) = length(risingEdges);
        edges(ii,2) = length(fallingEdges);
        vals(ii,1) = sum(thisSignal > 2.5);
        vals(ii,2) = sum(thisSignal < 2.5);
        ratioV(ii) = vals(ii,1)/vals(ii,2);
    end


    ind = find(ratioV == max(ratioV));
    channels{ind} = 'photo_sensor';

    channels{1} = 'frames';

    inds = setdiff([1:size(d,2)],[1 ind]);

    ind = find(edges(inds,1) == min(edges(inds,1)));

    channels{inds(ind)} = 'air_puff';

    inds = setdiff(inds,inds(ind));

    ind = min(inds);
    channels{ind} = 'ch_a';
    ind = setdiff(inds,ind);
    channels{ind} = 'ch_b';
end


% db.channel{1} = 'frames';
% db.channel{2} = 'ch_a';
% db.channel{3} = 'ch_b';
% db.channel{4} = 'photo_sensor';
% db.channel{5} = 'air_puff';