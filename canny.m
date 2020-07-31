% CANNY - Canny edge detection��Canny��Ե̽�⣬ͼ���Ե��ǿ��
%
% Function to perform Canny edge detection. Code uses modifications as
% suggested by Fleck (IEEE PAMI No. 3, Vol. 14. March 1992. pp 337-345)
%
% Usage: [gradient or] = canny(im, sigma)
%
% Arguments:   im       - image to be procesed�������ͼ��
%              sigma    - standard deviation of Gaussian smoothing filter����˹ƽ���˲����ı�׼�
%                      (typically 1)
%		       scaling  - factor to reduce input image by(���Űٷֱȣ���������ͼ�������)
%		       vert     - weighting for vertical gradients(��ֱ�ٷֱȣ���ֱ����ļ�Ȩ)
%		       horz     - weighting for horizontal gradients(ˮƽ�ٷֱȣ�ˮƽ����ļ�Ȩ)
%
% Returns:     gradient - edge strength image (gradient amplitude)����Ե��ǿͼ��-������ȣ�
%              or       - orientation image (in degrees 0-180, positive����λͼ����0-180��Ϊ��λ��
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
gaussian = fspecial('gaussian',hsize,sigma); %fspecial�������ڽ���Ԥ������˲����ӣ�type='gaussian'Ϊ��˹��ͨ�˲���hsize��ʾģ��ߴ磬sigmaΪ�˲���׼ֵ
im = filter2(gaussian,im);        % Smoothed image.filter2(B,X)BΪ�˲�����XΪҪ�˲�������
im = imresize(im, scaling);%imresize ��im�Ŵ�scaling��
[rows, cols] = size(im);

h =  [  im(:,2:cols)  zeros(rows,1) ] - [  zeros(rows,1)  im(:,1:cols-1)  ];
v =  [  im(2:rows,:); zeros(1,cols) ] - [  zeros(1,cols); im(1:rows-1,:)  ];
d1 = [  im(2:rows,2:cols) zeros(rows-1,1); zeros(1,cols) ] - [ zeros(1,cols); zeros(rows-1,1) im(1:rows-1,1:cols-1)  ];
d2 = [  zeros(1,cols); im(1:rows-1,2:cols) zeros(rows-1,1);  ] - [ zeros(rows-1,1) im(2:rows,1:cols-1); zeros(1,cols)   ];

X = ( h + (d1 + d2)/2.0 ) * xscaling;
Y = ( v + (d1 - d2)/2.0 ) * yscaling;

gradient = sqrt(X.*X + Y.*Y); % Gradient amplitude.

or = atan2(-Y, X);            % Angles -pi to + pi.�����к���
neg = or<0;                   % Map angles to 0-pi.
or = or.*~neg + (or+pi).*neg; 
or = or*180/pi;               % Convert to degrees.
