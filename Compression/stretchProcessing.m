%% This task is a part of Weather radar signal and data processing project.
% Author : Supriya Sudarshan 
% Implementing a stretch processor for estimating target range-profile
% Reference:  Bassem R. Mahafza, Radar Signal Analyis and Processing using Matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
clc;
close all;

%%function [rxC] = stretch(nscat, taup, fc, B, scat_range, rrec, scat_rcs)
%% Input
nscat = 3; % number of targets
taup = 10e-3; % transmitted signal width [s]
fc = 5.6e9;% carrier frequency [Hz]
B = 1e9;% bandwidth [Hz]
scat_range = [5,5.1,10];% Range of each targets [m]
rrec = 30;% radar receiving window [m]
scat_rcs = [1,1,2];% RCS of each target [m^2]

%% Output
% rxC = received signal completely compressed

c = 3e8; % Speed of light
trec = 2 * rrec / c; 
n = fix(2 * trec * B);
x(nscat,1:n) = 0;
y(1:n) = 0;

t = linspace(0,taup,n);
for k = 1:1:nscat
  range = scat_range(k);
  psi1 = 4 * pi * range * fc / c - 4 * pi * B * range * range / c / c/ taup;
  psi2 = (2 * 4 * pi * B * range / c / taup) .* t;
  x(k,:) = scat_rcs(k) .* exp(1j * psi1 + 1j .* psi2);
  y = y + x(k,:);
end

yfft = fft(y,n)./n;
rxC= fftshift(abs(yfft));
figure(1)
range_axis = linspace(-rrec/2,rrec/2,n);
plot(range_axis,rxC,'k')
xlabel ('Relative range in meters')
ylabel ('Compressed echo')
title('Range profile using Stretch Processing')
grid on
