% circlecoords - returns the pixel coordinates of a circle defined by the
%                radius and x, y coordinates of its
%                centre.（返回由圆的半径和圆心坐标决定的圆上各点像素的坐标）
%
% Usage: 
% [x,y] = circlecoords(c, r, imgsize,nsides)
%
% Arguments:
%	c           - an array containing the centre coordinates of the circle
%	              [x,y] 一个包含圆心坐标的数组
%   r           - the radius of the circle 圆的半径
%   imgsize     - size of the image array to plot coordinates onto
%   要在其上绘制坐标的图像数组的大小
%   nsides      - the circle is actually approximated by a polygon, this
%                 argument gives the number of sides used in this approximation. Default
%                 is 600. 圆实际上是由多边形的，此参数给出在近似中使用的边数，默认值是600
%
% Output:
%	x		    - an array containing x coordinates of circle boundary
%	              points 包含圆边界坐标x的数组
%   y		    - an array containing y coordinates of circle boundary
%                 points 包含圆边界坐标y的数组
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003

function [x,y] = circlecoords(c, r, imgsize,nsides)

    
    if nargin == 3
	nsides = 600;
    end
    
    nsides = round(nsides);
    
    a = [0:pi/nsides:2*pi];
    xd = (double(r)*cos(a)+ double(c(1)) );
    yd = (double(r)*sin(a)+ double(c(2)) );
    
    xd = round(xd);
    yd = round(yd);
    
    %get rid of -ves    
    %get rid of values larger than image
    xd2 = xd;
    coords = find(xd>imgsize(2));
    xd2(coords) = imgsize(2);
    coords = find(xd<=0);
    xd2(coords) = 1;
    
    yd2 = yd;
    coords = find(yd>imgsize(1));
    yd2(coords) = imgsize(1);
    coords = find(yd<=0);
    yd2(coords) = 1;
    
    x = int32(xd2);
    y = int32(yd2);   