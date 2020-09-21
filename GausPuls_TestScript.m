% Gaussian Propagation Test Script 
% This script is used to test the propagation of the NoveldaPulseGen,
% NoveldaChirpParams, and gauspuls scripts

[St, tV, Fs] = NoveldaPulseGen('X4',0,23.3,100);

%% 
figure();
subplot(2,2,1);
plot(St);
title('Impulse delta(t)')

targets = zeros(1,1536);
targets(500) = 1;
targets(600) = 1;
targets(700:900) = 1.25;
targets(1000:10:1100) = .5;
targets(1005:10:1095) = 1;
subplot(2,2,2);
stem(targets);
title('Targets m(t)')

pt=conv(St,targets);
subplot(2,2,3)
plot(pt);
title('Convolved Response d(t)*m(t)');
smt = deconv(pt,St);
subplot(2,2,4)
plot(smt);
title('Matched Filter');
%% 
