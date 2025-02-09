function FV = clipMesh(FV, cutoff, over, dim)
    % CLIPMESH 
    %
    % Description:
    %   Remove faces and vertices above/below a cutoff point
    %
    % Inputs:
    %   FV      Struct with 'faces' and 'vertices' OR patch handle
    %   cutoff  Cutoff point (microns)
    % Optional inputs:
    %   over    Set true to keep points greater than Z (default = true)
    %   dim     Which dimension: x y or z (default = 3)
    %
    % Outputs:
    %   FV      New struct with 'faces' and 'vertices'
    %           If FV is a patch handle and no output, will apply to patch
    %
    % See also:
    %   CLIPMESHBYSTRATIFICATION, CLIPMESHBYVERTICES
    %
    % History:
    %   09Jan2018 - SSP
    %   28Jan2018 - SSP - Added trimMesh to remove clipped vertices
    %   12Dec2020 - SSP - Added option to cut X or Y dimensions
    % ---------------------------------------------------------------------
    
    renderNow = false;
    
    if nargin < 3
        over = true;
    end

    if nargin < 4
        dim = 3;
    end
    
    if isa(FV, 'matlab.graphics.primitive.Patch')
        p = FV;
        FV = struct(...
            'faces', get(p, 'Faces'),...
            'vertices', get(p, 'Vertices'));
        if nargout == 0
            % Change the render to match output
            renderNow = true;
        end
    end
    
    verts = FV.vertices;
    faces = FV.faces;
    
    % Get the indices of vertices to be clipped out
    if over
        idx = verts(:, dim) < cutoff;
    else
        idx = verts(:, dim) > cutoff;
    end
    cutVerts = find(idx);
    fprintf('Clipping out %u of %u vertices\n', nnz(idx), numel(idx));
    
    % Find which faces contain one or more clipped vertices
    cutFacesIdx = [];
    for i = 1:size(faces,1)
        if ~isempty(intersect(faces(i,:), cutVerts))
            cutFacesIdx = [cutFacesIdx, i]; %#ok
        end
    end

    % Remove the faces with vertices over/under the cutoff point
    FV.faces(cutFacesIdx, :) = [];
    % Trim out the unused vertices
    [FV.vertices, FV.faces] = trimMesh(FV.vertices, FV.faces);
    
    if renderNow
        set(p, 'Faces', FV.faces, 'Vertices', FV.vertices);
    end