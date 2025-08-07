clear;clc

path = '/public/mig_old_storage/home1/ISTBI_data/toolbox/Neurosynth/Overlap_Terms';
Terms = dir(path);
Terms = Terms(3:end);
Terms = Terms([Terms.isdir]);

Mask = y_ReadAll('/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/Stim_ROI/MNI152_T1_3mm_GM_priors.nii');
Obs = y_ReadAll('/public/home/ISTBI_data/Other_Work/dlPFC_dmPFC/New_Preprocessed/New_Seed_FC_3mm/diff_dmPFC_Seed_FC_Dmap_GM.nii');

Outind = find(abs(Obs(:)) < 0.8 & Mask(:) > 0.4);

Stats = zeros(length(Terms),5);
for i = 1:length(Terms)
    disp(i);
    Zmap = y_ReadAll(fullfile(path,Terms(i).name,'Reslice_association-test_z.nii'));
    [Stats(i,1),Stats(i,2)] = corr(Obs(abs(Obs(:)) > 0.8),Zmap(abs(Obs(:)) > 0.8),'row','complete');
    parfor j = 1:10000
        permind = randperm(length(Outind),sum(abs(Obs(:)) > 0.8));
        r0(j) = corr(Obs(Outind(permind)),Zmap(Outind(permind)),'row','complete');
    end
    Stats(i,3) = nanmean(r0);
    Stats(i,4) = real(sqrt(1-(1-power(Stats(i,1),2))/(1-power(nanmean(r0),2))))*Stats(i,1)/abs(Stats(i,1));
    Stats(i,5) = sum(r0 > Stats(i,1))/10000;
end
[~,Stats(:,6)] =  FDR(Stats(:,5),0.05,'harmonic');

T = table;
T.Terms = {Terms.name}';
T = [T,array2table(Stats,'VariableNames',{'r_obs','p_obs','r0','r_adj','p_adj','FDR'})];
