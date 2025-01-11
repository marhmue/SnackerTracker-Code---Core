function arrayOut = dataCompression(arrayIn,compressionFactor,bincont)
    % Where arrayIn is a vector, compressionFactor specifies the number of
    % data points being represented by a single output value, and bincont
    % specifies whether the input array contains binary (0) or continuous 
    % (1) data. First, determine the height of data columns in the 
    % compressed file as calculated by rounding down from the number of 
    % compressionFactor values which can be found within the height of the 
    % input array
    heightOut = floor(height(arrayIn)/compressionFactor);
    % Initialise output array
    arrayOut = zeros(heightOut,1);
    % Initialise counter variable for the index of arrayIn
    indexIn = 1;
    % Initialise variable for the running sum of arrayIn elements
    runSumIn = 0;
    % Calculate the mean of values spanned by compressionFactor 
    for c = 1:heightOut
        % Sum all input array values in the compressionFactor range
        for r = 1:compressionFactor
            runSumIn = runSumIn + arrayIn(indexIn);
            indexIn = indexIn + 1;
        end
        % Calculate the mean of this data range
        meanHere = runSumIn/compressionFactor;
        % Round, if a binary column
        if bincont == 0
            meanHere = round(meanHere);
        elseif bincont == 1
            meanHere = meanHere + 0;
        else
            fprintf("Error: invalid entry for binary/continuous data designation.")
            return
        end
        % Apply the mean to the compressed output array
        arrayOut(c,1) = meanHere;
        % Repeating for all elements, ending with any unused input array 
        % values left as remainders, after clearing necessary variables
        runSumIn = 0;
    end
end