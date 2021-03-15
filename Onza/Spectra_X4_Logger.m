%%------------Onza Example1 - For data viewing and logging---------------%%
% 
% Important Input Arguments for tuning:
%   Variables     = radar parameter settings
%   bufferLen     = the number of radar frames to collect
%
% Important Output Variables:
%   radarSettings = struct of common, tunable radar settings
%   rawFrame      = matrix of raw radar data (time/distance bins vs. radar frames and amplitude is in DAC counter values)     
%   scaledFrame   = maxtrix of scaled radar data (time/distance bins vs. radar frames and amplitude scaled to volts using normalizeX4.m)
%   FPS           = final data acquisition speed in frames per second (system platform, OS, connection, and processing dependent)
%

% Housekeeping
clear;
close all;

% Speed of light
c = 2.99792458e8;

% Inputs
% bufferLen = 1e4;
bufferLen = 100;

% Flags
% DDC_Flag = true;
DDC_Flag = false;

matFileSave = true;
%matFileSave = false;

matfilename = 'Callibration_Plate_at_143cm_0deg';

pause(1);
% -------------------------------------------------------------------------
% Set Radar Variables
% -------------------------------------------------------------------------
Variables = containers.Map;                                 % stored in container map

% Common Variables between all platforms
Variables('PPS') = 8;                                       % set PulsesPerStep, amplitude averaging
Variables('Iterations') = 32;                               % set Iterations, frame averaging
Variables('DACStep') = 0;                                   % set DACStepFine (2^Int = DACStep, so 0-3 = 1, 2, 4, or 8)
Variables('DACMax') = 2047;                                 % set DACMax, < 2048
Variables('DACMin') = 0;                                    % set DACMin, >= 0
Variables('SampleDelay') = 0;                               % start distance integer, every increase by 1 is ~0.6 meters increase
Variables('FrameStitch') = 1;                               % number of frames to stitch together or concatenate
Variables('TxRegion') = 3;                                  % 3 => ETSI/FCC Region, CF = 7.290 GHz; 4 => KCC/FCC Region, CF = 8.748 GHz

% -------------------------------------------------------------------------
% Initialize Radar Connection
% ------------------------------------------------------------------------- 
% Create the radar object
radar = radarWrapper('192.168.7.2');        % Connect via USB, otherwise specify correct IP address 
% radar = radarWrapper('192.168.10.13');    % Ethernet address 

% Set Chip Type
radar.SetChipType('X4');

% Open a connection to the radar module
radar.Open('X4');

% -------------------------------------------------------------------------
% Turn on LNA (just in case...)
% ------------------------------------------------------------------------- 
fprintf('Turning on LNA...\n');
radar.SetIOPinDirection(8, 17, 'output');
radar.WriteIOPin(8, 17, 'high');

% Enable Xethru DDC and Decimate by 8
if DDC_Flag
    radar.EnableX4HWDDC(1);
end

% -------------------------------------------------------------------------
% Update Variables
% -------------------------------------------------------------------------
keys = Variables.keys;
vals = Variables.values;
for n = 1:Variables.length
    % Creat radarSettings struct and print to screen
    if ischar(vals{n})
        % Print Registers values
        fprintf('Setting %s to %s\n', keys{n}, vals{n});
        
        % Print settings to struct => char to double
        eval(['radarSettings.' keys{n} ' = str2double(vals{n});']);
    else
        % Print Registers values
        fprintf('Setting %s to %d\n', keys{n}, vals{n});
        
        % Print settings to struct as double
        eval(['radarSettings.' keys{n} ' = vals{n};']);
    end
    
    % Update Register values
    radar.TryUpdateChip(keys{n}, vals{n});
end

% -------------------------------------------------------------------------
% Read Variables
% -------------------------------------------------------------------------

% Determine the length of the radar signals, # of samplers (length of signal)
frameSize = radar.Item('SamplersPerFrame');                             % grab FrameSize, in SamplersPerFrame
if DDC_Flag
    frameSize = frameSize / 2;
end

% Get the measured sampling rate (assumes calibration was run...)
samplingRate = radar.Item('SamplingRate');                              % grab Sampling Rate
if DDC_Flag
    samplingRate = samplingRate / 8;
end
Fs = samplingRate;

% Get the measured sampling rate (assumes calibration was run...)
sampleDelay = radar.Item('SampleDelay');                                % grab SampleDelay, aka StartDistance

% Grab the Pulse Repition Frequency
prf = radar.Item('PRF');                                                % grab PRF, Hz
% Get the true (2^n) DACStep Value (only on a Get...)
dacStep = radar.Item('DACStep');

% Compute the sample resolution based on the measured sampling rate
resolution = c / samplingRate / 2;

% Add to radarSettings Variable
radarSettings.SamplersPerFrame = frameSize;
radarSettings.SamplingRate = samplingRate;
radarSettings.Resolution = resolution;
radarSettings.SampleDelay = sampleDelay;
radarSettings.StartDistance = sampleDelay * c / 2;
radarSettings.PRF = prf;
radarSettings.DACStep = dacStep;

% Tx Region Settings
if radarSettings.TxRegion == 3
    radarSettings.TxRegionStr = 'EU/US';
    radarSettings.TxRegionCf = 7.29;
elseif radarSettings.TxRegion == 4
    radarSettings.TxRegionStr = 'KCC/US';
    radarSettings.TxRegionCf = 8.748;
