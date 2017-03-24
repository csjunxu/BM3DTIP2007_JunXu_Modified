clear all

% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% GT_fpath = fullfile(GT_Original_image_dir, '*mean.png');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% TT_fpath = fullfile(TT_Original_image_dir, '*real.png');

GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_MeanImage\';
GT_fpath = fullfile(GT_Original_image_dir, '*.png');
TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_NoisyImage\';
TT_fpath = fullfile(TT_Original_image_dir, '*.png');

GT_im_dir  = dir(GT_fpath);
TT_im_dir  = dir(TT_fpath);
im_num = length(TT_im_dir);

method = 'BM3DPoisson';
for alpha = [1]
    PSNR_yhat   = [];
    SSIM_yhat   =  [];
    
    PSNR_yhat_cfa   =  [];
    SSIM_yhat_cfa   =  [];
    
    PSNR_yhat_asy   =  [];
    SSIM_yhat_asy   =   [];
    
    PSNR_yhat_alg   =  [];
    SSIM_yhat_alg   =  [];
    for i = 1:im_num
        
        z = im2double( imread(fullfile(TT_Original_image_dir, TT_im_dir(i).name)) );
        y = im2double( imread(fullfile(GT_Original_image_dir, GT_im_dir(i).name)) );
        
        S = regexp(GT_im_dir(i).name, '\.', 'split');
        fprintf('%s :\n', TT_im_dir(i).name);
        [h, w, ch] = size(z);
        
        % mixed Poisson-Gaussian noise parameters
        
        % Poisson scaling factor
        for c = 1:ch
            % Gaussian component N(g,sigma^2)
            sigma = NoiseEstimation(z(:, :, c), 8);
            g = 0.0;
            
            %% Apply forward variance stabilizing transformation
            fz = GenAnscombe_forward(z(:, :, c), sigma,alpha,g); % Generalized Anscombe VST (J.L. Starck, F. Murtagh, and A. Bijaoui, Image  Processing  and  Data Analysis, Cambridge University Press, Cambridge, 1998)
            
            %% DENOISING
            
            sigma_den = 1;  % Standard-deviation value assumed after variance-stabiliation
            
            % Scale the image (BM3D processes inputs in [0,1] range)
            scale_range = 1;
            scale_shift = (1-scale_range)/2;
            
            maxzans = max(fz(:));
            minzans = min(fz(:));
            fz = (fz-minzans)/(maxzans-minzans);   sigma_den = sigma_den/(maxzans-minzans);
            fz = fz*scale_range+scale_shift;       sigma_den = sigma_den*scale_range;
            
            [dummy, D] = BM3D(y(:, :, c),fz,sigma_den*255,'np',0); % denoise assuming AWGN
            
            % Scale back to the initial VST range
            D = (D-scale_shift)/scale_range;
            D = D*(maxzans-minzans)+minzans;
            
            %% Apply the inverse transformation
            yhat(:, :, c) = GenAnscombe_inverse_exact_unbiased(D,sigma,alpha,g);   % exact unbiased inverse
            yhat_cfa(:, :, c) = GenAnscombe_inverse_closed_form(D,sigma,alpha,g);  % closed-form approximation
            yhat_asy(:, :, c) =  (D/2).^2 - 1/8 - sigma^2;                       % asymptotical inverse
            yhat_alg(:, :, c) =  (D/2).^2 - 3/8 - sigma^2;                       % algebraic inverse
        end
        
        
        PSNR_yhat   =  [PSNR_yhat csnr( y*255, yhat*255, 0, 0 )];
        SSIM_yhat   = [SSIM_yhat  cal_ssim( y*255, yhat*255, 0, 0 )];
        fprintf('%s : PSNR = %2.4f, SSIM = %2.4f \n', TT_im_dir(i).name, PSNR_yhat(i), SSIM_yhat(i) );
        PSNR_yhat_cfa   = [PSNR_yhat_cfa  csnr( y*255, yhat_cfa*255, 0, 0 )];
        SSIM_yhat_cfa   = [SSIM_yhat_cfa  cal_ssim( y*255, yhat_cfa*255, 0, 0 )];
        fprintf('%s : PSNR = %2.4f, SSIM = %2.4f \n', TT_im_dir(i).name, PSNR_yhat_cfa(i), SSIM_yhat_cfa(i) );
        PSNR_yhat_asy   = [PSNR_yhat_asy  csnr( y*255, yhat_asy*255, 0, 0 )];
        SSIM_yhat_asy   =  [SSIM_yhat_asy cal_ssim( y*255, yhat_asy*255, 0, 0 )];
        fprintf('%s : PSNR = %2.4f, SSIM = %2.4f \n', TT_im_dir(i).name, PSNR_yhat_asy(i), SSIM_yhat_asy(i) );
        PSNR_yhat_alg   = [PSNR_yhat_alg  csnr( y*255, yhat_alg*255, 0, 0 )];
        SSIM_yhat_alg   = [SSIM_yhat_alg  cal_ssim( y*255, yhat_alg*255, 0, 0 )];
        fprintf('%s : PSNR = %2.4f, SSIM = %2.4f \n', TT_im_dir(i).name, PSNR_yhat_alg(i), SSIM_yhat_alg(i) );
        
        %         imname = sprintf([method '_CC15_exact_alpha' num2str(alpha) '_' TT_im_dir(i).name]);
        %         imwrite(yhat, imname);
        %         imname = sprintf([method '_CC15_closed_alpha' num2str(alpha) '_' TT_im_dir(i).name]);
        %         imwrite(yhat_cfa, imname);
        %         imname = sprintf([method '_CC15_asymptotical_alpha' num2str(alpha) '_' TT_im_dir(i).name]);
        %         imwrite(yhat_asy, imname);
        imname = sprintf(['C:/Users/csjunxu/Desktop/CVPR2017/cc_Results/' method '/' method '_CC15_algebraic_alpha' num2str(alpha) '_' TT_im_dir(i).name]);
        imwrite(yhat_alg, imname);
    end
    mPSNR_yhat=mean(PSNR_yhat);
    mSSIM_yhat=mean(SSIM_yhat);
    fprintf('The average PSNR_yhat = %2.4f, SSIM_yhat = %2.4f. \n', mPSNR_yhat,mSSIM_yhat);
    
    mPSNR_yhat_cfa=mean(PSNR_yhat_cfa);
    mSSIM_yhat_cfa=mean(SSIM_yhat_cfa);
    fprintf('The average PSNR_yhat_cfa = %2.4f, SSIM_yhat_cfa = %2.4f. \n', mPSNR_yhat_cfa,mSSIM_yhat_cfa);
    
    mPSNR_yhat_asy=mean(PSNR_yhat_asy);
    mSSIM_yhat_asy=mean(SSIM_yhat_asy);
    fprintf('The average PSNR_yhat_asy = %2.4f, SSIM_yhat_asy = %2.4f. \n', mPSNR_yhat_asy,mSSIM_yhat_asy);
    
    mPSNR_yhat_alg=mean(PSNR_yhat_alg);
    mSSIM_yhat_alg=mean(SSIM_yhat_alg);
    fprintf('The average PSNR_yhat_alg = %2.4f, SSIM_yhat_alg = %2.4f. \n', mPSNR_yhat_alg,mSSIM_yhat_alg);
    
    name = sprintf(['C:/Users/csjunxu/Desktop/CVPR2017/cc_Results/' method '_CC' num2str(im_num) '_alpha' num2str(alpha) '.mat']);
    save(name,'PSNR_yhat','SSIM_yhat','mPSNR_yhat','mSSIM_yhat','PSNR_yhat_cfa','SSIM_yhat_cfa','mPSNR_yhat_cfa','mSSIM_yhat_cfa','PSNR_yhat_asy','SSIM_yhat_asy','mPSNR_yhat_asy','mSSIM_yhat_asy','PSNR_yhat_alg','SSIM_yhat_alg','mPSNR_yhat_alg','mSSIM_yhat_alg');
end




