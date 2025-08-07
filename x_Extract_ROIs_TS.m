clear;clc

path = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/Preprocessed/fmriprep';
sub = dir(fullfile(path,'sub*'));
sub = sub([sub.isdir]);

Target = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/New_Seed_FC_3mm';
Seed = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/Stim_ROI/Reslice_dlPFC_dmPFC_stim.nii';
Clusters = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/New_Clusters_08/Merge_Effect_Size_08_Clusters.nii';

tic
parfor i = 1:length(sub)
    disp(i);
    sub_func = dir(fullfile(path,sub(i).name,'ses-*','func','Reslice_sub*desc-smoothAROMAnonaggr_bold.nii.gz'));
    for j = 1:length(sub_func)
        if contains(sub_func(j).folder,'ses-pre')
            prefix = [sub(i).name,'_pre'];
        else
            prefix = [sub(i).name,'_post'];
        end
        unix(['fslmeants -i ',fullfile(sub_func(j).folder,sub_func(j).name),' --label=',Seed,...
            ' -o ',fullfile(Target,sub(i).name,[prefix,'_Seed_TS.txt'])]);
        unix(['fslmeants -i ',fullfile(sub_func(j).folder,sub_func(j).name),' --label=',Clusters,...
            ' -o ',fullfile(Target,sub(i).name,[prefix,'_Clusters_TS.txt'])]);
    end
end
toc
