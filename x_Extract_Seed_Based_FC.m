clear;clc

path = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/Preprocessed/fmriprep';
sub = dir(fullfile(path,'sub*'));
sub = sub([sub.isdir]);

Target = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/New_Seed_FC_3mm';

ROI = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/Stim_ROI/Reslice_dlPFC_dmPFC_stim.nii';
Mask = '/public/home/ISTBI_data/toolbox/Template/MNI152/MNI152_T1_3mm_brain.nii.gz';

tic
parfor i = 1:length(sub)
    disp(i);
    mkdir(fullfile(Target,sub(i).name))
    sub_func = dir(fullfile(path,sub(i).name,'ses-*','func','sub*desc-smoothAROMAnonaggr_bold.nii.gz'));
    for j = 1:length(sub_func)
        if contains(sub_func(j).folder,'ses-pre')
            prefix = [sub(i).name,'_pre'];
        else
            prefix = [sub(i).name,'_post'];
        end
        
%         unix(['3dFourier -lowpass 0.1 -highpass 0.01 -prefix ',fullfile(sub_func(j).folder,['Filter_',sub_func(j).name]),...
%             ' ',fullfile(sub_func(j).folder,sub_func(j).name)]);
        unix(['flirt -in ',fullfile(sub_func(j).folder,sub_func(j).name),...
            ' -ref /home1/ISTBI_data/toolbox/Template/MNI152/MNI152_T1_3mm_brain.nii.gz -applyxfm -usesqform -out ',...
            fullfile(sub_func(j).folder,['Reslice_',sub_func(j).name])]);
        
        unix(['3dNetCorr -prefix ',fullfile(Target,sub(i).name,prefix),...
            ' -inset ',fullfile(sub_func(j).folder,['Reslice_',sub_func(j).name]),' -in_rois ',ROI,...
            ' -push_thru_many_zeros -ts_wb_corr -nifti -mask ',Mask]);
        unix(['mv ',fullfile(Target,sub(i).name,[prefix,'_000_INDIV'],'WB_CORR_ROI_001.nii.gz'),' ',...
            fullfile(Target,sub(i).name,[prefix,'_dlPFC_Seed_Rmap.nii.gz'])]);
        unix(['mv ',fullfile(Target,sub(i).name,[prefix,'_000_INDIV'],'WB_CORR_ROI_002.nii.gz'),' ',...
            fullfile(Target,sub(i).name,[prefix,'_dmPFC_Seed_Rmap.nii.gz'])]);
        unix(['3dcalc -a ',fullfile(Target,sub(i).name,[prefix,'_dlPFC_Seed_Rmap.nii.gz']),...
            ' -expr "log((1+a)/(1-a))/2" -prefix ',fullfile(Target,sub(i).name,[prefix,'_dlPFC_Seed_Zmap.nii.gz'])]);
        unix(['3dcalc -a ',fullfile(Target,sub(i).name,[prefix,'_dmPFC_Seed_Rmap.nii.gz']),...
            ' -expr "log((1+a)/(1-a))/2" -prefix ',fullfile(Target,sub(i).name,[prefix,'_dmPFC_Seed_Zmap.nii.gz'])]);
        unix(['rm -rf ',fullfile(Target,sub(i).name,[prefix,'_000*'])]);
        unix(['rm -f ',fullfile(Target,sub(i).name,[prefix,'_000*'])]);
    end
end
toc
                                                                          