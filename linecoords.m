% linecoords - returns the x y coordinates of positions along a
% line（返回一条线的上各点的x,y坐标值）
%
% Usage: 
% [x,y] = linecoords(lines, imsize)
%
% Arguments:
%	lines       - an array containing parameters of the line in
%                 form 包含直线形式参数的数组
%   imsize      - size of the image, needed so that x y coordinates
%                 are within the image boundary 图像尺寸，需要在图像边界内的X,Y坐标
%
% Output:
%	x           - x coordinates  x坐标
%	y           - corresponding y coordinates 对应y坐标
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003

function [x,y] = linecoords(lines, imsize)

xd = [1:imsize(2)];
yd = (-lines(3) - lines(1)*xd ) / lines(2);

coords = find(yd>imsize(1));
yd(coords) = imsize(1);
coords = find(yd<1);
yd(coords) = 1;

x = int32(xd);
y = int32(yd);   