end
    
%%------------------------Plotting Setup---------------------------------%%
% Frequency Variables                                           
frame = nan(1, frameSize);                                                                                                          % single frame allocation
Nf = frameSize;                                                                                                                     % fft frame size for zero padding
timeVector = (0:frameSize - 1) / samplingRate + sampleDelay;                                                                        % time vector
xticks = linspace(0, frameSize - 1, 14);                                                                                            % Always subtract 1, for 1 to 0 conversion
xtickmeters = (round((xticks * resolution + radarSettings.StartDistance) * 100)) / 100;                                             % meters

% Print specs
fprintf('\nStart Time(Distance) = %3.3f ns(%3.1f mm)\n', sampleDelay * 1e9, radarSettings.StartDistance * 1e3);                     % print start distance
fprintf('Resolution           = %3.3f mm\n', resolution * 1e3);                                                                     % print resolution
fprintf('Sampling Rate        = %3.3f GS/s\n', samplingRate / 1e9);                                                                 % print sampling rate
fprintf('Tx Region(%d)         = %0.3f GHz (%s)\n', radarSettings.TxRegion, radarSettings.TxRegionCf, radarSettings.TxRegionStr);   % print sampling rate

% Set up time plot signal
h_fig = figure; %h_ax = gca; 
% set(h_fig, 'position', [1 41 3440 1323]);
sp1 = subplot(211);
sp2 = subplot(212);

h1 = plot(sp1, 1:frameSize, frame);
title(sp1, 'radar time waveform');
set(sp1, 'xlim', [1 frameSize]);
xlabel(sp1, 'distance [meters]');
ylabel(sp1, 'amplitude [v]');
set(sp1, 'xtick', xticks, 'xticklabel', xtickmeters);
grid(sp1, 'on');

h2 = plot(sp2, 1:frameSize, frame);
title(sp2, 'power spectra');
set(sp2, 'ylim', [-160 -80]);
xlabel(sp2, 'frequency [hz]');
ylabel(sp2, 'power [dBm / hz]');
% set(sp2, 'xtick', xticks, 'xticklabel', xtickmeters);
grid(sp2, 'on')


% Allocation
rawFrame = nan(frameSize, bufferLen);
scaledFrame = nan(frameSize, bufferLen);
time_samples = nan(1,bufferLen);

% Start timer
tic; 
     
% Loop for bufferLen times
for i = 1:bufferLen 
    if ishandle(h_fig)
        % Get Frame
        counterValueFrame = radar.GetFrameRawDouble;                                                        % Get frame raw
        if i == 1
            counterValueFrame = radar.GetFrameRawDouble;                                                        % Get frame raw
        end
            
        if DDC_Flag
            counterValueMag = abs(counterValueFrame);
            counterValueReal = real(counterValueFrame);
            counterValueImag = imag(counterValueFrame);
            [normalVoltFrame, normalDACFrame] = normalizeX4(counterValueMag, radarSettings, false);         % Normalize and Scale signal, according to Rx = 1.2V
        else
            [normalVoltFrame, normalDACFrame] = normalizeX4(counterValueFrame, radarSettings, true);       % Normalize and Scale signal, according to Rx = 1.2V
        end
        
        % Create Spectra
        [freqVector, pwrdB, pwrdBm, pwrdBmPerHz] = powerSpectra(normalVoltFrame, Fs);   % call new powerSpectra function instead (always pads to 2 * Nt, 2 * length of time vector) 
        
        % Save data
        rawFrame(:, i) = counterValueFrame;
        scaledFrame(:, i) = normalVoltFrame;
        time_samples(1,i) = toc;

        % Find Vpmax/Vpmin for scaling
        VpMax = max(normalVoltFrame);
        VpMin = min(normalVoltFrame);
        if mod(i, 50) == 0
            % Scale every 50 frames
%             ylim(h_ax, [VpMin*1.5 VpMax*1.5]);                                                              % scale appropriately
            if DDC_Flag
%                 ylim([0 20]);
            else
%                 ylim([-0.02 0.02]);
            end
        end

        % Plot data
%         title(sp1, sprintf('radar time waveform, tx region(%d) = %0.3f GHz (%s)',...
%                             radarSettings.TxRegion, radarSettings.TxRegionCf, radarSettings.TxRegionStr));  % set plot title        
%         set(h1, 'xdata', timeVector * 1e9, 'ydata', normalVoltFrame);                                       % time waveform (in millivolts)
        set(h1, 'xdata', 1:frameSize, 'ydata', normalVoltFrame);                                       % time waveform (in millivolts)
        
        set(h2, 'xdata', freqVector, 'ydata', pwrdBmPerHz);  
        drawnow;
        
        % Iteration number
         fprintf('Iteration: %d, %0.2f%%\n', i, (i / bufferLen) * 100);
    end
    end

    
% Show Frames Per Second (FPS)
FPS = i / toc;
fprintf('FPS = %2.2f\n', FPS);
time = toc;

% Close the connection to the radar
fprintf('Closing X4 connections...\n');
radar.Close();

% Close figure
if ishandle(h_fig)
    close(h_fig);
end

% Save matfile data
if matFileSave
    save([matfilename datestr(now, 'dd-mmm-yyyy_HH-MM') '.mat'], 'rawFrame', 'scaledFrame', 'time_samples', 'FPS', '');
    fprintf('Saving Data\n');
end