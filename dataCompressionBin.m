function arrayOut = dataCompressionBin(arrayIn,secondsIn,secondsBin,binaryContinuous)
    % Where arrayIn is an input array, and secondsIn is a vector which 
    % MUST have units of seconds. secondsBin bins seconds represented by 
    % a single output value, and binaryContinuous specifies whether the 
    % input array contains binary (0) or continuous (1) data. After this 
    % function is called, and upon plotting, secondsIn should be replaced 
    % by an evenly-spaced array of second values between 0 and the 
    % specified end point, binned by the value represented by secondsBin.
    % First, determine the height of data columns in the compressed file
    heightOut = floor(floor(secondsIn(end))/secondsBin);
    % Initialise binned seconds array
    binnedSeconds = zeros(heightOut,1);
    % Initialise output array
    arrayOut = zeros(heightOut,1);
    % Calculate the mean of values within each secondsBin 
    for c = 1:heightOut
        binnedSeconds(c,1) = c*secondsBin;
        runSumIn = 0;
        numVal = 0;
        % For the first bin
        if c == 1
            for s = 1:height(secondsIn)
                if secondsIn(s,1) >= 0 && secondsIn(s,1) < binnedSeconds(c,1)
                    runSumIn = runSumIn + arrayIn(s,1);
                    numVal = numVal + 1;
                end
            end
            meanHere = runSumIn/numVal;
            % Round, if a binary column
            if binaryContinuous == 0
                meanHere = round(meanHere);
            elseif binaryContinuous == 1
                meanHere = meanHere + 0;
            else
                fprintf("Error: invalid entry for binary/continuous data designation.")
                return
            end
        else
            for s = 1:height(secondsIn)
                if secondsIn(s,1) >= binnedSeconds((c - 1),1) && secondsIn(s,1) < binnedSeconds(c,1)
                    runSumIn = runSumIn + arrayIn(s,1);
                    numVal = numVal + 1;
                end
            end
            meanHere = runSumIn/numVal;
            % Round, if a binary column
            if binaryContinuous == 0
                meanHere = round(meanHere);
            elseif binaryContinuous == 1
                meanHere = meanHere + 0;
            else
                fprintf("Error: invalid entry for binary/continuous data designation.")
                return
            end
        end
        arrayOut(c,1) = meanHere;
    end
end