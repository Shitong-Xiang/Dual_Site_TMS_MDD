clear;clc

path = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/New_Seed_FC_3mm';
sub = dir(fullfile(path,'sub-*'));

parfor i = 1:length(sub)
    disp(i);
    sub_seed = importdata(fullfile(path,sub(i).name,[sub(i).name,'_pre_Seed_TS.txt']));
    sub_cluster = importdata(fullfile(path,sub(i).name,[sub(i).name,'_pre_Clusters_TS.txt']));
    Sub_Pre_FC(i,:) = [corr(sub_seed(:,1),sub_cluster,'row','complete'),corr(sub_seed(:,2),sub_cluster,'row','complete'),corr(sub_seed(:,1),sub_seed(:,2),'row','complete')];
    sub_seed = importdata(fullfile(path,sub(i).name,[sub(i).name,'_post_Seed_TS.txt']));
    sub_cluster = importdata(fullfile(path,sub(i).name,[sub(i).name,'_post_Clusters_TS.txt']));
    Sub_Post_FC(i,:) = [corr(sub_seed(:,1),sub_cluster,'row','complete'),corr(sub_seed(:,2),sub_cluster,'row','complete'),corr(sub_seed(:,1),sub_seed(:,2),'row','complete')];
end
Sub_Pre_FC = 0.5*log((1+Sub_Pre_FC)./(1-Sub_Pre_FC));
Sub_Post_FC = 0.5*log((1+Sub_Post_FC)./(1-Sub_Post_FC));

% Cluster = reshape(y_ReadAll('/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/New_Clusters_08/Merge_Effect_Size_08_Clusters.nii'),[],1);
% parfor i = 1:length(sub)
%     disp(i);
%     sub_dlPFC = reshape(y_ReadAll(fullfile(path,sub(i).name,[sub(i).name,'_pre_dlPFC_Seed_Zmap.nii.gz'])),[],1);
%     sub_dmPFC = reshape(y_ReadAll(fullfile(path,sub(i).name,[sub(i).name,'_pre_dmPFC_Seed_Zmap.nii.gz'])),[],1);
%     tmp1 = zeros(1,max(Cluster));
%     tmp2 = zeros(1,max(Cluster));
%     for j = 1:max(Cluster)
%         tmp1(j) = nanmean(sub_dlPFC(Cluster == j));
%         tmp2(j) = nanmean(sub_dmPFC(Cluster == j));
%     end
%     Sub_Pre_FC(i,:) = [tmp1,tmp2];
%     sub_dlPFC = reshape(y_ReadAll(fullfile(path,sub(i).name,[sub(i).name,'_post_dlPFC_Seed_Zmap.nii.gz'])),[],1);
%     sub_dmPFC = reshape(y_ReadAll(fullfile(path,sub(i).name,[sub(i).name,'_post_dmPFC_Seed_Zmap.nii.gz'])),[],1);
%     tmp1 = zeros(1,max(Cluster));
%     tmp2 = zeros(1,max(Cluster));
%     for j = 1:max(Cluster)
%         tmp1(j) = nanmean(sub_dlPFC(Cluster == j));
%         tmp2(j) = nanmean(sub_dmPFC(Cluster == j));
%     end
%     Sub_Post_FC(i,:) = [tmp1,tmp2];
% end

Group = readtable('/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/MDDTMSZH_infoForMRI.csv');
diff = Sub_Post_FC - Sub_Pre_FC;
Aind = find(cell2mat(cellfun(@(x) strcmp(x,'A'),Group.Group,'un',0)));
[~,p,~,t] = ttest(diff(Aind,:));

group = [ones(sum(cell2mat(cellfun(@(x) strcmp(x,'A'),Group.Group,'un',0))),1);...
    zeros(sum(cell2mat(cellfun(@(x) strcmp(x,'S'),Group.Group,'un',0))),1)];
X = [group,table2array(Group([find(cell2mat(cellfun(@(x) strcmp(x,'A'),Group.Group,'un',0)));...
    find(cell2mat(cellfun(@(x) strcmp(x,'S'),Group.Group,'un',0)))],[2,3,12,13]))];
Gind = [find(cell2mat(cellfun(@(x) strcmp(x,'A'),Group.Group,'un',0)));...
    find(cell2mat(cellfun(@(x) strcmp(x,'S'),Group.Group,'un',0)))];
for i = 1:size(diff,2)
    disp(i)
    [~,~,stats] = glmfit(X,diff(Gind,i));
    t_stats(i) = stats.t(2);
    p_stats(i) = stats.p(2);
end