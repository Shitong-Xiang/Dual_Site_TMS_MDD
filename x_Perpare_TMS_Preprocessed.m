clear;clc

path = '/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/BIDS';
sub = dir(fullfile(path,'sub-*'));

parfor i = 1:length(sub)
    disp(i);
    sub_func = dir(fullfile(path,sub(i).name,'ses-*','func','*bold.nii.gz'));
    for j = 1:length(sub_func)
        unix(['fslroi ',fullfile(sub_func(j).folder,sub_func(j).name),' ',...
            fullfile(sub_func(j).folder,sub_func(j).name),' 10 240']);
    end
end

clear;clc

path = '/home1/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/BIDS';
sub = dir(fullfile(path,'sub-*'));

tic
parfor i = 1:length(sub)
    disp(i);
    unix(['singularity run --cleanenv /home1/ISTBI_data/toolbox/fmriprep/fmriprep-20.2.7.simg ',path,...
        ' /home1/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/Preprocessed participant --participant-label ',...
        replace(sub(i).name,'sub-',''),' --skip_bids_validation --nprocs 20 --force-bbr --use-aroma --fs-license-file /home1/ISTBI_data/toolbox/freesurfer/license.txt --fs-no-reconall -w /home1/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/Preprocessed/tmp --output-spaces MNI152NLin6Asym:res-2']);
end
toc

clear;clc

path = '/home1/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/Preprocessed/fmriprep';
sub = dir(fullfile(path,'sub-*'));
sub = sub([sub.isdir]);
BIDS = '/home1/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/BIDS';

error = zeros(1,length(sub));
parfor i = 1:length(sub)
    %     [~,cmdout] = unix(['grep ''No errors to report'' ',fullfile(path,[sub(i).name,'.html'])]);
    %     if length(cmdout) ~= 32
    %         error(i) = i;
    %     end
    func = dir(fullfile(path,sub(i).name,'ses-*','func','sub*desc-smoothAROMAnonaggr_bold.nii.gz'));
    check = dir(fullfile(BIDS,sub(i).name,'ses-*','func','*bold.nii.gz'));
    if length(func) ~= length(check)
        error(i) = i;
    end
end
error(error == 0) = [];