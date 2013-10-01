% plots hit miss histograms  

figure;
    subplot(221);
    [gtrhisthit,binss]= hist(gtr(gthitIx==1));
    bar(binss,gtrhisthit,'b');
    hold;
    [gtrhistmiss,binss] = hist(gtr(gthitIx==0),binss);
    bar(binss,gtrhistmiss, 'red');
    title('True/Missed GT radius');
    subplot(222);
    [gtzhisthit,binss] = hist(gtz(gthitIx==1));
    bar(binss,gtzhisthit,'b');
    hold;
    [gtzhistmiss, binss] = hist(gtz(gthitIx==0),binss);
    bar(binss,gtzhistmiss,'r');
    title('True/Missed GT z pos');
    subplot(223);
    [gtxhisthit,binss] = hist(gtx(gthitIx==1));
    bar(binss,gtxhisthit,'b');
    hold;
    [gtxhistmiss,binss] = hist(gtx(gthitIx==0),binss);
    bar(binss,gtxhistmiss,'r');
    title('True/Missed GT x pos');
    subplot(224);
    [gtyhisthit,binss] = hist(gty(gthitIx==1));
    bar(binss,gtyhisthit,'b');
    hold;
    [gtyhistmiss,binss] = hist(gty(gthitIx==0),binss);
    bar(binss,gtyhistmiss,'r');
    title('True/Missed GT y pos');
    
    figure;
    subplot(221);
    [dtzhisthit,binss] = hist(CC.centroids(dthitIx==1,3));
    bar(binss,dtzhisthit,'b');
    hold;
    [dtzhistfalse,binss] = hist(CC.centroids(dthitIx==0,3),binss);
    bar(binss,dtzhistfalse,'r');
    title('True/False detections z pos')
    
    subplot(222);
    [dtyhisthit,binss] = hist(CC.centroids(dthitIx==1,2));
    bar(binss,dtyhisthit,'b');
    hold;
    [dtyhistfalse,binss] = hist(CC.centroids(dthitIx==0,2),binss);
    bar(binss,dtyhistfalse,'r');
    title('True/False detections y pos')
    
    subplot(223);
    [dtxhisthit,binss] = hist(CC.centroids(dthitIx==1,1));
    bar(binss,dtxhisthit,'b');
    hold;
    [dtxhistfalse,binss] = hist(CC.centroids(dthitIx==0,1),binss);
    bar(binss,dtxhistfalse,'r');
    title('True/False detections x pos')
    
    subplot(224);
    [dtahisthit,binss] = hist(CC.areas(dthitIx==1,1));
    bar(binss,dtahisthit,'b');
    hold;
    [dtahistfalse,binss] = hist(CC.areas(dthitIx==0,1), binss);
    bar(binss,dtahistfalse,'r');
    title('True/False detections Volume')
    

