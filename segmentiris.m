% segmentiris - peforms automatic segmentation of the iris region
% from an eye image. Also isolates noise areas such as occluding
% eyelids and eyelashes.（虹膜区域分割，而且隔离噪声区域）
%
% Usage: 
% [circleiris, circlepupil, imagewithnoise] = segmentiris(image)
%
% Arguments:
%	eyeimage		- the input eye image 眼睛图像输入
%	
% Output:
%	circleiris	    - centre coordinates and radius  
%			          of the detected iris boundary检测到的虹膜边界的中心坐标和半径
%	circlepupil	    - centre coordinates and radius
%			          of the detected pupil boundary检测到的瞳孔边界的中心坐标和半径
%	imagewithnoise	- original eye image, but with 原始眼图，但具有标有噪声的位置的值
%			          location of noise marked with
%			          NaN values
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003

function [circleiris, circlepupil, imagewithnoise] = segmentiris(eyeimage)

% define range of pupil & iris radii
%pupil:瞳孔 radii:半径

%CASIA
lpupilradius = 10;
upupilradius = 55;
lirisradius = 70;
uirisradius = 100;

%CASIA——version2/device1
%lpupilradius = 22;
%upupilradius = 60;
%lirisradius = 75;
%uirisradius = 150;


%Panassonic
% lpupilradius = 25;
% upupilradius = 30;
% lirisradius = 87;
% uirisradius = 93;

%    %LIONS
%    lpupilradius = 32;
%    upupilradius = 85;
%    lirisradius = 145;
%    uirisradius = 169;


% define scaling factor to speed up Hough transform 定义缩放因子去加速霍夫转换
scaling = 0.4;

reflecthres = 240;

% find the iris boundary  找到虹膜边界
%[row, col, r] = findcircle(eyeimage, 80, 150, 0.4, 2, 0.20, 0.19, 1.00,
%0.00);
[row, col, r] = findcircle(eyeimage, lirisradius, uirisradius, 0.2, 2, 0.20, 0.19, 1.00, 0.00);

circleiris = [row col r];

rowd = double(row);
cold = double(col);
rd = double(r);

irl = round(rowd-rd);
iru = round(rowd+rd);
icl = round(cold-rd);
icu = round(cold+rd);

imgsize = size(eyeimage);

if irl < 1 
    irl = 1;
end

if icl < 1
    icl = 1;
end

if iru > imgsize(1)
    iru = imgsize(1);
end

if icu > imgsize(2)
    icu = imgsize(2);
end

% to find the inner pupil, use just the region within the previously
% detected iris boundary
imagepupil = eyeimage( irl:iru,icl:icu);

%find pupil boundary 找到瞳孔边界
%[rowp, colp, r] = findcircle(imagepupil, 28, 75 ,0.6,2,0.25,0.25,1.00,1.00);
[rowp, colp, r] = findcircle(imagepupil, lpupilradius, upupilradius ,0.2,2,0.25,0.25,1.00,1.00);

rowp = double(rowp);
colp = double(colp);
r = double(r);

row = double(irl) + rowp;
col = double(icl) + colp;

row = round(row);
col = round(col);

circlepupil = [row col r];

% set up array for recording noise regions
% noise pixels will have NaN values
imagewithnoise = double(eyeimage);

%find top eyelid  找到上眼皮
topeyelid = imagepupil(1:(rowp-r),:);
lines = findline(topeyelid);

if size(lines,1) > 0
    [xl yl] = linecoords(lines, size(topeyelid));%返回一条线的上各点的x,y坐标值
    yl = double(yl) + irl-1;
    xl = double(xl) + icl-1;
    
    yla = max(yl);
    
    y2 = 1:yla;
    
    ind3 = sub2ind(size(eyeimage),yl,xl);%对矩阵索引号检索，
    %size当只有一个输出参数时，返回一个行变量，第一个元素是行数，第二个是列数
    %当有两个输出参数时，size函数将矩阵的行数返回到第一个输出变量r，将矩阵的列数返回到第二个输出变量c
    imagewithnoise(ind3) = NaN;
    
    imagewithnoise(y2, xl) = NaN;
end

%find bottom eyelid 找到下眼皮
bottomeyelid = imagepupil((rowp+r):size(imagepupil,1),:);
lines = findline(bottomeyelid);

if size(lines,1) > 0
    
    [xl yl] = linecoords(lines, size(bottomeyelid));%返回一条线的上各点的x,y坐标值
    yl = double(yl)+ irl+rowp+r-2;
    xl = double(xl) + icl-1;
    
    yla = min(yl);
    
    y2 = yla:size(eyeimage,1);
    
    ind4 = sub2ind(size(eyeimage),yl,xl);%对矩阵索引号检索，
    imagewithnoise(ind4) = NaN;
    imagewithnoise(y2, xl) = NaN;
    
end

%For CASIA, eliminate eyelashes by thresholding
%ref = eyeimage < 100;
%coords = find(ref==1);
%imagewithnoise(coords) = NaN;
