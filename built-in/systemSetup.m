function myPlots = systemSetup(txmotion,rxmotion,tgtmotion,waveform,rngdopresp,y)

figure('Color','w');

txpos = txmotion.InitialPosition/1000;
rxpos = rxmotion.InitialPosition/1000;
tgtpos = tgtmotion.InitialPosition/1000;

msize = 10;

myPlots.htxpath = plot3(txpos(1),txpos(2),txpos(3),...
    'Color','k','Marker','o','MarkerSize',msize,'LineStyle','none');
hold on;
text(1,0.1,0.05,'Transmitter')


myPlots.hrxpath = plot3(rxpos(1),rxpos(2),rxpos(3),...
    'Color','m','Marker','>','MarkerSize',msize,'LineStyle','none');
text(1.1*rxpos(1),1.1*rxpos(2),1.1*rxpos(3),'Receiver')

tgtcolor = ['b','r'];
tgtmarker = ['x','+'];
for m = size(tgtpos,2):-1:1
    myPlots.htgtpath(m) = plot3(tgtpos(1,m),tgtpos(2,m),tgtpos(3,m),...
        'Color',tgtcolor(m),'Marker',tgtmarker(m),...
        'MarkerSize',msize,'LineStyle','none');
    text(1.1*tgtpos(1,m),1.1*tgtpos(2,m),1.05*tgtpos(3,m),sprintf('Target %d',m))
end

drawnow;
view(30,10);
grid on;
set(gca,'Color','none');
xlabel('x (km)');
ylabel('y (km)');
zlabel('z (km)');
title('System Dynamics');

drawnow;

mfcoeff = getMatchedFilter(waveform);
[~,rng_grid,dop_grid] = rngdopresp(y,mfcoeff);
dop_grid = dop_grid*2;  % bistatic
myPlots.himg = phased.scopes.MatrixViewer( ...
    'XStart',  dop_grid(1)*18/5, ...
    'XScale',  (dop_grid(2)-dop_grid(1))*18/5, ...
    'YStart',  rng_grid(1)/1000, ...
    'YScale',  (rng_grid(2)-rng_grid(1))/1000, ...
    'YInvert', true, ...
    'XLabel',  'Speed (km/h)', ...
    'YLabel',  'Range (km)', ...
    'Title',   'Range-Doppler Map');

hold on;

drawnow;

% [EOF]
