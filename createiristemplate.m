% createiristemplate - generates a biometric template from an iris in
% an eye image.������һ����Ĥ������ģ�壩
%
% Usage: 
% [template, mask] = createiristemplate(eyeimage_filename)
%
% Arguments:
%	eyeimage_filename   - the file name of the eye image �۾�ͼ����ļ���
%
% Output:
%	template		    - the binary iris biometric template  �����ƺ�Ĥ����ʶ��ģ��
%	mask			    - the binary iris noise mask  �����ƺ�Ĥ��������
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

DIAGPATH = 'D:\Users\15002\Desktop\�ȸ�����\CASIA-IrisV4(png)\CASIA-Iris-Interval\001\R\';

%normalisation parameters 
radial_res = 100; 
angular_res = 240;
% with these settings a 9600 bit iris template is created

%feature encoding parameters
nscales=1;
minWaveLength=18;
mult=1; % not applicable if using nscales = 1
sigmaOnf=0.5;

eyeimage = imread(eyeimage_filename); %��ͼ��

savefile = [eyeimage_filename,'-houghpara.mat']; %����ͼ���mat
[stat,mess]=fileattrib(savefile); %��ȡ�ļ�����

if stat == 1
    % if this file has been processed before
    % then load the circle parameters and
    % noise information for that file.
    load(savefile);%���ļ��������ص���������
    
else
    
    % if this file has not been processed before
    % then perform automatic segmentation and
    % save the results to a file
    
    [circleiris circlepupil imagewithnoise] = segmentiris(eyeimage);%��Ĥ�ָ������������
    save(savefile,'circleiris','circlepupil','imagewithnoise');%�����������ǰ����Ŀ¼
    
end

% WRITE NOISE IMAGE
%

imagewithnoise2 = uint8(imagewithnoise);%uint8�����д���255����ǿ����Ϊ255
imagewithcircles = uint8(eyeimage);

%get pixel coords for circle around iris ��ú�Ĥ��Χ���ص���������
[x,y] = circlecoords([circleiris(2),circleiris(1)],circleiris(3),size(eyeimage));%������Բ�İ뾶��Բ�����������Բ�ϸ������ص�����
ind2 = sub2ind(size(eyeimage),double(y),double(x)); 

%get pixel coords for circle around pupil ���ͫ����Χ���ص���������
[xp,yp] = circlecoords([circlepupil(2),circlepupil(1)],circlepupil(3),size(eyeimage));%������Բ�İ뾶��Բ�����������Բ�ϸ������ص�����
ind1 = sub2ind(size(eyeimage),double(yp),double(xp));%��������߾�����±�ת��Ϊ�������������һ�е�һ��������ֵ��һ��


% Write noise regions д��������
imagewithnoise2(ind2) = 255;
imagewithnoise2(ind1) = 255;
% Write circles overlayed дԲ��������
imagewithcircles(ind2) = 255;%����Ĥ�����ص�������Ӧ��ֵ��ֵΪ255
imagewithcircles(ind1) = 255;%��ͫ�����ص�������Ӧ��ֵ��ֵΪ255


% w = cd;
% cd(DIAGPATH);
pos = findstr(eyeimage_filename,'\');%�ڽϳ����ַ����в��ҽ϶̵��ַ������ֵĴ�������������λ��
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


% WRITE NORMALISED PATTERN, AND NOISE PATTERN д��һ��ģʽ������ģʽ
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
  [template mask] = encode(polar_array, noise_array, nscales, minWaveLength, mult, sigmaOnf,eyeimage_filename); %�Ծ�����һ����ͼ�����������ȡ������