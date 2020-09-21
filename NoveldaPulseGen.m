function [St, timeVector, Fs] = NoveldaPulseGen(chipSet, PGen, Sampler, SNR, delay_ns, equalize, verbose)
% Function to generate a simulated Novelda pulse from any chip, X1 
% (NVA6100) or X2(NVA620x), using any pulse generator, 0-2 or 0-10,
% respectively.
%
% [St, timeVector, Fs] = NoveldaPulseGen(chipSet, PGen, Sampler, SNR, Delay, verbose)
% 
% Outputs: The sampled time vector, St, in volts, the time duration as a 
% vector, timeVector, in seconds and the sampling rate, Fs, in Samples/sec
% 
% Update 9/26/2017, Added support for X4 SoC
%

% Check for Verbosity (Plotting and printing, default to false = OFF)
if ~exist('verbose', 'var')
    verbose = false;
end

% Check for Distance Equalizer
if ~exist('equalize', 'var')
    equalize = false;
end

% Constants
c = 2.9979e8;                       % speed of light

% Call NoveldaChipParams to get center frequency fc, fractional bandwith
% bw, at bwr dB down from normalized peak, with instanteous output 
% amplitude vp volts, with a frame size of n
[fc, bw, bwr, vp, frameSize, ~, ~, fs_hz] = NoveldaChipParams(chipSet, PGen, Sampler);
fc
bw
bwr
vp

% Sampling Rate
if ischar(Sampler)
    % Sampling Rate
    Fs = fs_hz;
elseif isnumeric(Sampler)
    
    % Else, Sampler becomes the Sampling rate specified in GS/s
    fprintf('Using specified numeric Sampler input, Sampling Rate = %d GHz\n', Sampler);
    Fs = Sampler * 1e9;
else
    % Else error
    error('Sampler as string input must be, 4mm, 8mm, or 4cm...Or Sampler as numeric input Sampling Rate in GHz.');    
end

% Displacement vectors (time and distance)
t = (0:frameSize - 1) / Fs;         % time
x = t * c / 2;                      % distance
res_time = t(2) - t(1);             % time resolution
res_dist = x(2) - x(1);             % spatial resolution

% Time/Phase delay offset (seconds)
if exist('delay_ns', 'var') && ~isempty(delay_ns)
    dt = delay_ns * 1e-9;           % turn into seconds
else
    dt = t(round(frameSize / 2));   % else find center of window
end

% Signal Amplitude (volts peak)
pulseVolts = vp;

% Generate the Gaussian pulse using built-in function "gauspuls"
pulse = pulseVolts * gauspuls((t - dt), fc, bw, bwr);

% Equalize Pulse over Distance (Linear negatively sloping ramp)
if equalize
    equ = linspace(1, 0.2512, frameSize); % about 12 dB round trip...
    pulse = pulse .* equ;
end

% Noise Amplitude (volts) and random noise (uniform or normal?, normal seems more valid...)
noiseVolts = 10.^(-SNR / 20) * pulseVolts;
noise = noiseVolts * randn(size(pulse));

% Add the noise to the pulse
pulse_w_noise = pulse + noise;

% Rename outputs, and structure as column vector
St = pulse_w_noise.';
timeVector = t.';

%%-----Plot pulse
if verbose
    % time waveform
    h_fig = figure;
    set(h_fig, 'position', [1063 598 1245 471]);
    set(h_fig, 'Name', ['Novelda Radar Simulated Ultra-Wideband Pulse: ' upper(chipSet)],  'NumberTitle', 'off');
    sp1 = subplot(211);
    plot(sp1, t * 1e9, pulse_w_noise, 'b', 'linewidth', 2);
    xlabel(sp1, 'time [nsec]');
    ylabel(sp1, 'amplitude [volts]');
    title(sp1, ['Gaussian Pulse:  Fc = ' num2str(fc/1e9) ' GHz,  PGen = ' num2str(PGen) ',  Fs = ' num2str(Fs/1e9) ' GS/s,  SNR = ' num2str(SNR) ' dB'], 'Fontsize', 14);
    xlim(sp1, [t(1) t(frameSize)]*1e9);

    % distance waveform
    sp2 = subplot(212);
    plot(sp2, x, pulse_w_noise, 'b', 'linewidth', 2);
    xlabel(sp2, 'distance [m]');
    ylabel(sp2, 'amplitude [volts]');
    xlim(sp2, [x(1) x(frameSize)]);

    % Print to screen
    fprintf('Temporal resolution = %0.2f ps\n', res_time*1e12);
    fprintf('Temporal range      = %0.2f ns\n\n', t(frameSize)*1e9);
    fprintf('Spatial resolution  = %0.2f mm\n', res_dist*1e3);
    fprintf('Spatial range       = %0.2f m\n', x(frameSize));
end