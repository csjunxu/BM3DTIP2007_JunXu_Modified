clear;

Original_image_dir  =    'C:\Users\csjunxu\Desktop\ECCV2016\grayimages\';
fpath = fullfile(Original_image_dir,'*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
for scale = [0.01]
    mPSNR = [];
    mSSIM = [];
    for Sample = 1:1
        imPSNR{Sample} = [];
        imSSIM{Sample} = [];
        for i = 1:im_num
            S = regexp(im_dir(i).name, '\.', 'split');
            % read the clean image and normalization
            I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
            randn('seed',Sample-1);
            V = scale*rand(size(I));
            %% Generate noisy observation
            noiseI = imnoise(I,'localvar',V);
            noiseIn = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/NoisyImage/%s_GauLocVar_scale%2.2f.png',S{1},scale);
            imwrite(noiseI,noiseIn,'png');
            RannSig = NoiseLevel(noiseI*255);
            % Denoise 'noiseI'. The denoised image is 'restoredI'
            [~, restoredI] = BM3D(I, noiseI, RannSig);
            % Compute the putput PSNR
            imPSNR{Sample} = [imPSNR{Sample} csnr( restoredI*255, I*255, 0, 0 )];
            imSSIM{Sample}  = [imSSIM{Sample} cal_ssim( restoredI*255, I*255, 0, 0 )];
            restoredIn = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/BM3D/GauLocVar/BM3D_GauLocVar_scale%2.2f_Sample%d__%s',scale,Sample,im_dir(i).name);
            imwrite(restoredI,restoredIn,'png');
            fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
        end
        fprintf('The %dth Sampling is over. \n',Sample);
        Rmatname = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/BM3D/BM3D_GauLocVar_scale%2.2f.mat',scale);
        mPSNR(Sample) = mean(imPSNR{Sample});
        mSSIM(Sample) = mean(imSSIM{Sample});
        save(Rmatname,'scale','imPSNR','imSSIM','mPSNR','mSSIM');
    end
    matname = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/BM3D/BM3D_GauLocVar_scale%2.2f.mat',scale);
    PSNR = mean(mPSNR);
    SSIM = mean(mSSIM);
    save(Rmatname,'scale','PSNR','SSIM','imPSNR','imSSIM','mPSNR','mSSIM');
end