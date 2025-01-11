%{

SnackerTracker Data Processing
Molnar Lab 2023
Marissa Mueller

snackertracker.m 

%}

%{

Overview: 

This code imports SnackerTracker output files, filters recordings in nine 
steps according to user-specifications, then re-formats data for 
visualisation and analysis. These nine steps (line reference) include:

Step 1: raw data and switch assessment (210)
Step 2: crop specifications (470)
Step 3: mass filtering (931)
Step 4: plateau filter application (1359)
Step 5: interactions assessment and frequency analysis (2027)
Step 6: LDR filtering (2351)
Step 7: output summary (2541)
Step 8: cropping and alignment (2741)
Step 9: data compression (3261)

Code Requirements: 

SnackerTracker SD output .txt file name, directory location, and
user-inputted processing specifications

Export and Application:

Output files are saved in the parent folder as SKRTKR-Processed.csv. These
can be exported to a graphing program of choice for further visualisation 
and data analysis. Re-naming or moving this output file is recommended 
before processing other SnackerTracker datasets to avoid data overwrite.

%}

%% Establish working directories and select base variables

clear
% Define preset working directory; change data type for future navigation
parentfolderchar = pwd;
parentfolderstr = convertCharsToStrings(parentfolderchar);
fprintf("\n");
fprintf("SnackerTracker Data Processing");
fprintf("\n");
fprintf("\n");
% Prompt user for directory location
prompt_skrtkdFileLocation = "Please enter the folder path for SKRTKR.txt input files: ";
skrtkrFileLocation = input(prompt_skrtkdFileLocation,"s");
skrtkrFileLocationChar = convertStringsToChars(skrtkrFileLocation);
% Import SKRTKR.txt
fprintf("Processing directory information... ");
fprintf("\n");
% Extract all file names,  
skrtkrFileNames = dir([skrtkrFileLocationChar, '\*.txt']);
numSKRTKRFiles = length(skrtkrFileNames);

%% Repeating for each data file in the folder

