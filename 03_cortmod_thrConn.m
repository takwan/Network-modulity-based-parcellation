conn = csvread('consMatDM_low.csv');
conn_s = sort(conn(:),'descend');             % sort descending

for g=1:141
    % long running time; uncomment when you need
    thr{g} = conn_s(1:ceil(length(conn_s)*(0.15-0.001*(g-1))));     % sorted output
    thr_val(g) = thr{g}(end);

    conn_thr(:,:,g) = conn.*(conn>thr_val(g)); % thresholded conn for infomap input; more than one value to be thresholded due to some overlapping values in multiple regions (less diversity)
	[row{g}, col{g}] = find(conn_thr(:,:,g));
end


%% extract connectivity values (weight)
% g: thr, c: conn
for g=1:141
    for c=1:size(row{g},1)
        wgt{g}(c,1) = conn_thr(row{g}(c,1),col{g}(c,1),g);
    end
    % input for infomap (row col weight)
    netLink{g}(:,:) = [row{g} col{g} wgt{g}];
end

save('connLinks_group.mat','col','row','wgt','netLink','-v7.3')


thr = {'150', '149', '148', '147', '146', '145', '144', '143', '142', '141', '140', '139', '138', '137', '136', '135', '134', '133', '132', '131', '130', '129', '128', '127', '126', '125', '124', '123', '122', '121', '120', '119', '118', '117', '116', '115', '114', '113', '112', '111', '110', '109', '108', '107', '106', '105', '104', '103', '102', '101', '100', '099', '098', '097', '096', '095', '094', '093', '092', '091', '090', '089', '088', '087', '086', '085', '084', '083', '082', '081', '080', '079', '078', '077', '076', '075', '074', '073', '072', '071', '070', '069', '068', '067', '066', '065', '064', '063', '062', '061', '060', '059', '058', '057', '056', '055', '054', '053', '052', '051', '050', '049', '048', '047', '046', '045', '044', '043', '042', '041', '040', '039', '038', '037', '036', '035', '034', '033', '032', '031', '030', '029', '028', '027', '026', '025', '024', '023', '022', '021', '020', '019', '018', '017', '016', '015', '014', '013', '012', '011', '010'};
for g=1:size(thr,2)
%     eval(sprintf('connLinks_thr%d = netLink{g}', str2num(thr{g})));   % interate to threshold links
    connLinks_thr = netLink{g};
    dlmwrite(['./links_group/clink_thr' thr{g} '.net'],connLinks_thr(:,:),'delimiter','\t','precision',15)
end
