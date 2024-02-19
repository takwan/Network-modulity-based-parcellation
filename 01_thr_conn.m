%% prep connectivity matrix (connMat.mat)
conn = load('connMat.mat','Z'); conn = conn.Z;

for i=1:size(conn,3)
    conn_subj = triu(conn(:,:,i),1);
    conn_s(:,i) = sort(conn_subj(:),'descend');             % sort descending
    conn_si = conn_s(:,i);
    
    for g=1:141
        % long running time
        thr{g}(:,i) = conn_si(1:ceil(length(conn_si)*(0.15-0.001*(g-1))));     % sorted output
        thr_val(g,i) = thr{g}(end,i);
 
        conn_thr(:,:,i,g) = conn_subj.*(conn_subj>thr_val(g,i)); % thresholded conn for infomap input
    	[row{g}(:,i), col{g}(:,i)] = find(conn_thr(:,:,i,g));
    end
end
save('connMat_thr4D','conn_thr','-v7.3')
save('connLinks.mat','col','row','-v7.3')


%% extract connectivity values (weight)
% g: thr, i: subj, c: conn
for g=1:141
    for i=1:size(conn,3)
        for c=1:size(row{g},1)
            wgt{g}(c,i) = conn_thr(row{g}(c,i),col{g}(c,i),i,g);
        end
        % input for infomap (row col weight)
        netLink{g}(:,:,i) = [row{g}(:,i) col{g}(:,i) wgt{g}(:,i)];
    end
end
save('connLinks.mat','col','row','wgt','netLink','-v7.3')


subj = subjList;
thr = {'150', '149', '148', '147', '146', '145', '144', '143', '142', '141', '140', '139', '138', '137', '136', '135', '134', '133', '132', '131', '130', '129', '128', '127', '126', '125', '124', '123', '122', '121', '120', '119', '118', '117', '116', '115', '114', '113', '112', '111', '110', '109', '108', '107', '106', '105', '104', '103', '102', '101', '100', '099', '098', '097', '096', '095', '094', '093', '092', '091', '090', '089', '088', '087', '086', '085', '084', '083', '082', '081', '080', '079', '078', '077', '076', '075', '074', '073', '072', '071', '070', '069', '068', '067', '066', '065', '064', '063', '062', '061', '060', '059', '058', '057', '056', '055', '054', '053', '052', '051', '050', '049', '048', '047', '046', '045', '044', '043', '042', '041', '040', '039', '038', '037', '036', '035', '034', '033', '032', '031', '030', '029', '028', '027', '026', '025', '024', '023', '022', '021', '020', '019', '018', '017', '016', '015', '014', '013', '012', '011', '010'};
for g=1:size(thr,2)
    connLinks_thr = netLink{g};
    for i=1:size(subj,2)        
        dlmwrite(['./linkArray/' subj{i} '/clink_thr' thr{g} '.net'],connLinks_thr(:,:,i),'delimiter','\t','precision',15)
    end
end
