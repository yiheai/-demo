% linecoords - returns the x y coordinates of positions along a
% line������һ���ߵ��ϸ����x,y����ֵ��
%
% Usage: 
% [x,y] = linecoords(lines, imsize)
%
% Arguments:
%	lines       - an array containing parameters of the line in
%                 form ����ֱ����ʽ����������
%   imsize      - size of the image, needed so that x y coordinates
%                 are within the image boundary ͼ��ߴ磬��Ҫ��ͼ��߽��ڵ�X,Y����
%
% Output:
%	x           - x coordinates  x����
%	y           - corresponding y coordinates ��Ӧy����
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