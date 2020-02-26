function [snr_out] = range_calc_PR(Pt, fo, Ti, Gt, Gr, tau, PRF, RCS, T0, F, L, R)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simple script to find the SNR, given the range of target for pulse radars
% Plot the dependancy of SNR with respect to range of the target
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
%   Pt = Transmitted power (W)
%   tau = pulse width (sec)
%   PRF = pulse repetition frequency (Hz)
%   Ti = time to target (sec)
%   G = gain of antenna (Gt * Gr) (db)
%   fo = operating frequency (Hz)
%   RCS = radar cross section (m^2)
%   T0 = temperature in Kelvin (K)
%   F = system noise figure (db)
%   L = total system losses (db)
%   R = range of the target (m)
%--------------------------------------------------------------------------
% Outputs:
%   SNR = signal to noise ratio (db)
%--------------------------------------------------------------------------

%declare constants and variables
c = 3e8;
lambda = c/fo ;

%compute the duty cycle of pulse radars
duty_cycle = tau * PRF; % di = tau * PRF
pavg = Pt * duty_cycle; % Pt * di
pavg_db = 10.0*log10(pavg);

%calculate all the parameters in db
lamdba_db = 10.0 * log10(lambda^2);
Ti_db = 10.0 * log10(Ti);
RCS_db = 10.0 * log10(RCS);
four_pi_db = 10.0 * log10((4*pi)^3);
k_db = 10.0 * log10(1.38e-23); %Boltzman constant
t_db = 10.0 * log10(T0);
range_db = 10.0 *log10(R^4);

snr_out = pavg_db + Gt + Gr + lamdba_db + RCS_db + Ti_db - four_pi_db...
        - k_db - t_db - F - L - range_db;

%let the range vary from 10km to 1000km
i = 1;
for range_var = 10:10:1000
    range_var_db = 10.0 * log10(range_var * 1000);
    snr(i) = pavg_db + Gt + Gr + lamdba_db + RCS_db + Ti_db - four_pi_db...
        - k_db - t_db - F - L - (4 * range_var_db);
    i = i + 1;
end
range_var = 10:10:1000;
plot(range_var,snr);
xlabel('Range in km');
ylabel('SNR in db');
title('Range of target - SNR dependancies')
          
return
end

    

    

