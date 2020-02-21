% Scenario Viewer Matlab Demo

updateRate = 1;


x_loc = 1*data.AntX;
y_loc = 1*data.AntY;
z_loc = zeros(1,676);

b = [0 time_samples(1:675)];

wpts = [b' x_loc' y_loc' z_loc'];

radarPlatform = phased.Platform('MotionModel','Custom',...
    'CustomTrajectory', wpts);


airplanePlatforms = phased.Platform(...
    'InitialPosition',[0;0;0],...
    'Velocity',[0;0;0]);

sSV = phased.ScenarioViewer('BeamRange',10.0,'UpdateRate',updateRate,...
    'PlatformNames',{'Radarr','Points'},'ShowPosition',true,...
    'ShowSpeed',true,'ShowAltitude',true,'ShowLegend',true);

slowTime = 0.2;


for i = 1:100
    [radar_pos,radar_vel] = radarPlatform(slowTime);
    [tgt_pos,tgt_vel] = airplanePlatforms(slowTime);
    [rng,ang] = rangeangle(tgt_pos,radar_pos);
    
    step(sSV,radar_pos,radar_vel,tgt_pos,tgt_vel);
    pause(0.1);
end
