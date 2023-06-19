function [PDS, c, s] = plotPsycho(PDS, c, s)

% all trials that didn't end in a non-start state-code
g       = ~ismember(PDS.state,[0, 3.3]);

% color-change deltas
x       = linspace(min(PDS.joyholdreq(g)),max(PDS.joyholdreq(g)),c.psychFuncBins);

xvals   = myBin(PDS.joyholdreq,x)';

hits = PDS.state == 1.5;

y   = grpstats(hits(g),xvals(g),@sum);
n   = grpstats(hits(g),xvals(g),@length);
    
    % Fitting options:
    out    = pfit([x', y, n],'FIX_GAMMA','NaN','CUTS',0.8,'SENS',0,'VERBOSE','FALSE');
    
    [p,pci] = binofit(y,n);
    
    % Plot the data
    figure;
    ax1      = axes;
    hold on
    fo = mybarerr(x,p,pci,[],[0.8 0.8 0.8]);
    for j = 1:length(fo)
        set(fo{j},'EdgeColor','none')
    end
    h      = psychoplot([x' y n], out, {out.shape, out.params.est}, 'LineWidth', 2, 'Color', [0 0 0]);
    set(h{1},'Visible','off')
    hold off
    
    set(ax1,'TickDir','out','TickLength',[0.005 0.025],'LineWidth',1.25,'FontSize',12)  
end