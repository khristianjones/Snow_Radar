function w = tukeywin(N,alpha);
% From www.wikipedia.org/wiki/Blackman_window#Blackman_windows this function
% is available in the Matlab signal processing toolbox, but is given here in case the user has only
% the basic Matlab license.
n = [0:N-1]';, w = ones(N,1);
% beginning taper
w1 = 0.5*( 1 + cos(pi*(2*n/(alpha*(N-1)) - 1)) );
diff1 = diff(w1(1:end-1));, diff2 = diff(w1(2:end));
samp = 1+min(find(diff1>0 & diff2<0));
w(1:samp) = w1(1:samp);
% ending taper
w2 = 0.5*( 1 + cos(pi*(2*n/(alpha*(N-1)) - (2/alpha) + 1)) );
diff1 = diff(w2(1:end-1));, diff2 = diff(w2(2:end));
samp = 1+max(find(diff1>0 & diff2<0));
w(samp:end) = w2(samp:end);