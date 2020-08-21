clear;
addpath('D:\Github\BM3DTIP2007_JunXu_Modified');
Original_image_dir  =    'D:/Github/Noisy-As-Clean/data/Set12/'; % Set12 ; BSD68
Sdir = regexp(Original_image_dir, '\', 'split');
fpath = fullfile(Original_image_dir,'*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
for nSig = [25 30 40 50]
    PSNR = [];
    SSIM = [];
    for i = 1:im_num
        S = regexp(im_dir(i).name, '\.', 'split');
        %  read the clean image and normalization
        I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
        randn('seed', 0);
        nI = I + nSig/255*randn(size(I));
        nPSNR = csnr( nI*255, I*255, 0, 0 );
        nSSIM = cal_ssim( nI*255, I*255, 0, 0 );
        %nIn = sprintf('D:\JunXu\NAC_TPAMI\BSD68_%d_Noisy_%2.2f_%2.4f_%s',nSig,nPSNR,nSSIM,im_dir(i).name);
        %imwrite(nI,nIn,'png');
        fprintf(' The noise level is :%2.2f. \n',nSig);
        %  Denoise 'nI'. The denoised image is 'rI'
        [~, rI] = BM3D(I, nI, nSig);
        %  Compute the putput PSNR
        PSNR = [PSNR csnr( rI*255, I*255, 0, 0 )];
        SSIM = [SSIM cal_ssim( rI*255, I*255, 0, 0 )];
        rIn = sprintf('D:/JunXu/NAC_TPAMI/BM3D_Set12_%d_%2.2f_%2.4f_%s',nSig,csnr( rI*255, I*255, 0, 0 ),cal_ssim( rI*255, I*255, 0, 0 ),im_dir(i).name);
        imwrite(rI,rIn,'png');
        fprintf('PSNR is:%f, SSIM is %f\n',csnr( rI*255, I*255, 0, 0 ),cal_ssim( rI*255, I*255, 0, 0 ));
    end
    mPSNR = mean(PSNR);
    mSSIM = mean(SSIM);
    matname = sprintf('D:/JunXu/NAC_TPAMI/BM3D_Set12_nSig%d.mat',nSig);
    save(matname,'nSig','PSNR','SSIM','mPSNR','mSSIM');
end