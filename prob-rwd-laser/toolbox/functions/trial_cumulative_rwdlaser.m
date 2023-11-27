function cumul_outcome = trial_cumulative_rwdlaser(PDS)
    cumul_outcome.laser = cumsum(PDS.magnitude_punish,'omitnan');
    cumul_outcome.reward = cumsum(PDS.timereward,'omitnan');
end
