function FigHandle = find2ndMonitor(varargin)
MP = get(0, 'MonitorPositions');
if size(MP, 1) == 1  % Single monitor
  FigH = figure(varargin{:});
else                 % Multiple monitors
  % Catch creation of figure with disabled visibility: 
  indexVisible = find(strncmpi(varargin(1:2:end), 'Vis', 3));
  if ~isempty(indexVisible)
    paramVisible = varargin(indexVisible(end) + 1);
  else
    paramVisible = get(0, 'DefaultFigureVisible');
  end
  %
  Shift    = MP(1, 1:2);
  FigH     = figure(varargin{:}, 'Visible', 'off');
  drawnow;
  set(FigH, 'Units', 'pixels');
  pos      = get(FigH, 'Position');
  pause(0.02);  % See Stefan Glasauer's comment
  set(FigH, 'Position', [pos(1:2) + Shift, pos(3:4)], ...
            'Visible', paramVisible);
end
if nargout ~= 0
  FigHandle = FigH;
end