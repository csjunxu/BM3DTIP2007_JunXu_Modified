clear;

%% read  image directory
GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\1_Results\Real_NoisyImage\';
GT_fpath = fullfile(GT_Original_image_dir, '*.png');
TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\1_Results\Real_NoisyImage\';
TT_fpath = fullfile(TT_Original_image_dir, '*.png');
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% GT_fpath = fullfile(GT_Original_image_dir, '*mean.png');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% TT_fpath = fullfile(TT_Original_image_dir, '*real.png');

% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_MeanImage\';
% GT_fpath = fullfile(GT_Original_image_dir, '*.png');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_NoisyImage\';
% TT_fpath = fullfile(TT_Original_image_dir, '*.png');
% GT_Original_image_dir = 'C:/Users/csjunxu/Desktop/CVPR2017/our_Results/Real_MeanImage/';
% GT_fpath = fullfile(GT_Original_image_dir, '*.JPG');
% TT_Original_image_dir = 'C:/Users/csjunxu/Desktop/CVPR2017/our_Results/Real_NoisyImage/';
% TT_fpath = fullfile(TT_Original_image_dir, '*.JPG');


GT_im_dir  = dir(GT_fpath);
TT_im_dir  = dir(TT_fpath);
im_num = length(TT_im_dir);

method = 'CBM3D';
% write image directory
write_sRGB_dir = ['C:/Users/csjunxu/Desktop/CVPR2017/1_Results/'];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end

colorspace = 'opp' ;
print_to_screen = 0;
profile = 'np'; %or 'np'

PSNR = [];
SSIM = [];
CCPSNR = [];
CCSSIM = [];
RunTime = [];
for i = [5 7 8 14 ]% 1 : im_num
    IMin = im2double(imread(fullfile(TT_Original_image_dir,TT_im_dir(i).name) ));
    IM_GT = im2double(imread(fullfile(GT_Original_image_dir, GT_im_dir(i).name)));
    S = regexp(TT_im_dir(i).name, '\.', 'split');
    IMname = S{1};
    fprintf('%s: \n',TT_im_dir(i).name);
    [h, w, ch] = size(IM_GT);
    time0 = clock;
    for c = 1:ch
        nSig(c) = NoiseEstimation(IMin(:, :, c)*255, 8);
    end
    fprintf('The initial PSNR = %2.4f, SSIM = %2.4f. \n', csnr( IMin*255,IM_GT*255, 0, 0 ), cal_ssim( IMin*255, IM_GT*255, 0, 0 ));
    %% denoising
    %     nSig = NoiseLevel( IMin*255);
    %         mnSig = NoiseEstimation( IMin*255, 6);
    mnSig = sqrt(sum(nSig.^2)/3);
    
    [~, IMout] = CBM3D(IM_GT, IMin, 4*mnSig, profile, print_to_screen, colorspace);
    RunTime = [RunTime etime(clock,time0)];
    fprintf('Total elapsed time = %f s\n', (etime(clock,time0)) );
    %% output
    PSNR = [PSNR csnr( IMout*255, IM_GT*255, 0, 0 )];
    SSIM = [SSIM cal_ssim( IMout*255, IM_GT*255, 0, 0 )];
    fprintf('The final PSNR = %2.4f, SSIM = %2.4f. \n', PSNR(end), SSIM(end));
    %% output
    imwrite(IMout, [write_sRGB_dir 'Real_' method '/' method '_our' num2str(im_num) '_' IMname '.png']);
end
mPSNR = mean(PSNR);
mSSIM = mean(SSIM);
mRunTime = mean(RunTime);
matname = sprintf([write_sRGB_dir method '_our' num2str(im_num) '.mat']);
save(matname,'PSNR','SSIM','mPSNR','mSSIM','RunTime','mRunTime');