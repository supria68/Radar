%% This task is a part of Weather radar signal and data processing project.
% Author : Supriya Sudarshan 
% Implementing a Correlation processor for target detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
%--------------------------------
% declare constants and variables
%--------------------------------
c = 3e8;        %m/s   
B = 100e6;      %Hz
tau = 0.005e-3; %s
rw = 200;       %m

n = 5*B*tau; % number of scatters, N >= 2*B*tau!! 

%------------------------------
%simulate a replica and its plot
%------------------------------

t = linspace(-tau/2, tau/2, n);
replica = exp(1j * pi * (B/tau) * t.^2);

figure(1)
subplot(2,2,1)
plot(t, real(replica));
xlabel('time in seconds');
ylabel('Real part of replica');
grid

sampling_interval = 2*tau/n;
freq_limit = 1/sampling_interval;
freq = linspace(-freq_limit, freq_limit, n);
subplot(2,2,2)
plot(freq, fftshift(abs(fft(replica))));
xlabel('Frequency in Hz');
ylabel('Replica spectrum');
grid

%-------------------------------------------------
% simulate a received signal (y) considering 3 targets
% let the targets be at the range of [10,30,100]
%-------------------------------------------------

scat_range = [10,30,100];
num_scat = 3;

x(num_scat,1:n) = 0; % declare input signal and initialise
y(1:n) = 0;          % output signal is initialised

for k = 1:num_scat
    range = scat_range(k);
    x(k,:) = exp(1j * pi * (B/tau) .* (t + (2*range/c)).^2);
    y = y + x(k,:);
end
figure(2)
plot(t, real(y));
xlabel('time in sec');
ylabel('received signal (uncompressed)');
grid

%---------------------------------------------------
% perform pulse compression to detect the scatters
%---------------------------------------------------

out = xcorr(replica, y);
out = out./n; % normalise the output
figure(3)
Npoints = ceil((2*rw*n)/(tau*c));
dist = linspace(0,rw,Npoints);
plot(dist,abs(out(n:n+Npoints-1)));
xlabel('Target positions');
ylabel('Compressed received signal');
grid