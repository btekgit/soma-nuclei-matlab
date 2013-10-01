%plots scatter matrices

bins = 1: 7552;
figure;
hist(gt.validannotations(:,6),bins);

zaxis = load('D:\mouse_brain\20130506-interareal_mag4\20130506-interareal_mag4\zaxis2.txt');

figure

subplot(131);
scatter3(gtlistreordered(:,1),gtlistreordered(:,2)',gtlistreordered(:,3),floor(gtlistreordered(:,4)/2),'b');
xlim([0 1024]); ylim([0 800]); zlim([0 7600]);
title('GTruth Annotation');
xlabel('x'); ylabel('y'); zlabel('z');
view(-45,8)

%hold on;
subplot(132);
scatter3(gtx(gthitIx==1),gty(gthitIx==1),gtz(gthitIx==1),floor(gtr(gthitIx==1)/2),'g');
xlim([0 1024]); ylim([0 800]); zlim([0 7600]);
title('GTruth Detected');
xlabel('x'); ylabel('y'); zlabel('z');
view(-45,8)
hold on;

subplot(133);
scatter3(gtx(gthitIx==0),gty(gthitIx==0),gtz(gthitIx==0),floor(gtr(gthitIx==0)/2),'r');
xlim([0 1024]); ylim([0 800]); zlim([0 7600]);
title('GTruth Missed');
xlabel('x'); ylabel('y'); zlabel('z');
view(-45,8)

figure

subplot(131);
scatter3(dt_ctr(:,1),dt_ctr(:,2),dt_ctr(:,3),floor(CC.areas/1000),'b');
xlim([0 1024]); ylim([0 850]); zlim([0 7600]);
xlabel('x'); ylabel('y'); zlabel('z');
title('Detections');
view(-45,8)


subplot(132);
scatter3(dt_ctr(dthitIx==1,1),dt_ctr(dthitIx==1,2),dt_ctr(dthitIx==1,3),floor(CC.areas(dthitIx==1)/1000),'g');
xlim([0 1024]); ylim([0 850]); zlim([0 7600]);
title('True Detections');
xlabel('x'); ylabel('y'); zlabel('z');
view(-45,8)

subplot(133);
scatter3(dt_ctr(dthitIx==0,1),dt_ctr(dthitIx==0,2),dt_ctr(dthitIx==0,3),floor(CC.areas(dthitIx==0)/1000),'r');
xlim([0 1024]); ylim([0 850]); zlim([0 7600]);
title('False Detections');
xlabel('x'); ylabel('y'); zlabel('z');
view(-45,8)