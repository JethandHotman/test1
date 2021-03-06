function theResult = PXSet(self, theField, theValue)

% PXSet -- No help available.
% PXSet -- Set values in self, a px reference.
%  PXSet(self, 'theField', theValue) sets
%   'theField' of self, a "px" reference,
%   to theValue.
%  PXSet(self, 'theField') returns the value
%   of 'theField' of self.
%  PXSet(self) returns all the fields of self
%   as a "struct" object.
%  PXSet (no argument) shows help.


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

  
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 04-Apr-1997 13:31:58.

if nargin < 1, help(mfilename), return, end

result = [];

switch nargin
case 0
   help(mfilename), return
case 1
   result = pxset(px(self));
   if nargout < 1, disp(result), end
case 2
   result = pxset(px(self), theField);
otherwise
   result = pxset(px(self), theField, theValue);
end

if nargout > 0
   theResult = result;
  elseif nargin < 3
   disp(result)
end
