clear;

Original_image_dir  =    'C:\Users\csjunxu\Desktop\ECCV2016\grayimages\';
fpath = fullfile(Original_image_dir,'*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
for nSigG = 10
    for nSigL = [15 30 45]
        for Sample = 1:1
            imPSNR{Sample} = [];
            imSSIM{Sample} = [];
            for i = 1:im_num
                S = regexp(im_dir(i).name, '\.', 'split');
                % read the clean image and normalization
                I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
                randn('seed',Sample-1);
                noiseI = I + nSigG/255*randn(size(I));
                %% add spiky noise 0 or random-valued impulse noise 1
                rand('seed',Sample-1);
                noiseI = noiseI + nSigL/255.*randl(size(I));
                nLevel = NoiseLevel(noiseI*255);
                [~, restoredI] = BM3D(I, noiseI, nLevel);
                % Compute the putput PSNR
                imPSNR{Sample} = [imPSNR{Sample} csnr( restoredI*255, I*255, 0, 0 )];
                imSSIM{Sample}  = [imSSIM{Sample} cal_ssim( restoredI*255, I*255, 0, 0 )];
                restoredIn = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/BM3D/GauLap/BM3D_GauLap_%d_%d_%s',nSigG,nSigL,im_dir(i).name);
                imwrite(restoredI,restoredIn,'png');
                fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
            end
            mPSNR(Sample) = mean(imPSNR{Sample});
            mSSIM(Sample) = mean(imSSIM{Sample});
            result = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/BM3D/BM3D_GauLap_%d_%d.mat',nSigG,nSigL);
            save(result,'nSigG','nSigL','imPSNR','imSSIM','mPSNR','mSSIM');
        end
    end
end
