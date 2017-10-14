clear;
Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2018 Denoising\dnd_2017\images_srgb\';
fpath = fullfile(Original_image_dir, '*.mat');
im_dir  = dir(fpath);
im_num = length(im_dir);
load 'C:\Users\csjunxu\Desktop\CVPR2018 Denoising\dnd_2017\info.mat';

method = 'CBM3D';
% write image directory
write_MAT_dir = ['C:/Users/csjunxu/Desktop/CVPR2018 Denoising/dnd_2017Results/'];
write_sRGB_dir = ['C:/Users/csjunxu/Desktop/CVPR2018 Denoising/dnd_2017Results/' method];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end

colorspace = 'opp' ;
print_to_screen = 0;
profile = 'np'; %or 'np'

PSNR = [];
SSIM = [];
nPSNR = [];
nSSIM = [];
RunTime = [];
for i = 1:im_num
    load(fullfile(Original_image_dir, im_dir(i).name));
    S = regexp(im_dir(i).name, '\.', 'split');
    [h,w,ch] = size(InoisySRGB);
    for j = 1:size(info(1).boundingboxes,1)
        time0 = clock;
        IMinname = [S{1} '_' num2str(j)];
        IMin = InoisySRGB(info(i).boundingboxes(j,1):info(i).boundingboxes(j,3),info(i).boundingboxes(j,2):info(i).boundingboxes(j,4),1:3);
        IM_GT = IMin;
        %         for c = 1:ch
        %             nSig(c) = NoiseEstimation(IMin(:, :, c)*255, 8);
        %         end
        %         mnSig = sqrt(sum(nSig.^2)/3);
        mnSig = NoiseEstimation(IMin*255, 8);
        fprintf('The initial PSNR = %2.4f, SSIM = %2.4f. \n', csnr( IMin*255,IM_GT*255, 0, 0 ), cal_ssim( IMin*255, IM_GT*255, 0, 0 ));
        %% denoising
        [~, IMout] = CBM3D(IM_GT, IMin, mnSig, profile, print_to_screen, colorspace);
        RunTime = [RunTime etime(clock,time0)];
        fprintf('Total elapsed time = %f s\n', (etime(clock,time0)) );
        %% output
        PSNR = [PSNR csnr( IMout*255, IM_GT*255, 0, 0 )];
        SSIM = [SSIM cal_ssim( IMout*255, IM_GT*255, 0, 0 )];
        fprintf('The final PSNR = %2.4f, SSIM = %2.4f. \n', PSNR(end), SSIM(end));
        %% output
        imwrite(IMout, [write_sRGB_dir '/' method '_DND_' IMinname '.png']);
    end
end
% mPSNR = mean(PSNR);
% mSSIM = mean(SSIM);
% mnPSNR = mean(nPSNR);
% mnSSIM = mean(nSSIM);
% mRunTime = mean(RunTime);
% matname = sprintf([write_MAT_dir method '_our.mat']);
% save(matname,'PSNR','SSIM','mPSNR','mSSIM','nPSNR','nSSIM','mnPSNR','mnSSIM','RunTime','mRunTime');