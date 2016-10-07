clear;
GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
GT_fpath = fullfile(GT_Original_image_dir, '*mean.png');
TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
TT_fpath = fullfile(TT_Original_image_dir, '*real.png');
GT_im_dir  = dir(GT_fpath);
TT_im_dir  = dir(TT_fpath);
im_num = length(TT_im_dir);

PSNR = [];
SSIM = [];
CCPSNR = [];
CCSSIM = [];
for i = 1 : im_num
    IMin = im2double(imread(fullfile(TT_Original_image_dir,TT_im_dir(i).name) ));
    IM_GT = im2double(imread(fullfile(GT_Original_image_dir, GT_im_dir(i).name)));
    S = regexp(TT_im_dir(i).name, '\.', 'split');
    IMname = S{1};
    [h,w,ch] = size(IMin);
    fprintf('%s: \n',TT_im_dir(i).name);
    CCPSNR = [CCPSNR csnr( IMin*255,IM_GT*255, 0, 0 )];
    CCSSIM = [CCSSIM cal_ssim( IMin*255, IM_GT*255, 0, 0 )];
    fprintf('The initial PSNR = %2.4f, SSIM = %2.4f. \n', CCPSNR(end), CCSSIM(end));
    IMinycbcr = rgb2ycbcr(IMin);
    IM_GTycbcr = rgb2ycbcr(IM_GT);
    IMoutycbcr = zeros(size(IMinycbcr));
    for cc = 1:ch
        %% denoising
        nSig = NoiseLevel( IMinycbcr(:,:,cc)*255);
        [~, IMoutycbcrcc] = BM3D(IM_GTycbcr(:,:,cc), IMinycbcr(:,:,cc), nSig);
        IMoutycbcr(:,:,cc) = IMoutycbcrcc;
    end
    IMout = ycbcr2rgb(IMoutycbcr);
    %% output
    PSNR = [PSNR csnr( IMout*255, IM_GT*255, 0, 0 )];
    SSIM = [SSIM cal_ssim( IMout*255, IM_GT*255, 0, 0 )];
    fprintf('The final PSNR = %2.4f, SSIM = %2.4f. \n', PSNR(end), SSIM(end));
    %% output
    imwrite(IMout, ['C:/Users/csjunxu/Desktop/CVPR2017/cc_Results/Real_BM3D/BM3D_BID_' IMname '.png']);
end
mPSNR = mean(PSNR);
mSSIM = mean(SSIM);
mCCPSNR = mean(CCPSNR);
mCCSSIM = mean(CCSSIM);
save(['C:/Users/csjunxu/Desktop/CVPR2017/cc_Results/Real_BM3D_BID_CCNoise_15.mat'],'PSNR','mPSNR','SSIM','mSSIM','CCPSNR','mCCPSNR','CCSSIM','mCCSSIM');

run DemoCBM3D.m