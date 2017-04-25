clear;

Original_image_dir  =    'C:\Users\csjunxu\Desktop\Projects\WODL\20images\';
% Original_image_dir  =    'C:\Users\csjunxu\Desktop\Projects\WODL\20newimages\';
Sdir = regexp(Original_image_dir, '\', 'split');
fpath = fullfile(Original_image_dir,'*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
for nSig = [20 40 60 80 100]
    PSNR = [];
    SSIM = [];
    for i = 1:im_num
        S = regexp(im_dir(i).name, '\.', 'split');
        %                     read the clean image and normalization
        I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
        randn('seed', 0);
        noiseI = I + nSig/255*randn(size(I));
        fprintf(' The noise level is :%2.2f. \n',nSig);
        %                     Denoise 'noiseI'. The denoised image is 'restoredI'
        [~, restoredI] = BM3D(I, noiseI, nSig);
        %                     Compute the putput PSNR
        PSNR = [PSNR csnr( restoredI*255, I*255, 0, 0 )];
        SSIM = [SSIM cal_ssim( restoredI*255, I*255, 0, 0 )];
        restoredIn = sprintf('C:/Users/csjunxu/Desktop/NIPS2017/W3Results/BM3D_nSig%d_%s',nSig,im_dir(i).name);
        imwrite(restoredI,restoredIn,'png');
        fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
    end
    mPSNR = mean(PSNR);
    mSSIM = mean(SSIM);
    matname = sprintf('C:/Users/csjunxu/Documents/GitHub/WODL_RID/Gaussian/BM3D_nSig%d.mat',nSig);
    save(matname,'nSig','PSNR','SSIM','mPSNR','mSSIM');
end