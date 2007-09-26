function varargout = PXCall(theFcn, varargin)

% PXCall -- Call a function with variable argument list.
%  {varargout} = PXCall('theFcn', {varargin}) performs
%   a call to 'theFcn' function, using the given input
%   and output arguments.  The varargin{1} must be a
%   reference to a "px" object.


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
 
% Version of 07-Apr-1997 13:50:38.

if nargin < 1, help(mfilename), return, end

if length(varargin) > 0
   varargin{1} = px(varargin{1});
end

varargout = cell(1, nargout);

theCall = vargstr(theFcn, length(varargin), length(varargout));

onFailure = ['## Error while trying: ' theCall];

eval(theCall, 'disp(onFailure)');   % Note two arguments.
