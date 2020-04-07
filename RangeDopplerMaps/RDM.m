%% This task is a part of Weather radar signal and data processing project.
% Author : Supriya Sudarshan 
% Range-Doppler map for FMCW radar using 2D-FFT method

% Simulate the FMCW radar, get the range compressed data using compression techniques
% Apply 2D FFT on the mixer output to get the range-doppler map.
% Assume the values for range and doppler cells

clear all;
clc;
close all;

%% RADAR Specifications
% Frequency of operation, fc: 3.3GHz 
% Max range, range: 500m
% Range resolution, delR: 3.3m
% Bandwidth, B = c / (2* range resolution)
% Chirp time , Tchirp = 2 * Max range / c
% Chirp rate, alpha = bandwidth / chirp time

%% Initial target range and velocity
d0 = 80; % initial range
v0 = -50; % velocity (assumed constant)

%% FMCW Waveform Design
delR = 3.3; %m
speed_of_light = 3e8; %m/s  
range = 500; %m
B = speed_of_light / (2 * delR);  % Hz
Tchirp = 2 * range / speed_of_light; %s
alpha = B / Tchirp; 
fc = 3.3e9; %Hz 
lambda = speed_of_light/fc; %m                                                     
Nd = 128; %doppler cells, given by Tdwell/PRT. default 128 for hybrid receivers
Nr = 1024; %range cells

t = linspace(0, Nd * Tchirp, Nr * Nd); % total time for samples

% vectors for Tx, Rx and Mix based on the total samples input
Tx = zeros(1, length(t));    % transmitted signal
Rx = zeros(1, length(t));    % received signal
mixerOut = zeros(1, length(t));   % beat signal

% vectors for range covered and time delay
rcov = zeros(1, length(t));
td = zeros(1, length(t));

rcov = d0 + v0 * t;
td = 2 * rcov / speed_of_light;

%% Signal generation and Moving Target simulation

for i = 1:length(t)         
    Tx(i) = cos(2 * pi * (fc * t(i) + alpha * t(i)^2 / 2));
    Rx(i) = cos(2 * pi * (fc * (t(i) - td(i)) + (alpha * (t(i) - td(i))^2) / 2));
    mixerOut(i) = Tx(i) * Rx(i);  % beat signal
end


%% RANGE MEASUREMENT
% FFT on beat signal along Nr gives the range compressed output
% Normalise the range compressed output
range_fft = fft(mixerOut, Nr)./Nr;
range_fft = abs(range_fft);       
%plot of range compressed data
figure('Name', 'Range information from first FFT')   
plot(range_fft(1:Nr/2)); grid on;
axis([0 200 0 1]);
xlabel('Measured range in m');
ylabel('Compressed data in dB');

%% RANGE DOPPLER RESPONSE

% Running a 2D FFT on the mixed signal (beat signal) output and generate a Range Doppler Map (RDM)
% The output of the 2D FFT is an image that has reponse in the range and doppler FFT bins. 
% Therefore, it is important to convert the axis from bin sizes to range and doppler based on their max values
Mix = reshape(mixerOut, [Nr, Nd]);

% 2D FFT using the FFT size for both dimensions
doppler_fft2 = fft2(Mix, Nr, Nd);
RDM = abs(doppler_fft2(1 : Nr/4 , 1 : Nd));
RDM = 10*log10(RDM);

%plotting range doppler map
doppler_axis = linspace(-100, 100, Nd).*(lambda/2); %doppler velocity
range_axis = linspace(0, 200, Nr/2)* ((Nr / 2) / 400);
figure('Name', 'Range Doppler Map from 2D FFT');
imagesc(doppler_axis,range_axis, RDM);
set(gca,'Ydir','normal')
xlabel('Relative doppler velocity in m/s');
ylabel('Range in m');
