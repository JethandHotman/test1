function theResult = savemask(self)

% starbare/savemask -- Save the masks.
%  savemask(self) saves any new marks found in the
%   masks associated with images that represemt the
%   variables of self, a "starbare" object.


%%% START USGS BOILERPLATE -------------%
% Use of this program is described in:
%
% Acoustic Doppler Current Profiler Data Processing System Manual 
% Jessica M. C�t�, Frances A. Hotchkiss, Marinna Martini, Charles R. Denham
% Revisions by: Andr�e L. Ramsey, Stephen Ruane
% U.S. Geological Survey Open File Report 00-458 
% Check for later versions of this Open-File, it is a living document.
%
% Program written in Matlab v7.1.0 SP3
% Program updated in Matlab 7.2.0.232 (R2006a)
% Program ran on PC with Windows XP Professional OS.
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%
%%% END USGS BOILERPLATE --------------

  
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 13-Jan-1999 11:30:03.

if nargin < 1, help(mfilename), return, end

if nargout > 0, theResult = []; end

theImages = pxget(self, 'itsImages');
theMask = pxget(self, 'itsMask');
theVariables = pxget(self, 'itsVariables');
len = length(theVariables);

for k = 1:len
	theMaskVariables{k} = theMask{theVariables{k}};
end

for k = 1:length(theImages)
	h = theImages(k);
	p = px(h);
	if changed(p)
		busy
		x = p.x;   % Ensemble.
		y = p.y;   % Bin.
		s = p.s;   % 0 or 1.
		v = theMaskVariables{k};
		v(x, y) = s.';   % Note transpose.
		p = changed(p, 0);
	end
end

idle
