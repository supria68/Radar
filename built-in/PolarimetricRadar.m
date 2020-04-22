%% Simulating a Polarimetric Radar to obtain Range Doppler Map 
% This test is a part of Weather radar signal processing project.
% Author: Supriya Sudarshan
% Version: 16.04.2020

clear;
close all;
clc;

%% System Setup
maxrng = 48e3;         % Maximum range (m)
rngres = 50;           % Range resolution (m)
tbprod = 20;           % Time-bandwidth product 
fc = 300e6;            % Carrier frequency (Hz)
c = 3e8;               % Propagation speed (m/s)
lambda = c/fc;         % Operating wavelength (m)
bw = c/(2*rngres);     % Sampling rate (Hz)

%% Radar Blocks
% Waveform
waveform = phased.LinearFMWaveform('PulseWidth',tbprod/bw,'PRF',c/(2*maxrng),...
    'SweepBandwidth',bw,'SampleRate',bw);

%Antenna
antenna = phased.ShortDipoleAntennaElement('AxisDirection','Z');
array = phased.ULA(4,lambda/2,'Element',antenna);

% Transmitter and Radiator
transmitter = phased.Transmitter('PeakPower',5000);
txmotion = phased.Platform('OrientationAxesOutputPort',true,...
                          'OrientationAxes',azelaxes(0,0));

radiator = phased.Radiator('Sensor',array,'PropagationSpeed',c,...
                       'Polarization','Combined');
            
% Channel
channel = phased.FreeSpace('SampleRate',bw,...
    'OperatingFrequency',fc,'PropagationSpeed',c);
                   
% Collector and Receiver
collector = phased.Collector('Sensor',array,...
    'PropagationSpeed',c,...
    'OperatingFrequency',fc,...
    'Polarization','Combined');
receiver = phased.ReceiverPreamp('SampleRate',bw);
rxmotion = phased.Platform('InitialPosition',[0;0;0],...
    'Velocity',[0;0;0],'OrientationAxesOutputPort',true,...
    'OrientationAxes',azelaxes(0,0));

% Matlab Built-in function for RDM
rngdopresp = phased.RangeDopplerResponse('SampleRate',bw,...
    'PropagationSpeed',c,...
    'DopplerOutput','Speed',...
    'OperatingFrequency',fc,...
    'DopplerFFTLengthSource','Property',...
    'DopplerFFTLength',512,...
    'DopplerWindow','Taylor',...
    'DopplerSidelobeAttenuation',40);

% Target Creation
ScatteringMatrices = {[1 0;0 1];[0 1;1 0]};
tgtpos = [[15000;1000;500],[35000;-1000;1000]];
tgtvel = [[100;100;0],[-160;0;-50]];
tgtmotion = phased.Platform('InitialPosition',tgtpos,...
    'Velocity',tgtvel,'OrientationAxesOutputPort',true,...
    'OrientationAxes',azelaxes(0,0));

for i=1:2             % For each target   
    target{i} = phased.RadarTarget('EnablePolarization',true,...
        'Mode','Bistatic','ScatteringMatrix',ScatteringMatrices{i},...
        'PropagationSpeed',c,'OperatingFrequency',fc); 
end

%% Radar Pulse Simulation

Nblock = 64; % Burst size
dt = 1/waveform.PRF;
y = complex(zeros(round(waveform.SampleRate*dt),Nblock)); % pre-allocate received signal array with 0s

%Antenna considered is stationary!!
pos = [0;0;0];
vel = [0;0;0];
axes = [1,0,0;0,1,0;0,0,1]; 

%Set the basic plot
myPlots = systemSetup(txmotion,rxmotion,tgtmotion,waveform,rngdopresp,y);

% LinearFM waveform synthesis
Npulse = Nblock*4;
for m = 1:Npulse
    
    % Update position of targets
    [tgtp,tgtv,tgtax] = tgtmotion(dt);
   
    % Calculate the target angles as seen by the transmitter
    [txrng,radang] = rangeangle(tgtp,pos,axes);
     
    % Simulate propagation of pulse in direction of targets  
    wav = waveform();
    wav = transmitter(wav);
    sigtx = radiator(wav,radang,axes);
    sigtx = channel(sigtx,pos,tgtp,vel,tgtv);

    % Reflect pulse off of targets
    for n = 2:-1:1
        [~,ang] = rangeangle(pos,tgtp(:,n),tgtax(:,:,n));
        sigtgt(n) = target{n}(sigtx(n),ang,ang,tgtax(:,:,n));
    end

    % Back propagation via channel
    sigrx = channel(sigtgt,pos,tgtp,vel,tgtv);
    rspeed = radialspeed(tgtp,tgtv,pos,vel);
         
    % Receive target returns
    sigrx = collector(sigrx,radang,axes);
    y(:,mod(m-1,Nblock)+1) = receiver(sum(sigrx,2));
    
end

% plotting the result
mfcoeff = getMatchedFilter(waveform); % reference signal
resp = rngdopresp(y,mfcoeff); % RDM of received and reference
myPlots.himg(mag2db(abs(resp)));  