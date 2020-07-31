% CANNY - Canny edge detection（Canny边缘探测，图像边缘增强）
%
% Function to perform Canny edge detection. Code uses modifications as
% suggested by Fleck (IEEE PAMI No. 3, Vol. 14. March 1992. pp 337-345)
%
% Usage: [gradient or] = canny(im, sigma)
%
% Arguments:   im       - image to be procesed（处理的图像）
%              sigma    - standard deviation of Gaussian smoothing filter（高斯平滑滤波器的标准差）
%                      (typically 1)
%		       scaling  - factor to reduce input image by(缩放百分比，减少输入图像的因数)
%		       vert     - weighting for vertical gradients(垂直百分比，垂直渐变的加权)
%		       horz     - weighting for horizontal gradients(水平百分比，水平渐变的加权)
%
% Returns:     gradient - edge strength image (gradient amplitude)（边缘增强图像-渐变幅度）
%              or       - orientation image (in degrees 0-180, positive（方位图，以0-180度为单位）
%                         anti-clockwise)
%
% See also:  NONMAXSUP, HYSTHRESH

% Author: 
% Peter Kovesi   
% Department of Computer Science & Software Engineering
% The University of Western Australia
% pk@cs.uwa.edu.au  www.cs.uwa.edu.au/~pk
%
% April 1999    Original version
% January 2003  Error in calculation of d2 corrected
% March 2003	Modified to accept scaling factor and vertical/horizontal
%		        gradient bias (Libor Masek)

function [gradient, or] = canny(im, sigma, scaling, vert, horz)
xscaling = vert;
yscaling = horz;
hsize = [6*sigma+1, 6*sigma+1];   % The filter size.
gaussian = fspecial('gaussian',hsize,sigma); %fspecial函数用于建立预定义的滤波算子，type='gaussian'为高斯低通滤波，hsize表示模板尺寸，sigma为滤波标准值
im = filter2(gaussian,im);        % Smoothed image.filter2(B,X)B为滤波器，X为要滤波的数据
im = imresize(im, scaling);%imresize 将im放大scaling倍
[rows, cols] = size(im);

h =  [  im(:,2:cols)  zeros(rows,1) ] - [  zeros(rows,1)  im(:,1:cols-1)  ];
v =  [  im(2:rows,:); zeros(1,cols) ] - [  zeros(1,cols); im(1:rows-1,:)  ];
d1 = [  im(2:rows,2:cols) zeros(rows-1,1); zeros(1,cols) ] - [ zeros(1,cols); zeros(rows-1,1) im(1:rows-1,1:cols-1)  ];
d2 = [  zeros(1,cols); im(1:rows-1,2:cols) zeros(rows-1,1);  ] - [ zeros(rows-1,1) im(2:rows,1:cols-1); zeros(1,cols)   ];

X = ( h + (d1 + d2)/2.0 ) * xscaling;
Y = ( v + (d1 - d2)/2.0 ) * yscaling;

gradient = sqrt(X.*X + Y.*Y); % Gradient amplitude.

or = atan2(-Y, X);            % Angles -pi to + pi.求反正切函数
neg = or<0;                   % Map angles to 0-pi.
or = or.*~neg + (or+pi).*neg; 
or = or*180/pi;               % Convert to degrees.
