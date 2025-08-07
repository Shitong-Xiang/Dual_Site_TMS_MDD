clear;clc

path = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/New_Seed_FC_3mm';
sub = dir(fullfile(path,'sub-*'));
Group = readtable('/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/MDDTMSZH_infoForMRI.csv');

parfor i = 1:length(sub)
    pre_dlPFC(i,:) = reshape(y_ReadAll(fullfile(path,sub(i).name,[sub(i).name,'_pre_dlPFC_Seed_Zmap.nii.gz'])),[],1);
    pre_dmPFC(i,:) = reshape(y_ReadAll(fullfile(path,sub(i).name,[sub(i).name,'_pre_dmPFC_Seed_Zmap.nii.gz'])),[],1);
    post_dlPFC(i,:) = reshape(y_ReadAll(fullfile(path,sub(i).name,[sub(i).name,'_post_dlPFC_Seed_Zmap.nii.gz'])),[],1);
    post_dmPFC(i,:) = reshape(y_ReadAll(fullfile(path,sub(i).name,[sub(i).name,'_post_dmPFC_Seed_Zmap.nii.gz'])),[],1);
end

[Data,~,~,Header] = y_ReadAll(fullfile(path,sub(1).name,[sub(1).name,'_pre_dlPFC_Seed_Zmap.nii.gz']));
Vars = who('pre*PFC');
for i = 1:length(Vars)
    [~,~,~,t] = ttest(eval(Vars{i}));
    t.tstat(isnan(t.tstat)) = 0;
    y_Write(reshape(t.tstat,size(Data)),Header,['All_',Vars{i},'_Seed_Tmap.nii']);
end

Score = table2array(Group(:,5));
Covas = table2array(Group(:,[2,3,12]));
for i = 1:length(Vars)
    tmp = eval(Vars{i});
    r = partialcorr(Score,tmp,Covas,'row','complete');
    t = r./sqrt(1-power(r,2))*sqrt(49);
    y_Write(reshape(r,size(Data)),Header,fullfile(path,[Vars{i},'_Seed_FC_Corr_with_BL_Score_Rmap.nii']));
    y_Write(reshape(t,size(Data)),Header,fullfile(path,[Vars{i},'_Seed_FC_Corr_with_BL_Score_Tmap.nii']));
end

diff_dlPFC = post_dlPFC - pre_dlPFC;
diff_dmPFC = post_dmPFC - pre_dmPFC;
Vars = who('diff*PFC');
ind = find(cell2mat(cellfun(@(x) strcmp(x,'A'),Group.Group,'un',0)));

for i = 1:length(Vars)
    [~,~,~,t] = ttest(eval([Vars{i},'(ind,:)']));
    t.tstat(isnan(t.tstat)) = 0;
    y_Write(reshape(t.tstat,size(Data)),Header,['AGroup_',Vars{i},'_Seed_Tmap.nii']);
end

Mask = y_ReadAll('/public/home/ISTBI_data/toolbox/Template/MNI152/MNI152_T1_2mm_brain_mask.nii.gz');
group = [ones(sum(cell2mat(cellfun(@(x) strcmp(x,'A'),Group.Group,'un',0))),1);...
    zeros(sum(cell2mat(cellfun(@(x) strcmp(x,'S'),Group.Group,'un',0))),1)];
X = [group,table2array(Group([find(cell2mat(cellfun(@(x) strcmp(x,'A'),Group.Group,'un',0)));...
    find(cell2mat(cellfun(@(x) strcmp(x,'S'),Group.Group,'un',0)))],[2,3,12,13]))];
Vars = who('diff*PFC');
for i = 1:length(Vars)
    tmp = eval([Vars{i},'(:,reshape(Mask,[],1) == 1)']);
    for j = 1:size(tmp,2)
        disp(j);
        [~,~,stats] = glmfit(X,tmp([find(cell2mat(cellfun(@(x) strcmp(x,'A'),Group.Group,'un',0)));...
            find(cell2mat(cellfun(@(x) strcmp(x,'S'),Group.Group,'un',0)))],j));
        t_stats(j) = stats.t(2);
    end
    t_stats(isnan(t_stats)) = 0;
    Tmap = zeros(size(eval(Vars{i}),2),1);
    Tmap(reshape(Mask,[],1) == 1) = t_stats;
    y_Write(reshape(Tmap,size(Data)),Header,fullfile(path,[Vars{i},'_Seed_FC_Tmap.nii']));
end

clear;clc;

GM = y_ReadAll('/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/Stim_ROI/MNI152_T1_3mm_GM_priors.nii');
[dlPFC,~,~,dlPFC_Header] = y_ReadAll('/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/New_Seed_FC_3mm/diff_dlPFC_Seed_FC_Dmap.nii');
[dmPFC,~,~,dmPFC_Header] = y_ReadAll('/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/New_Seed_FC_3mm/diff_dmPFC_Seed_FC_Dmap.nii');

dlPFC(GM < 0.4) = 0;
y_Write(dlPFC,dlPFC_Header,'diff_dlPFC_Seed_FC_Dmap_GM.nii');
dmPFC(GM < 0.4) = 0;
y_Write(dmPFC,dmPFC_Header,'diff_dmPFC_Seed_FC_Dmap_GM.nii');