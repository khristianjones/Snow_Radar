% Scenario Viewer Matlab Demo

updateRate = 0.1;
radarPlatform = phased.Platform(...
    'InitialPosition',[0;0;10], ...
    'Velocity',[0;0;0]);
airplanePlatforms = phased.Platform(...
    'InitialPosition',[5000.0;3500.0;6000.0],...
    'Velocity',[-300;0;0]);

sSV = phased.ScenarioViewer('BeamRange',5000.0,'UpdateRate',updateRate,...
    'PlatformNames',{'Ground Radar','Airplane'},'ShowPosition',true,...
    'ShowSpeed',true,'ShowAltitude',true,'ShowLegend',true);

for i = 1:100
    [radar_pos,radar_vel] = step(radarPlatform,updateRate);
    [tgt_pos,tgt_vel] = step(airplanePlatforms,updateRate);
    [rng,ang] = rangeangle(tgt_pos,radar_pos);
    sSV.BeamSteering = ang;
    step(sSV,radar_pos,radar_vel,tgt_pos,tgt_vel);
    pause(0.1);
end
