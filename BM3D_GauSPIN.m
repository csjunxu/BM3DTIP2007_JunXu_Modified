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
                % read the clean image and normalization
                I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
                randn('seed',Sample-1);
                noiseI = I + nSig/255*randn(size(I));
                %% add spiky noise or "salt and pepper" noise
                %                 rand('seed',Sample-1)
                %                 noiseI = imnoise(noiseI, 'salt & pepper', SpikyRatio); %"salt and pepper" noise
                %% add spiky noise 0 or random-valued impulse noise 1
                rand('seed',Sample-1)
                [noiseI,Narr]          =   impulsenoise(noiseI*255,SpikyRatio,0);
                %                 stream = RandStream('mt19937ar','Seed',Sample-1);
                %                 SampleIndex = randperm(stream,numel(noiseI));
                %                 SpikyPixels = fix(SpikyRatio*numel(noiseI));
                %                 noiseI(SampleIndex(1 : SpikyPixels)) = imnoise(noiseI(SampleIndex(1 : SpikyPixels)), 'salt & pepper', 1);
                % Denoise 'noiseI'. The denoised image is 'restoredI'
                nLevel = NoiseLevel(noiseI);
                [~, restoredI] = BM3D(I, noiseI/255, nLevel);
                % Compute the putput PSNR
                imPSNR{Sample} = [imPSNR{Sample} csnr( restoredI*255, I*255, 0, 0 )];
                imSSIM{Sample}  = [imSSIM{Sample} cal_ssim( restoredI*255, I*255, 0, 0 )];
                restoredIn = sprintf('./BM3Dresults/GauSpi/BM3D_GauSpi_%d_%2.2f_Sample%d_%s',nSig,SpikyRatio,Sample,im_dir(i).name);
                imwrite(restoredI,restoredIn,'png');
                fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
            end
            fprintf('The %dth Sampling is over.',Sample);
            mPSNR(Sample) = mean(imPSNR{Sample});
            mSSIM(Sample) = mean(imSSIM{Sample});
            result = sprintf('BM3D_GauSpi_%d_%2.2f_sample%d.mat',nSig,SpikyRatio,Sample);
            save(result,'nSig','imPSNR','imSSIM','mPSNR','mSSIM');
        end
    end
end
