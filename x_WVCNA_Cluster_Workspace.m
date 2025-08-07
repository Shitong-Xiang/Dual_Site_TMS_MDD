clear;clc

path = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/HCP_Filter';
sub = dir(path);
sub(1:2) = [];
sub = sub([sub.isdir]);

parfor i = 1:length(sub)
    dlPFC(i,:) = reshape(y_ReadAll(fullfile(path,sub(i).name,'Resliced_dlPFC_Seed_Mean_Zmap.nii.gz')),[],1);
    dmPFC(i,:) = reshape(y_ReadAll(fullfile(path,sub(i).name,'Resliced_dmPFC_Seed_Mean_Zmap.nii.gz')),[],1);
end

Target = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/HCP_Clusters';
Mask = y_ReadAll(fullfile(Target,'Select_Sig_FC_ROI_mask.nii'));

dlPFC = dlPFC(:,reshape(Mask,[],1) == 1);
file = fopen(fullfile(Target,'HCP_Selected_dlPFC_Seed_FC.rds'),'wb');
fwrite(file,dlPFC,'double');
fclose(file);

dmPFC = dmPFC(:,reshape(Mask,[],1) == 1);
file = fopen(fullfile(Target,'HCP_Selected_dmPFC_Seed_FC.rds'),'wb');
fwrite(file,dmPFC,'double');
fclose(file);

clear;clc

Mask = y_ReadAll('/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/HCP_Clusters/Select_Sig_FC_ROI_mask.nii');
[~,~,~,Header] = y_ReadAll('/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/HCP_Filter/Resliced_Group_Level_dlPFC_Seed_FC_Mean_Zmap.nii');

Label = importdata('/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/HCP_Clusters/List_of_Merge_dlPFC_dmPFC_Seed_FC_Power6_Min10_Merge08_UnsignedTOM_mean_bicor.txt');

Data = reshape(Mask,[],1);
Data(reshape(Mask,[],1) == 1) = Label;
y_Write(reshape(Data,size(Mask)),Header,'Merge_dlPFC_dmPFC_Seed_FC_Power6_Min10_Merge08_mean_bicor_Cluster.nii');