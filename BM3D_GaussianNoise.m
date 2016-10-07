clear;

Original_image_dir  =    'C:\Users\csjunxu\Desktop\ECCV2016\grayimages\';
fpath = fullfile(Original_image_dir,'*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
for nSig = [20 30 40 50 75]
    for Sample = 1:1
        imPSNR{Sample} = [];
        imSSIM{Sample} = [];
        for i = 1:im_num
            S = regexp(im_dir(i).name, '\.', 'split');
            %                     read the clean image and normalization
            I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
            randn('seed',Sample-1);
            noiseI = I + nSig/255*randn(size(I));
            EnSig = NoiseLevel(noiseI*255);
            fprintf(' The estimated noise level is :%2.2f. \n',EnSig);
            %                     Denoise 'noiseI'. The denoised image is 'restoredI'
            [~, restoredI] = BM3D(I, noiseI, EnSig);
            %                     Compute the putput PSNR
            imPSNR{Sample} = [imPSNR{Sample} csnr( restoredI*255, I*255, 0, 0 )];
            imSSIM{Sample}  = [imSSIM{Sample} cal_ssim( restoredI*255, I*255, 0, 0 )];
            restoredIn = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/BM3D/Gaussian/BM3D_nSig%d_EnSig%d_Sample%d_%s',nSig,EnSig,Sample,im_dir(i).name);
            imwrite(restoredI,restoredIn,'png');
            fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
        end
        fprintf('The %dth Sampling is over. \n',Sample);
        SmPSNR(Sample) = mean(imPSNR{Sample});
        SmSSIM(Sample) = mean(imSSIM{Sample});
        Smatname = sprintf('BM3D_nSig%d.mat',nSig);
        save(Smatname,'nSig','imPSNR','imSSIM','SmPSNR','SmSSIM');
    end
    mPSNR = mean(SmPSNR);
    mSSIM = mean(SmSSIM);
    matname = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/BM3D/BM3D_nSig%d_Sample%d.mat',nSig,Sample);
    save(matname,'nSig','SmPSNR','SmSSIM','mPSNR','mSSIM');
end