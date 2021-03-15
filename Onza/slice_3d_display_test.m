%% Generate sample images
[x,y,z,v] = flow; %// x,y,z and v are all of size [25x50x25]

im1 = v(:,:,5);  %// extract the slice at Z=5.  im1 size is [25x50]
im2 = v(:,:,10); %// extract the slice at Z=10. im2 size is [25x50]
im3 = v(:,:,15); %// extract the slice at Z=15. im3 size is [25x50]
im4 = v(:,:,20); %// extract the slice at Z=20. im4 size is [25x50]

hf = figure ;
subplot(221);imagesc(im1);title('Z=5');
subplot(222);imagesc(im2);title('Z=10');
subplot(223);imagesc(im3);title('Z=15');
subplot(224);imagesc(im4);title('Z=20');

%// This is just how I generated sample images, it is not part of the "answer" !

M(:,:,1) = im1 ;
M(:,:,2) = im2 ;
M(:,:,3) = im3 ;
M(:,:,4) = im4 ;
%% 
hf2 = figure ;
hs = slice(M,[],[],9:10) ;
shading interp
set(hs,'FaceAlpha',0.8);