load fis_vs_hes.mat
x=total_acc';
bar(x);
title('Accuracy'); 
ylabel('Accuracy');xlabel('Number of images');
legend('Fissure','Hessian');
axis([0 6 0 100]);
figure;

y=sen';
bar(y);
title('Sensitivity'); 
ylabel('Sensitivity');xlabel('Number of images');
legend('Fissure','Hessian');
axis([0 6 0 100]);
figure;

z=spec';
bar(z);
title('Specificity'); 
ylabel('Specificity');xlabel('Number of images');
legend('Fissure','Hessian');
axis([0 6 0 100]);
figure;

a=pre';
bar(a);
title('Precision'); 
ylabel('Precision');xlabel('Number of images');
legend('Fissure','Hessian');
axis([0 6 0 1.2]);
