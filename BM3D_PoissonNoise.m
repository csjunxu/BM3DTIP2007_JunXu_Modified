clear;

Original_image_dir  =    'C:\Users\csjunxu\Desktop\ECCV2016\grayimages\';
fpath = fullfile(Original_image_dir,'airfield.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
for nSig = [10 20 30 40 50 75 100]
    Ran = 0;
    for RannSig = (nSig-10):2:(nSig+10)
        if RannSig > 0
            Ran = Ran + 1;
            Rmatname = sprintf('BM3D_nSig%d_RannSig%d.mat',nSig,RannSig);
            for Sample = 1:10
                if exist(Rmatname,'file')
                    eval(['load ' Rmatname]);
                    if RannSig == RanIndex
                        if Sample <=length(SmPSNR)
                            continue
                        end
                    end
                end
                imPSNR{Sample} = [];
                imSSIM{Sample} = [];
                for i = 1:im_num
                    S = regexp(im_dir(i).name, '\.', 'split');
                    % read the clean image and normalization
                    I = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
                    randn('seed',Sample-1);
                    noiseI = imnoise(zero(size(I)),'Poisson');
                    noiseIn = sprintf('%s_noise%d.png',S{1},nSig);
                    imwrite(noiseI,noiseIn,'png');
                    % Denoise 'noiseI'. The denoised image is 'restoredI'
                    [~, restoredI] = BM3D(I, noiseI, RannSig);
                    % Compute the putput PSNR
                    imPSNR{Sample} = [imPSNR{Sample} csnr( restoredI*255, I*255, 0, 0 )];
                    imSSIM{Sample}  = [imSSIM{Sample} cal_ssim( restoredI*255, I*255, 0, 0 )];
                    restoredIn = sprintf('./BM3Dresults/Gaussian/BM3D_nSig%d_RannSig%d_Sample%d__%s',nSig,RannSig,Sample,im_dir(i).name);
                    imwrite(restoredI,restoredIn,'png');
                    fprintf('PSNR is:%f, SSIM is %f\n',csnr( restoredI*255, I*255, 0, 0 ),cal_ssim( restoredI*255, I*255, 0, 0 ));
                end
                fprintf('The %dth Sampling is over.',Sample);
                RanIndex = RannSig ;
                SmPSNR(Sample) = mean(imPSNR{Sample});
                SmSSIM(Sample) = mean(imSSIM{Sample});
                save(Rmatname,'nSig','imPSNR','imSSIM','SmPSNR','SmSSIM','RanIndex');
            end
            RanIndex = RannSig;
            RmPSNR(Ran) = mean(SmPSNR);
            RmSSIM(Ran) = mean(SmSSIM);
            save(Rmatname,'nSig','RmPSNR','RmSSIM','imPSNR','imSSIM','SmPSNR','SmSSIM','RanIndex');
        end
    end
    mPSNR = mean(RmPSNR);
    mSSIM = mean(RmSSIM);
    matname = sprintf('BM3D_nSig%d.mat',nSig);
    save(matname,'RmPSNR','RmSSIM','mPSNR','mSSIM');
end