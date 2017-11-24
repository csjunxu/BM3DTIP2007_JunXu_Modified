clear;

Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2018 Denoising\dnd_2017\images_srgb\';
fpath = fullfile(Original_image_dir, '*.mat');
im_dir  = dir(fpath);
im_num = length(im_dir);
load 'C:\Users\csjunxu\Desktop\CVPR2018 Denoising\dnd_2017\info.mat';

method = 'GATBM3D';
% write image directory
write_MAT_dir = ['C:/Users/csjunxu/Desktop/CVPR2018 Denoising/dnd_2017Results/'];
write_sRGB_dir = [write_MAT_dir method];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end

load 'C:/Users/csjunxu/Desktop/CVPR2017_Guided/PG-GMM_TrainingCode/PGGMM_RGB_6x6_3_win15_nlsp10_delta0.001_cls33.mat';
% dictionary and regularization Parameter
Par.D= GMM.D;
Par.S = GMM.S;
Par.step = 3;       % the step of two neighbor patches
Par.IteNum = 3;  % the iteration number
Par.ps = ps;        % patch size
Par.nlsp = nlsp;  % number of non-local patches
Par.win = win;    % size of window around the patch
for alpha = [1]
    PSNR_yhat   = [];
    SSIM_yhat   =  [];
    
    PSNR_yhat_cfa   =  [];
    SSIM_yhat_cfa   =  [];
    
    PSNR_yhat_asy   =  [];
    SSIM_yhat_asy   =   [];
    
    PSNR_yhat_alg   =  [];
    SSIM_yhat_alg   =  [];
    
    RunTime = [];
    for i = 1 %1:im_num
        Par.image = i;
        load(fullfile(Original_image_dir, im_dir(i).name));
        S = regexp(im_dir(i).name, '\.', 'split');
        [h,w,ch] = size(InoisySRGB);
        for j = 2 %1:size(info(1).boundingboxes,1)
            IMinname = [S{1} '_' num2str(j)];
            fprintf('%s: \n', IMinname);
            bb = info(i).boundingboxes(j,:);
            z = InoisySRGB(bb(1):bb(3), bb(2):bb(4),:);
            y = z;
            % mixed Poisson-Gaussian noise parameters
            yhat_alg  = zeros(size(z));
            % noise estimation
            for c = 1:ch
                % Gaussian component N(g,sigma^2)
                sigma = NoiseEstimation(z(:, :, c), 8);
                g = 0.0;
                
                %% Apply forward variance stabilizing transformation
                fz = GenAnscombe_forward(z(:, :, c), sigma, alpha, g); % Generalized Anscombe VST (J.L. Starck, F. Murtagh, and A. Bijaoui, Image  Processing  and  Data Analysis, Cambridge University Press, Cambridge, 1998)
                
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
            % denoising
            t1=clock;
            [IMout,Par]  =  Denoising_Guided_EI(Par,model);
            t2=clock;
            etime(t2,t1)
            alltime(Par.image)  = etime(t2, t1);
            %% output
            IMoutname = sprintf([write_sRGB_dir '/' method '_DND_alpha_' num2str(alpha) '_' IMinname '.png']);
            imwrite(yhat_alg, IMoutname);
        end
    end
end
