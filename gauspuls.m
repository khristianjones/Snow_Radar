% ## Copyright (C) 2007 Sylvain Pelissier <sylvain.pelissier@gmail.com>
% ##
% ## This program is free software; you can redistribute it and/or modify it under
% ## the terms of the GNU General Public License as published by the Free Software
% ## Foundation; either version 3 of the License, or (at your option) any later
% ## version.
% ##
% ## This program is distributed in the hope that it will be useful, but WITHOUT
% ## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% ## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% ## details.
% ##
% ## You should have received a copy of the GNU General Public License along with
% ## this program; if not, see <http://www.gnu.org/licenses/>.
% 
% ## -*- texinfo -*-
% ## @deftypefn {Function File} {[@var{y}] =} gauspuls(@var{t},@var{fc},@var{bw})
% ## Return the Gaussian modulated sinusoidal pulse.
% ## @end deftypefn

function y = gauspuls(t, fc, bw, bwr)
  if nargin < 1, error('All three input arguments needed...'); end
  if fc < 0 , error('fc must be positive'); end
  if bw <= 0, error('bw must be stricltly positive'); end
  if ~exist('bwr', 'var'), bwr = 6; end

  fv = -(bw.^2.*fc.^2)/(8.*log(10.^(-bwr/20)));
  tv = 1/(4.*pi.^2.*fv); 
  y = exp(-t.*t/(2.*tv)).*cos(2.*pi.*fc.*t);
end
