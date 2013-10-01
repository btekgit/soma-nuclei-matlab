%plot nearest neihbour distance and distribution.


dist_gt = nnDistance3D(gtlistreordered);
dist_dt = nnDistance3D(CC.centroids);
figure;
[hist_nn_gt,binss] = hist(dist_gt);
[hist_nn_dt,binss] = hist(dist_dt,binss);

bar(binss,hist_nn_gt, 'FaceColor',[0.5 0.5 0.5]);
hold on;
bar(binss,hist_nn_dt, 'FaceColor',[1 0 0],'BarWidth',0.5);
xlabel('Inter nuclei distance in px');
ylabel('#Nuclei');
legend('Ground truth', 'Detections');

%zstacked plot
zrange = linspace(1,7600,4)
[hist_nn_gt,binss] = hist(dist_gt);
disthistmat_gt = zeros(length(zrange)-1, length(binss));
disthistmat_dt = zeros(length(zrange)-1, length(binss));
for i = 2:length(zrange)
    zlow= zrange(i-1);
    zhigh = zrange(i);
    Iinrange_gt = find(gtlistreordered(:,3)>zlow & gtlistreordered(:,3)<zhigh);
    subsetIgt = gtlistreordered(Iinrange_gt,1:3);
    Iinrange_dt = find(CC.centroids(:,3)>zlow & CC.centroids(:,3)<zhigh);

    subsetIdt = CC.centroids(Iinrange_dt,1:3);
    dist_gt_i = nnDistance3D(subsetIgt);
    dist_dt_i = nnDistance3D(subsetIdt);
    [hist_nn_gt_i,binss] = hist(dist_gt_i,binss);
    [hist_nn_dt_i,binss] = hist(dist_dt_i,binss);
    disthistmat_gt(i-1,:) = hist_nn_gt_i;
    disthistmat_dt(i-1,:) = hist_nn_dt_i;
end
figure
subplot(121);
bar(binss,disthistmat_gt');
xlabel('Inter nuclei centroid distance for Ground Truth');
ylabel('#Nuclei');
subplot(122);
bar(binss,disthistmat_dt');
xlabel('Inter nuclei centroid distance for Detections');
ylabel('#Nuclei');