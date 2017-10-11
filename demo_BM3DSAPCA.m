% BM3D-SAPCA : BM3D with Shape-Adaptive Principal Component Analysis  (v1.00, 2009)
% (demo script)
% BM3D-SAPCA is an algorithm for attenuation of additive white Gaussian noise (AWGN)
% from grayscale images. This algorithm reproduces the results from the article:
%  K. Dabov, A. Foi, V. Katkovnik, and K. Egiazarian, "BM3D Image Denoising with
%  Shape-Adaptive Principal Component Analysis", Proc. Workshop on Signal Processing
%  with Adaptive Sparse Structured Representations (SPARS'09), Saint-Malo, France,
%  April 2009.     (PDF available at  http://www.cs.tut.fi/~foi/GCF-BM3D )
%
% SYNTAX:
%     y_est = BM3DSAPCA2009(z, sigma)
%
% where  z  is an image corrupted by AWGN with noise standard deviation  sigma
% and  y_est  is an estimate of the noise-free image.
% Signals are assumed on the intensity range [0,1].
%
% USAGE EXAMPLE:
%
%     y = im2double(imread('Cameraman256.png'));
%     sigma=25/255;
%     z=y+sigma*randn(size(y));
%     y_est = BM3DSAPCA2009(z,sigma);
%
% Copyright (c) 2009-2011 Tampere University of Technology.   All rights reserved.
% This work should only be used for nonprofit purposes.
%
% author:  Alessandro Foi,   email:  firstname.lastname@tut.fi
%%
clear all
addpath('BM3D-SAPCA');
Original_image_dir  =    'C:\Users\csjunxu\Desktop\Projects\WODL\20images\';
Sdir = regexp(Original_image_dir, '\', 'split');
fpath = fullfile(Original_image_dir,'*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
% -------------------------------------------------------------------------
%% directory to save the results
method = 'BM3D-SAPCA';
writematpath = 'C:/Users/csjunxu/Desktop/CVPR2018 Denoising/Results_Gaussian/';
writefilepath  = [writematpath method '/'];
if ~isdir(writefilepath)
    mkdir(writefilepath);
end
for nSig = [20 40 60 80 100]
    PSNR = [];
    SSIM = [];
    for i = 1:im_num
        S = regexp(im_dir(i).name, '\.', 'split');
        %                     read the clean image and normalization
        I = im2double(imread( strcat(Original_image_dir,im_dir(i).name) ));
        randn('seed', 0);
        noiseI = I + nSig/255*randn(size(I));
        fprintf(' The noise level is :%2.2f. \n',nSig);
        %                     Denoise 'noiseI'. The denoised image is 'restoredI'
        restoredI = BM3DSAPCA2009(noiseI,nSig/255);
        %                     Compute the putput PSNR
        PSNR = [PSNR csnr( restoredI*255, I*255, 0, 0 )];
        SSIM = [SSIM cal_ssim( restoredI*255, I*255, 0, 0 )];
        restoredIn = sprintf([writefilepath 'BM3DSAPCA_' num2str(nSig) '_' im_dir(i).name]);
        imwrite(restoredI, restoredIn,'png');
        fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
    end
    mPSNR = mean(PSNR);
    mSSIM = mean(SSIM);
    matname = sprintf([writematpath 'BM3DSAPCA_' num2str(nSig) '.mat']);
    save(matname,'nSig','PSNR','SSIM','mPSNR','mSSIM');
end
