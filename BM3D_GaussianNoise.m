clear;

Original_image_dir  =    '../DnCNN/testsets/BSD68/'; % Set12 ; BSD68
Sdir = regexp(Original_image_dir, '\', 'split');
fpath = fullfile(Original_image_dir,'*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
for nSig = [5 10 15 20 25]
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
        restoredIn = sprintf('/home/csjunxu/Github/NIPS2019/Gaussian_BSD68_BM3D/BM3D_BSD68_nSig%d_%s',nSig,im_dir(i).name);
        imwrite(restoredI,restoredIn,'png');
        fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
    end
    mPSNR = mean(PSNR);
    mSSIM = mean(SSIM);
    matname = sprintf('/home/csjunxu/Github/NIPS2019/BM3D_BSD68_nSig%d.mat',nSig);
    save(matname,'nSig','PSNR','SSIM','mPSNR','mSSIM');
end