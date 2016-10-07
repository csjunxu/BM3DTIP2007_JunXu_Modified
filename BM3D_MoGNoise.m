clear;

Original_image_dir  =    'C:\Users\csjunxu\Desktop\ECCV2016\grayimages\';
fpath = fullfile(Original_image_dir,'*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
nSig = [10 30 50];
nWeight = [0.25 0.5 0.25];
for Sample = 1:1
    imPSNR{Sample} = [];
    imSSIM{Sample} = [];
    for i = 1:im_num
        S = regexp(im_dir(i).name, '\.', 'split');
        % read the clean image and normalization
        I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
        %
        stream = RandStream('mt19937ar','Seed',Sample-1);
        SampleIndex = randperm(stream,numel(I));
        NoiseMatrix = zeros(size(I));
        randn('seed',Sample-1)
        Pixels1 = fix(nWeight(1)*numel(NoiseMatrix));
        NoiseMatrix(SampleIndex(1 : Pixels1)) = nSig(1)/255*randn(1,Pixels1);
        randn('seed',Sample-1)
        Pixels2 = fix(nWeight(2)*numel(NoiseMatrix));
        NoiseMatrix(SampleIndex(Pixels1+1 : Pixels1+Pixels2)) = nSig(2)/255*randn(1,Pixels2);
        randn('seed',Sample-1)
        Pixels3 = numel(NoiseMatrix) - (Pixels1+Pixels2);
        NoiseMatrix(SampleIndex(Pixels1+Pixels2+1 : end)) = nSig(3)/255*randn(1,Pixels3);
        noiseI = I + NoiseMatrix;
        noiseIn = sprintf('%s_%d_%2.2f_%d_%2.2f_%d_%2.2f.png',S{1},nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
        imwrite(noiseI,noiseIn,'png');
        %% noise level estimation
        nLevel = NoiseLevel(noiseI*255);
        fprintf( 'Noisy Image: Noise Level is %2.2f, PSNR = %2.2f \n\n\n',nLevel, csnr( noiseI*255, I*255, 0, 0 ) );
        %% Denoise 'noiseI'. The denoised image is 'restoredI'
        [~, restoredI] = BM3D(I, noiseI, nLevel);
        %% Compute the putput PSNR
        imPSNR{Sample} = [imPSNR{Sample} csnr( restoredI*255, I*255, 0, 0 )];
        imSSIM{Sample}  = [imSSIM{Sample} cal_ssim( restoredI*255, I*255, 0, 0 )];
        restoredIn = sprintf('./BM3Dresults/BM3D_MoG_Sample%d_%d_%2.2f_%d_%2.2f_%d_%2.2f_%s',Sample,nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3),im_dir(i).name);
        imwrite(restoredI,restoredIn,'png');
        fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
    end
    fprintf('The %dth Sampling is over.',Sample);
    mPSNR(Sample) = mean(imPSNR{Sample});
    mSSIM(Sample) = mean(imSSIM{Sample});
    result = sprintf('BM3D_MoG_%d_%2.2f_%d_%2.2f_%d_%2.2f.mat',nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
    save(result,'nSig','imPSNR','imSSIM','mPSNR','mSSIM');
end
PSNR = mean(mPSNR);
SSIM = mean(mSSIM);
result = sprintf('BM3D_MoG_%d_%2.2f_%d_%2.2f_%d_%2.2f.mat',nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
save(result,'nSig','imPSNR','imSSIM','mPSNR','mSSIM','PSNR','SSIM');


nSig = [10 30 100];
nWeight = [0.5 0.25 0.25];
for Sample = 1:1
    imPSNR{Sample} = [];
    imSSIM{Sample} = [];
    for i = 1:im_num
        S = regexp(im_dir(i).name, '\.', 'split');
        % read the clean image and normalization
        I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
        %
        stream = RandStream('mt19937ar','Seed',Sample-1);
        SampleIndex = randperm(stream,numel(I));
        NoiseMatrix = zeros(size(I));
        randn('seed',Sample-1)
        Pixels1 = fix(nWeight(1)*numel(NoiseMatrix));
        NoiseMatrix(SampleIndex(1 : Pixels1)) = nSig(1)/255*randn(1,Pixels1);
        randn('seed',Sample-1)
        Pixels2 = fix(nWeight(2)*numel(NoiseMatrix));
        NoiseMatrix(SampleIndex(Pixels1+1 : Pixels1+Pixels2)) = nSig(2)/255*randn(1,Pixels2);
        randn('seed',Sample-1)
        Pixels3 = numel(NoiseMatrix) - (Pixels1+Pixels2);
        NoiseMatrix(SampleIndex(Pixels1+Pixels2+1 : end)) = nSig(3)/255*randn(1,Pixels3);
        noiseI = I + NoiseMatrix;
        noiseIn = sprintf('%s_%d_%2.2f_%d_%2.2f_%d_%2.2f.png',S{1},nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
        imwrite(noiseI,noiseIn,'png');
        %% noise level estimation
        nLevel = NoiseLevel(noiseI*255);
        fprintf( 'Noisy Image: Noise Level is %2.2f, PSNR = %2.2f \n\n\n',nLevel, csnr( noiseI*255, I*255, 0, 0 ) );
        %% Denoise 'noiseI'. The denoised image is 'restoredI'
        [~, restoredI] = BM3D(I, noiseI, nLevel);
        %% Compute the putput PSNR
        imPSNR{Sample} = [imPSNR{Sample} csnr( restoredI*255, I*255, 0, 0 )];
        imSSIM{Sample}  = [imSSIM{Sample} cal_ssim( restoredI*255, I*255, 0, 0 )];
        restoredIn = sprintf('./BM3Dresults/BM3D_MoG_Sample%d_%d_%2.2f_%d_%2.2f_%d_%2.2f_%s',Sample,nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3),im_dir(i).name);
        imwrite(restoredI,restoredIn,'png');
        fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
    end
    fprintf('The %dth Sampling is over.',Sample);
    mPSNR(Sample) = mean(imPSNR{Sample});
    mSSIM(Sample) = mean(imSSIM{Sample});
    result = sprintf('BM3D_MoG_%d_%2.2f_%d_%2.2f_%d_%2.2f.mat',nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
    save(result,'nSig','imPSNR','imSSIM','mPSNR','mSSIM');
end
PSNR = mean(mPSNR);
SSIM = mean(mSSIM);
result = sprintf('BM3D_MoG_%d_%2.2f_%d_%2.2f_%d_%2.2f.mat',nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
save(result,'nSig','imPSNR','imSSIM','mPSNR','mSSIM','PSNR','SSIM');


nSig = [10 30 100];
nWeight = [0.25 0.5 0.25];
for Sample = 1:1
    imPSNR{Sample} = [];
    imSSIM{Sample} = [];
    for i = 1:im_num
        S = regexp(im_dir(i).name, '\.', 'split');
        % read the clean image and normalization
        I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
        %
        stream = RandStream('mt19937ar','Seed',Sample-1);
        SampleIndex = randperm(stream,numel(I));
        NoiseMatrix = zeros(size(I));
        randn('seed',Sample-1)
        Pixels1 = fix(nWeight(1)*numel(NoiseMatrix));
        NoiseMatrix(SampleIndex(1 : Pixels1)) = nSig(1)/255*randn(1,Pixels1);
        randn('seed',Sample-1)
        Pixels2 = fix(nWeight(2)*numel(NoiseMatrix));
        NoiseMatrix(SampleIndex(Pixels1+1 : Pixels1+Pixels2)) = nSig(2)/255*randn(1,Pixels2);
        randn('seed',Sample-1)
        Pixels3 = numel(NoiseMatrix) - (Pixels1+Pixels2);
        NoiseMatrix(SampleIndex(Pixels1+Pixels2+1 : end)) = nSig(3)/255*randn(1,Pixels3);
        noiseI = I + NoiseMatrix;
        noiseIn = sprintf('%s_%d_%2.2f_%d_%2.2f_%d_%2.2f.png',S{1},nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
        imwrite(noiseI,noiseIn,'png');
        %% noise level estimation
        nLevel = NoiseLevel(noiseI*255);
        fprintf( 'Noisy Image: Noise Level is %2.2f, PSNR = %2.2f \n\n\n',nLevel, csnr( noiseI*255, I*255, 0, 0 ) );
        %% Denoise 'noiseI'. The denoised image is 'restoredI'
        [~, restoredI] = BM3D(I, noiseI, nLevel);
        %% Compute the putput PSNR
        imPSNR{Sample} = [imPSNR{Sample} csnr( restoredI*255, I*255, 0, 0 )];
        imSSIM{Sample}  = [imSSIM{Sample} cal_ssim( restoredI*255, I*255, 0, 0 )];
        restoredIn = sprintf('./BM3Dresults/BM3D_MoG_Sample%d_%d_%2.2f_%d_%2.2f_%d_%2.2f_%s',Sample,nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3),im_dir(i).name);
        imwrite(restoredI,restoredIn,'png');
        fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
    end
    fprintf('The %dth Sampling is over.',Sample);
    mPSNR(Sample) = mean(imPSNR{Sample});
    mSSIM(Sample) = mean(imSSIM{Sample});
    result = sprintf('BM3D_MoG_%d_%2.2f_%d_%2.2f_%d_%2.2f.mat',nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
    save(result,'nSig','imPSNR','imSSIM','mPSNR','mSSIM');
end
PSNR = mean(mPSNR);
SSIM = mean(mSSIM);
result = sprintf('BM3D_MoG_%d_%2.2f_%d_%2.2f_%d_%2.2f.mat',nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
save(result,'nSig','imPSNR','imSSIM','mPSNR','mSSIM','PSNR','SSIM');


nSig = [10 30 100];
nWeight = [0.25 0.25 0.5];
for Sample = 1:1
    imPSNR{Sample} = [];
    imSSIM{Sample} = [];
    for i = 1:im_num
        S = regexp(im_dir(i).name, '\.', 'split');
        % read the clean image and normalization
        I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
        %
        stream = RandStream('mt19937ar','Seed',Sample-1);
        SampleIndex = randperm(stream,numel(I));
        NoiseMatrix = zeros(size(I));
        randn('seed',Sample-1)
        Pixels1 = fix(nWeight(1)*numel(NoiseMatrix));
        NoiseMatrix(SampleIndex(1 : Pixels1)) = nSig(1)/255*randn(1,Pixels1);
        randn('seed',Sample-1)
        Pixels2 = fix(nWeight(2)*numel(NoiseMatrix));
        NoiseMatrix(SampleIndex(Pixels1+1 : Pixels1+Pixels2)) = nSig(2)/255*randn(1,Pixels2);
        randn('seed',Sample-1)
        Pixels3 = numel(NoiseMatrix) - (Pixels1+Pixels2);
        NoiseMatrix(SampleIndex(Pixels1+Pixels2+1 : end)) = nSig(3)/255*randn(1,Pixels3);
        noiseI = I + NoiseMatrix;
        noiseIn = sprintf('%s_%d_%2.2f_%d_%2.2f_%d_%2.2f.png',S{1},nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
        imwrite(noiseI,noiseIn,'png');
        %% noise level estimation
        nLevel = NoiseLevel(noiseI*255);
        fprintf( 'Noisy Image: Noise Level is %2.2f, PSNR = %2.2f \n\n\n',nLevel, csnr( noiseI*255, I*255, 0, 0 ) );
        %% Denoise 'noiseI'. The denoised image is 'restoredI'
        [~, restoredI] = BM3D(I, noiseI, nLevel);
        %% Compute the putput PSNR
        imPSNR{Sample} = [imPSNR{Sample} csnr( restoredI*255, I*255, 0, 0 )];
        imSSIM{Sample}  = [imSSIM{Sample} cal_ssim( restoredI*255, I*255, 0, 0 )];
        restoredIn = sprintf('./BM3Dresults/BM3D_MoG_Sample%d_%d_%2.2f_%d_%2.2f_%d_%2.2f_%s',Sample,nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3),im_dir(i).name);
        imwrite(restoredI,restoredIn,'png');
        fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
    end
    fprintf('The %dth Sampling is over.',Sample);
    mPSNR(Sample) = mean(imPSNR{Sample});
    mSSIM(Sample) = mean(imSSIM{Sample});
    result = sprintf('BM3D_MoG_%d_%2.2f_%d_%2.2f_%d_%2.2f.mat',nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
    save(result,'nSig','imPSNR','imSSIM','mPSNR','mSSIM');
end
PSNR = mean(mPSNR);
SSIM = mean(mSSIM);
result = sprintf('BM3D_MoG_%d_%2.2f_%d_%2.2f_%d_%2.2f.mat',nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
save(result,'nSig','imPSNR','imSSIM','mPSNR','mSSIM','PSNR','SSIM');