% Iterating through for each input sheet
for s = 1:numSKRTKRFiles
%s = 2;
    % Initialise dummy variables
    inverseSwitch1 = "No";
    inverseSwitch2 = "No";
    % Initialise variables which will be included in the final output
    % parameter table. These will all be overwritten, with the exception 
    % of those initialised to 'N/A' under certain logic flows. Variables
    % are only initialised for the first file iteration such that, for
    % future iterations, the parameter value inputted for the previous
    % processed file will be returned.
    %if s == 2
    if s == 1
        Fs = 1;
        timeFormat = "d";
        massUnit = "g";
        truncateStart = "N";
        startPoint = 1;
        truncateEnd = "N";
        endPoint = 100;
        setTime = 32;
        origOrInvSwitch1 = "0";
        sw1FilterMass = "N";
        sw1FilterLDR = "N";
        origOrInvSwitch2 = "0";
        sw2FilterMass = "N";
        sw2FilterLDR = "N";
        binDuration = 1;
        doFileCompression = "N";
        compressSecondsFactor = "0";
        fileCompFactor = 1;
        bufferHere = 0.1;
        measureSpan = 30;
        window = 60;
        whichFilter = 6;
        shiftFilter = 1000;
        shiftTolerance = 0.99;
        applyPlateau = "Y";
        applyShift = "Y";
        applyShiftAndPlateau = "Y";
        intdervBuffer = 6000;
        fooddervBuffer = 6000;
        doFilterLight = "N";
        lightFilterType = "N/A";
        smoothBeforeBinary = "N/A";
        smoothLightWindow = "N/A";
        lightCutoff = 15;
    end
    if s == 1
        lightFilterTypeEx = "0";
        smoothBeforeBinaryEx = "200";
        smoothLightWindowEx = "200";
    else
        lightFilterTypeEx = lightFilterType;
        smoothBeforeBinaryEx = num2str(smoothBeforeBinary);
        smoothLightWindowEx = num2str(smoothLightWindow);
    end
    % Extract the name of the present SnackerTracker file
    fileName = skrtkrFileNames(s).name;
    fileNameChar = convertStringsToChars(fileName);
    fprintf("\n");
    fprintf("Part 1: Data Import for " + fileName + ":");
    fprintf("\n");
    % Error-checking to ensure folder and file directory locations suffice
    % and that the data file is not duplicated in the path specification
    fileNameContainLength = length(fileNameChar) - 1;
    fileNameIndexLength = length(fileNameChar) + 1;
    % If the folder/file path is long enough to contain fileName
    if length(skrtkrFileLocationChar) > fileNameContainLength
        % If fileName is included in the user-defined path
        if convertCharsToStrings(skrtkrFileLocationChar((end-fileNameContainLength):end)) == fileName
            % Truncate folder path name and convert data type
            skrtkrFolderChar = skrtkrFileLocationChar(1:(end-fileNameIndexLength));
            skrtkrFolderStr = convertCharsToStrings(skrtkrFolderChar);
            % skrtkrFileLocation does not need to be changed
        end
    end
    % If fileName was not included in the user-defined path
    if convertCharsToStrings(skrtkrFileLocationChar((end-fileNameContainLength):end)) ~= fileName
        % The folder string is already defined
        skrtkrFolderStr = skrtkrFileLocation;
        % Append fileName
        skrtkrFileLocationWithName = skrtkrFileLocation + "\" + fileName;
    end  
    % Specify datetime format
    datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss')
    % Add the skrtkdFileLocation folder to the working directory path
    addpath(skrtkrFolderStr,'-end');
    finaliseOutput = "N";
    while finaliseOutput == "N"
        clearvars -except timeLightOn timeLightOff yearStart monthStart dayStart startDate startTimeAbs howMany24H timeLightOnHourAndMin timeLightOffHourAndMin do24HTruncation doFileCompression fileCompFactor binDuration compressSecondsFactor applyShift applyShiftAndPlateau shiftFilter shiftTolerance parentfolderstr parentfolderchar s intdervBuffer fooddervBuffer lightFilterTypeEx smoothBeforeBinaryEx smoothLightWindowEx finaliseOutput smoothLightWindow skrtkrFileNames numSKRTKRFiles smoothBeforeBinary lightCutoff doFilterLight lightFilterType applyPlateau dervBuffer window whichFilter bufferHere measureSpan setTime origOrInvSwitch1 sw1FilterMass sw1FilterLDR origOrInvSwitch2 sw2FilterMass sw2FilterLDR truncateStart truncateEnd endPoint Fs timeFormat initialMass massUnit inverseSwitch1 inverseSwitch2 inaliseOutput skrtkrFileLocation skrtkrFileLocationWithName skrtkrFolderStr skrtkrFileLocationChar fileNameIndexLength fileNameContainLength fileName fileNameChar skrtkrFolderChar
        % Extract SKRTKR.txt
        skrtkrImport = readcell(fileNameChar);
        % Parse individual input columns
        dateInfo = skrtkrImport(2:height(skrtkrImport),1);
        timeInfo = skrtkrImport(2:height(skrtkrImport),2);
        s1Info = skrtkrImport(2:height(skrtkrImport),3);
        s2Info = skrtkrImport(2:height(skrtkrImport),4);
        massInfo = skrtkrImport(2:height(skrtkrImport),5);
        ldrInfo = skrtkrImport(2:height(skrtkrImport),6);
        fprintf("\n");
        fprintf("Part 2: Data Processing for " + fileName + ":");
        fprintf("\n");
        fprintf("\n");
        % Initialise intermediate and final output columns
        secondsOutCol = zeros(height(dateInfo),1);
        rawMass = zeros(height(dateInfo),1);
        ldrColumn = zeros(height(dateInfo),1);
        switch1Column = zeros(height(dateInfo),1);
        switch2Column = zeros(height(dateInfo),1);
        baseHour = 0;
        baseMinute = 0;        
        % Set the baseline (initial) date and time
        baseDayPlace = dateInfo(1);
        baseDay = baseDayPlace{1};
        baseTimePlace = timeInfo(1);
        baseTime = baseTimePlace{1};
        baseDateTime = baseDay + baseTime;
        % Other variables
        chipFilterDetails = "";
        shortDervCorrection = "N";
        for i = 1:height(timeInfo)
            % Set the start date and time
            currentDayPlace = dateInfo(i);
            currentDay = currentDayPlace{1};
            currentTimePlace = timeInfo(i);
            currentTime = currentTimePlace{1};
            currentDateTime = currentDay + currentTime;
            % Calculate the time elapsed, in seconds, and save to the
            % intermediate/final output column
            secondsOutCol(i) = seconds(currentDateTime - baseDateTime);
            % For the event marker (switch 1) column
            switch1Column(i) = cell2mat(s1Info(i));
            % For the wireless connection (switch 2) column
            switch2Column(i) = cell2mat(s2Info(i));
            % For the mass column
            rawMass(i) = cell2mat(massInfo(i));
            % For the LDR readings column
            ldrColumn(i) = cell2mat(ldrInfo(i));
        end
        % Determine the mean sampling frequency
        Fs = secondsOutCol(end)/length(secondsOutCol);

        % Step 1: raw data and switch assessment

        % Only retreive time formatting information for the first file as
        % well as mass unit. Other files will be formatted the same
        if s == 1   
            prompt_startDate = "Enter the date (YYYY/MM/DD) on which data collection began: ";
            startDate = input(prompt_startDate,"s");
            yearStart = extractBetween(convertCharsToStrings(startDate),1,4);
            yearStart = str2double(yearStart);
            monthStartChar = convertStringsToChars(extractBetween(convertCharsToStrings(startDate),6,7));
            if monthStartChar(1) == '0'
                monthStart = convertCharsToStrings(monthStartChar(2));
            else
                monthStart = convertCharsToStrings(monthStartChar);
            end
            monthStart = str2double(monthStart);
            dayStartChar = convertStringsToChars(extractBetween(convertCharsToStrings(startDate),9,10));
            if dayStartChar(1) == '0'
                dayStart = convertCharsToStrings(dayStartChar(2));
            else
                dayStart = convertCharsToStrings(dayStartChar);
            end
            dayStart = str2double(dayStart);
            % Prompt user for the format of timestamped data 
            % (i.e., w, d, h, m, or s)
            fprintf("How would you like to report time?\n");
            prompt_timeFormat = "Enter 'w' for 'weeks', or 'd' " + "for 'days', 'h' for 'hours', 'm' for 'minutes', " + "or 's' for 'seconds (e.g., " + timeFormat + ")': ";
            timeFormat = input(prompt_timeFormat,"s");
            % Error-checking for a valid timeFormat entry
            while timeFormat ~= "w" && timeFormat ~= "d" && timeFormat ~= "h" && timeFormat ~= "m" && timeFormat ~= "s"
                prompt_invalidTime = "Invalid entry. Please enter 'w' for 'weeks', or 'd' for 'days', 'h' for 'hours', 'm' for 'minutes', or 's' for 'seconds' (e.g., " + timeFormat + "): ";
                timeFormat = input(prompt_invalidTime, "s");
            end
            prompt_massUnit = "Please enter the unit of mass (e.g., " + massUnit + "): ";
            massUnit = input(prompt_massUnit,"s");
            % Provide information regarding the light-dark cycle
            fprintf("Please provide information regarding the light-dark cycle, whether actual or trained prior to constant darkness.\n");
            prompt_timeLightOn = "Please enter the time at which lights turn on (24-h format, e.g. 07:00 for 7:00 AM: ";
            timeLightOn = input(prompt_timeLightOn,"s");
            timeLightOnHourChar = convertStringsToChars(extractBetween(convertCharsToStrings(timeLightOn),1,2));
            if timeLightOnHourChar(1) == '0'
                timeLightOnHour = str2double(convertCharsToStrings(timeLightOnHourChar(2)));
            else
                timeLightOnHour = str2double(convertCharsToStrings(timeLightOnHourChar));
            end
            timeLightOnMinChar = convertStringsToChars(extractBetween(convertCharsToStrings(timeLightOn),4,5));
            if timeLightOnMinChar(1) == '0'
                timeLightOnMin = str2double(convertCharsToStrings(timeLightOnMinChar(2)));
            else
                timeLightOnMin = str2double(convertCharsToStrings(timeLightOnMinChar));
            end
            timeLightOnHourAndMin = timeLightOnHour + timeLightOnMin/60;
            prompt_timeLightOff = "Please enter the time at which lights turn off (24-h format, e.g. 19:00 for 7:00 PM): ";
            timeLightOff = input(prompt_timeLightOff,"s");
            timeLightOffHourChar = convertStringsToChars(extractBetween(convertCharsToStrings(timeLightOff),1,2));
            if timeLightOffHourChar(1) == '0'
                timeLightOffHour = str2double(convertCharsToStrings(timeLightOffHourChar(2)));
            else
                timeLightOffHour = str2double(convertCharsToStrings(timeLightOffHourChar));
            end
            timeLightOffMinChar = convertStringsToChars(extractBetween(convertCharsToStrings(timeLightOff),4,5));
            if timeLightOffMinChar(1) == '0'
                timeLightOffMin = str2double(convertCharsToStrings(timeLightOffMinChar(2)));
            else
                timeLightOffMin = str2double(convertCharsToStrings(timeLightOffMinChar));
            end
            timeLightOffHourAndMin = timeLightOffHour + timeLightOffMin/60;
        end
        % Prompt user for the time at which data recordings began
        prompt_timeStart = "Please enter the time at which recordings began (24-hour format, e.g. 09:08 for 9:08 AM, or 15:31 for 3:31 PM): ";
        timeStart = input(prompt_timeStart,"s");
        startHourChar = convertStringsToChars(extractBetween(convertCharsToStrings(timeStart),1,2));
        if startHourChar(1) == '0'
            startHour = str2double(convertCharsToStrings(startHourChar(2)));
        else
            startHour = str2double(convertCharsToStrings(startHourChar));
        end
        startMinChar = convertStringsToChars(extractBetween(convertCharsToStrings(timeStart),4,5));
        if startMinChar(1) == '0'
            startMin = str2double(convertCharsToStrings(startMinChar(2)));
        else
            startMin = str2double(convertCharsToStrings(startMinChar));
        end
        startHourAndMin = startHour + startMin/60;
        secStart = 0;
        datetimeRecordingStart = datetime(yearStart,monthStart,dayStart,startHour,startMin,secStart);
        % Create light paradigm array
        lightsOnOff = zeros(height(secondsOutCol),1);
        % Convert secondsOutCol to an hourly array, such that light
        % paradigms can be applied
        hoursOutCol = secondsOutCol./(60*60);
        % Create a "24-hour" time array to place absolute time difference
        % in the context of a 24 hour day
        time24H = hoursOutCol + startHourAndMin;
        % Set lightsOnOff to 1 where the light is on, and 0 if off
        for t = 1:height(secondsOutCol)
            if timeLightOnHourAndMin < timeLightOffHourAndMin
                % If the 24-h time at which lights turn on is before that 
                % at which lights turn off 
                lr = 1;
                if rem(time24H(t,1),24) < timeLightOnHourAndMin 
                    lightsOnOff(t,1) = 0;    
                elseif rem(time24H(t,1),24) > timeLightOnHourAndMin && rem(time24H(t,1),24) < timeLightOffHourAndMin
                    lightsOnOff(t,1) = 1; 
                elseif rem(time24H(t,1),24) > timeLightOffHourAndMin
                    lightsOnOff(t,1) = 0; 
                end
            elseif timeLightOnHourAndMin > timeLightOffHourAndMin
                % If the 24-h time at which lights turn on is after that 
                % at which lights turn off 
                if rem(time24H(t,1),24) < timeLightOffHourAndMin 
                    lightsOnOff(t,1) = 1;    
                elseif rem(time24H(t,1),24) > timeLightOffHourAndMin && rem(time24H(t,1),24) < timeLightOnHourAndMin
                    lightsOnOff(t,1) = 0; 
                elseif rem(time24H(t,1),24) > timeLightOnHourAndMin
                    lightsOnOff(t,1) = 1; 
                end
            elseif timeLightOnHourAndMin == timeLightOffHourAndMin && timeLightOnHourAndMin == 0
                lightsOnOff(t,1) = 0; 
            elseif timeLightOnHourAndMin == timeLightOffHourAndMin && timeLightOnHourAndMin == 24
                lightsOnOff(t,1) = 1;
            end
        end
        % Re-format time-stamped data
        timeValues = zeros(height(timeInfo),1);
        if timeFormat == "w"
            timeValues = secondsOutCol./(60*60*24*7);
            timeUnit = "Weeks";
        elseif timeFormat == "d"
            timeValues = secondsOutCol./(60*60*24);
            timeUnit = "Days";
        elseif timeFormat == "h"
            timeValues = secondsOutCol./(60*60);
            timeUnit = "h";
        elseif timeFormat == "m"
            timeValues = secondsOutCol./(60);
            timeUnit = "min";
        elseif timeFormat == "s"
            timeValues = secondsOutCol;
            timeUnit = "s";
        end   
        % Create initial startPoint and endPoint
        startPoint = 1;
        endPoint = height(secondsOutCol);
        % Create an inverse-switch status for switches 1 and 2
        inverseSwitch1Column = zeros(height(timeInfo),1);
        for r = 1:height(timeInfo)
            if switch1Column(r) == 0
                inverseSwitch1Column(r) = 1;
            elseif switch1Column(r) == 1
                inverseSwitch1Column(r) = 0;
            end
        end
        inverseSwitch2Column = zeros(height(timeInfo),1);
        for r = 1:height(timeInfo)
            if switch2Column(r) == 0
                inverseSwitch2Column(r) = 1;
            elseif switch2Column(r) == 1
                inverseSwitch2Column(r) = 0;
            end
        end
        % Plot the status of switches 1 and 2 over time, alongside mass  
        % and LDR data to 1) select the appropriate switch status 
        % (regular or inverted) and whether either is to be used to
        % filter out data
        switch1ColumnPlot = switch1Column.*100;
        switch2ColumnPlot = switch2Column.*100;
        inverseSwitch1ColumnPlot = inverseSwitch1Column.*100;
        inverseSwitch2ColumnPlot = inverseSwitch2Column.*100;
        lightColumnPlot = lightsOnOff.*100;
        % Determine ylimLight as 1.3* the maximum light reading
        ylimLight = max(ldrColumn)*1.3;

        % Plot raw data
    
        figure(1)
    
        subplot(2,2,1)
        yyaxis left
        plot(timeValues,rawMass)
        hold on
        area(timeValues,switch1ColumnPlot,'LineStyle','none',['' 'FaceColor'],'black','FaceAlpha',0.3)
        area(timeValues,lightColumnPlot,'LineStyle','none',['' 'FaceColor'],'yellow','FaceAlpha',0.3)
        hold off
        ylim([0 100])
        ylabel("Mass(g)")
        yyaxis right
        plot(timeValues,ldrColumn)
        ylabel("Light (LDR) Recording")
        xlim([0 timeValues(end)])
        ylim([0 100])
        xlabel("Time (" + timeUnit + ")")
        legend("Mass Recording","Switch 1 Status","Scheduled Light","Light (LDR) Recording",'Location','southoutside')
        title('Switch 1 Status (Mass and LDR Data Overlaid)')
        lgd.FontSize = 1;
    
        subplot(2,2,2) 
        yyaxis left  
        plot(timeValues,rawMass)
        hold on
        area(timeValues,switch2ColumnPlot,'LineStyle','none',['' 'FaceColor'],'black','FaceAlpha',0.3)
        area(timeValues,lightColumnPlot,'LineStyle','none',['' 'FaceColor'],'yellow','FaceAlpha',0.3)
        hold off
        ylim([0 100])
        ylabel("Mass(g)")
        yyaxis right
        plot(timeValues,ldrColumn)
        ylabel("Light (LDR) Recording")
        ylim([0 100])
        xlabel("Time (" + timeUnit + ")")
        legend("Mass Recording","Switch 2 Status","Scheduled Light","Light (LDR) Recording",'Location','southoutside')
        title('Switch 2 Status (Mass and LDR Data Overlaid)')
        xlim([0 timeValues(end)])
        lgd.FontSize = 1;
    
        subplot(2,2,3) 
        yyaxis left
        plot(timeValues,rawMass)
        hold on
        area(timeValues,inverseSwitch1ColumnPlot,'LineStyle',['' 'none'],'FaceColor','black','FaceAlpha',0.3)
        area(timeValues,lightColumnPlot,'LineStyle','none',['' 'FaceColor'],'yellow','FaceAlpha',0.3)
        hold off
        ylim([0 100])
        ylabel("Mass(g)")
        yyaxis right
        plot(timeValues,ldrColumn)
        ylabel("Light (LDR) Recording")
        ylim([0 100])
        xlabel("Time (" + timeUnit + ")")
        legend("Mass Recording","Inverse Switch 1 Status","Scheduled Light","Light (LDR) Recording",['Location' ''],'southoutside')
        title('Inverse Switch 1 Status (Mass and LDR Data Overlaid)')
        xlim([0 timeValues(end)])
        lgd.FontSize = 1;
    
        subplot(2,2,4)
        yyaxis left
        plot(timeValues,rawMass)
        hold on
        area(timeValues,inverseSwitch2ColumnPlot,'LineStyle',['' 'none'],'FaceColor','black','FaceAlpha',0.3)
        area(timeValues,lightColumnPlot,'LineStyle','none',['' 'FaceColor'],'yellow','FaceAlpha',0.3)
        hold off
        ylim([0 100])
        ylabel("Mass(g)")
        yyaxis right
        plot(timeValues,ldrColumn)
        ylabel("Light (LDR) Recording")
        ylim([0 100])
        xlabel("Time (" + timeUnit + ")")
        legend("Mass Recording","Inverse Switch 2 Status","" + "Scheduled Light","Light (LDR) Recording",['Location' ''],'southoutside')
        title('Inverse Switch 2 Status (Mass and LDR Data Overlaid)')
        xlim([0 timeValues(end)])
        lgd.FontSize = 1;

        % Enlarge figure to full screen.
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
        % Remove tool bars and pulldown menus
        set(gcf, 'Toolbar', 'none', 'Menu', 'none');
    
        figure1 = gcf;

        % Step 2: crop specifications

        % Exclude measurements at the beginning of the recording timeframe
        truncateStart = "Y";
        % Exclude measurements at the end of the recording timeframe
        truncateEnd = "Y";
        % Error-checking for a valid entry
        do24HStart = 1;
        do24HEnd = height(timeValues);
        % Enter information regarding 24h data file truncation
        prompt_do24HTruncation = "Would you like to apply 24-hour cropping? Enter 'Y' if 'Yes' and 'N' if 'No': ";
        do24HTruncation = input(prompt_do24HTruncation,"s");
        % Error-checking for a valid entry
        do24HTruncation = skrtkr_isentryerror("Y","" + "N",do24HTruncation);
        % If 24-hour truncation is to be performed
        if do24HTruncation == "Y"
            prompt_howMany24H = "How many 24-hour periods? Enter an integer value: ";
            howMany24H = input(prompt_howMany24H);
            % Immediately exit the script if the current data file does 
            % not contain 24 hours of data values
            % Calculate the total time in hours to later check duration
            totalTimeHours = secondsOutCol(end)/(60*60);
            while totalTimeHours < 24*howMany24H
                fprintf("Error: this data file contains less than the specified 24-hour recorded data timeframes.\n");
                prompt_reset24 = "Enter '2' to switch to non-24h truncation, '1' to re-enter the number of 24-hour periods, or '0' to exit program: ";
                reset24 = input(prompt_reset24,"s");
                % Error-checking for a valid entry
                reset24 = skrtkr_isentryerror("1","0",reset24);
                if reset24 == "2"
                    howMany24H = 0;
                    do24HTruncation = "N";
                elseif reset24 == "1"
                    howMany24H = input(prompt_howMany24H);
                elseif reset24 == "0"
                    fprintf("Insufficient data length. Exiting program.\n");
                    return
                end
            end
        end
        % Set start and end point values 
        startPointX = timeValues(1);
        endPointX = timeValues(end);
        startPointPos = 1;
        endPointPos = height(timeValues);
        if do24HTruncation == "Y" || truncateStart == "Y" || truncateEnd == "Y"
            truncateOK = "N";
            while truncateOK == "N"
                % If 24-hour truncation will be applied
                if do24HTruncation == "Y"
                    goodLength = "N";
                    skipThis = "N";
                    while goodLength == "N"
                        % Ask whether scheduled light status should be 
                        % used to govern 24-hour truncation
                        prompt_lightFor24HCrop = "Will the scheduled light status be used to dictate 24-hour cropping? Enter 'Y' for 'Yes' or 'N' for 'No': ";
                        lightFor24HCrop = input(prompt_lightFor24HCrop,"s");
                        % Error-checking for a valid entry
                        lightFor24HCrop = skrtkr_isentryerror("Y","N",lightFor24HCrop);
                        % If yes
                        if lightFor24HCrop == "Y"
                            % Ask whether cropping should begin when 
                            % lights turn ON or OFF
                            prompt_lightFor24HCropONOFF = "Would you like data to begin when lights turn ON (ZT) or OFF? Enter '1' for 'ON' or '0' for 'OFF' (ideally '1'): ";
                            lightFor24HCropONOFF = input(prompt_lightFor24HCropONOFF,"s");
                            % Error-checking for a valid entry
                            lightFor24HCropONOFF = skrtkr_isentryerror("1","0",lightFor24HCropONOFF);
                            alignLight = "Y";
                        end
                        if lightFor24HCrop == "N"
                            % Determine and validate the starting data 
                            % value
                            prompt_do24HStart = "For 24-h truncation, please enter the starting data value (ignoring any cropping): ";
                            do24HStart = input(prompt_do24HStart);
                            % Determine the corresponding time value
                            startTime24HTrunc = timeValues(do24HStart);
                            % Determine the time value which would be 
                            % 24*howMany24H hours later
                            if timeFormat == "w"
                                endTime24HTrunc = startTime24HTrunc + (1/7)*howMany24H;
                            elseif timeFormat == "d"
                                endTime24HTrunc = startTime24HTrunc + 1*howMany24H;
                            elseif timeFormat == "h"
                                endTime24HTrunc = startTime24HTrunc + 24*howMany24H;
                            elseif timeFormat == "m"
                                endTime24HTrunc = startTime24HTrunc + (24*60)*howMany24H;
                            elseif timeFormat == "s"
                                endTime24HTrunc = startTime24HTrunc + (24*60*60)*howMany24H;
                            end
                            if endTime24HTrunc > timeValues(end)
                                fprintf("This dataset is not long enough to contain a full set of 24-hour timeframes.\n");
                                fprintf("It may suffice, however, if a custom start point is defined, followed by light alignment.\n");
                                prompt_retryCropping = "Enter '1' to try with a different start point, or '0' to exit this program: ";
                                retryCropping = input(prompt_retryCropping,"s");
                                % Error-checking for a valid entry
                                retryCropping = skrtkr_isentryerror("1","0",retryCropping);
                                if retryCropping == "1"
                                    skipThis = "Y";
                                elseif retryCropping == "0"
                                    fprintf("Exiting program.\n");
                                    return
                                end
                            else
                                goodLength = "Y";
                            end
                            if skipThis ~= "Y"
                                % Iterate through timeValues to find the 
                                % location of the data point which just 
                                % exceeds this 24-hour end time
                                checker24End = 0;
                                do24HEnd = height(timeValues);
                                for v = 1:height(timeValues)
                                    if timeValues(v) >= endTime24HTrunc && checker24End == 0
                                        do24HEnd = v;
                                        checker24End = 1;
                                    end
                                end
                                % Determine how many data points to keep
                                numDataKeep24H = do24HEnd - do24HStart;
                                % Determine the latest possible starting 
                                % value which enables 24-h truncation
                                lastPossible = height(timeValues) - numDataKeep24H - 1;
                                while do24HStart < 1 || do24HStart > height(timeValues) || do24HStart > lastPossible
                                    fprintf("Invalid entry: Must be between 1 and " + num2str(lastPossible) + ".\n");
                                    do24HStart = input(prompt_do24HStart);
                                end
                                prompt_alignLight = "Would you like to shift and align 24-hour outputs such that they begin with light/dark onset? Enter 'Y' if 'Yes', or 'N' if 'No': ";
                                alignLight = input(prompt_alignLight,"s");
                                % Error-checking for a valid entry
                                alignLight = skrtkr_isentryerror("Y","N",alignLight);
                                % Ask whether cropping should begin 
                                % when lights turn ON or OFF
                                if alignLight == "Y"
                                    prompt_lightFor24HCropONOFF = "Would you like data to begin when lights turn ON (ZT) or OFF? Enter '1' for 'ON' or '0' for 'OFF' (ideally '1'): ";
                                    lightFor24HCropONOFF = input(prompt_lightFor24HCropONOFF,"s");
                                    % Error-checking for a valid entry
                                    lightFor24HCropONOFF = skrtkr_isentryerror("1","0",lightFor24HCropONOFF);
                                    lightAlignFor24HCropONOFF = lightFor24HCropONOFF;
                                end
                            end
                        elseif lightFor24HCrop == "Y"
                            indexFound = 0;
                            % If 24-hour light status is to be used to 
                            % truncate data recordings, iterate through 
                            % the dataset to find the first instance of 
                            % the light turning ON or OFF according to 
                            % lightFor24HCropONOFF
                            for u = 1:length(lightsOnOff)
                                % Find first instance of lights turning ON
                                if lightFor24HCropONOFF == "1"
                                    if u ~= 1 && indexFound == 0
                                        if lightsOnOff(u - 1) == 0 && lightsOnOff(u) == 1
                                            % Record the index
                                            do24HStart = u;
                                            % Determine the corresponding 
                                            % time value
                                            startTime24HTrunc = timeValues(do24HStart);
                                            % Determine the time value 
                                            % which would be howMany24H 
                                            % 24-hour periods later
                                            if timeFormat == "w"
                                                endTime24HTrunc = startTime24HTrunc + (1/7)*howMany24H;
                                            elseif timeFormat == "d"
                                                endTime24HTrunc = startTime24HTrunc + 1*howMany24H;
                                            elseif timeFormat == "h"
                                                endTime24HTrunc = startTime24HTrunc + 24*howMany24H;
                                            elseif timeFormat == "m"
                                                endTime24HTrunc = startTime24HTrunc + (24*60)*howMany24H;
                                            elseif timeFormat == "s"
                                                endTime24HTrunc = startTime24HTrunc + (24*60*60)*howMany24H;
                                            end
                                            if endTime24HTrunc > timeValues(end)
                                                fprintf("This dataset is not long enough to contain a full set of 24-hour timeframes.\n");
                                                fprintf("It may suffice, however, if a custom start point is defined, followed by light alignment.\n");
                                                prompt_retryCropping = "Enter '1' try with a different start point, or '0' to exit this program: ";
                                                retryCropping = input(prompt_retryCropping,"s");
                                                % Error-checking 
                                                retryCropping = skrtkr_isentryerror("1","0",retryCropping);
                                                if retryCropping == "1"
                                                    skipThis = "Y";
                                                elseif retryCropping == "0"
                                                    fprintf("Exiting program.\n");
                                                    return
                                                end
                                            else
                                                goodLength = "Y";
                                            end
                                            if skipThis ~= "Y"
                                                % Iterate through 
                                                % timeValues to find the 
                                                % location of the data
                                                % point which just exceeds
                                                % the 24-hour end time
                                                checker24End = 0;
                                                do24HEnd = height(timeValues);
                                                for v = 1:height(timeValues)
                                                    if timeValues(v) >= endTime24HTrunc && checker24End == 0
                                                        do24HEnd = v;
                                                        checker24End = 1;
                                                    end
                                                end
                                                % Determine the number of 
                                                % data points to keep
                                                numDataKeep24H = do24HEnd - do24HStart;
                                                indexFound = 1;
                                            end
                                        end
                                    end
                                % Find the first instance of lights 
                                % turning OFF
                                elseif lightFor24HCropONOFF == "0"
                                    if skipThis ~= "Y"
                                        if u ~= 1 && indexFound == 0
                                            if lightsOnOff(u - 1) == 1 && lightsOnOff(u) == 0
                                                % Record the index
                                                do24HStart = u;
                                                % Determine the 
                                                % corresponding time value
                                                startTime24HTrunc = timeValues(do24HStart);
                                                % Determine the time value 
                                                % which would be 
                                                % howMany24H 24-hour 
                                                % periods later
                                                if timeFormat == "w"
                                                    endTime24HTrunc = startTime24HTrunc + (1/7)*howMany24H;
                                                elseif timeFormat == "d"
                                                    endTime24HTrunc = startTime24HTrunc + 1*howMany24H;
                                                elseif timeFormat == "h"
                                                    endTime24HTrunc = startTime24HTrunc + 24*howMany24H;
                                                elseif timeFormat == "m"
                                                    endTime24HTrunc = startTime24HTrunc + (24*60)*howMany24H;
                                                elseif timeFormat == "s"
                                                    endTime24HTrunc = startTime24HTrunc + (24*60*60)*howMany24H;
                                                end
                                                if endTime24HTrunc > timeValues(end)
                                                    fprintf("This dataset is not long enough to contain a full set of 24-hour timeframes.\n");
                                                    fprintf("It may suffice, however, if a custom start point is defined, followed by light alignment.\n");
                                                    prompt_retryCropping = "Enter '1' try with a different start point, or '0' to exit this program: ";
                                                    retryCropping = input(prompt_retryCropping,"s");
                                                    % Error-checking for a 
                                                    % valid entry
                                                    retryCropping = skrtkr_isentryerror("1","0",retryCropping);
                                                    if retryCropping == "1"
                                                        skipThis = "Y";
                                                    elseif retryCropping == "0"
                                                        fprintf("Exiting program.\n");
                                                        return
                                                    end
                                                else
                                                    goodLength = "Y";
                                                end
                                                if skipThis ~= "Y"
                                                    % Iterate through 
                                                    % timeValues to find 
                                                    % the location of the 
                                                    % data point which 
                                                    % just exceeds this 
                                                    % 24-hour end time
                                                    checker24End = 0;
                                                    do24HEnd = height(timeValues);
                                                    for v = 1:height(timeValues)
                                                        if timeValues(v) >= endTime24HTrunc && checker24End == 0
                                                            do24HEnd = v;
                                                            checker24End = 1;
                                                        end
                                                    end
                                                    % Determine the number 
                                                    % of points to keep
                                                    numDataKeep24H = do24HEnd - do24HStart;
                                                    indexFound = 1;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if skipThis ~= "Y"
                                if alignLight == "Y"
                                    lightAlignFor24HCropONOFF = lightFor24HCropONOFF;
                                end
                            end
                        end
                    end
                end
                if truncateStart == "Y"
                    % Remove measurements before truncateStart
                    prompt_startPoint = "Please specify how many measurement points should be truncated from the start of recordings: ";
                    startPoint = input(prompt_startPoint);
                    startPointPos = startPoint;
                    startPointX = timeValues(startPoint);
                    if do24HTruncation == "Y"
                        startPointPos = do24HStart;
                        while startPoint > do24HStart
                            fprintf("Error: this truncation value cannot exceed the 24-h start point (" + num2str(do24HStart) + ").\n");
                            startPoint = input(prompt_startPoint);
                        end
                    end
                end
                if truncateEnd == "Y"
                    % Remove measurements after truncateEnd
                    prompt_endPoint = "Please specify how many measurement points should be truncated from the end of recordings: ";
                    endPoint = input(prompt_endPoint);
                    endPointPos = endPoint;
                    endPointX = timeValues(height(timeValues) - endPoint);
                    % Determine the maximum number of points which can be
                    % truncated from the end of recordings and which
                    % maintain the possible 24-hour truncation window
                    maxTrunc = height(timeValues) - do24HEnd - 2;
                    if do24HTruncation == "Y"
                        endPointPos = do24HEnd;
                        while endPoint > maxTrunc
                            fprintf("Error: this truncation value cannot compromise the 24-h end point (must be less than " + num2str(maxTrunc) + ").\n");
                            endPoint = input(prompt_endPoint);
                            endPointPos = endPoint;
                            endPointX = timeValues(height(timeValues) - endPoint);
                        end
                    end
                end
        
                % Plot raw mass and LDR data with lines denoting start and 
                % end cutoff points designated by the user
            
                figure(2)
            
                subplot(2,1,1) 
                plot(timeValues,rawMass)
                hold on
                area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
                hold off
                axis tight
                xlabel("Time (" + timeUnit + ")")
                ylabel("Mass (" + massUnit + ")")
                title('Mass Readings: Cropping Options')
                xline([startPointX endPointX],'-r',{['Start' ''],'End'})
                xline([timeValues(do24HStart) timeValues(do24HEnd)],'-b',{['24-h Start' ''],'24-h End'})
                ylim([0 100])
                xlim([0 timeValues(end)])
                lgd.FontSize = 1;
            
                subplot(2,1,2) 
                plot(timeValues,ldrColumn)
                hold on
                area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
                hold off
                axis tight
                xlabel("Time (" + timeUnit + ")")
                ylabel("Light (LDR) Reading")
                title('Light (LDR) Readings: Cropping Options')
                xline([startPointX endPointX],'-r',{['Start' ''],'End'})
                xline([timeValues(do24HStart) timeValues(do24HEnd)],'-b',{['24-h Start' ''],'24-h End'})
                ylim([0 100])
                xlim([0 timeValues(end)])
                lgd.FontSize = 1;

                % Enlarge figure to full screen.
                set(gcf, 'Units', 'Normalized', ['OuterPosition' ''], [0 0 1 1]);
                % Remove the tool bar and pulldown menus
                set(gcf, 'Toolbar', 'none', 'Menu', 'none');
    
                figure2 = gcf;
        
                % Ask whether the user is satisfied with the cutoff points
                fprintf("Are these cutoff points satisfactory?\n");
                prompt_truncateOK = "Enter 'Y' if 'Yes', or 'N' if 'No' to adjust cutoff parameters: ";
                truncateOK = input(prompt_truncateOK,"s");
                % Error-checking for a valid entry
                truncateOK = skrtkr_isentryerror("Y","N",truncateOK);
            end
            absoluteSecondsFromStart = secondsOutCol(do24HStart);
            absCropStartPointX = startPointX;
            absCropEndPointX = endPointX;
            abs24HStart = do24HStart;
            abs24HEnd = do24HEnd;
            % Apply truncation to all important data columns
            if truncateStart == "Y"
                % Truncate startPoint values
                secondsOutCol = secondsOutCol((startPoint):end,:);
                hoursOutCol = hoursOutCol((startPoint):end,:);
                timeValues = timeValues((startPoint):end,:);
                rawMass = rawMass((startPoint):end,:);
                ldrColumn = ldrColumn((startPoint):end,:);
                switch1Column = switch1Column((startPoint):end,:);
                switch2Column = switch2Column((startPoint):end,:);
                inverseSwitch1Column = inverseSwitch1Column((startPoint):end,:);
                inverseSwitch2Column = inverseSwitch2Column((startPoint):end,:);
                lightsOnOff = lightsOnOff((startPoint):end,:);
                lightColumnPlot = lightColumnPlot((startPoint):end,:);
                do24HStart = do24HStart - startPoint;
                do24HEnd = do24HEnd - startPoint;
                startPointPos = do24HStart;
                endPointPos = do24HEnd;
            end
            currentHeight = height(secondsOutCol);
            if truncateEnd == "Y"
                % Truncate endPoint values
                secondsOutCol = secondsOutCol(1:(currentHeight - endPoint),:);
                hoursOutCol = hoursOutCol(1:(currentHeight - endPoint),:);
                timeValues = timeValues(1:(currentHeight - endPoint),:);
                rawMass = rawMass(1:(currentHeight - endPoint),:);
                ldrColumn = ldrColumn(1:(currentHeight - endPoint),:);
                switch1Column = switch1Column(1:(currentHeight - endPoint),:);
                switch2Column = switch2Column(1:(currentHeight - endPoint),:);
                inverseSwitch1Column = inverseSwitch1Column(1:(currentHeight - endPoint),:);
                inverseSwitch2Column = inverseSwitch2Column(1:(currentHeight - endPoint),:);
                lightsOnOff = lightsOnOff(1:(currentHeight - endPoint),:);
                lightColumnPlot = lightColumnPlot(1:(currentHeight - endPoint),:);
            end
        % If no cropping is needed
        else
            figure(2)
            
            subplot(2,1,1) 
            plot(timeValues,rawMass)
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            title('Mass Readings: Cropping Options')
            xline([1 currentHeight],'-r',{['Start Point' ''],'End Point'})
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['24-h Start' ''],'24-h End'})
            ylim([0 100])
            xlim([0 timeValues(end)])
            lgd.FontSize = 1;
        
            subplot(2,1,2) 
            plot(timeValues,ldrColumn)
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Light (LDR) Reading")
            title('Light (LDR) Readings: Cropping Options')
            xline([1 currentHeight],'-r',{['Start Point' ''],'End Point'})
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['24-h Start' ''],'24-h End'})
            ylim([0 100])
            xlim([0 timeValues(end)])
            lgd.FontSize = 1;

            % Enlarge figure to full screen.
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
            % Remove tool bar and pulldown menus
            set(gcf, 'Toolbar', 'none', 'Menu', 'none');

            figure2 = gcf;

            absCropStartPointX = 1;
            absCropEndPointX = height(timeValues);
            abs24HStart = 1;
            abs24HEnd = height(timeValues);
        end
        % Shift timeValues
        timeValues = timeValues - timeValues(1);
        % Document the new number of indices between the cropped start 
        % point and the start of 24-hour recordings, as well as the number 
        % of indices between the cropped end of recordings and the end of 
        % a 24-hour recording
        if do24HTruncation == "Y"
            newCropStart24H = startPointPos - startPoint;
            newCropEnd24H = endPointPos - startPoint;
        end
        if alignLight == "Y"
            newCropStart24H = startPointPos - startPoint;
            newCropEnd24H = endPointPos - startPoint;
        end

        % Step 3: mass filtering

        % Now begin mass filtering, starting with baseline establishment
        % by setting the first 10 values to that of the calibrated mass
        newMassInfo = rawMass;
        massColumn = rawMass;
        % Define the maximum mass recording to be displayed for filter
        % assessment (this does not change the underlying dataset). 50 is
        % selected as the SnackerTracker is not designed to hold more than
        % 50 g of food
        yMax = 50;
        xMax = timeValues(end);
        % Set the figure legend font size
        fontHere = 0.5;
        % Create a series to identify where raw mass data exceeds yMax
        numOutBound = 0;
        for x = 1:height(massColumn)
            if massColumn(x) > yMax
                numOutBound = numOutBound + 1;
            end
        end
        outBoundX = zeros(numOutBound,1);
        outBoundY = zeros(numOutBound,1);
        outBoundIndex = 1;
        for x = 1:height(massColumn)
            if massColumn(x) > yMax
                outBoundX(outBoundIndex) = timeValues(x);
                outBoundY(outBoundIndex) = yMax - 5;
                outBoundIndex = outBoundIndex + 1; 
            end
        end
        % Iterate through filtering specifications/fine-tuning until the 
        % user indicates that they are satisfied with the filter choice
        massColumnO = massColumn;
        newMassInfoO = newMassInfo;
        doneFiltering = "N";
        while doneFiltering == "N"
            % There are several filtering parameters which can be adjusted  
            % for mass filters. These include:
                % setTime specifies the number of data points which   
                    % are to establish the filtering baseline
                % bufferHere is the acts as a band-pass filter to remove
                    % values exceeding this when compared to any prior 
                    % value within the measureSpan index
                % measureSpan is the range of prior values which upcoming
                    % ones are checked against. If upcoming values (i + 1) 
                    % fall outside the buffer range (positively or 
                    % negatively) for any measurement in this range, the  
                    % upcoming value is removed (i.e., set to 0). 
                    % measureSpan cannot be greater than setTime
                % window is the range of mean filter application. 
                    % This is the number of values from which the filtered 
                    % mean value is calculated and assigned
            % Initialise the first setTime mass data points and determine
            % how many data points (setTime) this should span. 32 is 
            % recommended as it is 2-times the length of the longest 
            % continuous animal interaction observed with the 
            % SnackerTracker during testing which elicited variation  
            % exceeding buffer range
            prompt_setTime = "Please enter the number of data points which should be incorporated for base set-time calculations (e.g., " + setTime + "): ";
            setTime = input(prompt_setTime);
            % Remove positive or negative outliers which exceed or are 
            % less than the previous reading by at least bufferHere units
            prompt_bufferHere = "Please enter the mass buffer range outside of which deviations will be deemed animal-device interactions (e.g., 0.1): ";
            bufferHere = input(prompt_bufferHere);
            % The span over which measurement values will be checked as 
            % to whether they fall within the buffer range
            prompt_measureSpan = "Please enter the number of measurement values which will be checked against the mass buffer range (e.g., " + measureSpan + "): ";
            measureSpan = input(prompt_measureSpan);
            % Error-checking to ensure that the time values over which the
            % buffer will be applied (measureSpan) is less than the number 
            % of values set to the baseline initialised value (setTime)
            if measureSpan >= setTime
                keepLoop = "Y";
                while keepLoop == "Y"
                    fprintf("You have specified a buffer range which is greater than the timeframe spanned by the initialised baseline values.")
                    fprintf("\n")
                    fprintf("Baseline range = " + setTime)
                    fprintf("\n")
                    fprintf("Buffer range = " + measureSpan)
                    fprintf("\n")
                    prompt_whichEdit = "Enter '0' to increase the baseline range or '1' to decrease the buffer range: ";
                    whichEdit = input(prompt_whichEdit,"s");
                    % Error-checking for a valid whichEdit entry
                    whichEdit = skrtkr_isentryerror("0","1",whichEdit);
                    if whichEdit == "0"
                        setTime = input(prompt_setTime);
                    end
                    if whichEdit == "1"
                        measureSpan = input(prompt_measureSpan);
                    end
                    if measureSpan < setTime
                        fprintf("These values are now suitable.")
                        keepLoop = "N";
                    else
                        fprintf("These values are still not suitable.")
                    end
                end
            end
            % Define window for moving filters
            prompt_window = "Please enter the number of mass values which will be incorporated into the moving mean filter (e.g., " + window + "): ";
            window = input(prompt_window);
            % Re-set massColumn and newMassInfo
            massColumn = massColumnO;
            newMassInfo = newMassInfoO;
            
            % Plot raw data
    
            figure(3) 
        
            subplot(2,3,1) 
            plot(timeValues,massColumn,outBoundX,outBoundY,"or")
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            legend("No Filter + No Smoothing","Out of Bounds",['Location' ''],'southoutside')
            title('Option 1: N-F/N-S')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 yMax])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
        
            subplot(2,3,4) 
            meanMassR = movmean(massColumn,5);
            plot(timeValues,massColumn,timeValues,meanMassR)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            legend("No Filter + No Smoothing","No Filter + Mean Smoothing",'Location','southoutside')
            title('Option 4: N-F/Mean-S')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 yMax])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
            
            % Overwrite the first setTime array values to the mean of the 
            % first setTime mass values
            initialMass = sum(massColumn(1:setTime))/setTime;
            massColumn(1:setTime) = initialMass;
            newMassInfo(1:setTime) = initialMass;
            % Initialise incrementer to count filtered mass values
            numFiltered1X = 0;
            % Starting at setTime, then evaluating the next to see whether 
            % it exceeds bufferHere. If so, the value is set to zero
            isFiltered = 0;
            for i = setTime:(length(massColumn) - 1)
                isFiltered = 0;
                for j = (i - measureSpan):i
                    % If the mass value has NOT already been filtered, and 
                    % if the prior mass value within measureSpan has 
                    % not already been set to 0
                    if isFiltered == 0 && massColumn(j) ~= 0
                        if massColumn(i + 1) > (massColumn(j) + bufferHere)
                            newMassInfo(i + 1) = 0;
                            numFiltered1X = numFiltered1X + 1;
                            isFiltered = 1;
                        elseif massColumn(i + 1) < (massColumn(j) - bufferHere)
                            newMassInfo(i + 1) = 0;
                            numFiltered1X = numFiltered1X + 1;
                            isFiltered = 1;
                        end
                    end
                end
                if sw1FilterMass == "Y"
                    if switch1Column(i + 1) == 1
                        newMassInfo(i + 1) = 0;
                    end
                end
                if sw2FilterMass == "Y"
                    if switch2Column(i + 1) == 1
                        newMassInfo(i + 1) = 0;
                    end
                end
            end
            % Create a series to identify where data was filtered (1X)
            filteredPoints1X_Y = zeros(numFiltered1X,1);
            filteredPoints1X_X = zeros(numFiltered1X,1);
            indHere = 1;
            for i = 1:(length(massColumn))
                if newMassInfo(i) == 0
                    filteredPoints1X_Y(indHere) = massColumn(i);
                    filteredPoints1X_X(indHere) = timeValues(i);
                    indHere = indHere + 1;
                end
            end
        
            % Plot filtered outliers that are +/- buffer units of prior 
            % measurements over the timeframe defined by measureSpan
            
            subplot(2,3,2) 
            plot(timeValues,newMassInfo,filteredPoints1X_X,filteredPoints1X_Y,".r")
            hold on
            area(timeValues,lightColumnPlot,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            legend("1X Filter + No Smoothing","Points Filtered",['Location' ''],'southoutside')
            title('Option 2: 1X-F/N-S')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 yMax])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
        
            subplot(2,3,5) 
            meanMass1 = movmean(newMassInfo,window);
            plot(timeValues,newMassInfo,timeValues,meanMass1)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            legend("1X Filter + No Smoothing","1X Filter + Mean Smoothing",'Location','southoutside')
            title('Option 5: 1X-F/Mean-S')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 yMax])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
        
            % Identify the two flanking values zeros. Set these as the 
            % maximum and minimum of a linear curve and interpolate all  
            % flanked values according to their timestamp
            numFiltered2X = 0;
            % Create a copy of the current newMassInfo to generate the 
            % interpolated plot of edited data
            newMassInfo2 = newMassInfo;
            for i = setTime:(length(newMassInfo))
                if newMassInfo2(i) == 0
                    % Set the starting point as directly prior to 0
                    x1 = i - 1;
                    y1 = newMassInfo(i - 1);
                    doBreak = 0;
                    skipHere = 0;
                    if i ~= length(newMassInfo)
                        for j = (i + 1):length(newMassInfo)
                            % Find the next non-zero element and set it 
                            % as y2 (also calculating the number of points 
                            % flanked, excluding x1 and x2 themselves)
                            if newMassInfo(j) ~= 0 && doBreak == 0
                                x2 = j;
                                y2 = newMassInfo(j);
                                numPointsFlanked = j - x1 - 1;
                                doBreak = 1;
                            end
                            % If there is no future non-zero element
                            if j == length(newMassInfo) && doBreak == 0
                                newMassInfo2(i:end) = newMassInfo(i - 1);
                                numFiltered2X = numFiltered2X + (length(newMassInfo) - i + 1);
                                skipHere = 1;
                            end
                        end
                    else
                        % If 0 is assigned to the last value, simply 
                        % overwrite and assign as the previous mass value
                        x2 = i;
                        y2 = newMassInfo(i - 1);
                        numPointsFlanked = 1;
                    end
                    % Unless working with a final string of zeros
                    if skipHere == 0
                        % Determine the slope of the line passing through  
                        % the two points flanking the non-zero region
                        mSlope = (y2 - y1)/(x2-x1);
                        % Likewise for the y-intercept
                        bIntercept = y1 - mSlope*x1;
                        % For each point flanked by bookends x1 and x2
                        for k = 1:numPointsFlanked
                            % Overwrite '0's via linear interpolation
                            newMassInfo2(i + k - 1) = mSlope*(i + k - 1) + bIntercept;
                            numFiltered2X = numFiltered2X + 1;
                        end
                        % Due to overwriting, subsequent 0-values will
                        % be skipped and the series iterated through until 
                        % the next 0-value is encountered
                    end
                end
                ldrColumnHolder = ldrColumn;
                % For LDR data
                if ldrColumn(i) == 0
                    % Set the starting point as directly prior to 0s
                    x1 = i - 1;
                    y1 = ldrColumnHolder(i - 1);
                    doBreak = 0;
                    skipHere = 0;
                    if i ~= length(ldrColumnHolder)
                        for j = (i + 1):length(ldrColumnHolder)
                            % Find the next non-zero element and set it 
                            % as y2 (also counting points flanked by
                            % this region, excluding x1 and x2)
                            if ldrColumnHolder(j) ~= 0 && doBreak == 0
                                x2 = j;
                                y2 = ldrColumnHolder(j);
                                numPointsFlanked = j - x1 - 1;
                                doBreak = 1;
                            end
                            % If there is no future non-zero element
                            if j == length(ldrColumnHolder) && doBreak == 0
                                ldrColumn(i:end) = ldrColumnHolder(i - 1);
                                skipHere = 1;
                            end
                        end
                    else
                        % If 0 is assigned to the last value, simply 
                        % overwrite and assign to the previous mass value
                        x2 = i;
                        y2 = ldrColumnHolder(i - 1);
                        numPointsFlanked = 1;
                    end
                    % Unless working with a final string of zeros
                    if skipHere == 0
                        % Determine the slope of the line passing through  
                        % the two points flanking the non-zero region
                        mSlope = (y2 - y1)/(x2-x1);
                        % Likewise for the y-intercept
                        bIntercept = y1 - mSlope*x1;
                        % For each point flanked by bookends x1 and x2
                        for k = 1:numPointsFlanked
                            % Overwrite '0's via linear interpolation
                            ldrColumn(i + k - 1) = mSlope*(i + k - 1) + bIntercept;
                        end
                        % Due to this overwriting, directly subsequent 0-
                        % values will be skipped and the series iterated 
                        % through until the next 0-value is encountered
                    end
                end
                % Iterating through the end of the series
            end
            % Create a series to identify where data was filtered (2X)
            filteredPoints2X_Y = zeros(numFiltered2X,1);
            filteredPoints2X_X = zeros(numFiltered2X,1);
            indHere2 = 1;
            for i = 1:length(newMassInfo)
                if newMassInfo(i) == 0
                    filteredPoints2X_Y(indHere2) = newMassInfo(i);
                    filteredPoints2X_X(indHere2) = timeValues(i);
                    indHere2 = indHere2 + 1;
                end
            end
        
            % Plot the series after interpolating flanked null regions
            
            subplot(2,3,3) 
            plot(timeValues,newMassInfo2,filteredPoints2X_X,filteredPoints2X_Y,".r")
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            legend("2X Filter + No Smoothing","Points Filtered",'Location','southoutside')
            title('Option 3: 2X-F/N-S')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 yMax])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
        
            subplot(2,3,6) 
            meanMass2 = movmean(newMassInfo2,window);
            plot(timeValues,newMassInfo2,timeValues,meanMass2)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            legend("2X Filter + No Smoothing","2X Filter + Mean Smoothing",'Location','southoutside')
            title('Option 6: 2X-F/Mean-S')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 yMax])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;

            % Enlarge figure to full screen.
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
            % Remove tool bars and pulldown menus
            set(gcf, 'Toolbar', 'none', 'Menu', 'none');
    
            figure3 = gcf;
        
            % Ask whether the user is satisfied with filter options or 
            % whether they would like to adjust filter parameters
            fprintf("Are these filter options satisfactory?\n");
            prompt_doneFiltering = "Enter 'Y' if 'Yes', or 'N' if 'No' to adjust filter parameters: ";
            doneFiltering = input(prompt_doneFiltering,"s");
            % Error-checking for a valid entry
            doneFiltering = skrtkr_isentryerror("Y","N",doneFiltering);
        end

        % Ask the user to specify the desired filtering method
        fprintf("Which filter would you like to apply?\n");
        prompt_whichFilter = "Enter the number (1-6) corresponding to the desired option in the figure plot (e.g., " + whichFilter + "): ";
        whichFilter = input(prompt_whichFilter);
        % Error-checking for a valid whichFilter entry
        isGood = 0;
        while isGood == 0
            for c = 1:6
                if whichFilter == c
                    isGood = 1;
                end
            end
            if isGood == 0
                fprintf("Invalid entry.\n");
                prompt_repeatWhichFilter = "Please enter a number from 1-6 corresponding to the desired filter option in the figure plot: ";
                whichFilter = input(prompt_repeatWhichFilter);
            end
        end
        % Apply the desired filter to massColumn to assign as output     
        if whichFilter == 1
            filteredOutput = massColumn;
        elseif whichFilter == 2
            filteredOutput = newMassInfo;
        elseif whichFilter == 3
            filteredOutput = newMassInfo2;
        elseif whichFilter == 4
            filteredOutput = meanMassR;
        elseif whichFilter == 5
            filteredOutput = meanMass1;
        elseif whichFilter == 6
            filteredOutput = meanMass2;
        end

        % Step 4: plateau filter application

        filteredOutputNoPlateau = filteredOutput;
        doneFilterHere = "N";
        breakChip = "N";
        while doneFilterHere == "N"
            % Transform (flip) filteredOutput to instead show the mass of   
            % food consumed by the animal over time
            filteredOutputFlip = zeros(height(filteredOutput),1);
            for i = 1:height(filteredOutputFlip)
                filteredOutputFlip(i) = initialMass - filteredOutput(i);
                % Set any negative values to 0
                if filteredOutputFlip(i) < 0
                    filteredOutputFlip(i) = 0;
                end
            end
            % First prompt for the shift filter, which will loop through 
            % the specified number of data points checking if all are
            % below the present data point. If so, future values are
            % shifted up to the value of the previous measurement
            prompt_shiftFilter = "Please enter a value for the shift filter (e.g., " + shiftFilter + "): ";
            shiftFilter = input(prompt_shiftFilter);
            shiftFilterCalc = shiftFilter;
            prompt_shiftTolerance = "Please enter a value for the shift filter tolerance (between 0-1, e.g. " + shiftTolerance + "): ";
            shiftTolerance = input(prompt_shiftTolerance);
            % Error-checking for a valid shiftTolerance entry
            while shiftTolerance <= 0 || shiftTolerance > 1
                fprintf("This is not a valid entry; the tolerance must > 0 and <= 1. ");
                shiftTolerance = input(prompt_shiftTolerance);
            end
            % Apply a 'plateau' filter wherein values greater than the 
            % prior are assigned to the previous value. This accounts for 
            % any mean- or outlier adjusted increases due to small 
            % measurement fluctuations. Then proceed to the shift filter
            filteredOutputPlateau = filteredOutput;
            filteredOutputShifted = filteredOutput;
            for i = 2:height(filteredOutputPlateau)
                countShift = 0;
                % For the simple plateau filter
                if filteredOutputPlateau(i) > filteredOutputPlateau(i - 1)
                    filteredOutputPlateau(i) = filteredOutputPlateau(i - 1);
                end
                % For the shift filter, first accounting for values at the
                % end of the data set where the number of future values is
                % less than that which can be accommodated by the present
                % value of shiftFilter
                if (height(filteredOutputShifted) - i) < shiftFilter
                    shiftFilterCalc = height(filteredOutputShifted) - i;
                else
                    shiftFilterCalc = shiftFilter;
                end
                % Applying the shift filter (or shiftFilterCalc for values
                % at the end of the dataset
                for h = 1:shiftFilterCalc
                    if filteredOutputShifted(i - 1 + h) > filteredOutputShifted(i - 1)
                        % Incrementing countShift if the value in the
                        % present loop (looping through each successive
                        % data point within the range specified by
                        % shiftFilterCalc) is greater than the previous
                        % (which should not be the case, indicating shift
                        % error)
                        countShift = countShift + 1;
                    end
                end
                countShiftRatio = countShift/shiftFilterCalc;
                % If the number of values in the range shiftFilterCalc,
                % incremented by countShift, exceeds the threshold
                % specified by shiftTolerance
                if (countShiftRatio >= shiftTolerance) && (filteredOutputShifted(i) > filteredOutputShifted(i - 1))
                    massDiff = abs(filteredOutputShifted(i) - filteredOutputShifted(i - 1));
                    for e = i:height(filteredOutputShifted)
                        % Shift the mass value of all subsequent values
                        filteredOutputShifted(e) = filteredOutputShifted(e) - massDiff;
                    end
                end
            end
            % Apply a double plateau filter to shifted data
            filteredOutputShiftedWP = filteredOutputShifted;
            for i = 1:height(filteredOutputShifted)
                % For the second plateau filter, which will be applied in
                % the backwards direction to account for the nature of
                % positive spikes in the shifted filter
                if i < height(filteredOutputShifted)
                    if filteredOutputShiftedWP(height(filteredOutputShiftedWP) - 1 - (i - 1)) < filteredOutputShiftedWP(height(filteredOutputShiftedWP) - (i - 1))
                        filteredOutputShiftedWP(height(filteredOutputShiftedWP) - 1 - (i - 1)) = filteredOutputShiftedWP(height(filteredOutputShiftedWP) - (i - 1));
                    end
                end
            end
            % Transform (flip) all three filtered data sets (as original)
            % to instead show the mass of food consumed over time
            filteredOutputPlateauFlip = zeros(height(filteredOutput),1);
            filteredOutputShiftedFlip = zeros(height(filteredOutputShifted),1);
            filteredOutputShiftedWPF = zeros(height(filteredOutputShiftedWP),1);
            for i = 1:height(filteredOutput)
                filteredOutputPlateauFlip(i) = initialMass - filteredOutputPlateau(i);
                filteredOutputShiftedFlip(i) = initialMass - filteredOutputShifted(i);
                filteredOutputShiftedWPF(i) = initialMass - filteredOutputShiftedWP(i);
                % Set any negative values to 0
                if filteredOutputPlateauFlip(i) < 0
                    filteredOutputPlateauFlip(i) = 0;
                end
                if filteredOutputShiftedFlip(i) < 0
                    filteredOutputShiftedFlip(i) = 0;
                end
                if filteredOutputShiftedWPF(i) < 0
                    filteredOutputShiftedWPF(i) = 0;
                end
            end
            % Plot filteredOutput transforms to show food consumption, 
            % both normal and flipped with plateau/shifted filters applied
            ymaxHere = max(filteredOutputFlip)*1.5;
            if ymaxHere == 0
                ymaxHere = 1;
            end
            % Plot filtered food consumption/intake, with and without the
            % plateau filter
        
            figure(4)
        
            subplot(2,4,1) 
            plot(timeValues,filteredOutput)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            title('Filtered Mass: No Filter')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 (max(filteredOutput)*1.5)])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
    
            subplot(2,4,2) 
            plot(timeValues,filteredOutputPlateau)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            title('Filtered Mass: Plateau Filter')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 (max(filteredOutput)*1.5)])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
    
            subplot(2,4,3) 
            plot(timeValues,filteredOutputShifted)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            title('Filtered Mass: Shift Filter')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 (max(filteredOutput)*1.5)])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;

            subplot(2,4,4) 
            plot(timeValues,filteredOutputShiftedWP)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            title('Filtered Mass: Shift + Plateau Filter')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 (max(filteredOutput)*1.5)])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
    
            subplot(2,4,5) 
            plot(timeValues,filteredOutputFlip)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            title('Food Intake: No Filter')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 ymaxHere])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
    
            subplot(2,4,6) 
            plot(timeValues,filteredOutputPlateauFlip)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            title('Food Intake: Plateau Filter')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 ymaxHere])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
    
            subplot(2,4,7) 
            plot(timeValues,filteredOutputShiftedFlip)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            title('Food Intake: Shift Filter')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 ymaxHere])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;

            subplot(2,4,8) 
            plot(timeValues,filteredOutputShiftedWPF)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            title('Food Intake: Shift + Plateau Filter')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 ymaxHere])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;

            % Enlarge figure to full screen.
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
            % Remove tool bar and pulldown menus
            set(gcf, 'Toolbar', 'none', 'Menu', 'none');
    
            figure4 = gcf;

            doChipFilter = "N";
            goodChip = "N";
            while goodChip == "N"
                % Apply a "chip" filter to account for abrupt mass changes
                % which exceed a certain threshold
                if doChipFilter == "N"
                    % Only reading for the first iteration in the case of 
                    % a repeated while loop
                    fprintf("Would you like to apply a 'chip' filter?\n");
                    prompt_doChipFilter = "Enter 'Y' if 'Yes', or 'N' if 'No': ";
                    doChipFilter = input(prompt_doChipFilter,"s");
                    % Error-checking for a valid entry
                    doChipFilter = skrtkr_isentryerror("Y","N",doChipFilter);
                end
                if doChipFilter == "Y"
                    % Make a copy of mass columns, which will later be 
                    % used to overwrite original mass columns if the chip
                    % filter is maintained
                    filteredOutputCopy = filteredOutput;
                    filteredOutputFlipCopy = filteredOutputFlip;
                    filteredOutputPlateauCopy = filteredOutputPlateau;
                    filteredOutputPlateauFlipCopy = filteredOutputPlateauFlip;
                    filteredOutputShiftedCopy = filteredOutputShifted;
                    filteredOutputShiftedFlipCopy = filteredOutputShiftedFlip;
                    filteredOutputShiftedWPCopy = filteredOutputShiftedWP;
                    filteredOutputShiftedWPFCopy = filteredOutputShiftedWPF;
                    % Determine chip filter parameters
                    prompt_chipMass = "Please enter a mass value for the chip filter (e.g., 0.5): ";
                    chipMass = input(prompt_chipMass);
                    prompt_chipTime = "Please enter a time value which occurs just before the chip: ";
                    chipStartTime = input(prompt_chipTime);
                    prompt_chipTimeTolerance = "Please enter a time value which occurs just after the chip: ";
                    chipEndTime = input(prompt_chipTimeTolerance);
                    % Determine the indices in timeValues of the times
                    % specified which occur before and after the chip
                    % supposedly takes place
                    findChipStart = "N";
                    findChipEnd = "N";
                    findIndex = 1;
                    while findChipStart == "N" || findChipEnd == "N"
                        if findChipStart == "N"
                            if timeValues(findIndex) > chipStartTime
                                chipStartIndex = findIndex - 1;
                                findChipStart = "Y";
                            end
                        end
                        if findChipEnd == "N"
                            if timeValues(findIndex) > chipEndTime
                                chipEndIndex = findIndex - 1;
                                findChipEnd = "Y";
                            end
                        end
                        findIndex = findIndex + 1;
                    end
                    % If the drop in mass (attributed to the chip) exceeds
                    % the threshold specified by chipMass, repeating for
                    % each filter option
                    if (filteredOutputCopy(chipStartIndex) - filteredOutputCopy(chipEndIndex)) > chipMass
                        massDifference = filteredOutputCopy(chipStartIndex) - filteredOutputCopy(chipEndIndex);
                        % Set the timeframe spanning the chip to the value
                        % directly prior to the chip
                        for c = chipStartIndex:chipEndIndex
                            filteredOutputCopy(c,1) = filteredOutputCopy(chipStartIndex);
                        end
                        % Subtract the mass difference spanned by the chip
                        % timeframes from subsequent data values
                        for h = (chipEndIndex + 1):height(filteredOutputCopy)
                            filteredOutputCopy(h,1) = filteredOutputCopy(h,1) + massDifference;
                        end
                    end
                    if (filteredOutputPlateauCopy(chipStartIndex) - filteredOutputPlateauCopy(chipEndIndex)) > chipMass
                        massDifference = filteredOutputPlateauCopy(chipStartIndex) - filteredOutputPlateauCopy(chipEndIndex);
                        % Set the timeframe spanning the chip to the value
                        % directly prior to the chip
                        for c = chipStartIndex:chipEndIndex
                            filteredOutputPlateauCopy(c,1) = filteredOutputPlateauCopy(chipStartIndex);
                        end
                        % Subtract the mass difference spanned by the chip
                        % timeframes from subsequent data values
                        for h = (chipEndIndex + 1):height(filteredOutputPlateauCopy)
                            filteredOutputPlateauCopy(h,1) = filteredOutputPlateauCopy(h,1) + massDifference;
                        end
                    end
                    if (filteredOutputShiftedCopy(chipStartIndex) - filteredOutputShiftedCopy(chipEndIndex)) > chipMass
                        massDifference = filteredOutputShiftedCopy(chipStartIndex) - filteredOutputShiftedCopy(chipEndIndex);
                        % Set the timeframe spanning the chip to the value
                        % directly prior to the chip
                        for c = chipStartIndex:chipEndIndex
                            filteredOutputShiftedCopy(c,1) = filteredOutputShiftedCopy(hipStartIndex);
                        end
                        % Subtract the mass difference spanned by the chip
                        % timeframes from subsequent data values
                        for h = (chipEndIndex + 1):height(filteredOutputShiftedCopy)
                            filteredOutputShiftedCopy(h,1) = filteredOutputShiftedCopy(h,1) + massDifference;
                        end
                    end
                    if (filteredOutputShiftedWPCopy(chipStartIndex) - filteredOutputShiftedWPCopy(chipEndIndex)) > chipMass
                        massDifference = filteredOutputShiftedWPCopy(chipStartIndex) - filteredOutputShiftedWPCopy(chipEndIndex);
                        % Set the timeframe spanning the chip to the value
                        % directly prior to the chip
                        for c = chipStartIndex:chipEndIndex
                            filteredOutputShiftedWPCopy(c,1) = filteredOutputShiftedWPCopy(chipStartIndex);
                        end
                        % Subtract the mass difference spanned by the chip
                        % timeframes from subsequent data values
                        for h = (chipEndIndex + 1):height(filteredOutputShiftedWPCopy)
                            filteredOutputShiftedWPCopy(h,1) = filteredOutputShiftedWPCopy(h,1) + massDifference;
                        end
                    end
                    % If the apparant increase in mass consumed 
                    % (attributed to the chip) exceeds the threshold
                    % specified by chipMass, again repeating for each
                    % filter option
                    if (filteredOutputFlipCopy(chipEndIndex) - filteredOutputFlipCopy(chipStartIndex)) > chipMass
                        massDifference = filteredOutputFlipCopy(chipEndIndex) - filteredOutputFlipCopy(chipStartIndex);
                        % Set the timeframe spanning the chip to the value
                        % directly prior to the chip
                        for c = chipStartIndex:chipEndIndex
                            filteredOutputFlipCopy(c,1) = filteredOutputFlipCopy(chipStartIndex);
                        end
                        % Subtract the mass difference spanned by the chip
                        % timeframes from subsequent data values
                        for h = (chipEndIndex + 1):height(filteredOutputFlipCopy)
                            filteredOutputFlipCopy(h,1) = filteredOutputFlipCopy(h,1) - massDifference;
                        end
                    end
                    if (filteredOutputPlateauFlipCopy(chipEndIndex) - filteredOutputPlateauFlipCopy(chipStartIndex)) > chipMass
                        massDifference = filteredOutputPlateauFlipCopy(chipEndIndex) - filteredOutputPlateauFlipCopy(chipStartIndex);
                        % Set the timeframe spanning the chip to the value
                        % directly prior to the chip
                        for c = chipStartIndex:chipEndIndex
                            filteredOutputPlateauFlipCopy(c,1) = filteredOutputPlateauFlipCopy(chipStartIndex);
                        end
                        % Subtract the mass difference spanned by the chip
                        % timeframes from subsequent data values
                        for h = (chipEndIndex + 1):height(filteredOutputPlateauFlipCopy)
                            filteredOutputPlateauFlipCopy(h,1) = filteredOutputPlateauFlipCopy(h,1) - massDifference;
                        end
                    end
                    if (filteredOutputShiftedFlipCopy(chipEndIndex) - filteredOutputShiftedFlipCopy(chipStartIndex)) > chipMass
                        massDifference = filteredOutputShiftedFlipCopy(chipEndIndex) - filteredOutputShiftedFlipCopy(chipStartIndex);
                        % Set the timeframe spanning the chip to the value
                        % directly prior to the chip
                        for c = chipStartIndex:chipEndIndex
                            filteredOutputShiftedFlipCopy(c,1) = filteredOutputShiftedFlipCopy(chipStartIndex);
                        end
                        % Subtract the mass difference spanned by the chip
                        % timeframes from subsequent data values
                        for h = (chipEndIndex + 1):height(filteredOutputShiftedFlipCopy)
                            filteredOutputShiftedFlipCopy(h,1) = filteredOutputShiftedFlipCopy(h,1) - massDifference;
                        end
                    end
                    if (filteredOutputShiftedWPFCopy(chipEndIndex) - filteredOutputShiftedWPFCopy(chipStartIndex)) > chipMass
                        massDifference = filteredOutputShiftedWPFCopy(chipEndIndex) - filteredOutputShiftedWPFCopy(chipStartIndex);
                        % Set the timeframe spanning the chip to the value
                        % directly prior to the chip
                        for c = chipStartIndex:chipEndIndex
                            filteredOutputShiftedWPFCopy(c,1) = filteredOutputShiftedWPFCopy(chipStartIndex);
                        end
                        % Subtract the mass difference spanned by the chip
                        % timeframes from subsequent data values
                        for h = (chipEndIndex + 1):height(filteredOutputShiftedWPFCopy)
                            filteredOutputShiftedWPFCopy(h,1) = filteredOutputShiftedWPFCopy(h,1) - massDifference;
                        end
                    end
                    % Plot chip filter boundaries, overwriting figure 4

                    figure(4)
        
                    subplot(2,4,1) 
                    plot(timeValues,filteredOutput)
                    hold on
                    plot(timeValues,filteredOutputCopy)
                    area(timeValues,lightColumnPlot,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
                    hold off
                    axis tight
                    xlabel("Time (" + timeUnit + ")")
                    ylabel("Mass (" + massUnit + ")")
                    title('Filtered Mass: No Filter')
                    xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
                    xline([timeValues(chipStartIndex) timeValues(chipEndIndex)],'-r',{['Chip Start' ''],'Chip End'})
                    ylim([0 (max(filteredOutputCopy)*1.5)])
                    xlim([timeValues(1) xMax])
                    lgd.FontSize = fontHere;
            
                    subplot(2,4,2) 
                    plot(timeValues,filteredOutputPlateau)
                    hold on
                    plot(timeValues,filteredOutputPlateauCopy)
                    area(timeValues,lightColumnPlot,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
                    hold off
                    axis tight
                    xlabel("Time (" + timeUnit + ")")
                    ylabel("Mass (" + massUnit + ")")
                    title('Filtered Mass: Plateau Filter')
                    xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
                    xline([timeValues(chipStartIndex) timeValues(chipEndIndex)],'-r',{['Chip Start' ''],'Chip End'})
                    ylim([0 (max(filteredOutputCopy)*1.5)])
                    xlim([timeValues(1) xMax])
                    lgd.FontSize = fontHere;
            
                    subplot(2,4,3) 
                    plot(timeValues,filteredOutputShifted)
                    hold on
                    plot(timeValues,filteredOutputShiftedCopy)
                    area(timeValues,lightColumnPlot,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
                    hold off
                    axis tight
                    xlabel("Time (" + timeUnit + ")")
                    ylabel("Mass (" + massUnit + ")")
                    title('Filtered Mass: Shift Filter')
                    xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
                    xline([timeValues(chipStartIndex) timeValues(chipEndIndex)],'-r',{['Chip Start' ''],'Chip End'})
                    ylim([0 (max(filteredOutputCopy)*1.5)])
                    xlim([timeValues(1) xMax])
                    lgd.FontSize = fontHere;
        
                    subplot(2,4,4) 
                    plot(timeValues,filteredOutputShiftedWP)
                    hold on
                    plot(timeValues,filteredOutputShiftedWPCopy)
                    area(timeValues,lightColumnPlot,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
                    hold off
                    axis tight
                    xlabel("Time (" + timeUnit + ")")
                    ylabel("Mass (" + massUnit + ")")
                    title('Filtered Mass: Shift + Plateau Filter')
                    xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
                    xline([timeValues(chipStartIndex) timeValues(chipEndIndex)],'-r',{['Chip Start' ''],'Chip End'})
                    ylim([0 (max(filteredOutputCopy)*1.5)])
                    xlim([timeValues(1) xMax])
                    lgd.FontSize = fontHere;
            
                    subplot(2,4,5) 
                    plot(timeValues,filteredOutputFlip)
                    hold on
                    plot(timeValues,filteredOutputFlipCopy)
                    area(timeValues,lightColumnPlot,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
                    hold off
                    axis tight
                    xlabel("Time (" + timeUnit + ")")
                    ylabel("Mass (" + massUnit + ")")
                    title('Food Intake: No Filter')
                    xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
                    xline([timeValues(chipStartIndex) timeValues(chipEndIndex)],'-r',{['Chip Start' ''],'Chip End'})
                    ylim([0 ymaxHere])
                    xlim([timeValues(1) xMax])
                    lgd.FontSize = fontHere;
            
                    subplot(2,4,6) 
                    plot(timeValues,filteredOutputPlateauFlip)
                    hold on
                    plot(timeValues,filteredOutputPlateauFlipCopy)
                    area(timeValues,lightColumnPlot,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
                    hold off
                    axis tight
                    xlabel("Time (" + timeUnit + ")")
                    ylabel("Mass (" + massUnit + ")")
                    title('Food Intake: Plateau Filter')
                    xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
                    xline([timeValues(chipStartIndex) timeValues(chipEndIndex)],'-r',{['Chip Start' ''],'Chip End'})
                    ylim([0 ymaxHere])
                    xlim([timeValues(1) xMax])
                    lgd.FontSize = fontHere;
            
                    subplot(2,4,7) 
                    plot(timeValues,filteredOutputShiftedFlip)
                    hold on
                    plot(timeValues,filteredOutputShiftedFlipCopy)
                    area(timeValues,lightColumnPlot,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
                    hold off
                    axis tight
                    xlabel("Time (" + timeUnit + ")")
                    ylabel("Mass (" + massUnit + ")")
                    title('Food Intake: Shift Filter')
                    xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
                    xline([timeValues(chipStartIndex) timeValues(chipEndIndex)],'-r',{['Chip Start' ''],'Chip End'})
                    ylim([0 ymaxHere])
                    xlim([timeValues(1) xMax])
                    lgd.FontSize = fontHere;
        
                    subplot(2,4,8) 
                    plot(timeValues,filteredOutputShiftedWPF)
                    hold on
                    plot(timeValues,filteredOutputShiftedWPFCopy)
                    area(timeValues,lightColumnPlot,['LineStyle' ''],'none','FaceColor','Yellow','FaceAlpha',0.3)
                    hold off
                    axis tight
                    xlabel("Time (" + timeUnit + ")")
                    ylabel("Mass (" + massUnit + ")")
                    title('Food Intake: Shift + Plateau Filter')
                    xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
                    xline([timeValues(chipStartIndex) timeValues(chipEndIndex)],'-r',{['Chip Start' ''],'Chip End'})
                    ylim([0 ymaxHere])
                    xlim([timeValues(1) xMax])
                    lgd.FontSize = fontHere;
        
                    % Enlarge figure to full screen.
                    set(gcf, 'Units', 'Normalized', ['' 'OuterPosition'], [0 0 1 1]);
                    % Remove tool bar and pulldown menus 
                    set(gcf, 'Toolbar', 'none', 'Menu', 'none');
            
                    figure4 = gcf;

                    % Ask if satisfactory
                    fprintf("Are you satisfied with the chip filter?\n");
                    prompt_goodChipThis = "Enter 'Y' if 'Yes', or 'N' if 'No': ";
                    goodChipThis = input(prompt_goodChipThis,"s");
                    % Error-checking for a valid entry
                    goodChipThis = skrtkr_isentryerror("Y","N",goodChipThis);
                    if goodChipThis == "Y"
                        % Document chip filter information for inclusion 
                        % in processing parameters output
                        chipFilterDetails = chipFilterDetails + "(" + convertCharsToStrings(num2str(chipStartTime)) + "/" + convertCharsToStrings(num2str(chipEndTime)) + "/" + convertCharsToStrings(num2str(chipMass)) + ")";
                        % Ask if another chip is to be addressed
                        fprintf("Would you like to apply another chip filter?\n");
                        prompt_anotherChip = "Enter 'Y' if 'Yes', or 'N' if 'No': ";
                        anotherChip = input(prompt_anotherChip,"s");
                        % Error-checking for a valid entry
                        anotherChip = skrtkr_isentryerror("Y","N",anotherChip);
                        if anotherChip == "Y"
                            % Overwrite original mass columns, and repeat
                            % to apply another chip filter
                            filteredOutput = filteredOutputCopy;
                            filteredOutputFlip = filteredOutputFlipCopy;
                            filteredOutputPlateau = filteredOutputPlateauCopy;
                            filteredOutputPlateauFlip = filteredOutputPlateauFlipCopy;
                            filteredOutputShifted = filteredOutputShiftedCopy;
                            filteredOutputShiftedFlip = filteredOutputShiftedFlipCopy;
                            filteredOutputShiftedWP = filteredOutputShiftedWPCopy;
                            filteredOutputShiftedWPF = filteredOutputShiftedWPFCopy;
                        else
                            % If the user is satisfied with this chip
                            % filter and does not want to apply another
                            goodChip = "Y";
                        end
                    else
                        % If it is not a satisfactory chip filter
                        fprintf("Would you like to adjust the parameters for this chip filter?\n");
                        prompt_adjustChip = "Enter 'Y' if 'Yes', or 'N' to alternatively break out of chip filter adjustments to try other parameter combinations: ";
                        adjustChip = input(prompt_adjustChip,"s");
                        % Error-checking for a valid entry
                        adjustChip = skrtkr_isentryerror("Y","N",adjustChip);
                        if adjustChip == "N"
                            breakChip = "Y";
                            goodChip = "Y";
                        end
                    end
                else
                    goodChip = "Y";
                end
            end
            if breakChip == "N"
                % Ask whether the user is satisfied with filter options  
                % or whether they would like to adjust filter parameters
                fprintf("Are these filter options satisfactory?\n");
                prompt_doneFilterHere = "Enter 'Y' if 'Yes', or 'N' if 'No' to adjust mass filter parameters: ";
                doneFilterHere = input(prompt_doneFilterHere,"s");
                % Error-checking for a valid entry
                doneFilterHere = skrtkr_isentryerror("Y","N",doneFilterHere);
            else
                doneFilterHere = "N";
            end
        end
        % Overwrite prior mass arrays if the chip filter was applied
        if doChipFilter == "Y"
            filteredOutput = filteredOutputCopy;
            filteredOutputFlip = filteredOutputFlipCopy;
            filteredOutputPlateau = filteredOutputPlateauCopy;
            filteredOutputPlateauFlip = filteredOutputPlateauFlipCopy;
            filteredOutputShifted = filteredOutputShiftedCopy;
            filteredOutputShiftedFlip = filteredOutputShiftedFlipCopy;
            filteredOutputShiftedWP = filteredOutputShiftedWPCopy;
            filteredOutputShiftedWPF = filteredOutputShiftedWPFCopy;
        end
        goodNumHere = "N";
        while goodNumHere == "N"
            prompt_numFilterCombo = "Enter a number between 1 - 4 corresponding to the column/filter combination you wish to select: ";
            numFilterCombo = input(prompt_numFilterCombo);
            if numFilterCombo == 1 
                goodNumHere = "Y";
                applyPlateau = "N";
                applyShift = "N";
                applyShiftAndPlateau = "N";
            end
            if numFilterCombo == 2
                goodNumHere = "Y";
                applyPlateau = "Y";
                applyShift = "N";
                applyShiftAndPlateau = "N";
            end
            if numFilterCombo == 3
                goodNumHere = "Y";
                applyPlateau = "N";
                applyShift = "Y";
                applyShiftAndPlateau = "N";
            end
            if numFilterCombo == 4
                goodNumHere = "Y";
                applyPlateau = "N";
                applyShift = "N";
                applyShiftAndPlateau = "Y";
            end
            if goodNumHere == "N"
                fprintf("Invalid entry.\n");
            end
        end
        % Assign user selection to the array to be used as final output
        if applyPlateau == "Y"
            filteredOutputCopy = filteredOutput;
            filteredOutput = filteredOutputPlateau;
            filteredOutputFlipCopy = filteredOutputFlip;
            filteredOutputFlip = filteredOutputPlateauFlip;
        end
        if applyShift == "Y"
            filteredOutputCopy = filteredOutput;
            filteredOutput = filteredOutputShifted;
            filteredOutputFlipCopy = filteredOutputFlip;
            filteredOutputFlip = filteredOutputShiftedFlip;
        end
        if applyShiftAndPlateau == "Y"
            filteredOutputCopy = filteredOutput;
            filteredOutput = filteredOutputShiftedWP;
            filteredOutputFlipCopy = filteredOutputFlip;
            filteredOutputFlip = filteredOutputShiftedWPF;
        end
        interactionsCountArray = zeros(height(filteredOutput),1);
        interactionsBinary = zeros(height(filteredOutput),1);
        amplitudeArray = zeros(height(filteredOutput),1);

        % Step 5: interactions assessment and frequency analysis

        % Set bufferInteractions to designate interaction amplitude 
        % threshhold
        bufferInteractions = bufferHere;
        % Starting at the setTime value, the first which is not set to the
        % initialised mass value, and evaluating to see whether the next 
        % is outside the buffer range. If so, the value is set to zero
        instanceMass = rawMass;
        isFilteredInst = 0;
        % For every value in the dataset
        for i = 1:(length(filteredOutput) - 1)
            amplitudeArray(i + 1) = abs(rawMass(i + 1) - filteredOutputCopy(i + 1));
            % Filtering amplitude differences less than bufferInteractions
            if amplitudeArray(i + 1) < bufferInteractions
                amplitudeArray(i + 1) = 0;
            end
            if sw1FilterMass == "Y"
                if switch1Column == 1
                    amplitudeArray(i + 1) = 0;
                end
            end
            % Checking to see if the next  value falls outside the buffer
            % range of any previous value within measureSpan
            isFilteredInst = 0;
            if i <= measureSpan
                measureSpanInst = 1;
            else
                measureSpanInst = i - measureSpan;
            end
            for j = measureSpanInst:i
                % If the mass value being evaluated has NOT already been
                % filtered and if the prior  value within measureSpan has 
                % not already been filtered/set to 0
                if isFilteredInst == 0 && rawMass(j) ~= 0
                    if rawMass(i + 1) > (rawMass(j) + bufferInteractions)
                        interactionsBinary(i + 1) = 1;
                        isFilteredInst = 1;
                        interactionsCountArray(i + 1) = interactionsCountArray(i) + 1;
                        if sw1FilterMass == "Y" && switch1Column(i + 1) == 1
                            interactionsBinary(i + 1) = 0;
                            interactionsCountArray(i + 1) = interactionsCountArray(i);
                        end
                    elseif rawMass(i + 1) < (rawMass(j) - bufferInteractions)
                        interactionsBinary(i + 1) = 1;
                        isFilteredInst = 1;
                        interactionsCountArray(i + 1) = interactionsCountArray(i) + 1;
                        if sw1FilterMass == "Y" && switch1Column(i + 1) == 1
                            interactionsBinary(i + 1) = 0;
                            interactionsCountArray(i + 1) = interactionsCountArray(i);
                        end
                    else
                        % interactionsBinary will be already set to 0
                        interactionsCountArray(i + 1) = interactionsCountArray(i);
                    end
                end
            end
        end
        % Compute the derivative of interactions cumulative counts to see
        % the time rate of change in feeding at each point in the series
        % Initialise looping variable to modify parameter specifications
        stopLoopingDerv = "N";
        while stopLoopingDerv == "N"
            goodBuffers = "N";
            while goodBuffers == "N"
                % Prompt the user to enter the food consumption 
                % derivative buffer
                prompt_dervBufferFood = "Please enter a value for the food consumption derivative buffer (an even number, e.g., " + fooddervBuffer + "): ";
                fooddervBuffer = input(prompt_dervBufferFood);
                notEvenFood = "0";
                if num2str(rem(fooddervBuffer,2)) ~= '0'
                    notEvenFood = "1";
                end
                while notEvenFood == "1"
                    fprintf("The food derivative buffer must be even (" + fooddervBuffer + " is not even).\n")
                    fooddervBuffer = input(prompt_dervBufferFood);
                    if rem(fooddervBuffer,2) == 0
                        notEvenFood = "0";
                    end
                end
                % Prompt the user to enter the interactions derivative 
                % buffer; that is, the number of measurements over which 
                % the derivative will be later calculated
                prompt_dervBuffer = "Please enter a value for the interactions derivative buffer (an even number, e.g., " + intdervBuffer + "): ";
                intdervBuffer = input(prompt_dervBuffer);
                notEven = "0";
                if num2str(rem(intdervBuffer,2)) ~= '0'
                    notEven = "1";
                end
                while notEven == "1"
                    fprintf("The interactions derivative buffer must be even (" + intdervBuffer + " is not even).\n")
                    intdervBuffer = input(prompt_dervBuffer);
                    if rem(intdervBuffer,2) == 0
                        notEven = "0";
                    end
                end
                if fooddervBuffer*2 >= height(interactionsCountArray) || intdervBuffer*2 >= height(interactionsCountArray)
                    fprintf("Invalid buffers; both must be less than half the length of this dataset (" + num2str(height(interactionsCountArray)/2) + ").\n")
                else
                    goodBuffers = "Y";
                end
            end
            dervInteractionsCumulative = zeros(height(interactionsCountArray),1);
            for i = 1:height(interactionsCountArray)
                % The derivative is the slope of the line spanning points
                % flanked by the derivative buffer. This slope is assigned 
                % to the middle value in the buffer range and can be
                % interpreted as the rate of device interaction at a
                % given time point. The slope can have a minimum value of 
                % 0 (no interactions) or 1 (constant interactions)
                if i > (intdervBuffer/2) && i < (height(interactionsCountArray) - (intdervBuffer/2))
                    dervInteractionsCumulative(i) = (interactionsCountArray(i + intdervBuffer/2) - interactionsCountArray(i - intdervBuffer/2))/((intdervBuffer*Fs)*(1/(60*60*24)));                
                elseif i <= (intdervBuffer/2)
                    % If in the first set of values (<= intDervBuffer/2)
                    dervInteractionsCumulative(i) = (interactionsCountArray(i + intdervBuffer/2) - interactionsCountArray(1))/(((intdervBuffer/2 + i - 1)*Fs)*(1/(60*60*24)));
                else
                    % For the last set of values (within intdervBuffer/2 
                    % of the last data point)
                    dervInteractionsCumulative(i) = (interactionsCountArray(end) - interactionsCountArray(i - intdervBuffer/2))/(((intdervBuffer/2 + height(interactionsCountArray) - i + 1)*Fs)*(1/(60*60*24)));
                end
            end
            dervFoodCumulative = zeros(height(filteredOutput),1);
            isFirstInstance = "Y";
            for i = 1:height(filteredOutput)
                % As with the interactions buffer
                if i > (fooddervBuffer/2) && i < (height(filteredOutputFlip) - (fooddervBuffer/2))
                    dervFoodCumulative(i) = (filteredOutputFlip(i + fooddervBuffer/2) - filteredOutputFlip(i - fooddervBuffer/2))/((fooddervBuffer*Fs)*(1/(60*60*24)));
                elseif i <= (fooddervBuffer/2)
                    % If in the first set of values (<= intDervBuffer/2)
                    dervFoodCumulative(i) = (filteredOutputFlip(i + fooddervBuffer/2) - filteredOutputFlip(1))/(((fooddervBuffer/2 + i - 1)*Fs)*(1/(60*60*24)));
                else
                    % For the last set of values (within intdervBuffer/2
                    % of the last data point)
                    dervFoodCumulative(i) = (filteredOutputFlip(end) - filteredOutputFlip(i - fooddervBuffer/2))/(((fooddervBuffer/2 + height(filteredOutputFlip) - i + 1)*Fs)*(1/(60*60*24)));
                end
            end
            % Compute the FFT
            rawMassFFT = fft(rawMass);
            % Moving to the frequency space, with Fs initialised to 1Hz
            fs = Fs;
            % Re-create array to correspond to sampling amplitude 
            % in frequency space
            rawMassFFTf = (0:length(rawMassFFT)-1)*fs/length(rawMassFFT);
            % Compute FFT of the derivative interaction counts
            dervInteractionsCumulativeFFT = fft(dervInteractionsCumulative);
            % Re-create array to correspond to sampling amplitude in 
            % frequency space
            dervInteractionsCumulativeFFTf = (0:length(dervInteractionsCumulative)-1)*fs/length(dervInteractionsCumulative);
            % Perform continuous wavelet transform of food data
            [cfsFood,fFood] = cwt(dervFoodCumulative,Fs);
            % Perform continuous wavelet transform of interaction data
            [cfsInteractions,fInteractions] = cwt(dervInteractionsCumulative,Fs);
            xlimfoodderv = (timeValues(1) + (fooddervBuffer/Fs)*(1/(60*60*24)));
            xmaxfoodderv = (xMax - (fooddervBuffer/Fs)*(1/(60*60*24)));
            xlimintderv = (timeValues(1) + (intdervBuffer/Fs)*(1/(60*60*24)));
            xmaxintderv = (xMax - (intdervBuffer/Fs)*(1/(60*60*24)));
            ymaxHere2 = max(filteredOutputFlip)*1.3;
            ymaxHere3 = max(dervFoodCumulative)*1.3;
            ymaxHere4 = max(interactionsCountArray)*1.3;
            ymaxHere5 = max(dervInteractionsCumulative)*1.3;
            if ymaxHere2 == 0
                ymaxHere2 = 1;
            end
            if ymaxHere3 == 0
                ymaxHere3 = 1;
            end
            if ymaxHere4 == 0
                ymaxHere4 = 1;
            end
            lightColumnPlotInteractions = lightColumnPlot.*800;

            % Plot derivative filter data

            figure(5)
            
            subplot(2,5,1)
            plot(timeValues,massColumn)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            title('Raw Mass Recordings')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 yMax])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
            
            subplot(2,5,2) 
            plot(timeValues,filteredOutputFlip)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Filtered Mass of Food Intake (" + massUnit + ")")
            title('Filtered Food Intake')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([filteredOutputFlip(1) ymaxHere2])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
            
            subplot(2,5,3) 
            plot(timeValues,dervFoodCumulative)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Food Consumption Rate (" + massUnit + "/d)")
            title('Rate of Food Consumption')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 ymaxHere3])
            xlim([xlimfoodderv xmaxfoodderv])
            lgd.FontSize = fontHere;

            subplot(2,5,4) 
            semilogy(rawMassFFTf,abs(rawMassFFT))
            axis tight
            xlabel("Frequency (Hz)")
            ylabel("Signal Magnitude")
            title('FFT of Raw Mass Values')
            %ylim([0 1.3])
            %xlim([0 10])
            lgd.FontSize = fontHere;

            subplot(2,5,5)
            imagesc(timeValues,fFood,abs(cfsFood))
            xlabel("Time (" + timeUnit + ")")
            ylabel('Frequency (Hz)')
            axis xy
            clim('auto')
            title('CWT of Food Intake')
            colorbar('eastoutside')
            
            subplot(2,5,6)
            plot(timeValues,interactionsBinary)
            hold on
            area(timeValues,lightColumnPlot,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Interactions")
            title('Binary Interactions')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 1.3])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
        
            subplot(2,5,7) 
            plot(timeValues,interactionsCountArray)
            hold on
            area(timeValues,lightColumnPlotInteractions.*1000,['' 'LineStyle'],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Total Number of Interactions")
            title('Cumulative Interactions')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 ymaxHere4])
            xlim([timeValues(1) xMax])
            lgd.FontSize = fontHere;
            
            subplot(2,5,8) 
            plot(timeValues,dervInteractionsCumulative)
            hold on
            area(timeValues,lightColumnPlotInteractions,['' 'LineStyle'],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Interaction Rate (Interactions/d)")
            title('Interaction Rate')
            xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 ymaxHere5])
            xlim([xlimintderv xmaxintderv])
            lgd.FontSize = fontHere; 
        
            subplot(2,5,9) 
            semilogy(dervInteractionsCumulativeFFTf,abs(dervInteractionsCumulativeFFT))
            axis tight
            xlabel("Frequency (Hz)")
            ylabel("Signal Magnitude")
            title('FFT of Interaction Rate')
            %ylim([0 1.3])
            %xlim([0 10])
            lgd.FontSize = fontHere;

            subplot(2,5,10) 
            imagesc(timeValues,fInteractions,abs(cfsInteractions))
            xlabel("Time (" + timeUnit + ")")
            ylabel('Frequency (Hz)')
            axis xy
            clim('auto')
            title('CWT of Interaction Rate')
            colorbar('eastoutside')

            % Enlarge figure to full screen.
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
            % Remove tool bar and pulldown menus
            set(gcf, 'Toolbar', 'none', 'Menu', 'none');
    
            figure5 = gcf;
        
            if isFirstInstance == "Y" && mean(dervFoodCumulative(1:(fooddervBuffer/2 - 1),1)) - mean(dervFoodCumulative((fooddervBuffer/2 + 1):(fooddervBuffer/2 + 30),1)) > 2
                fprintf("Large difference flagged: Does the first set of values appear unusually large?\n");
                prompt_shortDervCorrection = "Enter 'Y' if 'Yes' to apply the short-derivative correction, or 'N' if 'No': ";
                shortDervCorrection = input(prompt_shortDervCorrection,"s");
                % Error-checking for a valid entry
                shortDervCorrection = skrtkr_isentryerror("Y","N",shortDervCorrection);
                if shortDervCorrection == "Y"
                    dervFoodCumulative(1:(fooddervBuffer/2),1) = mean(dervFoodCumulative((ooddervBuffer/2 + 1):(fooddervBuffer/2 + 30),1));
                end
                isFirstInstance = "N";
            end
            % Ask whether the user is satisfied with filter options or 
            % whether they would like to adjust filter parameters
            fprintf("Are you satisfied with these derivative filters?\n");
            prompt_stopLoopingDerv = "Enter 'Y' if 'Yes', or 'N' if 'No' to adjust filter parameters: ";
            stopLoopingDerv = input(prompt_stopLoopingDerv,"s");
            % Error-checking for a valid entry
            stopLoopingDerv = skrtkr_isentryerror("Y","N",stopLoopingDerv);
        end

        % Step 6: LDR filtering

        % Determine whether light (ldr) data should be processed/filtered
        fprintf("Would you like to filter light (ldr) recordings?\n");
        prompt_doFilterLight = "Enter 'Y' for 'Yes', or 'N' for 'No' (e.g., " + doFilterLight + "): ";
        doFilterLight = input(prompt_doFilterLight,"s");
        % Error-checking for a valid doFilterLight entry
        doFilterLight = skrtkr_isentryerror("Y","N",doFilterLight);
        if doFilterLight == "Y"
            % Ask the user whether a binary or continuous 
            % filter is desired
            fprintf("Would you like to apply a binary or continuous (smoothing) filter?\n");
            prompt_lightFilterType = "Enter '0' for binary or '1' for continuous (e.g., " + lightFilterTypeEx + "): ";
            lightFilterType = input(prompt_lightFilterType,"s");
            % Error-checking for a valid doFilterLight entry
            lightFilterType = skrtkr_isentryerror("0","1",lightFilterType);
            % Initialise variable to iterate through parameter
            % selection/optimisations and visualisation
            % until indicated as satisfactory by the user
            doneFilteringLDR = "N";
            while doneFilteringLDR == "N"
                ldrColumnFiltered = ldrColumn;
                if lightFilterType == "0"
                    % Ask the user whether a smoothing filter is required 
                    % before applying the binary filter
                    fprintf("Would you like to apply a smoothing filter prior to binarisation?\n");
                    prompt_doSmoothBeforeBinary = "Enter 'Y' for 'Yes or 'N' for 'No': ";
                    doSmoothBeforeBinary = input(prompt_doSmoothBeforeBinary,"s");
                    % Error-checking for a valid entry
                    doSmoothBeforeBinary = skrtkr_isentryerror("Y","N",doSmoothBeforeBinary);
                    % Apply pre-binarisation smoothing filter if requested
                    if doSmoothBeforeBinary == "Y"                
                        prompt_smoothBeforeBinary = "Please enter the smoothing window over which a mean-value filter will be applied (e.g., " + smoothBeforeBinaryEx + "): ";
                        smoothBeforeBinary = input(prompt_smoothBeforeBinary);
                        % If switch 1 is to be used to filter LDR data
                        if sw1FilterLDR == "Y"
                            for n = 1:height(ldrColumnFiltered)
                                if switch1Column(n) == 1
                                    if n == 1
                                        % Set to 0 if the first reading
                                        ldrColumnFiltered(n) = 0;
                                    else
                                        % Set to the prior reading
                                        ldrColumnFiltered(n) = ldrColumnFiltered(n - 1);
                                    end
                                end
                            end
                        end
                        % If switch 2 is to be used to filter LDR data
                        if sw2FilterLDR == "Y"
                            for n = 1:height(ldrColumnFiltered)
                                if switch2Column(n) == 1
                                    if n == 1
                                        % Set to 0 if the first reading
                                        ldrColumnFiltered(n) = 0;
                                    else
                                        % Set to the prior reading
                                        ldrColumnFiltered(n) = ldrColumnFiltered(n - 1);
                                    end
                                end
                            end
                        end
                        % Apply mean smoothing filter
                        ldrColumnFiltered = movmean(ldrColumn,smoothBeforeBinary);
                    end
                    prompt_lightCutoff = "Please enter the cut-off value for LDR readings which indicates that the light is either ON or OFF (e.g., " + lightCutoff + "): ";
                    lightCutoff = input(prompt_lightCutoff);          
                    % Binarise light data if the recorded data
                    % value is greater to or less than the light cutoff
                    for n = 1:height(ldrColumnFiltered)
                        if ldrColumnFiltered(n) >= lightCutoff
                            ldrColumnFiltered(n) = 1;
                        else
                            ldrColumnFiltered(n) = 0;
                        end
                    end

                    % Plot light filters
        
                    figure(6)
        
                    subplot(2,1,1)
                    plot(timeValues,ldrColumn)
                    hold on
                    area(timeValues,lightColumnPlot.*5,['LineStyle' ''],'none','FaceColor','Yellow','FaceAlpha',0.3)
                    hold off
                    axis tight
                    xlabel("Time (" + timeUnit + ")")
                    ylabel("Raw Light (LDR) Reading")
                    title('Raw Light (LDR) Recordings')
                    xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
                    ylim([0 ylimLight])
                    xlim([timeValues(1) xMax])
                    lgd.FontSize = fontHere;
                    
                    subplot(2,1,2) 
                    plot(timeValues,ldrColumnFiltered)
                    hold on
                    area(timeValues,lightsOnOff.*1.3,['LineStyle' ''],'none','FaceColor','Yellow','FaceAlpha',0.3)
                    hold off
                    axis tight
                    xlabel("Time (" + timeUnit + ")")
                    ylabel("Binarised Light (LDR) Reading")
                    title('Binarised Light (LDR) Recordings')
                    xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
                    ylim([0 1.3])
                    xlim([timeValues(1) xMax])
                    lgd.FontSize = fontHere; 
            
                end
                if lightFilterType == "1"
                    prompt_smoothLightWindow = "Please enter the smoothing window over which a mean-value filter will be applied (e.g., " + smoothLightWindowEx + "): ";
                    smoothLightWindow = input(prompt_smoothLightWindow);
                    % If switch 1 is to be used to filter LDR data
                    if sw1FilterLDR == "Y"
                        for n = 1:height(ldrColumnFiltered)
                            if switch1Column(n) == 1
                                if n == 1
                                    % Set to 0 if the first reading
                                    ldrColumnFiltered(n) = 0;
                                else
                                    % Set to the prior reading
                                    ldrColumnFiltered(n) = ldrColumnFiltered(n - 1);
                                end
                            end
                        end
                    end
                    % If switch 2 is to be used to filter LDR data
                    if sw2FilterLDR == "Y"
                        for n = 1:height(ldrColumnFiltered)
                            if switch2Column(n) == 1
                                if n == 1
                                    % Set to 0 if the first reading
                                    ldrColumnFiltered(n) = 0;
                                else
                                    % Set to the prior reading
                                    ldrColumnFiltered(n) = ldrColumnFiltered(n - 1);
                                end
                            end
                        end
                    end
                    ldrColumnFiltered = movmean(ldrColumn,smoothLightWindow);

                    % Plot light filters
            
                    figure(6)
        
                    subplot(2,1,1)
                    plot(timeValues,ldrColumn)
                    axis tight
                    xlabel("Time (" + timeUnit + ")")
                    ylabel("Raw Light (LDR) Reading")
                    title('Raw Light (LDR) Recordings')
                    xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
                    ylim([0 ylimLight])
                    xlim([timeValues(1) xMax])
                    lgd.FontSize = fontHere;
                    
                    subplot(2,1,2) 
                    plot(timeValues,ldrColumnFiltered)
                    axis tight
                    xlabel("Time (" + timeUnit + ")")
                    ylabel("Smoothed Light (LDR) Reading")
                    title('Smoothed Light (LDR) Recordings')
                    xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
                    %ylim([0 yMax])
                    xlim([timeValues(1) xMax])
                    lgd.FontSize = fontHere;
            
                end

                % Enlarge figure to full screen.
                set(gcf, 'Units', 'Normalized', ['' 'OuterPosition'], [0 0 1 1]);
                % Remove tool bar and pulldown menus
                set(gcf, 'Toolbar', 'none', 'Menu', 'none');
    
                figure6 = gcf;
    
                % Ask whether the user is satisfied with filter options or 
                % whether they would like to adjust filter parameters
                fprintf("Is this filter satisfactory?\n");
                prompt_doneFilteringLDR = "Enter 'Y' if 'Yes', or 'N' if 'No' to adjust filter parameters: ";
                doneFilteringLDR = input(prompt_doneFilteringLDR,"s");
                % Error-checking for a valid entry
                doneFilteringLDR = skrtkr_isentryerror("Y","N",doneFilteringLDR);
            end
        else
            ldrColumnFiltered = ldrColumn;
        end

        % Step 7: output summary
        
        % Create a plot with all final output filters to visualise and 
        % evaluate whether filter speficiations need to be re-done
        ymaxHere6 = max(filteredOutputFlip)*1.3;
        ymaxHere7 = max(interactionsCountArray)*1.3;
        if ymaxHere5 == 0
            ymaxHere5 = 1;
        end
        if ymaxHere7 == 0
            ymaxHere7 = 1;
        end

        % Plot outputs
    
        figure(7)

        subplot(4,3,1)
        plot(timeValues,rawMass)
        hold on
        plot(timeValues,filteredOutput)
        hold off
        hold on
        area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Mass (" + massUnit + ")")
        title('Raw and Filtered Mass Recordings')
        xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 yMax])
        xlim([timeValues(1) xMax])
        lgd.FontSize = fontHere;

        subplot(4,3,2)
        plot(timeValues,interactionsBinary)
        hold on
        area(timeValues,lightsOnOff.*1.3,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Interactions")
        title('Binary Interactions')
        xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 1.3])
        xlim([timeValues(1) xMax])
        lgd.FontSize = fontHere;

        subplot(4,3,3)
        plot(timeValues,ldrColumn)
        hold on
        area(timeValues,lightColumnPlot.*4,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Light (LDR) Reading")
        title('Raw Light (LDR) Recordings')
        xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 ylimLight])
        xlim([timeValues(1) xMax])
        lgd.FontSize = fontHere;
         
        subplot(4,3,4)
        plot(timeValues,filteredOutputFlip)
        hold on
        area(timeValues,lightColumnPlot,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Filtered Mass of Food Consumed (" + massUnit + ")")
        title('Filtered Food Consumption')
        xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([filteredOutputFlip(1) ymaxHere6])
        xlim([timeValues(1) xMax])
        lgd.FontSize = fontHere;

        subplot(4,3,5)
        plot(timeValues,interactionsCountArray)
        hold on
        area(timeValues,lightColumnPlotInteractions.*1000,['' 'LineStyle'],'none','FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Total Number of Interactions")
        title('Cumulative Interactions')
        xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 ymaxHere7])
        xlim([timeValues(1) xMax])
        lgd.FontSize = fontHere;
        
        subplot(4,3,6)
        plot(timeValues,ldrColumnFiltered)
        hold on
        area(timeValues,lightsOnOff.*1.3,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Light (LDR) Reading")
        title('Filtered Light (LDR) Recordings')
        xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 1.3])
        xlim([timeValues(1) xMax])
        lgd.FontSize = fontHere;
        
        subplot(4,3,7)
        plot(timeValues,dervFoodCumulative)
        hold on
        area(timeValues,lightsOnOff.*40,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Food Consumption Rate (" + massUnit + "/d)")
        title('Rate of Food Consumption')
        xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 ymaxHere3])
        xlim([xlimfoodderv xmaxfoodderv])
        lgd.FontSize = fontHere;
    
        subplot(4,3,8)
        plot(timeValues,dervInteractionsCumulative)
        hold on
        area(timeValues,lightColumnPlotInteractions,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Interaction Rate (Interactions/d)")
        title('Rate of Animal-Device Interactions')
        xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 ymaxHere5])
        xlim([xlimintderv xmaxintderv])
        lgd.FontSize = fontHere;
        
        subplot(4,3,9)
        plot(timeValues,switch1Column)
        hold on
        area(timeValues,lightsOnOff.*1.3,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Switch 1 Status")
        title('Switch 1 Status')
        xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 1.3])
        xlim([timeValues(1) xMax])
        lgd.FontSize = fontHere;

        subplot(4,3,10)
        imagesc(timeValues,fFood,abs(cfsFood))
        xlabel("Time (" + timeUnit + ")")
        ylabel('Frequency (Hz)')
        axis xy
        clim('auto')
        title('CWT of Food Intake')
        colorbar('southoutside')
        
        subplot(4,3,11)
        imagesc(timeValues,fInteractions,abs(cfsInteractions))
        xlabel("Time (" + timeUnit + ")")
        ylabel('Frequency (Hz)')
        axis xy
        clim('auto')
        title('CWT of Interactions')
        colorbar('southoutside')
        
        subplot(4,3,12)
        plot(timeValues,switch2Column)
        hold on
        area(timeValues,lightsOnOff.*1.3,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Switch 2 Status")
        title('Switch 2 Status')
        xline([timeValues(startPointPos) timeValues(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 1.3])
        xlim([timeValues(1) xMax])
        lgd.FontSize = fontHere;

        % Enlarge figure to full screen.
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
        % Remove tool bar and pulldown menus
        set(gcf, 'Toolbar', 'none', 'Menu', 'none');
    
        figure7 = gcf;
    
        fprintf("Are you satisfied with these outputs?\n");
        prompt_finaliseOutput = "Enter 'Y' if 'Yes', or 'N' if 'No' to re-do filter parameter adjustments: ";
        finaliseOutput = input(prompt_finaliseOutput,"s");
        % Error-checking for a valid entry
        finaliseOutput = skrtkr_isentryerror("Y","N",finaliseOutput);
    end
    if do24HTruncation == "Y"
        newCropStart24H = startPointPos;
        newCropEnd24H = endPointPos;
    end
    if alignLight == "Y"
        newCropStart24H = startPointPos;
        newCropEnd24H = endPointPos;
    end

    % Step 8: cropping and alignment

    % If specified, truncate to 24h recordings
    if do24HTruncation == "Y"
        % Apply 24-hour cropping
        secondsOutCol = secondsOutCol(newCropStart24H:newCropEnd24H,1);
        secondsOutCol = secondsOutCol - secondsOutCol(1,1);
        timeValues = timeValues(newCropStart24H:newCropEnd24H,1);
        timeValues = timeValues - timeValues(1,1);
        hoursOutCol = hoursOutCol(newCropStart24H:newCropEnd24H,1);
        hoursOutCol = hoursOutCol - hoursOutCol(1,1);
        rawMass = rawMass(newCropStart24H:newCropEnd24H,1);
        filteredOutput = filteredOutput(newCropStart24H:newCropEnd24H,1);
        filteredOutputFlip = filteredOutputFlip(newCropStart24H:newCropEnd24H,1);
        filteredOutputFlip = filteredOutputFlip - filteredOutputFlip(1,1);
        dervFoodCumulative = dervFoodCumulative(newCropStart24H:newCropEnd24H,1);
        amplitudeArray = amplitudeArray(newCropStart24H:newCropEnd24H,1);
        interactionsBinary = interactionsBinary(newCropStart24H:newCropEnd24H,1);
        interactionsCountArray = interactionsCountArray(newCropStart24H:newCropEnd24H,1);
        interactionsCountArray = interactionsCountArray - interactionsCountArray(1,1);
        dervInteractionsCumulative = dervInteractionsCumulative(newCropStart24H:newCropEnd24H,1);
        rawMassFFT = rawMassFFT(newCropStart24H:newCropEnd24H,1);
        dervInteractionsCumulativeFFT = dervInteractionsCumulativeFFT(newCropStart24H:newCropEnd24H,1);
        ldrColumn = ldrColumn(newCropStart24H:newCropEnd24H,1);
        ldrColumnFiltered = ldrColumnFiltered(newCropStart24H:newCropEnd24H,1);
        switch1Column = switch1Column(newCropStart24H:newCropEnd24H,1);
        switch2Column = switch2Column(newCropStart24H:newCropEnd24H,1);
        lightsOnOff = lightsOnOff(newCropStart24H:newCropEnd24H,1);
        lightColumnPlot = lightColumnPlot(newCropStart24H:newCropEnd24H,1);
        startPointPos = 1;
        endPointPos = height(timeValues);
    end
    if do24HTruncation == "Y"
        newCropStart24H = 1;
        newCropEnd24H = height(timeValues);
    end
    if alignLight == "Y"
        newCropStart24H = 1;
        newCropEnd24H = height(timeValues);
    end
    % If it is decided to align to light, re-shape the plot such
    % that any values (which are to ultimately be obtained) prior
    % to the first specified light instance (i.e., turning ON or
    % OFF) are shifted to the end of the array 
    if alignLight == "Y"
        alignOK = "N";
        while alignOK == "N"
            indexFoundAlign = 0;
            customMassShift = "N";
            % Create a copy of the arrays which need to be transformed
            secondsOutColCopy = secondsOutCol;
            hoursOutColCopy = hoursOutCol;
            timeValuesCopy = timeValues;
            rawMassCopy = rawMass;
            filteredOutputCopy = filteredOutput;
            filteredOutputFlipCopy = filteredOutputFlip;
            interactionsCountArrayCopy = interactionsCountArray;
            % Create a copy of the arrays not needing rearrangement
            dervFoodCumulativeCopy = dervFoodCumulative;
            amplitudeArrayCopy = amplitudeArray;
            interactionsBinaryCopy = interactionsBinary;
            dervInteractionsCumulativeCopy = dervInteractionsCumulative;
            ldrColumnCopy = ldrColumn;
            ldrColumnFilteredCopy = ldrColumnFiltered;
            switch1ColumnCopy = switch1Column;
            switch2ColumnCopy = switch2Column;
            lightsOnOffCopy = lightsOnOff;
            lightColumnPlotCopy = lightColumnPlot;
            % Scanning lightsOnOff to identify the light-specified shift
            % index
            for u = 1:length(lightsOnOffCopy)
                % Find the first instance of lights turning ON
                if lightAlignFor24HCropONOFF == "1"
                    if u ~= 1 && indexFoundAlign == 0
                        if lightsOnOffCopy(u - 1) == 0 && lightsOnOffCopy(u) == 1
                            % Record the index
                            alignmentStartIndex = u - 1;
                            indexFoundAlign = 1;
                        end
                    end
                elseif lightAlignFor24HCropONOFF == "0"
                    if u ~= 1 && indexFoundAlign == 0
                        if lightsOnOffCopy(u - 1) == 1 && lightsOnOffCopy(u) == 0
                            % Record the index
                            alignmentStartIndex = u - 1;
                            indexFoundAlign = 1;
                        end
                    end
                end
            end
            % Determine the corresponding time and mass values needing
            % shift corrections prior to shifting, beginning with time
            alignmentStartSecondsOutCol = secondsOutColCopy(alignmentStartIndex + 1);
            alignmentStartHoursOutCol = hoursOutColCopy(alignmentStartIndex + 1);
            alignmentStartTime = timeValuesCopy(alignmentStartIndex + 1);
            % Calculate the difference between the
            % first minute of registered mass
            % recordings and the first minute of
            % registered mass recordings
            % following alignmentStartIndex
            alignmentStartMassDiff = filteredOutputCopy(1) - filteredOutputCopy(height(lightsOnOffCopy) - alignmentStartIndex + 1);
            % Re-arrange the data arrays to align with light cycles
            % Arrays which will need rearrangement
            secondsOutColCopy = circshift(secondsOutColCopy,[-alignmentStartIndex 0]);
            hoursOutColCopy = circshift(hoursOutColCopy,[-alignmentStartIndex 0]);
            timeValuesCopy = circshift(timeValuesCopy,[-alignmentStartIndex 0]);
            rawMassCopy = circshift(rawMassCopy,[-alignmentStartIndex 0]);
            filteredOutputCopy = circshift(filteredOutputCopy,[-alignmentStartIndex 0]);
            filteredOutputFlipCopy = circshift(filteredOutputFlipCopy,[-alignmentStartIndex 0]);
            interactionsCountArrayCopy = circshift(interactionsCountArrayCopy,[-alignmentStartIndex 0]);
            % Now for arrays which did not need rearrangement
            dervFoodCumulativeCopy = circshift(dervFoodCumulativeCopy,[-alignmentStartIndex 0]);
            amplitudeArrayCopy = circshift(amplitudeArrayCopy,[-alignmentStartIndex 0]);
            interactionsBinaryCopy = circshift(interactionsBinaryCopy,[-alignmentStartIndex 0]);
            dervInteractionsCumulativeCopy = circshift(dervInteractionsCumulativeCopy,[-alignmentStartIndex 0]);
            ldrColumnCopy = circshift(ldrColumnCopy,[-alignmentStartIndex 0]);
            ldrColumnFilteredCopy = circshift(ldrColumnFilteredCopy,[-alignmentStartIndex 0]);
            switch1ColumnCopy = circshift(switch1ColumnCopy,[-alignmentStartIndex 0]);
            switch2ColumnCopy = circshift(switch2ColumnCopy,[-alignmentStartIndex 0]);
            lightsOnOffCopy = circshift(lightsOnOffCopy,[-alignmentStartIndex 0]);
            lightColumnPlotCopy = circshift(lightColumnPlotCopy,[-alignmentStartIndex 0]);
            % Determine the time correction
            if timeFormat == "w"
                time24Hcorrect = (1/7)*howMany24H;
            elseif timeFormat == "d"
                time24Hcorrect = 1*howMany24H;
            elseif timeFormat == "h"
                time24Hcorrect = 24*howMany24H;
            elseif timeFormat == "m"
                time24Hcorrect = (24*60)*howMany24H;
            elseif timeFormat == "s"
                time24Hcorrect = (24*60*60)*howMany24H;
            end
            % Determined the filtered output and interactions corrections
            % for the first shifted block
            filteredOutputFlipNewStartVal = filteredOutputFlipCopy(1,1);
            interactionsCountArrayNewStartVal = interactionsCountArrayCopy(1,1);
            % Apply corrections to the first block of values shifted 
            % to the beginning of each array
            for g = 1:(height(lightsOnOffCopy) - alignmentStartIndex)
                secondsOutColCopy(g,1) = secondsOutColCopy(g,1) - alignmentStartSecondsOutCol;
                hoursOutColCopy(g,1) = hoursOutColCopy(g,1) - alignmentStartHoursOutCol;
                timeValuesCopy(g,1) = timeValuesCopy(g,1) - alignmentStartTime;
                rawMassCopy(g,1) = rawMassCopy(g,1) + alignmentStartMassDiff;
                filteredOutputCopy(g,1) = filteredOutputCopy(g,1) + alignmentStartMassDiff;
                filteredOutputFlipCopy(g,1) = filteredOutputFlipCopy(g,1) - filteredOutputFlipNewStartVal;
                interactionsCountArrayCopy(g,1) = interactionsCountArrayCopy(g,1) - interactionsCountArrayNewStartVal;
            end
            % Determine corrections for the second shifted block
            alignmentEndMassDiff = filteredOutputCopy((height(lightsOnOffCopy) - alignmentStartIndex + 1),1) - filteredOutputCopy((height(lightsOnOffCopy) - alignmentStartIndex),1);
            filteredOutputFlipEndDiff = filteredOutputFlipCopy(end - alignmentStartIndex - 1) - filteredOutputFlipCopy(end - alignmentStartIndex);
            interactionsCountArrayEndDiff = interactionsCountArrayCopy(end - alignmentStartIndex - 1) - interactionsCountArrayCopy(end - alignmentStartIndex);
            % Apply corrections to the second block of values shifted
            % to the end of each array
            for g = (height(lightsOnOffCopy) - alignmentStartIndex + 1):height(secondsOutColCopy)
                secondsOutColCopy(g,1) = secondsOutColCopy(g,1) + secondsOutColCopy((height(lightsOnOffCopy) - alignmentStartIndex),1);
                hoursOutColCopy(g,1) = hoursOutColCopy(g,1) + hoursOutColCopy((height(lightsOnOffCopy) - alignmentStartIndex),1);
                timeValuesCopy(g,1) = timeValuesCopy(g,1) + timeValuesCopy((height(lightsOnOffCopy) - alignmentStartIndex),1);
                rawMassCopy(g,1) = rawMassCopy(g,1) - alignmentEndMassDiff;
                filteredOutputCopy(g,1) = filteredOutputCopy(g,1) - alignmentEndMassDiff;
                filteredOutputFlipCopy(g,1) = filteredOutputFlipCopy(g,1) + filteredOutputFlipCopy((height(lightsOnOffCopy) - alignmentStartIndex),1);
                interactionsCountArrayCopy(g,1) = interactionsCountArrayCopy(g,1) + interactionsCountArrayCopy((height(lightsOnOffCopy) - alignmentStartIndex),1);
            end
            % Plot data after light shifting and 24-hour truncation (will 
            % need to apply to more datasets once configured above)
        
            figure(8)

            subplot(4,3,1)
            plot(timeValuesCopy,rawMassCopy)
            hold on
            plot(timeValuesCopy,filteredOutputCopy)
            hold off
            hold on
            area(timeValuesCopy,lightColumnPlotCopy,['LineStyle' ''],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            title('Raw and Filtered Mass Recordings')
            ylim([0 yMax])
            xlim([timeValuesCopy(1) timeValuesCopy(end)])
            lgd.FontSize = fontHere;
    
            subplot(4,3,2)
            plot(timeValuesCopy,interactionsBinaryCopy)
            hold on
            area(timeValuesCopy,lightsOnOffCopy.*1.3,['' 'LineStyle'],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Interactions")
            title('Binary Interactions')
            ylim([0 1.3])
            xlim([timeValuesCopy(1) timeValuesCopy(end)])
            lgd.FontSize = fontHere;
    
            subplot(4,3,3)
            plot(timeValuesCopy,ldrColumnCopy)
            hold on
            area(timeValuesCopy,lightColumnPlotCopy.*4,['' 'LineStyle'],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Light (LDR) Reading")
            title('Raw Light (LDR) Recordings')
            ylim([0 ylimLight])
            xlim([timeValuesCopy(1) timeValuesCopy(end)])
            lgd.FontSize = fontHere;
             
            subplot(4,3,4)
            plot(timeValuesCopy,filteredOutputFlipCopy)
            hold on
            area(timeValuesCopy,lightColumnPlotCopy,['' 'LineStyle'],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Filtered Mass of Food Consumed (" + massUnit + ")")
            title('Filtered Food Consumption')
            ylim([filteredOutputFlipCopy(1) ymaxHere6])
            xlim([timeValuesCopy(1) timeValuesCopy(end)])
            lgd.FontSize = fontHere;
    
            subplot(4,3,5)
            plot(timeValuesCopy,interactionsCountArrayCopy)
            hold on
            area(timeValuesCopy,lightColumnPlotCopy.*50000,['' 'LineStyle'],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Total Number of Interactions")
            title('Cumulative Interactions')
            ylim([0 ymaxHere7])
            xlim([timeValuesCopy(1) timeValuesCopy(end)])
            lgd.FontSize = fontHere;
            
            subplot(4,3,6)
            plot(timeValuesCopy,ldrColumnFilteredCopy)
            hold on
            area(timeValuesCopy,lightsOnOffCopy.*1.3,['' 'LineStyle'],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Light (LDR) Reading")
            title('Filtered Light (LDR) Recordings')
            ylim([0 1.3])
            xlim([timeValuesCopy(1) timeValuesCopy(end)])
            lgd.FontSize = fontHere;
            
            subplot(4,3,7)
            plot(timeValuesCopy,dervFoodCumulativeCopy)
            hold on
            area(timeValuesCopy,lightsOnOffCopy.*40,['' 'LineStyle'],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Food Consumption Rate (" + massUnit + "/d)")
            title('Rate of Food Consumption')
            ylim([0 ymaxHere3])
            xlim([timeValuesCopy(1) timeValuesCopy(end)])
            lgd.FontSize = fontHere;
        
            subplot(4,3,8)
            plot(timeValuesCopy,dervInteractionsCumulativeCopy)
            hold on
            area(timeValuesCopy,lightColumnPlotCopy.*50000,['' 'LineStyle'],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Interaction Rate (Interactions/d)")
            title('Rate of Animal-Device Interactions')
            ylim([0 ymaxHere5])
            xlim([timeValuesCopy(1) timeValuesCopy(end)])
            lgd.FontSize = fontHere;
            
            subplot(4,3,9)
            plot(timeValuesCopy,switch1ColumnCopy)
            hold on
            area(timeValuesCopy,lightsOnOffCopy.*1.3,['' 'LineStyle'],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Switch 1 Status")
            title('Switch 1 Status')
            ylim([0 1.3])
            xlim([timeValuesCopy(1) timeValuesCopy(end)])
            lgd.FontSize = fontHere;
    
            subplot(4,3,10)
            imagesc(timeValues,fFood,abs(cfsFood))
            xlabel("Time (" + timeUnit + ")")
            ylabel('Frequency (Hz)')
            axis xy
            clim('auto')
            title('CWT of Food Intake')
            colorbar('southoutside')
            
            subplot(4,3,11)
            imagesc(timeValues,fInteractions,abs(cfsInteractions))
            xlabel("Time (" + timeUnit + ")")
            ylabel('Frequency (Hz)')
            axis xy
            clim('auto')
            title('CWT of Interactions')
            colorbar('southoutside')
            
            subplot(4,3,12)
            plot(timeValuesCopy,switch2ColumnCopy)
            hold on
            area(timeValuesCopy,lightsOnOffCopy.*1.3,['' 'LineStyle'],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Switch 2 Status")
            title('Switch 2 Status')
            ylim([0 1.3])
            xlim([timeValuesCopy(1) timeValuesCopy(end)])
            lgd.FontSize = fontHere;

            % Enlarge figure to full screen.
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
            % Remove tool bar and pulldown menus
            set(gcf, 'Toolbar', 'none', 'Menu', 'none');

            figure8 = gcf;

            % Ask whether the user is satisfied with the cutoff points
            fprintf("Is this alignment satisfactory?\n");
            prompt_alignOK = "Enter 'Y' if 'Yes', or 'N' if 'No' to adjust shift parameters: ";
            alignOK = input(prompt_alignOK,"s");
            % Error-checking for a valid entry
            alignOK = skrtkr_isentryerror("Y","N",alignOK);
            if alignOK == "N"
                fprintf("Error with light alignment. Exiting program.\n");
                return
            end
        end
        % Overwright arrays for final data export
        secondsOutCol = secondsOutColCopy;
        hoursOutCol = hoursOutColCopy;
        timeValues = timeValuesCopy;
        rawMass = rawMassCopy;
        filteredOutput = filteredOutputCopy;
        filteredOutputFlip = filteredOutputFlipCopy;
        interactionsCountArray = interactionsCountArrayCopy;
        dervFoodCumulative = dervFoodCumulativeCopy;
        amplitudeArray = amplitudeArrayCopy;
        interactionsBinary = interactionsBinaryCopy;
        dervInteractionsCumulative = dervInteractionsCumulativeCopy;
        ldrColumn = ldrColumnCopy;
        ldrColumnFiltered = ldrColumnFilteredCopy;
        switch1Column = switch1ColumnCopy;
        switch2Column = switch2ColumnCopy;
        lightsOnOff = lightsOnOffCopy;
        lightColumnPlot = lightColumnPlotCopy;
    elseif alignLight == "N" && do24HTruncation == "Y"
        % Still plot figure 8 to show results after 24-hour truncation

        figure(8)

        subplot(4,3,1)
        plot(timeValues,rawMass)
        hold on
        plot(timeValues,filteredOutput)
        hold off
        hold on
        area(timeValues,lightColumnPlot,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Mass (" + massUnit + ")")
        title('Raw and Filtered Mass Recordings')
        ylim([0 yMax])
        xlim([timeValues(1) timeValues(end)])
        lgd.FontSize = fontHere;

        subplot(4,3,2)
        plot(timeValues,interactionsBinary)
        hold on
        area(timeValues,lightsOnOff.*1.3,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Interactions")
        title('Binary Interactions')
        ylim([0 1.3])
        xlim([timeValues(1) timeValues(end)])
        lgd.FontSize = fontHere;

        subplot(4,3,3)
        plot(timeValues,ldrColumn)
        hold on
        area(timeValues,lightColumnPlot.*4,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Light (LDR) Reading")
        title('Raw Light (LDR) Recordings')
        ylim([0 ylimLight])
        xlim([timeValues(1) timeValues(end)])
        lgd.FontSize = fontHere;
         
        subplot(4,3,4)
        plot(timeValues,filteredOutputFlip)
        hold on
        area(timeValues,lightColumnPlot,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Filtered Mass of Food Consumed (" + massUnit + ")")
        title('Filtered Food Consumption')
        ylim([filteredOutputFlip(1) ymaxHere6])
        xlim([timeValues(1) timeValues(end)])
        lgd.FontSize = fontHere;

        subplot(4,3,5)
        plot(timeValues,interactionsCountArray,'b')
        hold on
        area(timeValues,lightColumnPlot.*500,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Total Number of Interactions")
        title('Cumulative Interactions')
        ylim([0 ymaxHere7])
        xlim([timeValues(1) timeValues(end)])
        lgd.FontSize = fontHere;
        
        subplot(4,3,6)
        plot(timeValues,ldrColumnFiltered)
        hold on
        area(timeValues,lightsOnOff.*1.3,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Light (LDR) Reading")
        title('Filtered Light (LDR) Recordings')
        ylim([0 1.3])
        xlim([timeValues(1) timeValues(end)])
        lgd.FontSize = fontHere;
        
        subplot(4,3,7)
        plot(timeValues,dervFoodCumulative)
        hold on
        area(timeValues,lightsOnOff.*40,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Food Consumption Rate (" + massUnit + "/d)")
        title('Rate of Food Consumption')
        ylim([0 ymaxHere3])
        xlim([timeValues(1) timeValues(end)])
        lgd.FontSize = fontHere;
    
        subplot(4,3,8)
        plot(timeValues,dervInteractionsCumulative)
        hold on
        area(timeValues,lightsOnOff.*50000,'LineStyle',['none' ''],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Interaction Rate (Interactions/d)")
        title('Rate of Animal-Device Interactions')
        ylim([0 ymaxHere5])
        xlim([timeValues(1) timeValues(end)])
        lgd.FontSize = fontHere;
        
        subplot(4,3,9)
        plot(timeValues,switch1Column)
        hold on
        area(timeValues,lightsOnOff.*1.3,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Switch 1 Status")
        title('Switch 1 Status')
        ylim([0 1.3])
        xlim([timeValues(1) timeValues(end)])
        lgd.FontSize = fontHere;

        subplot(4,3,10)
        imagesc(timeValues,fFood,abs(cfsFood))
        xlabel("Time (" + timeUnit + ")")
        ylabel('Frequency (Hz)')
        axis xy
        clim('auto')
        title('CWT of Food Intake')
        colorbar('southoutside')
        
        subplot(4,3,11)
        imagesc(timeValues,fInteractions,abs(cfsInteractions))
        xlabel("Time (" + timeUnit + ")")
        ylabel('Frequency (Hz)')
        axis xy
        clim('auto')
        title('CWT of Interactions')
        colorbar('southoutside')
        
        subplot(4,3,12)
        plot(timeValues,switch2Column)
        hold on
        area(timeValues,lightsOnOff.*1.3,'LineStyle','none',['' 'FaceColor'],'Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Switch 2 Status")
        title('Switch 2 Status')
        ylim([0 1.3])
        xlim([timeValues(1) timeValues(end)])
        lgd.FontSize = fontHere;

        % Enlarge figure to full screen.
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
        % Remove tool bar and pulldown menus
        set(gcf, 'Toolbar', 'none', 'Menu', 'none');
    
        figure8 = gcf;

    end

    % Step 9: data compression
    
    % Enter information regarding output data file compression
    prompt_doFileCompression = "Would you like to compress final outputs? Enter 'Y' if 'Yes' and 'N' if 'No': ";
    doFileCompression = input(prompt_doFileCompression,"s");
    % Error-checking for a valid entry
    doFileCompression = skrtkr_isentryerror("Y","N",doFileCompression); 
    if doFileCompression == "Y"
        compressionOK = "N";
        while compressionOK == "N"
            prompt_compressSecondsFactor = "Indicate compression by binned seconds (enter '0') or a condensing factor ('1') (ideally '0'): ";
            compressSecondsFactor = input(prompt_compressSecondsFactor,"s");
            % Error-checking for a valid entry
            compressSecondsFactor = skrtkr_isentryerror("0","1",compressSecondsFactor);
            if compressSecondsFactor == "0"
                % If seconds-based (i.e., binned by seconds)
                prompt_binDuration = "How many seconds will be used for binning (an integer, e.g., 60): ";
                binDuration = input(prompt_binDuration);
                % Determine the number of bins in the timeframe
                numBins = floor(floor(secondsOutCol(end))/binDuration);
                % Create a new binned seconds array accordingly, with
                % values to represent the midpoint of each bin, for
                % eventual data reporting
                secondsOutColComp = zeros(numBins,1);
                % Populate secondsOutColComp and binEdges
                for b = 1:numBins
                    secondsOutColComp(b,1) = (binDuration/2) + binDuration*(b - 1);
                end
                % Apply data compression
                if timeFormat == "w"
                    timeValuesComp = secondsOutColComp./(60*60*24*7);
                elseif timeFormat == "d"
                    timeValuesComp = secondsOutColComp./(60*60*24);
                elseif timeFormat == "h"
                    timeValuesComp = secondsOutColComp./(60*60);
                elseif timeFormat == "m"
                    timeValuesComp = secondsOutColComp./(60);
                elseif timeFormat == "s"
                    timeValuesComp = secondsOutColComp;
                end 
                hoursOutColComp = dataCompressionBin(hoursOutCol,secondsOutCol,binDuration,1);
                rawMassComp = dataCompressionBin(rawMass,secondsOutCol,binDuration,1);
                filteredOutputComp = dataCompressionBin(filteredOutput,secondsOutCol,binDuration,1);
                filteredOutputFlipComp = dataCompressionBin(filteredOutputFlip,secondsOutCol,binDuration,1);
                dervFoodCumulativeComp = dataCompressionBin(dervFoodCumulative,secondsOutCol,binDuration,1);
                amplitudeArrayComp = dataCompressionBin(amplitudeArray,secondsOutCol,binDuration,1);
                interactionsBinaryComp = dataCompressionBin(interactionsBinary,secondsOutCol,binDuration,0);
                interactionsCountArrayComp = dataCompressionBin(interactionsCountArray,secondsOutCol,binDuration,1);
                dervInteractionsCumulativeComp = dataCompressionBin(dervInteractionsCumulative,secondsOutCol,binDuration,1);
                rawMassFFTComp = dataCompressionBin(rawMassFFT,secondsOutCol,binDuration,1);
                dervInteractionsCumulativeFFTComp = dataCompressionBin(dervInteractionsCumulativeFFT,secondsOutCol,binDuration,1);
                ldrColumnComp = dataCompressionBin(ldrColumn,secondsOutCol,binDuration,1);
                ldrColumnFilteredComp = dataCompressionBin(ldrColumnFiltered,secondsOutCol,binDuration,0);
                switch1ColumnComp = dataCompressionBin(switch1Column,secondsOutCol,binDuration,0);
                switch2ColumnComp = dataCompressionBin(switch2Column,secondsOutCol,binDuration,0);
                lightsOnOffComp = dataCompressionBin(lightsOnOff,secondsOutCol,binDuration,0);
                lightColumnPlotComp = dataCompressionBin(lightColumnPlot,secondsOutCol,binDuration,0);
                % Plot figure to show results after 24-hour truncation
                startPointPos = 1;
                endPointPos = height(timeValuesComp);
            elseif compressSecondsFactor == "1"
                % Enter the file compression factor, which represents the
                % number of data values which will be averaged and
                % thereafter represented by a single mean value
                prompt_fileCompFactor = "Please enter the file condensing factor (e.g., 100): ";
                fileCompFactor = input(prompt_fileCompFactor);
                % Compress all data outputs according to the specified
                % compression factor by applying the end-of-script  
                % function dataCompression to outputs
                secondsOutColComp = dataCompression(secondsOutColComp,fileCompFactor,1);
                timeValuesComp = dataCompression(timeValues,fileCompFactor,1);
                rawMassComp = dataCompression(rawMass,fileCompFactor,1);
                filteredOutputComp = dataCompression(filteredOutput,fileCompFactor,1);
                filteredOutputFlipComp = dataCompression(filteredOutputFlip,fileCompFactor,1);
                dervFoodCumulativeComp = dataCompression(dervFoodCumulative,fileCompFactor,1);
                amplitudeArrayComp = dataCompression(amplitudeArray,fileCompFactor,1);
                interactionsBinaryComp = dataCompression(interactionsBinary,fileCompFactor,0);
                interactionsCountArrayComp = dataCompression(interactionsCountArray,fileCompFactor,1);
                dervInteractionsCumulativeComp = dataCompression(dervInteractionsCumulative,fileCompFactor,1);
                rawMassFFTComp = dataCompression(rawMassFFT,fileCompFactor,1);
                dervInteractionsCumulativeFFTComp = dataCompression(dervInteractionsCumulativeFFT,fileCompFactor,1);
                ldrColumnComp = dataCompression(ldrColumn,fileCompFactor,1);
                ldrColumnFilteredComp = dataCompression(ldrColumnFiltered,fileCompFactor,0);
                switch1ColumnComp = dataCompression(switch1Column,fileCompFactor,0);
                switch2ColumnComp = dataCompression(switch2Column,fileCompFactor,0);
                lightsOnOffComp = dataCompression(lightsOnOff,fileCompFactor,0);
                lightColumnPlotComp = dataCompression(lightColumnPlot,fileCompFactor,0);
                % Plot figure to show results after 24-hour truncation
                startPointPos = 1;
                endPointPos = height(timeValuesComp);
            end
            % Plot according to file compression

            figure(9)
    
            subplot(4,3,1)
            plot(timeValuesComp,rawMassComp)
            hold on
            plot(timeValuesComp,filteredOutputComp)
            hold off
            hold on
            area(timeValuesComp,lightColumnPlotComp,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Mass (" + massUnit + ")")
            title('Raw and Filtered Mass Recordings')
            xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 yMax])
            xlim([timeValuesComp(1) timeValuesComp(end)])
            lgd.FontSize = fontHere;
    
            subplot(4,3,2)
            plot(timeValuesComp,interactionsBinaryComp)
            hold on
            area(timeValuesComp,lightsOnOffComp.*1.3,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Interactions")
            title('Binary Interactions')
            xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 1.3])
            xlim([timeValuesComp(1) timeValuesComp(end)])
            lgd.FontSize = fontHere;
    
            subplot(4,3,3)
            plot(timeValuesComp,ldrColumnComp)
            hold on
            area(timeValuesComp,lightColumnPlotComp.*4,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Light (LDR) Reading")
            title('Raw Light (LDR) Recordings')
            xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 ylimLight])
            xlim([timeValuesComp(1) timeValuesComp(end)])
            lgd.FontSize = fontHere;
             
            subplot(4,3,4)
            plot(timeValuesComp,filteredOutputFlipComp)
            hold on
            area(timeValuesComp,lightColumnPlotComp,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Filtered Mass of Food Consumed (" + massUnit + ")")
            title('Filtered Food Consumption')
            xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([filteredOutputFlipComp(1) ymaxHere6])
            xlim([timeValuesComp(1) timeValuesComp(end)])
            lgd.FontSize = fontHere;
    
            subplot(4,3,5)
            plot(timeValuesComp,interactionsCountArrayComp,'b')
            hold on
            area(timeValuesComp,lightColumnPlotComp.*500,['LineStyle' ''],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Total Number of Interactions")
            title('Cumulative Interactions')
            xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 ymaxHere7])
            xlim([timeValuesComp(1) timeValuesComp(end)])
            lgd.FontSize = fontHere;
            
            subplot(4,3,6)
            plot(timeValuesComp,ldrColumnFilteredComp)
            hold on
            area(timeValuesComp,lightsOnOffComp.*1.3,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Light (LDR) Reading")
            title('Filtered Light (LDR) Recordings')
            xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 1.3])
            xlim([timeValuesComp(1) timeValuesComp(end)])
            lgd.FontSize = fontHere;
            
            subplot(4,3,7)
            plot(timeValuesComp,dervFoodCumulativeComp)
            hold on
            area(timeValuesComp,lightsOnOffComp.*40,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Food Consumption Rate (" + massUnit + "/d)")
            title('Rate of Food Consumption')
            xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 ymaxHere3])
            xlim([timeValuesComp(1) timeValuesComp(end)])
            lgd.FontSize = fontHere;
        
            subplot(4,3,8)
            plot(timeValuesComp,dervInteractionsCumulativeComp)
            hold on
            area(timeValuesComp,lightsOnOffComp.*50000,['LineStyle' ''],'none','FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Interaction Rate (Interactions/d)")
            title('Rate of Animal-Device Interactions')
            xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 ymaxHere5])
            xlim([timeValuesComp(1) timeValuesComp(end)])
            lgd.FontSize = fontHere;
            
            subplot(4,3,9)
            plot(timeValuesComp,switch1ColumnComp)
            hold on
            area(timeValuesComp,lightsOnOffComp.*1.3,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Switch 1 Status")
            title('Switch 1 Status')
            xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 1.3])
            xlim([timeValuesComp(1) timeValuesComp(end)])
            lgd.FontSize = fontHere;
    
            subplot(4,3,10)
            imagesc(timeValues,fFood,abs(cfsFood))
            xlabel("Time (" + timeUnit + ")")
            ylabel('Frequency (Hz)')
            axis xy
            clim('auto')
            title('CWT of Food Intake')
            colorbar('southoutside')
            
            subplot(4,3,11)
            imagesc(timeValues,fInteractions,abs(cfsInteractions))
            xlabel("Time (" + timeUnit + ")")
            ylabel('Frequency (Hz)')
            axis xy
            clim('auto')
            title('CWT of Interactions')
            colorbar('southoutside')
            
            subplot(4,3,12)
            plot(timeValuesComp,switch2ColumnComp)
            hold on
            area(timeValuesComp,lightsOnOffComp.*1.3,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
            hold off
            axis tight
            xlabel("Time (" + timeUnit + ")")
            ylabel("Switch 2 Status")
            title('Switch 2 Status')
            xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
            ylim([0 1.3])
            xlim([timeValuesComp(1) timeValuesComp(end)])
            lgd.FontSize = fontHere;
    
            % Enlarge figure to full screen.
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
            % Remove tool bar and pulldown menus
            set(gcf, 'Toolbar', 'none', 'Menu', 'none');
        
            figure9 = gcf;

            % Ask whether the user is satisfied with compressions
            fprintf("Is this compression satisfactory?\n");
            prompt_compressionOK = "Enter 'Y' if 'Yes', or 'N' if 'No' to adjust compression parameters: ";
            compressionOK = input(prompt_compressionOK,"s");
            % Error-checking for a valid entry
            compressionOK = skrtkr_isentryerror("Y","N",compressionOK);
        end
    end
    % For all other data files, once parameters have been established
    if doFileCompression == "Y"
        % Plot according to file compression

        figure(9)

        subplot(4,3,1)
        plot(timeValuesComp,rawMassComp)
        hold on
        plot(timeValuesComp,filteredOutputComp)
        hold off
        hold on
        area(timeValuesComp,lightColumnPlotComp,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Mass (" + massUnit + ")")
        title('Raw and Filtered Mass Recordings')
        xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 yMax])
        xlim([timeValuesComp(1) timeValuesComp(end)])
        lgd.FontSize = fontHere;

        subplot(4,3,2)
        plot(timeValuesComp,interactionsBinaryComp)
        hold on
        area(timeValuesComp,lightsOnOffComp.*1.3,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Interactions")
        title('Binary Interactions')
        xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 1.3])
        xlim([timeValuesComp(1) timeValuesComp(end)])
        lgd.FontSize = fontHere;

        subplot(4,3,3)
        plot(timeValuesComp,ldrColumnComp)
        hold on
        area(timeValuesComp,lightColumnPlotComp.*4,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Light (LDR) Reading")
        title('Raw Light (LDR) Recordings')
        xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 ylimLight])
        xlim([timeValuesComp(1) timeValuesComp(end)])
        lgd.FontSize = fontHere;
         
        subplot(4,3,4)
        plot(timeValuesComp,filteredOutputFlipComp)
        hold on
        area(timeValuesComp,lightColumnPlotComp,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Filtered Mass of Food Consumed (" + massUnit + ")")
        title('Filtered Food Consumption')
        xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([filteredOutputFlipComp(1) ymaxHere6])
        xlim([timeValuesComp(1) timeValuesComp(end)])
        lgd.FontSize = fontHere;

        subplot(4,3,5)
        plot(timeValuesComp,interactionsCountArrayComp,'b')
        hold on
        area(timeValuesComp,lightColumnPlotComp.*500,['LineStyle' ''],'none','FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Total Number of Interactions")
        title('Cumulative Interactions')
        xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 ymaxHere7])
        xlim([timeValuesComp(1) timeValuesComp(end)])
        lgd.FontSize = fontHere;
        
        subplot(4,3,6)
        plot(timeValuesComp,ldrColumnFilteredComp)
        hold on
        area(timeValuesComp,lightsOnOffComp.*1.3,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Light (LDR) Reading")
        title('Filtered Light (LDR) Recordings')
        xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 1.3])
        xlim([timeValuesComp(1) timeValuesComp(end)])
        lgd.FontSize = fontHere;
        
        subplot(4,3,7)
        plot(timeValuesComp,dervFoodCumulativeComp)
        hold on
        area(timeValuesComp,lightsOnOffComp.*40,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Food Consumption Rate (" + massUnit + "/d)")
        title('Rate of Food Consumption')
        xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 ymaxHere3])
        xlim([timeValuesComp(1) timeValuesComp(end)])
        lgd.FontSize = fontHere;
    
        subplot(4,3,8)
        plot(timeValuesComp,dervInteractionsCumulativeComp)
        hold on
        area(timeValuesComp,lightsOnOffComp.*50000,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Interaction Rate (Interactions/d)")
        title('Rate of Animal-Device Interactions')
        xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 ymaxHere5])
        xlim([timeValuesComp(1) timeValuesComp(end)])
        lgd.FontSize = fontHere;
        
        subplot(4,3,9)
        plot(timeValuesComp,switch1ColumnComp)
        hold on
        area(timeValuesComp,lightsOnOffComp.*1.3,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Switch 1 Status")
        title('Switch 1 Status')
        xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 1.3])
        xlim([timeValuesComp(1) timeValuesComp(end)])
        lgd.FontSize = fontHere;

        subplot(4,3,10)
        imagesc(timeValues,fFood,abs(cfsFood))
        xlabel("Time (" + timeUnit + ")")
        ylabel('Frequency (Hz)')
        axis xy
        clim('auto')
        title('CWT of Food Intake')
        colorbar('southoutside')
        
        subplot(4,3,11)
        imagesc(timeValues,fInteractions,abs(cfsInteractions))
        xlabel("Time (" + timeUnit + ")")
        ylabel('Frequency (Hz)')
        axis xy
        clim('auto')
        title('CWT of Interactions')
        colorbar('southoutside')
        
        subplot(4,3,12)
        plot(timeValuesComp,switch2ColumnComp)
        hold on
        area(timeValuesComp,lightsOnOffComp.*1.3,'LineStyle',['' 'none'],'FaceColor','Yellow','FaceAlpha',0.3)
        hold off
        axis tight
        xlabel("Time (" + timeUnit + ")")
        ylabel("Switch 2 Status")
        title('Switch 2 Status')
        xline([timeValuesComp(startPointPos) timeValuesComp(endPointPos)],'-b',{['Start' ''],'End'})
        ylim([0 1.3])
        xlim([timeValuesComp(1) timeValuesComp(end)])
        lgd.FontSize = fontHere;

        % Enlarge figure to full screen.
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
        % Remove tool bar and pulldown menus
        set(gcf, 'Toolbar', 'none', 'Menu', 'none');
    
        figure9 = gcf;

    end
    % Determine the absolute start time
    dataReportedStartTime = datetimeRecordingStart + seconds(absoluteSecondsFromStart);
    % Determine the absolute end time
    dataReportedEndTime = dataReportedStartTime + seconds(secondsOutCol(end));
    % Determine the total mass of food consumed in the light phase
    totalMassDark = 0;
    totalMassLight = 0;
    totalMassDarkOnset = 0;
    totalMassLightOnset = 0;
    totalInteractionsDark = 0;
    totalInteractionsLight = 0;
    totalInteractionsDarkOnset = 0;
    totalInteractionsLightOnset = 0;
    % Initialise variable to document changing light switch status
    lightSwitch = "FLAT";
    hasStarted = "N";
    if doFileCompression == "Y"
        % If file compression was applied, perform summary data
        % calculations on compressed outputs to save processing time
        for f = 2:height(timeValuesComp)
            % If the lights just turned on
            if lightsOnOffComp(f) == 1 && lightsOnOffComp(f - 1) == 0
                lightSwitch = "ON";
            % If the lights just turned off
            elseif lightsOnOffComp(f) == 0 && lightsOnOffComp(f - 1) == 1
                lightSwitch = "OFF";
            % Otherwise
            else
                lightSwitch = "FLAT";
            end
            % If the lights are off
            if lightsOnOffComp(f) == 0
                % Add the difference between the present value and the 
                % previous value to the running total for darkness
                totalMassDark = totalMassDark + (filteredOutputFlipComp(f,1) - filteredOutputFlipComp((f - 1),1));
                totalInteractionsDark = totalInteractionsDark + (interactionsCountArrayComp(f,1) - interactionsCountArrayComp((f - 1),1));
            elseif lightsOnOffComp(f) == 1
                % Add the difference between the present value and the 
                % previous value to the running total for light
                totalMassLight = totalMassLight + (filteredOutputFlipComp(f,1) - filteredOutputFlipComp((f - 1),1));
                totalInteractionsLight = totalInteractionsLight + (interactionsCountArrayComp(f,1) - interactionsCountArrayComp((f - 1),1));
            end
            % Evaluating mass and interaction data within 3 hours of
            % light/dark onset (Milinski et. al., 2021), first 
            % in the case that recordings begin immediately after
            % either light or dark onset
            if lightFor24HCrop == "Y" || alignLight == "Y"
                % If recordings begin at light onset
                if lightFor24HCropONOFF == "1"
                    % If the present mass reading is within 3 hours 
                    % (Milinski et. al., 2021) of light onset, 
                    % spanning any 24-hour timeframe
                    if rem(hoursOutColComp(f,1),24) <= 3
                        totalMassLightOnset = totalMassLightOnset + (filteredOutputFlipComp(f,1) - filteredOutputFlipComp((f - 1),1));
                        totalInteractionsLightOnset = totalInteractionsLightOnset + (interactionsCountArrayComp(f,1) - interactionsCountArrayComp((f - 1),1));
                    end
                    % If the present mass reading is within 3 hours
                    % (Milinski et. al., 2021) of darkness onset, 
                    % spanning any 24-hour timeframe
                    if rem(hoursOutColComp(f,1),24) >= 12 && rem(hoursOutColComp(f,1),24) <= 15
                        totalMassDarkOnset = totalMassDarkOnset + (filteredOutputFlipComp(f,1) - filteredOutputFlipComp((f - 1),1));
                        totalInteractionsDarkOnset = totalInteractionsDarkOnset + (interactionsCountArrayComp(f,1) - interactionsCountArrayComp((f - 1),1));
                    end
                % If recordings begin at darkness onset
                elseif lightFor24HCropONOFF == "0"
                    % If the present mass reading is within 3 hours 
                    % (Milinski et. al., 2021) of darkness onset
                    if rem(hoursOutColComp(f,1),24) <= 3
                        totalMassDarkOnset = totalMassDarkOnset + (filteredOutputFlipComp(f,1) - filteredOutputFlipComp((f - 1),1));
                        totalInteractionsDarkOnset = totalInteractionsDarkOnset + (interactionsCountArrayComp(f,1) - interactionsCountArrayComp((f - 1),1));
                    end
                    % If the present mass reading is within 3 hours
                    % (Milinski et. al., 2021) of light onset
                    if rem(hoursOutColComp(f,1),24) >= 12 && rem(hoursOutColComp(f,1),24) <= 15
                        totalMassLightOnset = totalMassLightOnset + (filteredOutputFlipComp(f,1) - filteredOutputFlipComp((f - 1),1));
                        totalInteractionsLightOnset = totalInteractionsLightOnset + (interactionsCountArrayComp(f,1) - interactionsCountArrayComp((f - 1),1));
                    end
                end
            % In the case that recordings neither begin directly at
            % light or dark onset
            else
                % If the light has been switched ON or OFF for the
                % first time
                if lightSwitch == "ON" && hasStarted == "N"
                    % Document the start time for 24-hour calculations
                    % if the light has just switched on
                    beginOddTimeONOFF = "1";
                    beginOddTimeHere = hoursOutColComp(f,1);
                    beginOddIndex = f;
                    % Skip over this initialisation for future loop
                    % iterations
                    hasStarted = "Y";
                elseif lightSwitch == "OFF" && hasStarted == "N"
                    % Document the start time for 24-hour calculations
                    % if the light has just switched off
                    beginOddTimeONOFF = "0";
                    beginOddTimeHere = hoursOutColComp(f,1);
                    beginOddIndex = f;
                    % Skip over this initialisation for future loop
                    % iterations
                    hasStarted = "Y";
                end
                % Once the first light-switch instance has been
                % documented and not immediately after the switch
                if hasStarted == "Y" && f ~= beginOddIndex
                    % If the first switch is at light onset
                    if beginOddTimeONOFF == "1"
                        % If the present mass reading is within 3  
                        % hours (Milinski et. al., 2021) of light 
                        % onset,  spanning any 24-hour timeframe
                        if rem((hoursOutColComp(f,1) - beginOddTimeHere),24) <= 3
                            totalMassLightOnset = totalMassLightOnset + (filteredOutputFlipComp(f,1) - filteredOutputFlipComp((f - 1),1));
                            totalInteractionsLightOnset = totalInteractionsLightOnset + (interactionsCountArrayComp(f,1) - interactionsCountArrayComp((f - 1),1));
                        end
                        % If the present mass reading is within 3 hours
                        % (Milinski et. al., 2021) of darkness onset, 
                        % spanning any 24-hour timeframe
                        if rem((hoursOutColComp(f,1) - beginOddTimeHere),24) >= 12 && rem((hoursOutColComp(f,1) - beginOddTimeHere),24) <= 15
                            totalMassDarkOnset = totalMassDarkOnset + (filteredOutputFlipComp(f,1) - filteredOutputFlipComp((f - 1),1));
                            totalInteractionsDarkOnset = totalInteractionsDarkOnset + (interactionsCountArrayComp(f,1) - interactionsCountArrayComp((f - 1),1));
                        end
                    % If the first switch is at darkness onset
                    elseif beginOddTimeONOFF == "0"
                        % If the present mass reading is within 3 hours 
                        % (Milinski et. al., 2021) of darkness onset
                        if rem((hoursOutColComp(f,1) - beginOddTimeHere),24) <= 3
                            totalMassDarkOnset = totalMassDarkOnset + (filteredOutputFlipComp(f,1) - filteredOutputFlipComp((f - 1),1));
                            totalInteractionsDarkOnset = totalInteractionsDarkOnset + (interactionsCountArrayComp(f,1) - interactionsCountArrayComp((f - 1),1));
                        end
                        % If the present mass reading is within 3 hours
                        % (Milinski et. al., 2021) of light onset
                        if rem((hoursOutColComp(f,1) - beginOddTimeHere),24) >= 12 && rem((hoursOutColComp(f,1 ) - beginOddTimeHere),24) <= 15
                            totalMassLightOnset = totalMassLightOnset + (filteredOutputFlipComp(f,1) - filteredOutputFlipComp((f - 1),1));
                            totalInteractionsLightOnset = totalInteractionsLightOnset + (interactionsCountArrayComp(f,1) - interactionsCountArrayComp((f - 1),1));
                        end
                    end
                end
            end
        end
    else
        % If file compression was not applied, perform summary data
        % calculations on normal outputs
        for f = 2:height(timeValues)
            % If the lights just turned on
            if lightsOnOff(f) == 1 && lightsOnOff(f - 1) == 0
                lightSwitch = "ON";
            % If the lights just turned off
            elseif lightsOnOff(f) == 0 && lightsOnOff(f - 1) == 1
                lightSwitch = "OFF";
            % Otherwise
            else
                lightSwitch = "FLAT";
            end
            % If the lights are off
            if lightsOnOff(f) == 0
                % Add the difference between the present value and the 
                % previous value to the running total for darkness
                totalMassDark = totalMassDark + (filteredOutputFlip(f,1) - filteredOutputFlip((f - 1),1));
                totalInteractionsDark = totalInteractionsDark + (interactionsCountArray(f,1) - interactionsCountArray((f - 1),1));
            elseif lightsOnOff(f) == 1
                % Add the difference between the present value and the 
                % previous value to the running total for light
                totalMassLight = totalMassLight + (filteredOutputFlip(f,1) - filteredOutputFlip((f - 1),1));
                totalInteractionsLight = totalInteractionsLight + (interactionsCountArray(f,1) - interactionsCountArray((f - 1),1));
            end
            % Evaluating mass and interaction data within 3 hours of
            % light/dark onset (Milinski et. al., 2021), first 
            % in the case that recordings begin immediately after
            % either light or dark onset
            if lightFor24HCrop == Y || alignLight == "Y"
                % If recordings begin at light onset
                if lightFor24HCropONOFF == "1"
                    % If the present mass reading is within 3 hours 
                    % (Milinski et. al., 2021) of light onset, 
                    % spanning any 24-hour timeframe
                    if rem(hoursOutCol(f,1),24) <= 3
                        totalMassLightOnset = totalMassLightOnset + (filteredOutputFlip(f,1) - filteredOutputFlip((f - 1),1));
                        totalInteractionsLightOnset = totalInteractionsLightOnset + (interactionsCountArray(f,1) - interactionsCountArray((f - 1),1));
                    end
                    % If the present mass reading is within 3 hours
                    % (Milinski et. al., 2021) of darkness onset, 
                    % spanning any 24-hour timeframe
                    if rem(hoursOutCol(f,1),24) >= 12 && rem(hoursOutCol(f,1),24) <= 15
                        totalMassDarkOnset = totalMassDarkOnset + (filteredOutputFlip(f,1) - filteredOutputFlip((f - 1),1));
                        totalInteractionsDarkOnset = totalInteractionsDarkOnset + (interactionsCountArray(f,1) - interactionsCountArray((f - 1),1));
                    end
                % If recordings begin at darkness onset
                elseif lightFor24HCropONOFF == "0"
                    % If the present mass reading is within 3 hours 
                    % (Milinski et. al., 2021) of darkness onset
                    if rem(hoursOutCol(f,1),24) <= 3
                        totalMassDarkOnset = totalMassDarkOnset + (filteredOutputFlip(f,1) - filteredOutputFlip((f - 1),1));
                        totalInteractionsDarkOnset = totalInteractionsDarkOnset + (interactionsCountArray(f,1) - interactionsCountArray((f - 1),1));
                    end
                    % If the present mass reading is within 3 hours
                    % (Milinski et. al., 2021) of light onset
                    if rem(hoursOutCol(f,1),24) >= 12 && rem(hoursOutCol(f,1),24) <= 15
                        totalMassLightOnset = totalMassLightOnset + (filteredOutputFlip(f,1) - filteredOutputFlip((f - 1),1));
                        totalInteractionsLightOnset = totalInteractionsLightOnset + (interactionsCountArray(f,1) - interactionsCountArray((f - 1),1));
                    end
                end
            % In the case that recordings neither begin directly at
            % light or dark onset
            else
                % If the light has been switched ON or OFF for the
                % first time
                if lightSwitch == "ON" && hasStarted == "N"
                    % Document the start time for 24-hour calculations
                    % if the light has just switched on
                    beginOddTimeONOFF = "1";
                    beginOddTimeHere = hoursOutCol(f,1);
                    beginOddIndex = f;
                    % Skip over this initialisation for future loop
                    % iterations
                    hasStarted = "Y";
                elseif lightSwitch == "OFF" && hasStarted == "N"
                    % Document the start time for 24-hour calculations
                    % if the light has just switched off
                    beginOddTimeONOFF = "0";
                    beginOddTimeHere = hoursOutCol(f,1);
                    beginOddIndex = f;
                    % Skip over this initialisation for future loop
                    % iterations
                    hasStarted = "Y";
                end
                % Once the first light-switch instance has been
                % documented and not immediately after the switch
                if hasStarted == "Y" && f ~= beginOddIndex
                    % If the first switch is at light onset
                    if beginOddTimeONOFF == "1"
                        % If the present mass reading is within 3  
                        % hours (Milinski et. al., 2021) of light 
                        % onset,  spanning any 24-hour timeframe
                        if rem((hoursOutCol(f,1) - beginOddTimeHere),24) <= 3
                            totalMassLightOnset = totalMassLightOnset + (filteredOutputFlip(f,1) - filteredOutputFlip((f - 1),1));
                            totalInteractionsLightOnset = totalInteractionsLightOnset + (interactionsCountArray(f,1) - interactionsCountArray((f - 1),1));
                        end
                        % If the present mass reading is within 3 hours
                        % (Milinski et. al., 2021) of darkness onset, 
                        % spanning any 24-hour timeframe
                        if rem((hoursOutCol(f,1) - beginOddTimeHere),24) >= 12 && rem((hoursOutCol(f,1) - beginOddTimeHere),24) <= 15
                            totalMassDarkOnset = totalMassDarkOnset + (filteredOutputFlip(f,1) - filteredOutputFlip((f - 1),1));
                            totalInteractionsDarkOnset = totalInteractionsDarkOnset + (interactionsCountArray(f,1) - interactionsCountArray((f - 1),1));
                        end
                    % If the first switch is at darkness onset
                    elseif beginOddTimeONOFF == "0"
                        % If the present mass reading is within 3 hours 
                        % (Milinski et. al., 2021) of darkness onset
                        if rem((hoursOutCol(f,1) - beginOddTimeHere),24) <= 3
                            totalMassDarkOnset = totalMassDarkOnset + (filteredOutputFlip(f,1) - filteredOutputFlip((f - 1),1));
                            totalInteractionsDarkOnset = totalInteractionsDarkOnset + (interactionsCountArray(f,1) - interactionsCountArray((f - 1),1));
                        end
                        % If the present mass reading is within 3 hours
                        % (Milinski et. al., 2021) of light onset
                        if rem((hoursOutCol(f,1) - beginOddTimeHere),24) >= 12 && rem((hoursOutCol(f,1) - beginOddTimeHere),24) <= 15
                            totalMassLightOnset = totalMassLightOnset + (filteredOutputFlip(f,1) - filteredOutputFlip((f - 1),1));
                            totalInteractionsLightOnset = totalInteractionsLightOnset + (interactionsCountArray(f,1) - interactionsCountArray((f - 1),1));
                        end
                    end
                end
            end
        end
    end
    % Determine the total mass of food consumed in the dark phase
    fprintf("\n");
    fprintf("Part 3: Save and Export Data for " + fileName + ":");
    fprintf("\n");
    fprintf("\n");
    % Listed below is the order of output columns for reference
    numCols = 0;
    % For time values
    numCols = numCols + 1;
    timecol = numCols;
    % For mass data
    numCols = numCols + 1;
    masscol = numCols;
    % For filtered mass data
    numCols = numCols + 1;
    filteredmasscol = numCols;
    % For flipped and filtered mass data
    numCols = numCols + 1;
    filteredmassflipcol = numCols;
    % For the derivative of flipped and filtered mass data
    numCols = numCols + 1;
    filteredmassflipdervcol = numCols;
    % For interaction amplitude data
    numCols = numCols + 1;
    amplitudearraycol = numCols;
    % For binary interaction data
    numCols = numCols + 1;
    interactionsbinarycol = numCols;
    % For cumulative interaction count data
    numCols = numCols + 1;
    interactionscountarraycol = numCols;
    % For the derivative of cumulative interaction count data
    numCols = numCols + 1;
    interactionscountdervcol = numCols;
    % For fft data for raw mass values
    numCols = numCols + 1;
    fftrawcol = numCols;
    % For fft data for the derivative of interaction count data
    numCols = numCols + 1;
    fftinteractionscountdervcol = numCols;
    % For light data
    numCols = numCols + 1;
    lightcol = numCols;
    % For filtered light data
    numCols = numCols + 1;
    filteredlightcol = numCols;
    % For switch 1 data
    numCols = numCols + 1;
    switch1col = numCols;
    % For switch 2 data
    numCols = numCols + 1;
    switch2col = numCols;
    % For scheduled light data
    numCols = numCols + 1;
    scheduledLightcol = numCols;
    % Initialise variable for array size definitions
    numOutColF = height(timeValues);
    % Set column headers
    columnHeaders = strings(1,numCols);
    % Initialise output table
    outputTable = zeros(numOutColF,numCols);
    % Populate data columns, beginning at the value directly after setTime 
    % values which are to be truncated, and the column header array
    if alignLight == "N"
        % For time values
        colIndex = 1;
        columnHeaders(colIndex) = "time_" + timeUnit;
        outputTable(:,timecol) = timeValues(:,1);
        % For raw mass data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "mass_" + massUnit;
        outputTable(:,masscol) = rawMass(:,1);
        % For filtered mass data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "filtered_mass_" + massUnit ;
        outputTable(:,filteredmasscol) = filteredOutput(:,1);
        % For filtered and flipped mass data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "filtered_food_intake_" + massUnit ;
        outputTable(:,filteredmassflipcol) = filteredOutputFlip(:,1);
        % For the derivative of filtered and flipped mass data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "filtered_food_intake_derv";
        outputTable(:,filteredmassflipdervcol) = dervFoodCumulative(:,1);
        % For interactions (absolute differences in 
        % filtered-raw mass values)
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "interactions_amplitude_mass_" + massUnit ;
        outputTable(:,amplitudearraycol) = amplitudeArray(:,1);
        % For binarised interactions
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "interactions_binary";
        outputTable(:,interactionsbinarycol) = interactionsBinary(:,1);
        % For cumulative interaction counts
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "interactions_cumulative";
        outputTable(:,interactionscountarraycol) = interactionsCountArray(:,1);
        % For the derivative of cumulative interaction counts
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "interactions_derv";
        outputTable(:,interactionscountdervcol) = dervInteractionsCumulative(:,1);
        % For the FFT of raw mass data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "fft_raw";
        outputTable(:,fftrawcol) = rawMassFFT(:,1);
        % For the FFT of the derivative of cumulative interaction counts
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "fft_interactions_derv";
        outputTable(:,fftinteractionscountdervcol) = dervInteractionsCumulativeFFT(:,1);
        % For light data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "light_reading";
        outputTable(:,lightcol) = ldrColumn(:,1);
        % For filtered light data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "light_reading_filtered";
        outputTable(:,filteredlightcol) = ldrColumnFiltered(:,1);
        % For switch 1 data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "switch1_status";
        outputTable(:,switch1col) = switch1Column(:,1);
        % For switch 2 data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "switch2_status";
        outputTable(:,switch2col) = switch2Column(:,1);
        % For scheduled light data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "scheduled_light";
        outputTable(:,scheduledLightcol) = lightsOnOff(:,1);
        % Populate final output table with the data from outputTable and 
        % column headers
        finalOutputTable = cell((numOutColF + 1),numCols);
        for i = 1:width(finalOutputTable)
            for j = 1:height(finalOutputTable)
                if j == 1
                    finalOutputTable(j,i) = cellstr(columnHeaders(i));
                else
                    finalOutputTable(j,i) = num2cell(outputTable((j - 1),i));
                end
            end
        end
    else
        % For time values
        colIndex = 1;
        columnHeaders(colIndex) = "time_" + timeUnit;
        outputTable(:,timecol) = timeValuesCopy(:,1);
        % For raw mass data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "mass_" + massUnit;
        outputTable(:,masscol) = rawMassCopy(:,1);
        % For filtered mass data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "filtered_mass_" + massUnit ;
        outputTable(:,filteredmasscol) = filteredOutputCopy(:,1);
        % For filtered and flipped mass data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "filtered_food_intake_" + massUnit ;
        outputTable(:,filteredmassflipcol) = filteredOutputFlipCopy(:,1);
        % For the derivative of filtered and flipped mass data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "filtered_food_intake_derv";
        outputTable(:,filteredmassflipdervcol) = dervFoodCumulativeCopy(:,1);
        % For interactions (absolute differences in filtered-raw values)
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "interactions_amplitude_mass_" + massUnit;
        outputTable(:,amplitudearraycol) = amplitudeArrayCopy(:,1);
        % For binarised interactions
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "interactions_binary";
        outputTable(:,interactionsbinarycol) = interactionsBinaryCopy(:,1);
        % For cumulative interaction counts
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "interactions_cumulative";
        outputTable(:,interactionscountarraycol) = interactionsCountArrayCopy(:,1);
        % For the derivative of cumulative interaction counts
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "interactions_derv";
        outputTable(:,interactionscountdervcol) = dervInteractionsCumulativeCopy(:,1);
        % For the FFT of raw mass data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "fft_raw";
        outputTable(:,fftrawcol) = rawMassFFT(:,1);
        % For the FFT of the derivative of cumulative interaction counts
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "fft_interactions_derv";
        outputTable(:,fftinteractionscountdervcol) = dervInteractionsCumulativeFFT(:,1);
        % For light data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "light_reading";
        outputTable(:,lightcol) = ldrColumnCopy(:,1);
        % For filtered light data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "light_reading_filtered";
        outputTable(:,filteredlightcol) = ldrColumnFilteredCopy(:,1);
        % For switch 1 data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "switch1_status";
        outputTable(:,switch1col) = switch1ColumnCopy(:,1);
        % For switch 2 data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "switch2_status";
        outputTable(:,switch2col) = switch2ColumnCopy(:,1);
        % For scheduled light data
        colIndex = colIndex + 1;
        columnHeaders(colIndex) = "scheduled_light";
        outputTable(:,scheduledLightcol) = lightsOnOffCopy(:,1);
        % Populate final output table with the data from outputTable and 
        % column headers
        finalOutputTable = cell((numOutColF + 1),numCols);
        for i = 1:width(finalOutputTable)
            for j = 1:height(finalOutputTable)
                if j == 1
                    finalOutputTable(j,i) = cellstr(columnHeaders(i));
                else
                    finalOutputTable(j,i) = num2cell(outputTable((j - 1),i));
                end
            end
        end
    end
    % If data compression has been applied, save another output table with
    % compressed datasets (designed for Prism visualisation and analysis)
    if doFileCompression == "Y"
        % Determine the number of output rows following data compression
        numOutColFComp = height(timeValuesComp);
        % Initialise output table
        outputTableComp = zeros(numOutColFComp,numCols);
        % Populate columns, with indices and headers the same as before
        outputTableComp(:,timecol) = timeValuesComp(:,1);
        % For raw mass data
        outputTableComp(:,masscol) = rawMassComp(:,1);
        % For filtered mass data
        outputTableComp(:,filteredmasscol) = filteredOutputComp(:,1);
        % For filtered and flipped mass data
        outputTableComp(:,filteredmassflipcol) = filteredOutputFlipComp(:,1);
        % For the derivative of filtered and flipped mass data
        outputTableComp(:,filteredmassflipdervcol) = dervFoodCumulativeComp(:,1);
        % For interactions (absolute differences in filtered-raw masses)
        outputTableComp(:,amplitudearraycol) = amplitudeArrayComp(:,1);
        % For binarised interactions
        outputTableComp(:,interactionsbinarycol) = interactionsBinaryComp(:,1);
        % For cumulative interaction counts
        outputTableComp(:,interactionscountarraycol) = interactionsCountArrayComp(:,1);
        % For the derivative of cumulative interaction counts
        outputTableComp(:,interactionscountdervcol) = dervInteractionsCumulativeComp(:,1);
        % For the FFT of raw mass data
        outputTableComp(:,fftrawcol) = rawMassFFTComp(:,1);
        % For the FFT of the derivative of cumulative interaction counts
        outputTableComp(:,fftinteractionscountdervcol) = dervInteractionsCumulativeFFTComp(:,1);
        % For light data
        outputTableComp(:,lightcol) = ldrColumnComp(:,1);
        % For filtered light data
        outputTableComp(:,filteredlightcol) = ldrColumnFilteredComp(:,1);
        % For switch 1 data
        outputTableComp(:,switch1col) = switch1ColumnComp(:,1);
        % For switch 2 data
        outputTableComp(:,switch2col) = switch2ColumnComp(:,1);
        % For scheduled light data
        outputTableComp(:,scheduledLightcol) = lightsOnOffComp(:,1);
        % Populate final output table with the data from outputTable and 
        % the same column headers as before
        finalOutputTableComp = cell((numOutColFComp + 1),numCols);
        for i = 1:width(finalOutputTableComp)
            for j = 1:height(finalOutputTableComp)
                if j == 1
                    finalOutputTableComp(j,i) = cellstr(columnHeaders(i));
                else
                    finalOutputTableComp(j,i) = num2cell(outputTableComp((j - 1),i));
                end
            end
        end
    end
    % Initialise and create matrix to document processing parameters
    processParameters = strings(23,2);
    rowNum = 1;
    processParameters(rowNum,1) = "SnackerTracker Data: Summative and Processing Information";
    % Leave a blank row
    rowNum = rowNum + 2;
    % Section for key outputs
    processParameters(rowNum,1) = "Data Summary:";
    % Leave a blank row
    rowNum = rowNum + 2;
    % Report key outputs
    processParameters(rowNum,1) = "Total Mass Consumed:";
    processParameters(rowNum,2) = num2str(filteredOutputFlip(end,1));
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Total Mass Consumed in the Dark:";
    processParameters(rowNum,2) = totalMassDark;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Total Mass Consumed in the Light:";
    processParameters(rowNum,2) = totalMassLight;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Total Mass Consumed at Darkness Onset:";
    processParameters(rowNum,2) = totalMassDarkOnset;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Total Mass Consumed at Light Onset:";
    processParameters(rowNum,2) = totalMassLightOnset;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Total Interactions:";
    processParameters(rowNum,2) = num2str(interactionsCountArray(end,1));
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Total Interactions in the Dark:";
    processParameters(rowNum,2) = totalInteractionsDark;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Total Interactions in the Light:";
    processParameters(rowNum,2) = totalInteractionsLight;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Total Interactions at Darkness Onset:";
    processParameters(rowNum,2) = totalInteractionsDarkOnset;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Total Interactions at Light Onset:";
    processParameters(rowNum,2) = totalInteractionsLightOnset;
    % Leave a blank row
    rowNum = rowNum + 2;
    % Section for key outputs
    processParameters(rowNum,1) = "Data Processing Information:";
    % Leave a blank row
    rowNum = rowNum + 2;
    processParameters(rowNum,1) = "Start Date and Time || End Date and Time:";
    processParameters(rowNum,2) = string(dataReportedStartTime) + " || " + string(dataReportedEndTime);
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Lights On:";
    processParameters(rowNum,2) = timeLightOn;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Lights Off:";
    processParameters(rowNum,2) = timeLightOff;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Crop at Start (Yes-No/# Cropped):";
    if truncateStart == "Y"
        entryYN7 = "Yes";
    elseif truncateStart == "N"
        entryYN7 = "No";
    end
    processParameters(rowNum,2) = entryYN7 + "/" + num2str(startPoint);
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Crop at End (Yes-No/# Cropped):";
    if truncateEnd == "Y"
        entryYN8 = "Yes";
    elseif truncateEnd == "N"
        entryYN8 = "No";
    end
    processParameters(rowNum,2) = entryYN8 + "/" + num2str(endPoint);
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "24-Hour Truncation (Yes-No for Truncation/# Days/Start Index/Yes-No for Light Alignment/0-1 for at Lights Off-On/Yes-No for Light Shifting):";
    if do24HTruncation == "Y" && lightFor24HCrop == "Y"
        processParameters(rowNum,2) = "Yes" + "/" + num2str(howMany24H) + "/" + abs24HStart + "/" + lightFor24HCrop + "/" + lightFor24HCropONOFF + "/" + alignLight;
    elseif do24HTruncation == "Y" && lightFor24HCrop == "N"
        processParameters(rowNum,2) = "Yes" + "/" + num2str(howMany24H) + "/" + abs24HStart + "/" + lightFor24HCrop + "/NA/" + alignLight;
    elseif do24HTruncation == "N"
        processParameters(rowNum,2) = "No" + "/NA/NA/NA/NA/NA";
    end
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Output Time Units:";
    processParameters(rowNum,2) = timeFormat;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Switch 1 Filter (Inversion/Yes-No for Mass/Yes-No for Light):";
    if origOrInvSwitch1 == "0"
        entryYN10_1 = "Original";
    elseif origOrInvSwitch1 == "1"
        entryYN10_1 = "Inverted";
    end
    if sw1FilterMass == "Y"
        entryYN10_2 = "Yes";
    elseif sw1FilterMass == "N"
        entryYN10_2 = "No";
    end
    if sw1FilterLDR == "Y"
        entryYN10_3 = "Yes";
    elseif sw1FilterLDR == "N"
        entryYN10_3 = "No";
    end
    processParameters(rowNum,2) = entryYN10_1 + "/" + entryYN10_2 + "/" + entryYN10_3;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Switch 2 Filter (Inversion/Yes-No for Mass/Yes-No for Light):";
    if origOrInvSwitch2 == "0"
        entryYN11_1 = "Original";
    elseif origOrInvSwitch2 == "1"
        entryYN11_1 = "Inverted";
    end
    if sw2FilterMass == "Y"
        entryYN11_2 = "Yes";
    elseif sw2FilterMass == "N"
        entryYN11_2 = "No";
    end
    if sw2FilterLDR == "Y"
        entryYN11_3 = "Yes";
    elseif sw2FilterLDR == "N"
        entryYN11_3 = "No";
    end
    processParameters(rowNum,2) = entryYN11_1 + "/" + entryYN11_2 + "/" + entryYN11_3;
    rowNum = rowNum + 1;    
    processParameters(rowNum,1) = "Baseline Mass:";
    processParameters(rowNum,2) = num2str(initialMass);
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Mass Units:";
    processParameters(rowNum,2) = massUnit;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Data Points Set to Baseline:";
    processParameters(rowNum,2) = num2str(setTime);
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Mass Buffer:";
    processParameters(rowNum,2) = num2str(bufferHere);
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Time Buffer:";
    processParameters(rowNum,2) = num2str(measureSpan);
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Mean Filter Window:";
    processParameters(rowNum,2) = num2str(window);
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Mass Filter Option:";
    processParameters(rowNum,2) = num2str(whichFilter);
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Shift Filter:";
    processParameters(rowNum,2) = num2str(shiftFilter);
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Shift Tolerance:";
    processParameters(rowNum,2) = num2str(shiftTolerance);
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Plateau-Only Filter Applicaiton (Yes-No):";
    if applyPlateau == "Y"
        entryYN16 = "Yes";
    elseif applyPlateau == "N"
        entryYN16 = "No";
    end
    processParameters(rowNum,2) = entryYN16;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Shift-Only Filter Applicaiton (Yes-No):";
    if applyShift == "Y"
        entryYN19 = "Yes";
    elseif applyShift == "N"
        entryYN19 = "No";
    end
    processParameters(rowNum,2) = entryYN19;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Plateau and Shift Filter Applicaiton (Yes-No):";
    if applyShiftAndPlateau == "Y"
        entryYN20 = "Yes";
    elseif applyShiftAndPlateau == "N"
        entryYN20 = "No";
    end
    processParameters(rowNum,2) = entryYN20;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Chip Filter Application (Yes-No) (Start Time/End Time/Mass Threshold):";
    if doChipFilter == "Y"
        entryYNChip = "Yes";
    elseif doChipFilter == "N"
        entryYNChip = "No";
    end
    processParameters(rowNum,2) = entryYNChip + chipFilterDetails;
    rowNum = rowNum + 1; 
    processParameters(rowNum,1) = "Food Derivative Buffer:";
    processParameters(rowNum,2) = num2str(fooddervBuffer);
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Interactions Derivative Buffer:";
    processParameters(rowNum,2) = num2str(intdervBuffer);
    rowNum = rowNum + 1;   
    processParameters(rowNum,1) = "Short Derivative Correction (Yes-No):";
    if shortDervCorrection == "Y"
        entryYNShortDerv = "Yes";
    elseif shortDervCorrection == "N"
        entryYNShortDerv = "No";
    end
    processParameters(rowNum,2) = entryYNShortDerv;
    rowNum = rowNum + 1;
    processParameters(rowNum,1) = "Light Filter (Yes-No) (Overall/Binary-Continuous/Mean Filter Window/Light Cutoff):";
    if doFilterLight == "Y"
        entryYN23_1 = "Yes";
    elseif doFilterLight == "N"
        entryYN23_1 = "No";
    end
    if lightFilterType == "0"
        entryYN23_2 = "Binary";
        entry23_3 = smoothBeforeBinary;
    elseif lightFilterType == "1"
        entryYN23_2 = "Continuous";
        entry23_3 = smoothLightWindow;
    end
    processParameters(rowNum,2) = entryYN23_1 + "/" + entryYN23_2 + "/" + num2str(entry23_3) + "/" + num2str(lightCutoff);  
    rowNum = rowNum + 1;    
    processParameters(rowNum,1) = "File Compression (Binned-Condensed/Factor):";
    if compressSecondsFactor == "0"
        processParameters(rowNum,2) = "Binned/" + num2str(binDuration);
    else
        processParameters(rowNum,2) = "Condensed/" + num2str(fileCompFactor);
    end
    % Save figures, first creating an output folder if one does not
    % already exist
    fileNameHereNoExtension = extractBefore(fileName, ".");
    outputFolder = convertCharsToStrings(fileNameHereNoExtension) + "-Processed";
    % Make a new folder where outputs will be saved, if the folder does 
    % not already exist, and add it to the working directory
    if isfolder(outputFolder) == 0
       mkdir(skrtkrFolderStr,outputFolder)
    end
    % Add this path to the working directory
    %addpath(outputFolder,'-end');
    outputDirectoryStr = skrtkrFolderStr + "\" + outputFolder + "\";
    outputDirectoryChar = convertStringsToChars(outputDirectoryStr);
    filename1 = 'Figure-1_Switch-Data.jpg';
    exportgraphics(figure1,[outputDirectoryChar filename1]);
    filename2 = 'Figure-2_Crop-Data.jpg';
    exportgraphics(figure2,[outputDirectoryChar filename2]);
    filename3 = 'Figure-3_Mass-Filters.jpg';
    exportgraphics(figure3,[outputDirectoryChar filename3]);
    filename4 = 'Figure-4_Plateau Filter.jpg';
    exportgraphics(figure4,[outputDirectoryChar filename4]);
    filename5 = 'Figure-5_Interactions-Assessment.jpg';
    exportgraphics(figure5,[outputDirectoryChar filename5]);
    filename6 = 'Figure-6_LDR-Filter.jpg';
    exportgraphics(figure6,[outputDirectoryChar filename6]);
    filename7 = 'Figure-7_Output-Summary.jpg';
    exportgraphics(figure7,[outputDirectoryChar filename7]);
    if exist('figure8','var') == 1
        filename8 = 'Figure-8_Light-Shift.jpg';
        exportgraphics(figure8,[outputDirectoryChar filename8]);
    end
    if exist('figure9','var') == 1
        filename9 = 'Figure-9_Data-Compression.jpg';
        exportgraphics(figure9,[outputDirectoryChar filename9]);
    end
    if exist('figure10','var') == 1
        filename9 = 'Figure-10_Switch-Cropping.jpg';
        exportgraphics(figure10,[outputDirectoryChar filename10]);
    end
    close all hidden   
    % Define the location and name of the data output file
    savePath = outputDirectoryStr + convertCharsToStrings(fileName) + "-Processed.csv";
    % Save file. Re-run if you'd like to save numerous types of processed
    % data, for example with and without compressed outputs
    writecell(finalOutputTable,savePath)
    % If data compression was also performed
    if doFileCompression == "Y"
        % Define the location and name of the data output file
        savePathComp = outputDirectoryStr + convertCharsToStrings(fileName) + "-Processed-Compressed.csv";
        % Save file. Re-run to save numerous types of processed
        % data, for example with and without compressed outputs
        writecell(finalOutputTableComp,savePathComp)
    end
    % Define the location and name of the parameter output file
    savePathPP = outputDirectoryStr + convertCharsToStrings(fileName) + "-Process-Parameters.csv";
    % Save file
    writematrix(processParameters,savePathPP)
    % End of script
    fprintf("Data has been processed and saved for " + fileName + ".");
    fprintf("\n");
end
fprintf("Program complete.\n");

%% End-of-script functions

function checkedvar = skrtkr_isentryerror(validentry1,validentry2,checkvar)
    % Ensure entries are of data type 'string' for comparison. Inputs 
    % may not be assigned as strings in the parent script's function call
    validentry1 = string(validentry1);
    validentry2 = string(validentry2);
    checkvar = string(checkvar);
    % Re-prompts for a valid response while the user-response does not  
    % match a valid entry
    while checkvar ~= validentry1 && checkvar ~= validentry2
        prompt_invalidentry = "Invalid entry. Please enter '" + validentry1 + "' or '" + validentry2 + "': ";
        checkvar = input(prompt_invalidentry, "s");
    end
    checkedvar = string(checkvar);
end