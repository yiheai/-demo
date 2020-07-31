% normaliseiris - performs normalisation of the iris region by
% unwraping the circular region into a rectangular block of
% constant dimensions.（归一化操作）
%
% Usage: 
% [polar_array, polar_noise] = normaliseiris(image, x_iris, y_iris, r_iris,...
% x_pupil, y_pupil, r_pupil,eyeimage_filename, radpixels, angulardiv)
%
% Arguments:
% image                 - the input eye image to extract iris data from
% x_iris                - the x coordinate of the circle defining the iris
%                         boundary 定义虹膜的圆边界的x坐标
% y_iris                - the y coordinate of the circle defining the iris
%                         boundary 定义虹膜的圆边界的y坐标
% r_iris                - the radius of the circle defining the iris
%                         boundary 定义虹膜的圆的半径
% x_pupil               - the x coordinate of the circle defining the pupil
%                         boundary 定义瞳孔的圆边界的x坐标
% y_pupil               - the y coordinate of the circle defining the pupil
%                         boundary 定义瞳孔的圆边界的y坐标
% r_pupil               - the radius of the circle defining the pupil
%                         boundary 定义瞳孔的圆的半径
% eyeimage_filename     - original filename of the input eye image 输入眼睛图像的原始文件名
% radpixels             - radial resolution, defines vertical dimension of
%                         normalised representation 径向分辨率，定义归一化表示的垂直尺寸
% angulardiv            - angular resolution, defines horizontal dimension
%                         of normalised representation 角度分辨率，定义归一化表示的水平尺寸
%
% Output:
% polar_array 像素数组
% polar_noise 像素噪声
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003

function [polar_array, polar_noise] = normaliseiris(image, x_iris, y_iris, r_iris,...
x_pupil, y_pupil, r_pupil,eyeimage_filename, radpixels, angulardiv,write)

global DIAGPATH

radiuspixels = radpixels + 2;
angledivisions = angulardiv-1;

r = 0:(radiuspixels-1);

theta = 0:2*pi/angledivisions:2*pi;

x_iris = double(x_iris);
y_iris = double(y_iris);
r_iris = double(r_iris);

x_pupil = double(x_pupil);
y_pupil = double(y_pupil);
r_pupil = double(r_pupil);

% calculate displacement of pupil center from the iris center
ox = x_pupil - x_iris;
oy = y_pupil - y_iris;

if ox <= 0
    sgn = -1;
elseif ox > 0
    sgn = 1;
end

if ox==0 && oy > 0
    
    sgn = 1;
    
end

r = double(r);
theta = double(theta);

a = ones(1,angledivisions+1)* (ox^2 + oy^2);

% need to do something for ox = 0
if ox == 0
    phi = pi/2;
else
    phi = atan(oy/ox);
end

b = sgn.*cos(pi - phi - theta);%theta是pupil半径射线和以右手方向伪正向的x轴的夹角

% calculate radius around the iris as a function of the angle

r = (sqrt(a).*b) + ( sqrt( a.*(b.^2) - (a - (r_iris^2))));%pupil中心到iris边界的距离

r = r - r_pupil;

rmat = ones(1,radiuspixels)'*r;%生成一个全为1的矩阵

rmat = rmat.* (ones(angledivisions+1,1)*[0:1/(radiuspixels-1):1])';
rmat = rmat + r_pupil;


% exclude values at the boundary of the pupil iris border, and the iris scelra border
% as these may not correspond to areas in the iris region and will introduce noise.
%
% ie don't take the outside rings as iris data.
rmat  = rmat(2:(radiuspixels-1), :);

% calculate cartesian location of each data point around the circular iris
% region
xcosmat = ones(radiuspixels-2,1)*cos(theta);
xsinmat = ones(radiuspixels-2,1)*sin(theta);

xo = rmat.*xcosmat;    
yo = rmat.*xsinmat;

xo = x_pupil+xo;
yo = y_pupil-yo;

% extract intensity values into the normalised polar representation through
% interpolation
[x,y] = meshgrid(1:size(image,2),1:size(image,1));  
%[X,Y]=meshgrid(xgv,ygv);
%meshgrid函数生成的X，Y是大小相等的矩阵，xgv，ygv是两个网格矢量，xgv，ygv都是行向量。
%X：通过将xgv复制length(ygv)行（严格意义上是length(ygv)-1行）得到
%Y：首先对ygv进行转置得到ygv'，将ygv'复制（length(xgv)-1）次得到。
polar_array = interp2(x,y,image,xo,yo);%进行插值操作

% create noise array with location of NaNs in polar_array
polar_noise = zeros(size(polar_array));
coords = find(isnan(polar_array));%isnan 判断函数是否为NAN
polar_noise(coords) = 1;

polar_array = double(polar_array)./255;


% start diagnostics, writing out eye image with rings overlayed

% get rid of outling points in order to write out the circular pattern
coords = find(xo > size(image,2));
xo(coords) = size(image,2);
coords = find(xo < 1);
xo(coords) = 1;

coords = find(yo > size(image,1));
yo(coords) = size(image,1);
coords = find(yo<1);
yo(coords) = 1;

xo = round(xo);
yo = round(yo);

xo = int32(xo);
yo = int32(yo);

ind1 = sub2ind(size(image),double(yo),double(xo));%通过坐标返回索引值

image = uint8(image);

image(ind1) = 255;
%get pixel coords for circle around iris 获得虹膜周围像素的坐标
[x,y] = circlecoords([x_iris,y_iris],r_iris,size(image));%返回由圆的半径和圆心坐标决定的圆上各点像素的坐标
ind2 = sub2ind(size(image),double(y),double(x));
%get pixel coords for circle around pupil 获得瞳孔周围像素的坐标
[xp,yp] = circlecoords([x_pupil,y_pupil],r_pupil,size(image));
ind1 = sub2ind(size(image),double(yp),double(xp));

image(ind2) = 255;
image(ind1) = 255;


% write out rings overlaying original iris image 写出覆盖原始虹膜图像的环
% w = cd;
% cd(DIAGPATH);
% imwrite(image,[eyeimage_filename,'-normal.png'],'png');
if write
pos = findstr(eyeimage_filename,'\');
l=length(pos);
posdot = findstr(eyeimage_filename,'.');
addpos = pos(l);
final_normal = [eyeimage_filename(1:addpos),'normal-',eyeimage_filename(addpos+1:posdot),'.png'];

imwrite(image,final_normal,'png');
% 
% cd(w);
end
% end diagnostics

%replace NaNs before performing feature encoding
coords = find(isnan(polar_array));
polar_array2 = polar_array;
polar_array2(coords) = 0.5;
avg = sum(sum(polar_array2)) / (size(polar_array,1)*size(polar_array,2));
polar_array(coords) = avg;