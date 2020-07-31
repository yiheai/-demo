% segmentiris - peforms automatic segmentation of the iris region
% from an eye image. Also isolates noise areas such as occluding
% eyelids and eyelashes.����Ĥ����ָ���Ҹ�����������
%
% Usage: 
% [circleiris, circlepupil, imagewithnoise] = segmentiris(image)
%
% Arguments:
%	eyeimage		- the input eye image �۾�ͼ������
%	
% Output:
%	circleiris	    - centre coordinates and radius  
%			          of the detected iris boundary��⵽�ĺ�Ĥ�߽����������Ͱ뾶
%	circlepupil	    - centre coordinates and radius
%			          of the detected pupil boundary��⵽��ͫ�ױ߽����������Ͱ뾶
%	imagewithnoise	- original eye image, but with ԭʼ��ͼ�������б���������λ�õ�ֵ
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
%pupil:ͫ�� radii:�뾶

%CASIA
lpupilradius = 10;
upupilradius = 55;
lirisradius = 70;
uirisradius = 100;

%CASIA����version2/device1
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


% define scaling factor to speed up Hough transform ������������ȥ���ٻ���ת��
scaling = 0.4;

reflecthres = 240;

% find the iris boundary  �ҵ���Ĥ�߽�
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

%find pupil boundary �ҵ�ͫ�ױ߽�
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

%find top eyelid  �ҵ�����Ƥ
topeyelid = imagepupil(1:(rowp-r),:);
lines = findline(topeyelid);

if size(lines,1) > 0
    [xl yl] = linecoords(lines, size(topeyelid));%����һ���ߵ��ϸ����x,y����ֵ
    yl = double(yl) + irl-1;
    xl = double(xl) + icl-1;
    
    yla = max(yl);
    
    y2 = 1:yla;
    
    ind3 = sub2ind(size(eyeimage),yl,xl);%�Ծ��������ż�����
    %size��ֻ��һ���������ʱ������һ���б�������һ��Ԫ�����������ڶ���������
    %���������������ʱ��size������������������ص���һ���������r����������������ص��ڶ����������c
    imagewithnoise(ind3) = NaN;
    
    imagewithnoise(y2, xl) = NaN;
end

%find bottom eyelid �ҵ�����Ƥ
bottomeyelid = imagepupil((rowp+r):size(imagepupil,1),:);
lines = findline(bottomeyelid);

if size(lines,1) > 0
    
    [xl yl] = linecoords(lines, size(bottomeyelid));%����һ���ߵ��ϸ����x,y����ֵ
    yl = double(yl)+ irl+rowp+r-2;
    xl = double(xl) + icl-1;
    
    yla = min(yl);
    
    y2 = yla:size(eyeimage,1);
    
    ind4 = sub2ind(size(eyeimage),yl,xl);%�Ծ��������ż�����
    imagewithnoise(ind4) = NaN;
    imagewithnoise(y2, xl) = NaN;
    
end

%For CASIA, eliminate eyelashes by thresholding
%ref = eyeimage < 100;
%coords = find(ref==1);
%imagewithnoise(coords) = NaN;
