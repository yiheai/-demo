% findline - returns the coordinates of a line in an image using the
% linear Hough transform and Canny edge detection to create
% the edge map.（利用线性Hough变换和Canny边缘探测得到的线上各点的坐标）
%
% Usage: 
% lines = findline(image)
%
% Arguments:
%	image   - the input image
%
% Output:
%	lines   - parameters of the detected line in polar form
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003

function lines = findline(image)

% [I2 or] = canny(image, 2, 1, 0.00, 1.00);%function [gradient, or] = canny(im, sigma, scaling, vert, horz),I2为灰度阶梯图
% 
% I3 = adjgamma(I2, 1.9);%function newim = adjgamma(im, g) 
% I4 = nonmaxsup(I3, or, 1.5);%im = nonmaxsup(inimage, orient, radius)
% edgeimage = hysthresh(I4, 0.20, 0.15);%function bw = hysthresh(im, T1, T2)

% generate the edge image using toolbox
edgeimage = edge(image,'canny');%自动选择阈值，用canny算子进行边缘检测。

theta = (0:179)';%'表示转置矩阵
[R, xp] = radon(edgeimage, theta);%返回亮度图像在角度theta下的randon变换，
%randon变换是一幅图像在一个特定角度下的径向线方向的投影。如果theta是一个向量，R则是一个矩阵，矩阵的每一列是对应其中一个theta的Radon变换。
%[R,xp] = radon(...) 对应于R中的每一行，返回一个包含径向坐标的向量xp。xp中的径向坐标是沿着X’轴的数值，其为在theta下，X’轴逆时针方向映射来的。两个坐标系的原点为图像的中心点，且为floor((size(edegeimage)+1)/2)
maxv = max(max(R));

if maxv > 25
    i = find(R == max(max(R)));%找出R数组中等于max(max（R）)的元素的索引值
else
    lines = [];
    return;
end

[foo, ind] = sort(-R(i));%foo是排列结果，ind是排列时的索引顺序
u = size(i,1);  
k = i(ind(1:u));
[y,x]=ind2sub(size(R),k);%用于把数组中元素索引值转换为该元素在数组中对应的下标，k为索引值
t = -theta(x)*pi/180;
r = xp(y);

lines = [cos(t) sin(t) -r];

cx = size(image,2)/2-1;
cy = size(image,1)/2-1;
lines(:,3) = lines(:,3) - lines(:,1)*cx - lines(:,2)*cy;
