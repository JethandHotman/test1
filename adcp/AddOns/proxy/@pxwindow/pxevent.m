function theResult = PXEvent(self, theEvent, theMessage)

% PXEvent -- Process events for a "pxwindow" object.
%  PXEvent(self, theEvent, theMessage) processes
%   events associated with self, a "pxwindow" object.
%   The returned status is non-zero if theEvent was
%   not handled.


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
 
% Version of 16-Apr-1997 09:23:16.

if nargin < 1, help(mfilename), return, end
if nargin < 2, theEvent = ''; end
if nargin < 3, theMessage = []; end

if pxverbose
   pxbegets(' ## PXEvent', 3, self, theAction, theMessage)
end

status = 0;

switch lower(theEvent)
case 'resizefcn'
   pxresize(self)
otherwise   % Inherit.
   status = pxevent(super(self), theEvent, theMessage);
end

if nargout > 0, theResult = status; end
