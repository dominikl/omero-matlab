function ma = writeMapAnnotation(session, keys, values, varargin)
% WRITEMAPANNOTATION Create and upload a map annotation onto OMERO
%
%    ma = writeMapAnnotation(session, keys, values) creates and uploads a
%    map annotation owned by the session user containing a list of
%    key/value pairs.
%
%    ma = writeMapAnnotation(session, keys, values, 'description',
%    description) also specifies the description of the map annotation.
%
%    xa = writeMapAnnotation(session, keys, values, 'namespace', namespace)
%    also sets the namespace of the XML annotation.
%
%    Examples:
%
%        map = writeMapAnnotation(session, 'key', 'value');
%        map = writeMapAnnotation(session, {'key1', 'key2'}, {'value1', 'value2'});
%        map = writeMapAnnotation(session, 'key', 'value', 'description', description)
%        map = writeMapAnnotation(session, 'key', 'value', 'namespace', namespace)
%
% See also: WRITECOMMENTANNOTATION, WRITEDOUBLEANNOTATION,
% WRITEFILEANNOTATION, WRITELONGANNOTATION, WRITETAGANNOTATION,
% WRITETEXTANNOTATION, WRITETIMESTAMPANNOTATION, WRITEXMLANNOTATION

% Copyright (C) 2015 University of Dundee & Open Microscopy Environment.
% All rights reserved.
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

% Input check
ip = inputParser;
ip.addRequired('session');
ip.addRequired('keys', @(x) ischar(x) || iscellstr(x));
ip.addRequired('values', @(x) ischar(x) || iscellstr(x));
ip.addParamValue('namespace', '', @ischar);
ip.addParamValue('description', '', @ischar);
ip.parse(session, keys, values, varargin{:});

if ischar(keys)
    assert(isschar(values), 'Values must be');
    keys = {keys};
    values = {values};
end
assert(numel(keys) == numel(values));
% Create list of named values
nv = java.util.ArrayList();
for i = 1 : numel(keys)
    nv.add(omero.model.NamedValue(keys{i}, values{i}));
end

% Create a map annotation
ma = omero.model.MapAnnotationI();
ma.setMapValue(nv);


if ~isempty(ip.Results.description),
    ma.setDescription(rstring(ip.Results.description));
end

if ~isempty(ip.Results.namespace),
    ma.setNs(rstring(ip.Results.namespace))
end

% Save the map annotation
ma = session.getUpdateService().saveAndReturnObject(ma);
