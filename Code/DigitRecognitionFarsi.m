%% Persian Handwritten Digit Reader (Test File Parser)
% Author: AliAkbar Mohsennejad – Final Project (AI Course)
clc; clear; close all;

%% === [1] Initial Configuration ===
filename = 'Test 20000.cdb';  % Update path as needed

% Open file
fid = fopen(filename, 'rb');
if fid == -1
    error('File not found. Please check the path.');
end

%% === [2] Read Header Metadata ===
fread(fid, 1, 'uint16');   % Year
fread(fid, 1, 'uint8');    % Month
fread(fid, 1, 'uint8');    % Day

W = fread(fid, 1, 'uint8');       % Width
H = fread(fid, 1, 'uint8');       % Height
TotalRec = fread(fid, 1, 'uint32');  % Total records
LetterCount = fread(fid, 128, 'uint32');  % Label counts
imgType = fread(fid, 1, 'uint8');  % 0 = Binary, 1 = Grayscale

fread(fid, 256, 'int8');  % Description
fread(fid, 245, 'uint8'); % Reserved

normalSize = (W > 0) && (H > 0);

%% === [3] Initialize Data Structures ===
Data = cell(TotalRec, 1);        % Store images
Labels = zeros(TotalRec, 1);     % Store labels

%% === [4] Parse Records ===
for i = 1:TotalRec
    fread(fid, 1);                % Constant byte (expected to be 255)
    Labels(i) = fread(fid, 1);    % Class label
    
    % If size not specified globally, read it here
    if ~normalSize
        W = fread(fid, 1);
        H = fread(fid, 1);
    end

    fread(fid, 1, 'uint16');     % Unused

    % Initialize blank image
    Data{i} = uint8(zeros(H, W));

    % --- Binary image format ---
    if imgType == 0
        for y = 1:H
            bWhite = true;
            counter = 0;
            while counter < W
                WBcount = fread(fid, 1);
                for x = 1:WBcount
                    Data{i}(y, counter + x) = bWhite * 0 + ~bWhite * 255;
                end
                counter = counter + WBcount;
                bWhite = ~bWhite;
            end
        end
    % --- Grayscale image format ---
    else
        pixelData = fread(fid, W * H, 'uint8');
        Data{i} = transpose(reshape(pixelData, W, H));
    end
end
fclose(fid);

%% === [5] Display Label Counts ===
uniqueLabels = unique(Labels);
counts = histc(Labels, uniqueLabels);

fprintf('\n Sample count for each digit:\n');
for i = 1:length(uniqueLabels)
    fprintf('Digit %d: %d samples\n', uniqueLabels(i), counts(i));
end

%% === [6] Display One Sample from Each Digit ===
figure('Name', 'Sample Images from Test Dataset', 'NumberTitle', 'off');
for i = 1:length(uniqueLabels)
    idx = randsample(find(Labels == uniqueLabels(i)), 1);
    subplot(2, 5, i);
    imshow(Data{idx});
    title(sprintf('Digit %d', uniqueLabels(i)));
end
