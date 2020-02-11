function [freqVector, pwrdB, pwrdBm, pwrdBmPerHz, pwrLin, pwrLinNorm, RBW] = powerSpectra(St, Fs, zeroPadByXtimes)
% [freqVector, pwrdB, pwrdBm, pwrdBmPerHz, pwrLin, pwrLinNorm, RBW] = powerSpectra(St, Fs, zeroPadByXtimes)
%
% Inputs: time domain signal, St, in volts, and the sampling rate
% frequency, Fs.
%
% Outputs: The frequency vector, freqVector, normalized power, pwrNorm,
% absolute power, pwrdBm, based on PRF, and the power spectral density,
% pwrdBmPerHz, based on the resolution bandwidth (RBW) of the FFT.
%
% author: William Tidd date: 2/26/2013
% 
% 5/3/2017 added linear outputs
%
% 5/4/2017 add linear PSD to output, pwrLin and pwrLinNorm 5/5/2017 added
% zeroPadByXtimes variable and added RBW to output

% Input arguments
if nargin < 3
    % If zeroPadByX is omitted always multiply (zero pad) by 2
    zeroPadByXtimes = 2;
end

% Sampling length variables
Nt = length(St);                                                % length of time vector, St

% Make final FFT same length as time domain signal, i.e. Nf = 2 * Nt (this offers double zero padding: greater FFT resolution, but no waveform resolution gained)
Nf = zeroPadByXtimes * Nt;
Nf = 2^nextpow2(Nf);                                            % FFT frame length for zero padding, next power of 2 for FFT speed (greater FFT resolution, but no waveform resolution gained)  

% Frequency vector
freqVector = linspace(2/Nf, 1, Nf/2) * Fs/2;                    % frequency vector for FFT (removes DC automatically, index 0)
RBW = freqVector(2) - freqVector(1);                            % Resolution Bandwidth in Hz, based on bin width of FFT, i.e. # of FFT points

% Calculate FFT
Sf_complex_norm = fft(St, Nf) / Nt;                             % take Nf point FFT for frequency domain signal, i.e. complex FFT, and normalize by length of time signal, Nt (always equal to time domain length)

% Compute normalized FFT (proper indexing for half-spectrum and multiply by 2, or add 6dB, i.e. single-sided amplitude spectrum)                                                   
Sf_single_norm = 2 * abs( Sf_complex_norm(2:(Nf/2 + 1)) );      % abs for magnitude of FFT, and indexing removes DC value, i.e index 1

% Linear Outputs
pwrLin = Sf_single_norm;
pwrLinNorm = Sf_single_norm / max(Sf_single_norm);

% Normalized to maximum, turn into dB
pwrdB = 20 * log10(pwrLinNorm);

% Compute Power Spectra in dBm, and PSD in dBm/Hz
pwrdBm =  10 * log10(Sf_single_norm.^2 / 50 * 1000);            % square voltage, divide by 50 ohms (characteristic impedance) and multiple by 1000 for milliwatts (for dBm)
pwrdBmPerHz = pwrdBm - 10 * log10(RBW);                         % subtract RBW (Resolution Bandwidth) in dB, i.e. FFT bin width in Hz
           