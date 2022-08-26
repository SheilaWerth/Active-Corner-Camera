clc
clear all
close all
global wall_v0
global epsilon
global fovCenter
global roomHeightMax
roomHeightMax = 3;
addpath(genpath('/Users/sheilawerth/Dropbox/Lab/ActiveCornerCamera/SheilaHooverShare/Experimental Results/paperCode/'))

global l_xyz0
l_xyz0 = [-0.04    0.06         0];

posVec = 1;
cols = brewermap(length(posVec),'Greens');


figure(5)
% subplot(122)
hold on
bprop =0;


epsilon = 1e-8;

transparency = .1;
plotFlag = 0;
maxDist = .5;
c_light = 299792458; %Speed of light

load('data_020322_params.mat')


% define occluding edge
wall_v0 = [0,0,0];
n_wall = [1,0,0];  % unit vector pointing away from corner, parallel to wall
wall_v1 = [-5,0,0];


% SPAD Camera Parameters
n_w = [0,0,1];
bin_size = params.bin_size;
fovWidth = params.camera_FOV;

% populate camera structure
camera.cam_span_x = fovWidth;
camera.cam_span_y = fovWidth;
camera.num_time_bins = params.num_time_bins;
camera.cam_pixel_dim = params.cam_pixel_dim;
camera.cam_pixel_corner = [params.camera_FOV_center(1) - camera.cam_span_x/2,...
    params.camera_FOV_center(2) - camera.cam_span_y/2,0];
camera.bin_size = params.bin_size;

cam_span_x = camera.cam_span_x;
cam_span_y = camera.cam_span_y;
num_time_bins = camera.num_time_bins;
cam_pixel_dim = camera.cam_pixel_dim;
cam_pixel_corner = camera.cam_pixel_corner;
fovCenter = cam_pixel_corner + [cam_span_x/2,cam_span_y/2,0];



phiMidVec = [];
rbVec = [];
hVec = [];
rVec = [];
% save the 
for pos = 1:14
  
    load(['Facet_pos' num2str(pos) '.mat'])
    
    rprop = hist_foreground.rhist(:,end);
    hprop = hist_foreground.hhist(:,end);
    facet_phi1 = phiBoundsHat(:,1);
    facet_phi2 = phiBoundsHat(:,2);

    nobj = size(rprop,1);


    [proposedObject,normal_prior] = makeProposedObjectForegroundBackgroundTilt_multiTarget_FOV(...
    phiBoundsHat, hprop, ...
    rprop, modeEst.rb_mode, modeEst.b_mode);

    figure
    plotObjects(proposedObject,'r')
    hold on
    plotObjects(objects(1:3,:),'g')
    
    plot([-10,0],[0,0],'k','LineWidth',4) % plot wall footprint
    
    
    xlabel('x','Interpreter','latex','fontsize',14)
    ylabel('y','Interpreter','latex','fontsize',14)
    zlabel('z','Interpreter','latex','fontsize',14)
    
    xlim([-1.5 1.5])
    ylim([-.5 2.5])
    zlim([0 3])
    
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperSize',4*[3 3]);
    fig = gcf;
    fig.PaperUnits = 'centimeters';
    fig.PaperPosition = 4*[0 0 3 3];
    fig.Units = 'centimeters';
    fig.PaperSize=4*[3 3];
    fig.Units = 'centimeters';
    print(fig,['singleFrameResult_' num2str(pos) ], '-dpdf','-r200');
    
    
    for t = 1:nobj
        facet_phi1 = phiBoundsHat(t,1);
        facet_phi2 = phiBoundsHat(t,2);
        phiMidVec = [phiMidVec, mean([facet_phi1, facet_phi2])];
        hVec = [hVec, hprop(t)];
        rVec = [rVec, rprop(t)];
        rbVec = [rbVec, modeEst.rb_mode(t)];
        
    end
    
end

%%
[phiMidVec, order] = sort(phiMidVec,'ascend');
rbVec = rbVec(:,order);
rVec = rVec(:,order);
hVec = hVec(:,order);
%%

figure(5)
%     proposedObject = proposedObject(1:2,:);
% plotObjects(proposedObject,'r')
hold on
plotObjects(objects(1:3,:),'g')
plot([-10,0],[0,0],'k','LineWidth',4) % plot wall footprint


xlabel('x [m]','Interpreter','latex','fontsize',14)
ylabel('y [m]','Interpreter','latex','fontsize',14)
zlabel('z [m]','Interpreter','latex','fontsize',14)

xlim([-1.5 1.5])
ylim([-.5 2.6])
zlim([0 3])

nFacet = length(rVec);

count = 1;

for f = 1:nFacet
    tanalpha = (hVec(f)/rVec(f));
    phiMid = phiMidVec(f);
    if count>1
        phiMidPast = phiMidVec(f-1);
        rbpropPast = rbVec(f-1);
        rbprop = rbVec(f);
        x1 = cos(phiMidPast)*rbpropPast;
        y1 = sin(phiMidPast)*rbpropPast;
        x2 = cos(phiMid)*rbprop;
        y2 = sin(phiMid)*rbprop;
        facetHeight = tanalpha*rbprop;
        objVert = [x1,y1,0;...
            x1,y1,facetHeight;...
            x2,y2,facetHeight;...
            x2,y2,0];
        patch(objVert(:,1),objVert(:,2),objVert(:,3),'b','FaceAlpha',.15)
        
        
    end
    count = count + 1;

    
end
objVert = [-.25,0,0;...
    .25,0,0;...
    .25,-.5,0;...
    -.25,-.5,0];
set(gca, 'XDir','reverse')

patch(objVert(:,1),objVert(:,2),objVert(:,3),'k','FaceAlpha',.15)
view(-15,25)
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperSize',4*[3 3]);
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPosition = 4*[0 0 3 3];
fig.Units = 'centimeters';
fig.PaperSize=4*[3 3];
fig.Units = 'centimeters';
print(fig,['wallCompositeTwoTarg60' ], '-dpdf','-r200');

figure(5)
view(-10,80)

% set(gcf,'Position',[10 10 50 30])
% set(gcf,'PaperUnits','centimeters');
% set(gcf,'PaperSize',4*[3 3]);
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPosition = 4*[-.2 -.08 3 3];
fig.Units = 'centimeters';
fig.PaperSize=4*[2.6 2.8];
fig.Units = 'centimeters';
print(fig,['wallCompositeTwoTarg60view2' ], '-dpdf','-r200');



