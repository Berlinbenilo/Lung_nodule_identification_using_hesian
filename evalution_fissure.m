%% evalution metrices
global fissurenet input_image accuracy
ACTUAL= input_image;
PREDICTED=fissurenet;
idx = (ACTUAL()==1);
p = length(ACTUAL(idx));
n = length(ACTUAL(~idx));
N = p+n;
tp = sum(ACTUAL);
tp=sum(tp);
% tp=sum(tp);
tn = sum(PREDICTED);
tn=sum(tn);
% tn=sum(tn);
fp = n-tn;
fn = p-tp;
tp_rate = tp./p;
tn_rate = tn./n;
fp_rate = fp./n;
fn_rate = fn./p;
%accuracy = (tp+tn)./N;
accuracy = accuracy.*100;
% accuracy = (tp+tn)./N;
fprintf('accuracy:%f\n',accuracy);
sensitivity = 1-fp_rate;
specificity = tn_rate;
fprintf('specificity:%f\n',specificity);
precision = tp./(tp+fp);
fprintf('precision:%f\n',precision);
recall = sensitivity;
fprintf('recall:%f\n',recall);
gmean = sqrt(tp_rate.*tn_rate);

run Copy_of_graph.m