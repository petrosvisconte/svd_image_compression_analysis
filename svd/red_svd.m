% Reduced SVD function
% k: vector of ranks to test, top k singular values
% num_samples: number of random images to sample from each dataset
function red_svd(k, num_samples)
    % Set random seed
    rng(441)    
    % Define dataset folders
    dataset_paths = { 'landscape/color/', 'butterfly/', 'baseball/' };

    % Loop over all datasets
    for d = 1:length(dataset_paths)
        folder = dataset_paths{d};
        files = dir(fullfile(folder, '*.jpg'));
        num_files = length(files);
        % Randomly sample indices from the dataset
        rand_idx = randperm(num_files, min(num_samples, num_files));
        fprintf('\n=== Dataset: %s ===\n', folder);
        % Loop over sampled images
        for f = rand_idx
            filename = fullfile(folder, files(f).name);
            orig = imread(filename);
            Im = double(orig);
            fprintf('\nImage: %s\n', files(f).name);
            % Loop over ranks
            for r = k
                Imapprox = zeros(size(Im));
                for i = 1:size(Im,3)
                    [U,S,V] = svd(Im(:,:,i));
                    Imapprox(:,:,i) = U(:,1:r)*S(1:r,1:r)*V(:,1:r)';
                end
                approx_uint8 = uint8(Imapprox);
                % Save reduced (compressed) image as a PNG
                outFile = sprintf('output/%s_rank%d.png', files(f).name(1:end-4), r);
                imwrite(approx_uint8, outFile);
                % Get the file size in KB
                fileInfo = dir(outFile);
                fileSizeKB = fileInfo.bytes / 1024;
                % Compute quality metrics
                mse_val = immse(approx_uint8, orig);
                psnr_val = psnr(approx_uint8, orig);
                % Print information
                fprintf('Rank %d: MSE=%.2f, PSNR=%.2f dB, PNG size=%.1f KB\n', ...
                    r, mse_val, psnr_val, fileSizeKB);
            end
        end
    end
end
