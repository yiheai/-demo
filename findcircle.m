% findcircle - returns the coordinates of a circle in an image using the Hough transform
% and Canny edge detection to create the edge
% map.（计算所得线上各点的坐标归纳出一个圆的半径和圆心，确定该圆的各点坐标）
%
% Usage: 
% [row, col, r] = findcircle(image,lradius,uradius,scaling, sigma, hithres, lowthres, vert, horz)
%
% Arguments:
%	image		    - the image in which to find circles
%	lradius		    - lower radius to search for 搜索的最小半径
%	uradius		    - upper radius to search for 搜索的最大半径
%	scaling		    - scaling factor for speeding up the 缩放，加速缩放的缩放因子
%			          Hough transform 霍夫变换
%	sigma		    - amount of Gaussian smoothing to 高斯平滑量
%			          apply for creating edge map. 适用于创建边缘图
%	hithres		    - threshold for creating edge map 创建边缘图的阈值
%	lowthres	    - threshold for connected edges 连接边缘的阈值
%	vert		    - vertical edge contribution (0-1) 垂直边缘贡献
%	horz		    - horizontal edge contribution (0-1) 水平边缘贡献
%	
% Output:
%	circleiris	    - centre coordinates and radius 检测到的虹膜边界的中心坐标和半径
%			          of the detected iris boundary 
%	circlepupil	    - centre coordinates and radius 检测到的瞳孔边界的中心坐标和半径
%			          of the detected pupil boundary
%	imagewithnoise	- original eye image, but with 原始眼图，但与就标有噪声的NAN值
%			          location of noise marked with
%			          NaN values
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003

function [row, col, r] = findcircle(image,lradius,uradius,scaling, sigma, hithres, lowthres, vert, horz)

lradsc = round(lradius*scaling);%四舍五入取整
uradsc = round(uradius*scaling);
rd = round(uradius*scaling - lradius*scaling); 

% generate the edge image 
% [I2 or] = canny(image, sigma, scaling, vert, horz);
% I3 = adjgamma(I2, 1.9);
% I4 = nonmaxsup(I3, or, 1.5);
% edgeimage = hysthresh(I4, hithres, lowthres);

% generate the edge image using toolbox

edgeimage = edge(imresize(image,scaling),'canny');%先放大scaling倍数，再自动选择阈值，用canny算子进行边缘检测。

% perform the circular Hough transform
h = houghcircle(edgeimage, lradsc, uradsc);%取一幅经过canny变换的图像，利用hough变换找到图像中的一个圆

maxtotal = 0;

% find the maximum in the Hough space, and hence
% the parameters of the circle
for i=1:rd
    
    layer = h(:,:,i);
    [maxlayer] = max(max(layer));
    
    
    if maxlayer > maxtotal
        
        maxtotal = maxlayer;
        
        
        r = int32((lradsc+i) / scaling);%int32转换成有符号的32位整数
        
        [row,col] = ( find(layer == maxlayer) );%找到layer==maxlayer的索引值
        
        
        row = int32(row(1) / scaling); % returns only first max value 只返回第一个最大的值
        col = int32(col(1) / scaling);    
        
    end   
    
end