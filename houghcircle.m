% houghcircle - takes an edge map image, and performs the Hough transform
% for finding circles in the image.（取一幅经过canny变换的图像，利用hough变换找到图像中的一个圆）
%
% Usage: 
% h = houghcircle(edgeim, rmin, rmax)
%
% Arguments:
%	edgeim      - the edge map image to be transformed 要被转换的边缘map图像
%   rmin, rmax  - the minimum and maximum radius values
%                 of circles to search for 搜索圆的最小和最大的半径值
% Output:
%	h           - the Hough transform 霍夫转换
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003

function h = houghcircle(edgeim, rmin, rmax)

[rows,cols] = size(edgeim);
nradii = rmax-rmin+1;
h = zeros(rows,cols,nradii);

[y,x] = find(edgeim~=0);%找到edgeim中不等于0的索引值

%for each edge point, draw circles of different radii
for index=1:size(y)
    
    cx = x(index);
    cy = y(index);
    
    for n=1:nradii
        
        h(:,:,n) = addcircle(h(:,:,n),[cx,cy],n+rmin);
        
    end
    
end
