% shiftbits - function to shift the bit-wise iris patterns in order to provide the best match
% each shift is by two bit values and left to right, since one pixel value in the
% normalised iris pattern gives two bit values in the template
% also takes into account the number of scales
% used(����ƫ���Խ��й�һ�����ͼ��ƥ��ʶ��������������ת��ɵ���
%
% Usage: 
% [template, mask] = createiristemplate(eyeimage_filename)
%
% Arguments:
%	template        - the template to shift Ҫ�ƶ���ģ��
%   noshifts        - number of shifts to perform to the right, a negative value results in shifting to the left
                    %�����ƶ���λ������ֵ������
%   nscales         - number of filters used for encoding, needed to
%                     determine how many bits to move in a shift
%                     ���ڱ�����˲�����������Ҫȷ����λ����bit
%
% Output:
%   templatenew     - the shifted template ����λ��ģ��
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003

function templatenew = shiftbits(template, noshifts,nscales)

templatenew = zeros(size(template));

width = size(template,2);
s = round(2*nscales*abs(noshifts));
p = round(width-s);

if noshifts == 0
    templatenew = template;
    
    % if noshifts is negatite then shift towards the left
elseif noshifts < 0
    
    x=1:p;
    
    templatenew(:,x) = template(:,s+x);
    
    x=(p + 1):width;
    
    templatenew(:,x) = template(:,x-p);
    
else
    
    x=(s+1):width;
    
    templatenew(:,x) = template(:,x-s);
    
    x=1:s;
    
    templatenew(:,x) = template(:,p+x);
    
end