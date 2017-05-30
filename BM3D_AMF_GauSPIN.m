clear;

Original_image_dir  =    'C:\Users\csjunxu\Desktop\Projects\WODL\20images\';
Sdir = regexp(Original_image_dir, '\', 'split');
fpath = fullfile(Original_image_dir,'*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);

for nSig = [10 20 30]
    for SpikyRatio = [0.1 0.3 0.5]
        imPSNR = [];
        imSSIM = [];
        Type = 0;
        for i = 1:im_num
            S = regexp(im_dir(i).name, '\.', 'split');
            %% read the clean image and normalization
            I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
            %                 %% add Gaussian noise
            %                 randn('seed', 0);
            %                 noiseI = I + nSig/255*randn(size(I));
            %                 %% add "salt and pepper" noise
            %                 %                 rand('seed',Sample-1)
            %                 %                 noiseI = imnoise(noiseI, 'salt & pepper', SpikyRatio); %"salt and pepper" noise
            %                 %                 noiseI = noiseI*255;
            %                 %% add "salt and pepper" noise 0 or RVIN noise 1
            %                 rand('seed',Sample-1)
            %                 [noiseI,Narr]          =   impulsenoise(noiseI*255,SpikyRatio,1);
            if Type == 0
                noiseI = double( imread(['C:/Users/csjunxu/Documents/GitHub/WODL_RID/images/G' num2str(nSig) '_SPIN' num2str(SpikyRatio) '_' im_dir(i).name]));
            elseif Type == 1
                noiseI = double( imread(['C:/Users/csjunxu/Documents/GitHub/WODL_RID/images/G' num2str(nSig) '_RVIN' num2str(SpikyRatio) '_' im_dir(i).name]));
            else
                break;
            end
            %% AMF
            [noiseIAMF,ind]=adpmedft(noiseI,19);
            ind=(noiseIAMF~=noiseI)&((noiseI==255)|(noiseI==0));
            noiseIAMF(~ind)=noiseI(~ind);
            %% noise estimation
%             nLevel = NoiseEstimation(noiseIAMF, 8);
            nLevel = NoiseLevel(noiseIAMF);
            %% denoising
            [~, restoredI] = BM3D(I, noiseIAMF/255, nLevel);
            %% save Output
            imPSNR = [imPSNR csnr( restoredI*255, I*255, 0, 0 )];
            imSSIM  = [imSSIM cal_ssim( restoredI*255, I*255, 0, 0 )];
            %                 restoredIn = sprintf('BM3D_AMF2_GauRVIN_%d_%2.2f_%s',nSig,SpikyRatio,im_dir(i).name);
            restoredIn = sprintf('C:/Users/csjunxu/Desktop/NIPS2017/W3Results/GSPIN/BM3D_AMF2_GauSPIN_%d_%2.2f_%s',nSig,SpikyRatio,im_dir(i).name);
            imwrite(restoredI,restoredIn,'png');
            fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
        end
        %% save Output
        mPSNR = mean(imPSNR);
        mSSIM = mean(imSSIM);
        %         result = sprintf('C:/Users/csjunxu/Documents/GitHub/WODL_RID/GPVIN/BM3D_AMF2_GauRVIN_%d_%2.2f.mat',nSig,SpikyRatio);
        result = sprintf('C:/Users/csjunxu/Documents/GitHub/WODL_RID/GSPIN/BM3D_AMF2_GauSPIN_%d_%2.2f.mat',nSig,SpikyRatio);
        save(result,'nSig','SpikyRatio','imPSNR','imSSIM','mPSNR','mSSIM');
    end
end