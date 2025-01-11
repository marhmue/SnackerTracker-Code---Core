%{

SnackerTracker Bulk Sin Fitting
Molnar Lab 2024
Marissa Mueller

bulk_sin.m

%}

clear
% Retreive the parent directory for future navigation
prompt_folderLocation = "Enter the folder path where the " + ...
    "data table is located: ";
folderLocation = input(prompt_folderLocation,"s");
folderLocationChar = convertStringsToChars(folderLocation);
% Retreive the name of the input data sheet for analysis
prompt_dataFileName = "Enter the name of the input data " + ...
    "sheet for analysis: ";
dataFileName = input(prompt_dataFileName,"s");
dataFileNameChar = convertStringsToChars(dataFileName);
% Error-checking to ensure the folder and input sheet directory 
% locations suffice and that the excel data file is not duplicated 
% in the path specification
fileNameContainLength = length(dataFileNameChar) - 1;
fileNameIndexLength = length(dataFileNameChar) + 1;
% If the folder/file path is long enough to contain fileName
if length(folderLocationChar) > fileNameContainLength
    % If fileName is included in the user-defined path
    if convertCharsToStrings(folderLocationChar(( ...
            end-fileNameContainLength):end)) == dataFileName
        % Truncate excelFileName and convert data type
        folderLocationChar = folderLocationChar(1:( ...
            end-fileNameIndexLength));
        folderLocation = convertCharsToStrings(folderLocationChar);
        dataFileLocation = folderLocation;
        dataFileLocationChar = folderLocationChar;
    end
end
% If excelFileName was not included in the user-defined path
if convertCharsToStrings(folderLocationChar(( ...
        end-fileNameContainLength):end)) ~= dataFileName
    % The folder string is already defined, so just append file name
    dataFileLocation = folderLocation + "\" + dataFileName;
    dataFileLocationChar = convertStringsToChars( ...
        dataFileLocation);
end
% Extract data from the input excel sheet
% Add the skrtkdFileLocation folder to the working directory path
addpath(folderLocation,'-end');
fprintf("Importing data from ");
disp(dataFileLocation);
% Extract excelFileName.txt
dataImport = readcell(dataFileNameChar);
% Determine the number of files to be read
numFiles = width(dataImport) - 1;
% Determine the number of data points
numData = height(dataImport) - 2;
% Extract time series from the first column, which applies to all datasets
timeSeries = cell2mat(dataImport(3:end,1));
% Initialise data table to house calculated amplitudes and frequencies for
% all time series, where column 1 = mean amplitude, 2 = amplitude lower
% bound, 3 = amplitude upper bound, 4 = mean period, 5 = period lower
% bound, 6 = period upper bound, and 7 = R-square to indicate goodness of
% fit for the representative curve
outputData = zeros(numFiles,3);
% For each data column
for i = 1:numFiles
    % Extract current column
    dataHere = cell2mat(dataImport(3:end,(1 + i)));
    % Calculate the mean
    meanHere = mean(dataHere);
    % Perform y-shift to prepare for curveFitter
    dataHereShift = dataHere - meanHere;
    % Run the curve fitter
    curveFitter(timeSeries,dataHereShift)
    % Within curve fitter, select "Sum of Sin". Be sure to save a
    % screenshot of the fit of each curve for documentation purposes and
    % later reference if needed...
    % Prompt user to enter the amplitude determined by curve fitter,
    % including the upper and lower bounds (95% CI)
    prompt_amplitudeHere = "Enter the returned amplitude (a1): ";
    amplitudeHere = input(prompt_amplitudeHere);
    outputData(i,1) = 2*amplitudeHere;
    % Prompt user to enter the frequency determined by curve fitter,
    % again including the upper and lower bounds (95% CI)
    prompt_freqHere = "Enter the returned frequency (b1): ";
    freqHere = input(prompt_freqHere);
    % Calculate the period
    periodHere = 2*pi/freqHere;
    outputData(i,2) = periodHere;
    % Prompt the user to enter information regarding the goodness of fit
    % for the sin curve - an indication of how closely the model fits the
    % dataset
    prompt_rSquare = "Enter R-Square: ";
    rSquare = input(prompt_rSquare);
    outputData(i,3) = rSquare;
end
% Name each condition/file/replicate
names = strings(numFiles,1);
for i = 1:numFiles
    prompt_fileNameHere = "Enter the name of case " + num2str(i) + ": ";
    fileNameHere = input(prompt_fileNameHere,"s");
    names(i,1) = fileNameHere;
end
% Populate final output table
finalOutputTable = cell((numFiles + 1),4);
finalOutputTable(1,1) = cellstr("ID");
finalOutputTable(1,2) = cellstr("2*Amplitude");
finalOutputTable(1,3) = cellstr("Period");
finalOutputTable(1,4) = cellstr("R-Square");
% Populate with outputData
for i = 1:numFiles
    for j = 1:3
        finalOutputTable((i + 1),(j + 1)) = num2cell(outputData(i,j));
    end
    finalOutputTable(i + 1,1) = cellstr(names(i,1));
end
%%
% Save output table
% Define the location and name of the data output file
savePath = folderLocation + "\" + convertCharsToStrings( ...
    dataFileName) + "-Processed.csv";
% Save file. Re-run if you'd like to save numerous types of processed
% data, for example with and without compressed outputs
writecell(finalOutputTable,savePath)
% Code complete
fprintf("Code complete.\n");