load 'hes.mat'
load 'fis.mat'
figure;
plot(hes(:,2),hes(:,1),'Marker','.','MarkerSize',20);
title('OBJECT DIFFUSION');xlabel('TRACKING PERIODS');ylabel('BOUNDARY NODES');

grid on;hold on;
plot(fis(:,2),fis(:,1),'Marker','.','MarkerSize',20);
title('OBJECT DIFFUSION');xlabel('TRACKING PERIODS');ylabel('BOUNDARY NODES');
legend('DEMCO','RELIABLE');