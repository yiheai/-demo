% gethammingdistance - returns the Hamming Distance between two iris templates
% incorporates noise masks, so noise bits are not used for
% calculating the HD（返回两幅虹膜图像提取的特征码之间的汉明距离）
%
% Usage: 
% [template, mask] = createiristemplate(eyeimage_filename)
%
% Arguments:
%	template1       - first template 第一个模板
%   mask1           - corresponding noise mask 相应的噪声掩码
%   template2       - second template 第二个模板
%   mask2           - corresponding noise mask 相应的噪声掩码
%   scales          - the number of filters used to encode the templates,needed for shifting.需要移位的用于编码模板的过滤器数量
%
% Output:
%   hd              - the Hamming distance as a ratio 汉明距离
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003


function  hd = gethammingdistance(template1, mask1, template2, mask2, scales)

template1 = logical(template1);%将矩阵转换成逻辑矩阵，所有非零元素变为1
mask1 = logical(mask1);

template2 = logical(template2);
mask2 = logical(mask2);

hd = NaN;

% shift template left and right, use the lowest Hamming distance 左右移动模板，使用最低汉明距离
for shifts=-8:8
    
    template1s = shiftbits(template1, shifts,scales);%像素偏移以进行归一化后的图像匹配识别，消除人眼球旋转造成的误差
    mask1s = shiftbits(mask1, shifts,scales);
    
    
    mask = mask1s | mask2;
    
    nummaskbits = sum(sum(mask == 1));
    
    totalbits = (size(template1s,1)*size(template1s,2)) - nummaskbits;
    
    C = xor(template1s,template2);%异或操作，相同为0，否则为1
    
    C = C & ~mask;
    bitsdiff = sum(sum(C==1));%sum对向量进行求值
    
    if totalbits == 0
        
        hd = NaN;
        
    else
        
        hd1 = bitsdiff / totalbits;
        
        
        if  hd1 < hd || isnan(hd)
            
            hd = hd1;
            
        end
        
        
    end
    
end