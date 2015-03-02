function invtform = reversetransform(tsmoothed)
   tform = affine2d([tsmoothed(1,1),tsmoothed(1,2),0;tsmoothed(2,1),tsmoothed(2,2),0;tsmoothed(3,1),tsmoothed(3,2),1]);
   invtform = invert(tform);

