function h=nsubplot(nrows,ncols,row,col,varargin)
% 'Nice' subplot, with some options Ethan likes!
% Note that unlike the builtin subplot function, 
%  you specify the subplot by its (row,col) index.
% You can also specify a range of (row,col) indices
%  to change the shape of the subplot, e.g.
%   nsubplot(4,4,1:2,1:3)
%  generates a subplot spanning the first two rows
%  and first three columns.

if nargin < 1
    h = subplot(1,1,1);
elseif nargin >= 2 && (isequal(nrows,'pos') || isequal(nrows,'position')) 
    % if start call with 'position', call
    %  'axes' instead of 'subplot'
    switch nargin
        case 2
            varargin = {nrows,ncols};
        case 3
            varargin = {nrows,ncols,row};
        otherwise
            varargin = [{nrows,ncols,row,col} varargin];
    end;
    h = axes(varargin{:});
elseif nargin == 2
    row = ncols;
    ncols = ceil(sqrt(nrows));
    nrows = ceil(nrows ./ ncols);
    h = nsubplot(nrows,ncols,row);
elseif nargin <= 3
    h = subplot(nrows,ncols,row);
else
    orig_nrow = numel(row);
    orig_ncol = numel(col);
    row = repmat(row(:),[1 orig_ncol]);
    col = repmat(col(:)',[orig_nrow 1]);
    subplot_id = (row-1)*ncols + col;
    subplot_id = subplot_id(:);
    h = subplot(nrows,ncols,subplot_id,varargin{:});
end;

% apply some settings I like...
set(h,'Box','off');
set(h,'TickDir','out');
set(h,'ticklen',[.01 .01]);
set(h,'Color','none');
set(h,'layer','top');
% set parent figure to have white bg color
set(get(h,'parent'),'color','w');
hold(h,'on');

% modified 2021-09-07 to save original position.
% Since MATLAB has started strangely changing 
% subplot positions in a figure in the middle
% of doing later plotting commands, in a way that
% only occurs for certain figures/plots, but is 
% hard to predict, is different every time,
% and is affected by interacting with the figure
% while the plots are being made (e.g. resizing 
% the fig). So you can use this saved data to
% restore the subplot to its original position.
set(h,'UserData',struct('original_pos',get(h,'pos')));