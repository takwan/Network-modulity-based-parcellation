%% data input
dataDir = '/PATH/TO/Thal_netParcel';  % TT
subjlist = {'001', '002', '003'};

% subject data
for i = 1:length(subjlist)
    img_data{i} = load_nii([dataDir '/PATH/TO/Preproc_REST/rest_Subj' subjlist{i} '.nii']);
    img_data{i} = img_data{i}.img;
end

% thalamus mask
mask = load_nii([dataDir '/PATH/TO/ThalAtlas/morelThal_2mm.nii.gz']);
maskCoord = mask.img(:,:,:) ~= 0;     % extract non-zero values
ind = find(maskCoord);
sz = size(maskCoord);
[x, y, z] = ind2sub(sz,ind);   % assign mask coordinates of each ROIs
% caution to interpret the matrix coordinates in FSL MNI space;
% LR inverted, FSL coordinate starts from zero

clear mask maskCoord


%% partial correlation between thalamic voxles and means ts of each cortical network
clear meants_cortNet voxroi
for i = 1:length(subjlist)
    for k = 1:length(ind)
        voxroi{i}(1:112,k) = img_data{i}(x(k),y(k),z(k),1:112);
    end

    inText = [dataDir '/cortModule/cortMod_parc/cortMod_parc_6mods/cortNet_meants/ts_mods_sbj' subjlist{i} '.txt'];
    meants_cortNet{i} = importdata(inText,' ');
end
clear img_data


for i = 1:length(subjlist)
    fprintf('### calculating subj silhs: [%d / %d] ###\n',i,length(subjlist));
    for m = 1:size(meants_cortNet{1},2)
        y_var = meants_cortNet{i}(:,m);
        z_var = cat(2,meants_cortNet{i}(:,1:m-1),meants_cortNet{i}(:,m+1:end));  % covariates
        rho(:,m,i) = partialcorr(voxroi{i}, y_var, z_var);
    end
    clear y_var z_var
end


% average raw corr coefficients across subjects (opt 1, 4)
rho_m = mean(rho,3);
rho_mAbs = abs(rho_m);  % to compare strength of positive and negative coefficients

% average abs corr coefficients across subjects (opt 2)
rhoAbs = abs(rho);  % to treat positive and negative coefficients together
rhoAbs_m = mean(rhoAbs,3);

% assign thalamic network labels where having the largests partial correlation
for k = 1:length(ind)
    maxMod(k,1) = find(rho_m(k,:) == max(rho_m(k,:)));  % no abs conversion
end
for k = 1:length(ind)
    maxMod_Abs(k,1) = find(rhoAbs_m(k,:) == max(rhoAbs_m(k,:)));  % conversion to abs values before averaging
end

% creating probabilistic map across subjs (opt 3)
for i = 1:length(subjlist)
    for k = 1:length(ind)
        maxMod_subj(k,i) = find(rhoAbs(k,:,i) == max(rhoAbs(k,:,i)));
    end
end
for k = 1:length(ind)
    for m = 1:size(meants_cortNet{1},2)
        maxMod_subjRep(k,m) = sum(maxMod_subj(k,:) == m);  % choose a network with the highest replicability among subjs
    end
    max_tmp = find(maxMod_subjRep(k,:) == max(maxMod_subjRep(k,:),[],2));
    maxMod_subjMax(k,:) = max_tmp(1);  % ignore multiple maxs
end
save('thalNet_parc_6mods.mat','-v7.3');


%% recreate a nifti image of parceled seeds
% image generation using fslmaths
load('thalNet_parc_6mods.mat')
dir_thalParc = '/PATH/TO/Thal_netParcel/thal_parcel';
c = 6;
clear -regexp ^idc
clear -regexp ^roi_c

idc1 = find(abs(maxMod-1) <= 1e-10);
idc2 = find(abs(maxMod-2) <= 1e-10);
idc3 = find(abs(maxMod-3) <= 1e-10);
idc4 = find(abs(maxMod-4) <= 1e-10);
idc5 = find(abs(maxMod-5) <= 1e-10);
idc6 = find(abs(maxMod-6) <= 1e-10);

for id=1:length(idc1)
    roi_c1(id,:) = [90-(x(idc1(id))-1),y(idc1(id))-1,z(idc1(id))-1];
end
for id=1:length(idc2)
    roi_c2(id,:) = [90-(x(idc2(id))-1),y(idc2(id))-1,z(idc2(id))-1];
end
for id=1:length(idc3)
    roi_c3(id,:) = [90-(x(idc3(id))-1),y(idc3(id))-1,z(idc3(id))-1];
end
for id=1:length(idc4)
    roi_c4(id,:) = [90-(x(idc4(id))-1),y(idc4(id))-1,z(idc4(id))-1];
end
for id=1:length(idc5)
    roi_c5(id,:) = [90-(x(idc5(id))-1),y(idc5(id))-1,z(idc5(id))-1];
end
for id=1:length(idc6)
    roi_c6(id,:) = [90-(x(idc6(id))-1),y(idc6(id))-1,z(idc6(id))-1];
end


%% image generation using fsl in matlab
setenv('FSLDIR','/usr/local/fsl');  % set FSL directory path
setenv('FSLOUTPUTTYPE','NIFTI_GZ'); % set output file type
clear idcs rois fsl_math_base fsl_math_tmp fsl_math_add

idcs = {idc1, idc2, idc3, idc4, idc5, idc6};
rois = {roi_c1, roi_c2, roi_c3, roi_c4, roi_c5, roi_c6};
for idc = 1:c
    idc
    fsl_math_base = ['/usr/local/fsl/bin/fslmaths ' dir_thalParc '/ThalAtlas/morelThal_2mm.nii.gz -mul 0 ' dir_thalParc '/thalNet_mod0' num2str(idc) ' -odt float'];
    system(fsl_math_base);
    for v = 1:length(idcs{idc})
        fsl_math_tmp = ['/usr/local/fsl/bin/fslmaths ' dir_thalParc '/thalNet_mod0' num2str(idc) ' -add 1 -roi ' num2str(rois{idc}(v,1)) ' 1 ' num2str(rois{idc}(v,2)) ' 1 ' num2str(rois{idc}(v,3)) ' 1 0 1 ' dir_thalParc '/thalNet_mod0' num2str(idc) '_' num2str(v) ' -odt float'];
        system(fsl_math_tmp);
    end
    for v = 1:length(idcs{idc})
        fsl_math_add = ['/usr/local/fsl/bin/fslmaths ' dir_thalParc '/thalNet_mod0' num2str(idc) ' -add ' dir_thalParc '/thalNet_mod0' num2str(idc) '_' num2str(v) ' -bin ' dir_thalParc '/thalNet_mod0' num2str(idc)];
        system(fsl_math_add);
    end
    delete([dir_thalParc '/thalNet_mod0' num2str(idc) '_*nii.gz'])
end
