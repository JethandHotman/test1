function [hours]=hms2h(h,m,s);
%HMS2H converts hours, minutes, and seconds to hours
%
%  Usage:  [hours]=hms2h(h,m,s);   or [hours]=hms2h(hhmmss);
%


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

 if nargin== 1,
   hms=h;
   h=floor(hms/10000);
   ms=hms-h*10000;
   m=floor(ms/100);
   s=ms-m*100;
   hours=h+m/60+s/3600;
else
   hours=h+(m+s/60)/60;
end