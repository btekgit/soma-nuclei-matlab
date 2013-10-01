avg_pixel_radius =  mean([160,160,200])/1000;
avg_pixel_volume = prod([160,160,200])/1000000000; % in micro m
z_height = 50*4/1000/1000;
x_height = 40*4/1000/1000; 
y_height = 40*4/1000/1000;

figure;
[gtrhisthit,binss]= hist(gtr(gthitIx==1)*avg_pixel_radius);
bar(binss,gtrhisthit,'FaceColor',[0.6 0.6 0.6]);
hold;
[gtrhistmiss,binss] = hist(gtr(gthitIx==0)*avg_pixel_radius,binss);
bar(binss,gtrhistmiss, 'FaceColor',[1 0 0],'BarWidth',0.5);
ylabel('Nuclei Count');
xlabel('Radius (\mum)');
legend('Hit', 'Missed');
ylim([0,900]);
axis tight;
box on;
paper_fig(gca, 30);


figure;
[gtzhisthit,binss] = hist(gtz(gthitIx==1)*z_height);
bar(binss,gtzhisthit,'FaceColor',[0.6 0.6 0.6]);
hold;
[gtzhistmiss, binss] = hist(gtz(gthitIx==0)*z_height,binss);
bar(binss,gtzhistmiss,'FaceColor',[1 0 0],'BarWidth',0.5);
ylabel('Nuclei Count');
xlabel('Z Position (mm)');
legend('Hit', 'Missed');
ylim([0,500]);
axis tight;
box on;
paper_fig(gca, 30);


figure;
[gtzhisthit,binss] = hist(CC.areas(dthitIx==1,1)*avg_pixel_volume);
bar(binss,gtzhisthit,'FaceColor',[0.6 0.6 0.6]);
hold;
[gtzhistmiss, binss] = hist(CC.areas(dthitIx==0,1)*avg_pixel_volume,binss);
bar(binss,gtzhistmiss,'FaceColor',[1 0 0],'BarWidth',0.5);
ylabel('Nuclei Count');
xlabel('Volume (\mum^3)');
legend('True positive', 'False Positive');
axis tight;
box on;
%xlim([0 84])
paper_fig(gca, 30);

figure; % scatters 
scatter3(gtx(gthitIx==1)*x_height,gty(gthitIx==1)*y_height,gtz(gthitIx==1)*z_height,65,'b','.');
%xlim([0 1024]); ylim([0 800]); zlim([0 7600]);
daspect([1 1 1 ])
axis tight;
box on;
%pbaspect([1 1 1])
%xlabel('x (mm)'); 
%ylabel('y (mm)'); 
zlabel('z (mm)');
view(-45,20)
hold on;

scatter3(gtx(gthitIx==0)*x_height,gty(gthitIx==0)*y_height,gtz(gthitIx==0)*z_height,45,'r','x');
%xlim([0 1024]); ylim([0 800]); zlim([0 7600]);
set(gca,'ZDir','Reverse');
set(gca,'YTick',double(floor(max(gty(gthitIx==0)*y_height*100))/100))
set(gca,'XTick',double(floor(max(gtx(gthitIx==0)*x_height*100))/100))
daspect([1 1 1 ])
%pbaspect([1 1 1])
axis tight;
box on;
%legend('Hit','Missed');
%xlabel('x (mm)'); ylabel('y (mm)'); 
zlabel('z (mm)');
view(-45,20)
%paper_fig(gca);
axh = gca;
set(axh,'Fontsize', 18);  % font size
%set(get(axh,'Xlabel'),'Fontsize',14);
%set(get(axh,'Ylabel'),'Fontsize',14);
set(get(axh,'Zlabel'),'Fontsize',18);
orient tall



