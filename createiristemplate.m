% createiristemplate - generates a biometric template from an iris in
% an eye image.（产生一个虹膜的特征模板）
%
% Usage: 
% [template, mask] = createiristemplate(eyeimage_filename)
%
% Arguments:
%	eyeimage_filename   - the file name of the eye image 眼睛图像的文件名
%
% Output:
%	template		    - the binary iris biometric template  二进制虹膜生物识别模板
%	mask			    - the binary iris noise mask  二进制虹膜噪声掩码
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003

function [template, mask,circleiris,circlepupil] = createiristemplate(eyeimage_filename,write)

% path for writing diagnostic images
global DIAGPATH

DIAGPATH = 'D:\Users\15002\Desktop\谷歌下载\CASIA-IrisV4(png)\CASIA-Iris-Interval\001\R\';

%normalisation parameters 
radial_res = 100; 
angular_res = 240;
% with these settings a 9600 bit iris template is created

%feature encoding parameters
nscales=1;
minWaveLength=18;
mult=1; % not applicable if using nscales = 1
sigmaOnf=0.5;

eyeimage = imread(eyeimage_filename); %打开图像

savefile = [eyeimage_filename,'-houghpara.mat']; %保存图像的mat
[stat,mess]=fileattrib(savefile); %获取文件属性

if stat == 1
    % if this file has been processed before
    % then load the circle parameters and
    % noise information for that file.
    load(savefile);%将文件变量加载到工作区中
    
else
    
    % if this file has not been processed before
    % then perform automatic segmentation and
    % save the results to a file
    
    [circleiris circlepupil imagewithnoise] = segmentiris(eyeimage);%虹膜分割，隔离噪声区域
    save(savefile,'circleiris','circlepupil','imagewithnoise');%保存变量到当前工作目录
    
end

% WRITE NOISE IMAGE
%

imagewithnoise2 = uint8(imagewithnoise);%uint8把所有大于255的数强制置为255
imagewithcircles = uint8(eyeimage);

%get pixel coords for circle around iris 获得虹膜周围像素的像素坐标
[x,y] = circlecoords([circleiris(2),circleiris(1)],circleiris(3),size(eyeimage));%返回由圆的半径和圆心坐标决定的圆上各点像素的坐标
ind2 = sub2ind(size(eyeimage),double(y),double(x)); 

%get pixel coords for circle around pupil 获得瞳孔周围像素的像素坐标
[xp,yp] = circlecoords([circlepupil(2),circlepupil(1)],circlepupil(3),size(eyeimage));%返回由圆的半径和圆心坐标决定的圆上各点像素的坐标
ind1 = sub2ind(size(eyeimage),double(yp),double(xp));%把数组或者矩阵的下标转化为线性索引，如第一行第一个，索引值是一。


% Write noise regions 写噪声区域
imagewithnoise2(ind2) = 255;
imagewithnoise2(ind1) = 255;
% Write circles overlayed 写圆覆盖区域
imagewithcircles(ind2) = 255;%将虹膜上像素点的坐标对应的值赋值为255
imagewithcircles(ind1) = 255;%将瞳孔像素点的坐标对应的值赋值为255


% w = cd;
% cd(DIAGPATH);
pos = findstr(eyeimage_filename,'\');%在较长的字符串中查找较短的字符串出现的次数，并返回其位置
posdot = findstr(eyeimage_filename,'.');
l = length(pos);
addpos = pos(l);

final_segmented = [eyeimage_filename(1:addpos),'segmented-',eyeimage_filename(addpos+1:posdot),'.png'];


imwrite(imagewithcircles,final_segmented,'png');
% cd(w);

if write
    
final_noise = [eyeimage_filename(1:addpos),'noise-',eyeimage_filename(addpos+1:posdot),'.png'];    
imwrite(imagewithnoise2,final_noise,'png');    
%write the *-gabor_oiginal.png

writeoriginal(circleiris,circlepupil,eyeimage,eyeimage_filename,nscales, minWaveLength, mult, sigmaOnf);


end

% perform normalisation

[polar_array noise_array] = normaliseiris(imagewithnoise, circleiris(2),...
    circleiris(1), circleiris(3), circlepupil(2), circlepupil(1), circlepupil(3),eyeimage_filename, radial_res, angular_res,write);


% WRITE NORMALISED PATTERN, AND NOISE PATTERN 写归一化模式和噪声模式
% w = cd;
% cd(DIAGPATH);
if write
final_polar = [eyeimage_filename(1:addpos),'polar-',eyeimage_filename(addpos+1:posdot),'.png'];
final_polarnoise = [eyeimage_filename(1:addpos),'polarnoise-',eyeimage_filename(addpos+1:posdot),'.png'];

imwrite(polar_array,final_polar,'png');
imwrite(noise_array,final_polarnoise,'png');

% cd(w);
end
% perform feature encoding
% [template mask] = encode(polar_array, noise_array, nscales, minWaveLength, mult, sigmaOnf); 
  [template mask] = encode(polar_array, noise_array, nscales, minWaveLength, mult, sigmaOnf,eyeimage_filename); %对经过归一化的图像进行特征提取并编码