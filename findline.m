% findline - returns the coordinates of a line in an image using the
% linear Hough transform and Canny edge detection to create
% the edge map.����������Hough�任��Canny��Ե̽��õ������ϸ�������꣩
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

% [I2 or] = canny(image, 2, 1, 0.00, 1.00);%function [gradient, or] = canny(im, sigma, scaling, vert, horz),I2Ϊ�ҶȽ���ͼ
% 
% I3 = adjgamma(I2, 1.9);%function newim = adjgamma(im, g) 
% I4 = nonmaxsup(I3, or, 1.5);%im = nonmaxsup(inimage, orient, radius)
% edgeimage = hysthresh(I4, 0.20, 0.15);%function bw = hysthresh(im, T1, T2)

% generate the edge image using toolbox
edgeimage = edge(image,'canny');%�Զ�ѡ����ֵ����canny���ӽ��б�Ե��⡣

theta = (0:179)';%'��ʾת�þ���
[R, xp] = radon(edgeimage, theta);%��������ͼ���ڽǶ�theta�µ�randon�任��
%randon�任��һ��ͼ����һ���ض��Ƕ��µľ����߷����ͶӰ�����theta��һ��������R����һ�����󣬾����ÿһ���Ƕ�Ӧ����һ��theta��Radon�任��
%[R,xp] = radon(...) ��Ӧ��R�е�ÿһ�У�����һ�������������������xp��xp�еľ�������������X�������ֵ����Ϊ��theta�£�X������ʱ�뷽��ӳ�����ġ���������ϵ��ԭ��Ϊͼ������ĵ㣬��Ϊfloor((size(edegeimage)+1)/2)
maxv = max(max(R));

if maxv > 25
    i = find(R == max(max(R)));%�ҳ�R�����е���max(max��R��)��Ԫ�ص�����ֵ
else
    lines = [];
    return;
end

[foo, ind] = sort(-R(i));%foo�����н����ind������ʱ������˳��
u = size(i,1);  
k = i(ind(1:u));
[y,x]=ind2sub(size(R),k);%���ڰ�������Ԫ������ֵת��Ϊ��Ԫ���������ж�Ӧ���±꣬kΪ����ֵ
t = -theta(x)*pi/180;
r = xp(y);

lines = [cos(t) sin(t) -r];

cx = size(image,2)/2-1;
cy = size(image,1)/2-1;
lines(:,3) = lines(:,3) - lines(:,1)*cx - lines(:,2)*cy;
