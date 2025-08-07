clear;clc

path = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/HCP_Filter';
sub = dir(path);
sub(1:2) = [];
sub = sub([sub.isdir]);

parfor i = 1:length(sub)
    dlPFC(i,:) = reshape(y_ReadAll(fullfile(path,sub(i).name,'dlPFC_Seed_Mean_Zmap.nii.gz')),[],1);
    dmPFC(i,:) = reshape(y_ReadAll(fullfile(path,sub(i).name,'dmPFC_Seed_Mean_Zmap.nii.gz')),[],1);
end
diffPFC = dlPFC - dmPFC;

target = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/Dep_Beh_Map';
[Data,~,~,Header] = y_ReadAll(fullfile(path,sub(1).name,'dlPFC_Seed_Mean_Zmap.nii.gz'));
Mask = y_ReadAll('/public/home/ISTBI_data/toolbox/Template/MNI152/MNI152_T1_2mm_brain_mask.nii');

Beh = readtable('/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/HCP_Covas_Depression_Score.csv');
[~,ind1,ind2] = intersect(cell2mat(cellfun(@str2double,{sub.name},'un',0)),Beh.Subject);
Beh = Beh(ind2,:);

%% Diagnosis
Group = [ones(sum(Beh.SSAGA_Depressive_Ep == 5),1);zeros(sum(Beh.SSAGA_Depressive_Ep == 1),1)];
X = [Group,table2array(Beh([find(Beh.SSAGA_Depressive_Ep == 5);find(Beh.SSAGA_Depressive_Ep == 1)],2:10))];
Vars = who('*PFC');
for i = 1:length(Vars)
    tmp = eval([Vars{i},'(:,reshape(Mask,[],1) == 1)']);
    for j = 1:size(tmp,2)
        disp(j);
        [~,~,stats] = glmfit(X,tmp([find(Beh.SSAGA_Depressive_Ep == 5);find(Beh.SSAGA_Depressive_Ep == 1)],j));
        t_stats(j) = stats.t(2);
    end
    t_stats(isnan(t_stats)) = 0;
    Tmap = zeros(size(eval(Vars{i}),2),1);
    Tmap(reshape(Mask,[],1) == 1) = t_stats;
    y_Write(reshape(Tmap,size(Data)),Header,fullfile(target,[Vars{i},'_Seed_FC_Depression_vs_Control_Tmap.nii']));
end

%% Behaviour
Score = table2array(Beh(:,[11:18,20]));
Dep = Beh.Properties.VariableNames([11:18,20]);
Covas = table2array(Beh(:,2:10));
Vars = who('*PFC');
for i = 1:length(Vars)
    tmp = eval(Vars{i});
    r = partialcorr(Score,tmp,Covas,'row','complete');
    t = r./sqrt(1-power(r,2))*sqrt(1050);
    for j = 1:size(Score,2)
        y_Write(reshape(r(j,:),size(Data)),Header,fullfile(target,[Vars{i},'_Seed_FC_Corr_with_',Dep{j},'_Rmap.nii']));
        y_Write(reshape(t(j,:),size(Data)),Header,fullfile(target,[Vars{i},'_Seed_FC_Corr_with_',Dep{j},'_Tmap.nii']));
    end
end