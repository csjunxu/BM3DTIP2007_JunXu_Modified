clear;

%% read  image directory
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\DJI_Results\Real_MeanImage\';
% GT_fpath = fullfile(GT_Original_image_dir, '*.JPG');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\DJI_Results\Real_NoisyImage\';
% TT_fpath = fullfile(TT_Original_image_dir, '*.JPG');
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% GT_fpath = fullfile(GT_Original_image_dir, '*mean.png');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% TT_fpath = fullfile(TT_Original_image_dir, '*real.png');
% GT_im_dir  = dir(GT_fpath);
% TT_im_dir  = dir(TT_fpath);
% im_num = length(TT_im_dir);

Original_image_dir  =    'C:\Users\csjunxu\Desktop\JunXu\Datasets\kodak24\kodak_color\';
fpath = fullfile(Original_image_dir, '*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);

method = 'CBM3D';
% write image directory
write_sRGB_dir = ['C:/Users/csjunxu/Desktop/ICCV2017/24images/'];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end

% nSig = [5 30 15];
% nSig = [40 20 30];
% nSig = [30 10 50];
nSig = [25 25 25];

colorspace = 'opp' ;
print_to_screen = 0;
profile = 'np'; %or 'np'

PSNR = [];
SSIM = [];
CCPSNR = [];
CCSSIM = [];
for i = 1 : im_num
    %     IMin = im2double(imread(fullfile(TT_Original_image_dir,TT_im_dir(i).name) ));
    IM_GT = im2double(imread(fullfile(Original_image_dir, im_dir(i).name)));
    S = regexp(im_dir(i).name, '\.', 'split');
    IMname = S{1};
    fprintf('%s: \n',im_dir(i).name);
    [h, w, ch] = size(IM_GT);
    IMin = zeros(size(IM_GT));
    randn('seed',0);
    IMin = IM_GT + nSig(1)/255 * randn(size(IM_GT));
%     for c = 1:ch
%         randn('seed',0);
%         IMin(:, :, c) = IM_GT(:, :, c) + nSig(c)/255 * randn(size(IM_GT(:, :, c)));
%     end
    fprintf('The initial PSNR = %2.4f, SSIM = %2.4f. \n', csnr( IMin*255,IM_GT*255, 0, 0 ), cal_ssim( IMin*255, IM_GT*255, 0, 0 ));
%     imwrite(IMin, [write_sRGB_dir 'Noisy_nSig' num2str(nSig(1)) num2str(nSig(2)) num2str(nSig(3)) '_' IMname '.png']);
    
    %% denoising
    %     nSig = NoiseLevel( IMin*255);
    %     nSig = NoiseEstimation( IMin*255, 8);
%     mnSig = sqrt(sum(nSig.^2)/3);

    [~, IMout] = CBM3D(IM_GT, IMin, nSig, profile, print_to_screen, colorspace);
    %% output
    PSNR = [PSNR csnr( IMout*255, IM_GT*255, 0, 0 )];
    SSIM = [SSIM cal_ssim( IMout*255, IM_GT*255, 0, 0 )];
    fprintf('The final PSNR = %2.4f, SSIM = %2.4f. \n', PSNR(end), SSIM(end));
    %% output
%     imwrite(IMout, [write_sRGB_dir method '_nSig' num2str(nSig(1)) num2str(nSig(2)) num2str(nSig(3)) '_' IMname '.png']);
end
mPSNR = mean(PSNR);
mSSIM = mean(SSIM);
matname = sprintf([write_sRGB_dir method '_nSig' num2str(nSig(1)) num2str(nSig(2)) num2str(nSig(3)) '.mat', ]);
save(matname,'nSig','PSNR','SSIM','mPSNR','mSSIM');