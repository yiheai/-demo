% houghcircle - takes an edge map image, and performs the Hough transform
% for finding circles in the image.��ȡһ������canny�任��ͼ������hough�任�ҵ�ͼ���е�һ��Բ��
%
% Usage: 
% h = houghcircle(edgeim, rmin, rmax)
%
% Arguments:
%	edgeim      - the edge map image to be transformed Ҫ��ת���ı�Եmapͼ��
%   rmin, rmax  - the minimum and maximum radius values
%                 of circles to search for ����Բ����С�����İ뾶ֵ
% Output:
%	h           - the Hough transform ����ת��
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

[y,x] = find(edgeim~=0);%�ҵ�edgeim�в�����0������ֵ

%for each edge point, draw circles of different radii
for index=1:size(y)
    
    cx = x(index);
    cy = y(index);
    
    for n=1:nradii
        
        h(:,:,n) = addcircle(h(:,:,n),[cx,cy],n+rmin);
        
    end
    
end
