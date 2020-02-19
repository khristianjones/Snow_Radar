pd = 0.9;            % Probability of detection
pfa = 1e-6;          % Probability of false alarm
max_range = 5000;    % Maximum unambiguous range
range_res = 50;      % Required range resolution
tgt_rcs = 1;         % Required target radar cross section

prop_speed = physconst('LightSpeed');   % Propagation speed
pulse_bw = prop_speed/(2*range_res);    % Pulse bandwidth
pulse_width = 1/pulse_bw;               % Pulse width
prf = prop_speed/(2*max_range);         % Pulse repetition frequency
fs = 2*pulse_bw;                        % Sampling rate
waveform = phased.RectangularWaveform(...
    'PulseWidth',1/pulse_bw,...
    'PRF',prf,...
    'SampleRate',fs);