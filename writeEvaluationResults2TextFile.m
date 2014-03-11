% writes things to the file
writeXYZR2txt('./results/ex1_groundtruth_all_orig.txt', floor(gtlistreordered))
writeXYZR2txt('./results/ex1_groundtruth_all4x.txt',  floor(gtlistreordered.*4));

writeXYZR2txt('./results/ex1_groundtruth_hit.txt',  floor([gtx(gthitIx==1),gty(gthitIx==1),gtz(gthitIx==1),floor(gtr(gthitIx==1))]));

writeXYZR2txt('./results/ex1_groundtruth_miss.txt', floor([gtx(gthitIx==0),gty(gthitIx==0),gtz(gthitIx==0),floor(gtr(gthitIx==0))]));

writeXYZR2txt('./results/ex1_detections_all.txt', floor([dt_ctr(:,1),dt_ctr(:,2),dt_ctr(:,3),floor(dt_pseudo_radius)]));


writeXYZR2txt('./results/ex1_detections_true.txt',floor([dt_ctr(dthitIx==1,1),dt_ctr(dthitIx==1,2),dt_ctr(dthitIx==1,3),floor(dt_pseudo_radius(dthitIx==1))]));


writeXYZR2txt('./results/ex1_detections_false.txt', floor([dt_ctr(dthitIx==0,1),dt_ctr(dthitIx==0,2),dt_ctr(dthitIx==0,3),floor(dt_pseudo_radius(dthitIx==0))]));



