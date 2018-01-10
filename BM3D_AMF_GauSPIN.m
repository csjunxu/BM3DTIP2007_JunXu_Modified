clear;

Original_image_dir  =    'C:\Users\csjunxu\Desktop\TWSCGIN\cleanimages\';
Sdir = regexp(Original_image_dir, '\', 'split');
fpath = fullfile(Original_image_dir,'*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
method = 'BM3Damf2';
write_MAT_dir = ['C:/Users/csjunxu/Desktop/BWNNM/'];
write_sRGB_dir = [write_MAT_dir method];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end
for nSig = [10 20]
    for sp = [0.1 0.3 0.5]
        imPSNR = [];
        imSSIM = [];
        Type = 0;
        for i = 1:im_num
            S = regexp(im_dir(i).name, '\.', 'split');
            %% read the clean image and normalization
            I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
            %% add Gaussian noise
            randn('seed', 0);
            nI = I + nSig/255*randn(size(I));
            %% add "salt and pepper" noise
            %                 rand('seed',Sample-1)
            %                 noiseI = imnoise(noiseI, 'salt & pepper', SpikyRatio); %"salt and pepper" noise
            %                 noiseI = noiseI*255;
            %% add "salt and pepper" noise 0 or RVIN noise 1
            rand('seed',0)
            [nI,Narr]          =   impulsenoise(nI*255,sp,1);
            if Type == 0
                imname = sprintf([write_MAT_dir 'noisyimages/G' num2str(nSig) '_SPIN' num2str(sp) '_' im_dir(i).name]);
                imwrite(nI/255,imname);
                Par.nim = double( imread(imname));
            elseif Type == 1
                imname = sprintf([write_MAT_dir 'noisyimages/G' num2str(nSig) '_RVIN' num2str(sp) '_' im_dir(i).name]);
                imwrite(nI/255,imname);
                Par.nim = double( imread(imname));
            else
                break;
            end
            %% AMF
            [noiseIAMF,ind]=adpmedft(nI,19);
            ind=(noiseIAMF~=nI)&((nI==255)|(nI==0));
            noiseIAMF(~ind)=nI(~ind);
            %% noise estimation
            nLevel = NoiseEstimation(noiseIAMF, 8);
            %             nLevel = NoiseLevel(noiseIAMF);
            %% denoising
            [~, restoredI] = BM3D(I, noiseIAMF/255, nLevel);
            %% save Output
            imPSNR = [imPSNR csnr( restoredI*255, I*255, 0, 0 )];
            imSSIM  = [imSSIM cal_ssim( restoredI*255, I*255, 0, 0 )];
            restoredIn = sprintf([write_sRGB_dir '/BM3D_AMF2_GSPIN_p_' Sdir{end-1} '_nSig' num2str(nSig) '_sp' num2str(sp) '.mat']);
            imwrite(restoredI,restoredIn,'png');
            fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
        end
        %% save Output
        mPSNR = mean(imPSNR);
        mSSIM = mean(imSSIM);
        result = sprintf([write_MAT_dir '/BM3D_AMF2_GSPIN_p_' Sdir{end-1} '_nSig' num2str(nSig) '_sp' num2str(sp) '.mat']);
        save(result,'nSig','sp','imPSNR','imSSIM','mPSNR','mSSIM');
    end
end