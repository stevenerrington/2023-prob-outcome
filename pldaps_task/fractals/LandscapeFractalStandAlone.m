function [hm] = LandscapeFractal()
clc
for id = 1:10
    for xb=1:8
        % Set some defaults if the user didn't provide inputs.
        n         = 8;         % Iterations
        mesh_size = 513;      % Output mesh size
        h0        = 0.1 * rand();  % Elevation %was 0.1
        r0        = 0.5 * rand(); % Roughness
        rr        = 0.1 * rand(); % Roughness roughness
        
        n0 = randi(5);     % Number of initial points - was 5
        m  = 3;            % How many points grow from each old point - was 3
        nf = n0 * (m+1)^n; % Total number of points
        
        % Create initial x, y, and height coordinates and roughness map.
        x = [randn(n0, 1);           zeros(nf-n0, 1)];
        y = [randn(n0, 1);           zeros(nf-n0, 1)];
        h = [r0 * randn(n0, 1) + h0; zeros(nf-n0, 1)];
        r = [rr * randn(n0, 1) + r0; zeros(nf-n0, 1)];
        
        % Create new points from old points n times.
        for k = 1:n
            
            % Calculate the new variance for the x, y random draws and for the
            % h, r random draws.
            dxy = 0.75^k*rand();
            dh  = 0.5^k*rand();
            
            % Number of new points to generate
            n_new = m * n0;
            
            % Parents for new points
            parents = reshape(repmat(1:n0, m, 1), [n_new, 1]);
            
            % Calculate indices for new and existing points.
            new = (n0+1):(n0+n_new);
            old = 1:n0;
            
            % Generate new x/y values.
            theta  = 2*pi * rand(n_new, 1);
            radius = dxy * (rand(n_new, 1) + 1);
            %     x(new) = x(parents) + radius .* cos(theta)  ; %added rand
            %     y(new) = y(parents) + radius .* sin(theta) ; %added rand
            x(new) = x(parents)*rand() + radius .* cos(theta) *rand(); %added rand
            y(new) = y(parents)*rand() + radius .* sin(theta) *rand(); %added rand
            
            
            % Interpolate to find nominal new r and h values and add noise to
            % roughness and height maps.
            r(new) =   interpolate(x(old), y(old), r(old), x(new), y(new)) ...
                + (dh * rr) .* randn(n_new, 1);
            h(new) =   interpolate(x(old), y(old), h(old), x(new), y(new)) ...
                + (dh/dxy) * radius .* r(new) .* randn(n_new, 1);
            n0 = n_new + n0;
        end
        
        
        % Normalize the distribution of the points about the median.
        %x = (x - median(x))/std(x);
        %y = (y - median(y))/std(y);
        
        % If the user wants a mesh output, we can do that too. Create a mesh
        % over the significant part and interpolate over it.
        
        [xm, ym] = meshgrid(linspace(-1, 1, mesh_size));
        hm = interpolate(x*rand(), y*rand(), h*rand(), xm*rand(), ym*rand());
        
        if xb>1
            C = imfuse(hm,s(xb-1).hm);
            s(xb).hm=C; clear hm C
        else
            s(xb).hm=hm; clear hm
        end
    end
    
    
    img=s(xb).hm;
    varname=mat2str(id);
    imwrite(img,['j' varname '.tif']);
    disp('fractal made')
    
    
    
    
    
end
end

function vn = interpolate(x0, y0, v0, xn, yn)

int = TriScatteredInterp([100*[-1 -1 1 1]'; x0], ...
    [100*[-1 1 -1 1]'; y0], ...
    [zeros(4, 1);      v0], 'linear');
vn = int(xn, yn);

end
