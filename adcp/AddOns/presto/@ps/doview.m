function theResult = doview(self, varargin)

% ps/view -- Toggle between view(2) and view(3).
%  view(self) toggles the view of axes associated
%   with self, a "ps" object.


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
 
% Version of 10-Nov-1999 08:17:04.
% Updated    17-Nov-1999 09:05:37.

if nargout > 0, theResult = []; end

theMenu = gcbo;

v = view;
if norm(diag(view)) > 1.9
	view(3)
	if any(theMenu), set(gcbo, 'Checked', 'on'), end
else
	view(2)
	if any(theMenu), set(gcbo, 'Checked', 'off'), end
end

if nargout > 0
	theResult = self;
else
	assignin('caller', 'ans', self)
end
