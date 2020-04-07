# Range-Doppler map using 2D FFT 
Consider an FMCW radar operating at 3.3GHz. Simulate a target at 25m. Use the technique of 2D-FFT to get the range-doppler map

## Procedure:
1. Assume the radar specifications.  
   a. Carrier frequency = 3.3GHz  
   b. Maximum range = 500m  
   c. range resolution = 3.3m  
   Compute the following:  
   a. Bandwidth = speed_of_light / (2* range resolution)  
   b. Chirp time = 2 * Max range / speed_of_light  
   c. Chirp rate, alpha = bandwidth / chirp time  
   d. lambda = speed_of_light / carrier frequency  
2. Let the initial target range and velocity be 80 m and -50 m/s respectively.
3. Assume the range and doppler cells(Nr and Nd) needed for the computation of 2D-FFT.
4. Radar Signal Generation:  
   a. Tx signal = cos(2 * pi * (fc * t + alpha * t^2))  
   b. Rx signal = cos(2 * pi * (fc * (t-td) + alpha * (t-td)^2))  
   c. where td = 2 * (initial target range + initial target velocity * t) / speed_of_light  
   d. Beat signal, mixerOut = Tx * Rx  
5. Range measurement:  
   Compute the FFT of beat signal along Nr (range cells)
6. Range Doppler map:  
   Compute the 2D FFT of beat signal along Nr and Nd (both range and doppler cells)
7. Doppler velocity = doppler freq * lambda / 2
