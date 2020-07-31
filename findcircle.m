% findcircle - returns the coordinates of a circle in an image using the Hough transform
% and Canny edge detection to create the edge
% map.�������������ϸ����������ɳ�һ��Բ�İ뾶��Բ�ģ�ȷ����Բ�ĸ������꣩
%
% Usage: 
% [row, col, r] = findcircle(image,lradius,uradius,scaling, sigma, hithres, lowthres, vert, horz)
%
% Arguments:
%	image		    - the image in which to find circles
%	lradius		    - lower radius to search for ��������С�뾶
%	uradius		    - upper radius to search for ���������뾶
%	scaling		    - scaling factor for speeding up the ���ţ��������ŵ���������
%			          Hough transform ����任
%	sigma		    - amount of Gaussian smoothing to ��˹ƽ����
%			          apply for creating edge map. �����ڴ�����Եͼ
%	hithres		    - threshold for creating edge map ������Եͼ����ֵ
%	lowthres	    - threshold for connected edges ���ӱ�Ե����ֵ
%	vert		    - vertical edge contribution (0-1) ��ֱ��Ե����
%	horz		    - horizontal edge contribution (0-1) ˮƽ��Ե����
%	
% Output:
%	circleiris	    - centre coordinates and radius ��⵽�ĺ�Ĥ�߽����������Ͱ뾶
%			          of the detected iris boundary 
%	circlepupil	    - centre coordinates and radius ��⵽��ͫ�ױ߽����������Ͱ뾶
%			          of the detected pupil boundary
%	imagewithnoise	- original eye image, but with ԭʼ��ͼ������ͱ���������NANֵ
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

lradsc = round(lradius*scaling);%��������ȡ��
uradsc = round(uradius*scaling);
rd = round(uradius*scaling - lradius*scaling); 

% generate the edge image 
% [I2 or] = canny(image, sigma, scaling, vert, horz);
% I3 = adjgamma(I2, 1.9);
% I4 = nonmaxsup(I3, or, 1.5);
% edgeimage = hysthresh(I4, hithres, lowthres);

% generate the edge image using toolbox

edgeimage = edge(imresize(image,scaling),'canny');%�ȷŴ�scaling���������Զ�ѡ����ֵ����canny���ӽ��б�Ե��⡣

% perform the circular Hough transform
h = houghcircle(edgeimage, lradsc, uradsc);%ȡһ������canny�任��ͼ������hough�任�ҵ�ͼ���е�һ��Բ

maxtotal = 0;

% find the maximum in the Hough space, and hence
% the parameters of the circle
for i=1:rd
    
    layer = h(:,:,i);
    [maxlayer] = max(max(layer));
    
    
    if maxlayer > maxtotal
        
        maxtotal = maxlayer;
        
        
        r = int32((lradsc+i) / scaling);%int32ת�����з��ŵ�32λ����
        
        [row,col] = ( find(layer == maxlayer) );%�ҵ�layer==maxlayer������ֵ
        
        
        row = int32(row(1) / scaling); % returns only first max value ֻ���ص�һ������ֵ
        col = int32(col(1) / scaling);    
        
    end   
    
end