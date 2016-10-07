clear;

Original_image_dir  =    'C:\Users\csjunxu\Desktop\ECCV2016\grayimages\';
fpath = fullfile(Original_image_dir,'*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
for nSig = [10 20]
    for SpikyRatio = [0.15 0.3]
        for Sample = 1:1
            imPSNR{Sample} = [];
            imSSIM{Sample} = [];
            for i = 1:im_num
                S = regexp(im_dir(i).name, '\.', 'split');
                %% read the clean image and normalization
                I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
                %% add Gaussian noise
                randn('seed',Sample-1);
                noiseI = I + nSig/255*randn(size(I));
                %% add "salt and pepper" noise
                %                 rand('seed',Sample-1)
                %                 noiseI = imnoise(noiseI, 'salt & pepper', SpikyRatio); %"salt and pepper" noise
                %                 noiseI = noiseI*255;
                %% add "salt and pepper" noise 0 or RVIN noise 1
                rand('seed',Sample-1)
                [noiseI,Narr]          =   impulsenoise(noiseI*255,SpikyRatio,1);
                %% AMF
                [noiseIAMF,ind]=adpmedft(noiseI,19);
                ind=(noiseIAMF~=noiseI)&((noiseI==255)|(noiseI==0));
                noiseIAMF(~ind)=noiseI(~ind);
                %% noise estimation
                nLevel = NoiseLevel(noiseIAMF);
                %% denoising
                [~, restoredI] = BM3D(I, noiseIAMF/255, nLevel);
                %% save Output
                imPSNR{Sample} = [imPSNR{Sample} csnr( restoredI*255, I*255, 0, 0 )];
                imSSIM{Sample}  = [imSSIM{Sample} cal_ssim( restoredI*255, I*255, 0, 0 )];
                restoredIn = sprintf('BM3D_AMF2_GauRVIN_%d_%2.2f_Sample%d_%s',nSig,SpikyRatio,Sample,im_dir(i).name);
                %                 restoredIn = sprintf('BM3D_AMF2_GauSPIN_%d_%2.2f_Sample%d_%s',nSig,SpikyRatio,Sample,im_dir(i).name);
                imwrite(restoredI,restoredIn,'png');
                fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
            end
            %% save Output
            fprintf('The %dth Sampling is over.',Sample);
            mPSNR(Sample) = mean(imPSNR{Sample});
            mSSIM(Sample) = mean(imSSIM{Sample});
            result = sprintf('BM3D_AMF2_GauRVIN_%d_%2.2f.mat',nSig,SpikyRatio);
            %             result = sprintf('BM3D_AMF2_GauSPIN_%d_%2.2f.mat',nSig,SpikyRatio);
            save(result,'nSig','imPSNR','imSSIM','mPSNR','mSSIM');
        end
    end
end