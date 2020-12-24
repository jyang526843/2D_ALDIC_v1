function [strain_exx,strain_exy,strain_eyy,strain_principal_max,strain_principal_min, ...
    strain_maxshear,strain_vonMises] = PlotstrainQuadtree(U,F,coordinatesFEM,elementsFEM,CurrentImg,DICpara)
%FUNCTION PLOTSTRAINQUADTREE: to compute and plot DIC solved strain fields on the original DIC images
%   [strain_exx,strain_exy,strain_eyy,strain_principal_max,strain_principal_min, ...
%    strain_maxshear,strain_vonMises] = PlotstrainQuadtree(U,F,coordinatesFEMWorld,elementsFEM,CurrentImg,DICpara)
% ----------------------------------------------
%
%   INPUT: F                    DIC solved deformation gradient tensor
%          coordinatesFE        FE mesh coordinates
%          elementsFEM          FE mesh elements
%
%   OUTPUT: strain_exx              strain xx-compoent
%           strain_exy              strain xy-compoent
%           strain_eyy              strain yy-compoent
%           strain_principal_max    max principal strain on the xy-plane
%           strain_principal_min    min principal strain on the xy-plane
%           strain_maxshear         max shear strain on the xy-plane
%           strain_vonMises         equivalent von Mises strain
%
%   Plots:       
%       1) strain sxx
%       2) strain sxy
%       3) strain syy
%       4) max principal strain on the xy-plane 
%       5) min principal strain on the xy-plane
%       6) max shear strain on the xy-plane
%       7) equivalent von Mises strain
%
% ----------------------------------------------
% Reference
% [1] RegularizeNd. Matlab File Exchange open source. 
% https://www.mathworks.com/matlabcentral/fileexchange/61436-regularizend
% [2] Gridfit. Matlab File Exchange open source. 
% https://www.mathworks.com/matlabcentral/fileexchange/8998-surface-fitting-using-gridfit
% ----------------------------------------------
% Author: Jin Yang.  
% Contact and support: jyang526@wisc.edu -or- aldicdvc@gmail.com
% Last time updated: 11/2020.
% ==============================================


%% Initialization
warning off; load('./plotFiles/colormap_RdYlBu.mat','cMap');
OrigDICImgTransparency = DICpara.OrigDICImgTransparency; % Original raw DIC image transparency
Image2PlotResults = DICpara.Image2PlotResults; % Choose image to plot over (first only, second and next images)

disp_u = U(1:2:end); disp_v = U(2:2:end);
coordinatesFEMWorldDef = [coordinatesFEM(:,1)+Image2PlotResults*disp_u, coordinatesFEM(:,2)+Image2PlotResults*disp_v];


%% Compute strain components

u_x = F(1:4:end); v_x = F(2:4:end);
u_y = F(3:4:end); v_y = F(4:4:end);

strain_exx = u_x; 
strain_exy = 0.5*(v_x+u_y);
strain_eyy = v_y;

strain_maxshear = sqrt((0.5*(strain_exx-strain_eyy)).^2 + strain_exy.^2);
% Principal strain
strain_principal_max = 0.5*(strain_exx+strain_eyy) + strain_maxshear;
strain_principal_min = 0.5*(strain_exx+strain_eyy) - strain_maxshear;
% equivalent von Mises strain
strain_vonMises = sqrt(strain_principal_max.^2 + strain_principal_min.^2 - ...
             strain_principal_max.*strain_principal_min + 3*strain_maxshear.^2);


%% ====== 1) Strain exx ======
fig1=figure; ax1=axes; 
try h1=imshow( flipud(imread(CurrentImg) ),'InitialMagnification','fit');
catch h1=surf( flipud( imread(CurrentImg) ),'EdgeColor','none','LineStyle','none');
end

axis on; axis equal; axis tight; box on; set(gca,'fontSize',18); view(2); set(gca,'ydir','normal');
hold on; ax2=axes; %h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_exx,'EdgeColor','none','LineStyle','none');
h2=show([],elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_exx,'NoEdgeColor');
%h2=showQuadtree(elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_exx);
set(gca,'fontSize',18); view(2); box on; caxis auto; % set(gca,'ydir','normal');
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
colormap(jet); caxis([0,0.5]) % D Sample 
% colormap(jet); caxis([-0.1,0.02]) % foam
% colormap(jet); caxis([-0.004,0]); % Sample 12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if max(coordinatesFEM(:,1)) < 200,set(gca,'XTick',[]); end
if max(coordinatesFEM(:,2)) < 200,set(gca,'YTick',[]); end
set([ax1,ax2],'Position',[.17 .11 .685 .815]);  
ax1.Visible = 'on'; ax1.TickLabelInterpreter = 'latex'; 
cb2 = colorbar('Position',[.17+0.685+0.012 .11 .03 .815]); cb2.TickLabelInterpreter = 'latex';

xlabel( '$x$ (pixels)','Interpreter','latex'); ylabel('$y$ (pixels)','Interpreter','latex');
title('Strain $e_{xx}$','FontWeight','Normal','Interpreter','latex'); set(gcf,'color','w');



%% ====== 2) Strain exy ======
fig1=figure; ax1=axes; 
try h1=imshow( flipud(imread(CurrentImg)),'InitialMagnification','fit');
catch h1=surf( flipud( imread(CurrentImg) ),'EdgeColor','none','LineStyle','none');
end

axis on; axis equal; axis tight; box on; set(gca,'fontSize',18); view(2); set(gca,'ydir','normal');
hold on; ax2=axes; %h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_exy,'EdgeColor','none','LineStyle','none');
h2=show([],elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_exy,'NoEdgeColor');
%h2=showQuadtree(elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_exy);
set(gca,'fontSize',18); view(2); box on;  caxis auto; % set(gca,'ydir','normal');
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
colormap(jet); caxis([-0.08,0.08]) % D Sample 
% colormap(jet); caxis([-0.06,0.06]) % foam
% colormap(jet); caxis([-0.008,0.008]); % Sample 12 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if max(coordinatesFEM(:,1)) < 200,set(gca,'XTick',[]); end
if max(coordinatesFEM(:,2)) < 200,set(gca,'YTick',[]); end
set([ax1,ax2],'Position',[.17 .11 .685 .815]);  
ax1.Visible = 'on'; ax1.TickLabelInterpreter = 'latex'; 
cb2 = colorbar('Position',[.17+0.685+0.012 .11 .03 .815]); cb2.TickLabelInterpreter = 'latex';

xlabel( '$x$ (pixels)','Interpreter','latex'); ylabel('$y$ (pixels)','Interpreter','latex');
title('Strain $e_{xy}$','FontWeight','Normal','Interpreter','latex'); set(gcf,'color','w');



%% ====== 3) Strain eyy ======
fig1=figure; ax1=axes; 
try h1=imshow( flipud(imread(CurrentImg)),'InitialMagnification','fit');
catch h1=surf( flipud( imread(CurrentImg) ),'EdgeColor','none','LineStyle','none');
end

axis on; axis equal; axis tight; box on; set(gca,'fontSize',18); view(2); set(gca,'ydir','normal');
hold on; ax2=axes; %h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_eyy,'EdgeColor','none','LineStyle','none');
h2=show([],elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_eyy,'NoEdgeColor');
%h2=showQuadtree(elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_eyy);
set(gca,'fontSize',18); view(2); box on;  caxis auto; % set(gca,'ydir','normal');
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
colormap(jet); caxis([-0.15,0]) % D Sample 
% colormap(jet); caxis([-0.05,0.2]) % foam
% colormap(jet); caxis([-0.002,0.017]); % Sample 12 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if max(coordinatesFEM(:,1)) < 200,set(gca,'XTick',[]); end
if max(coordinatesFEM(:,2)) < 200,set(gca,'YTick',[]); end
set([ax1,ax2],'Position',[.17 .11 .685 .815]);  
ax1.Visible = 'on'; ax1.TickLabelInterpreter = 'latex'; 
cb2 = colorbar('Position',[.17+0.685+0.012 .11 .03 .815]); cb2.TickLabelInterpreter = 'latex';

xlabel( '$x$ (pixels)','Interpreter','latex'); ylabel('$y$ (pixels)','Interpreter','latex');
title('Strain $e_{yy}$','FontWeight','Normal','Interpreter','latex'); set(gcf,'color','w');

 

%% ====== 4) Strain e_principal_max ======
fig1=figure; ax1=axes; 
try h1=imshow( flipud(imread(CurrentImg)),'InitialMagnification','fit');
catch h1=surf(  flipud( imread(CurrentImg) ),'EdgeColor','none','LineStyle','none');
end

axis on; axis equal; axis tight; box on; set(gca,'fontSize',18); view(2); set(gca,'ydir','normal');
hold on; ax2=axes; %h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_principal_max,'EdgeColor','none','LineStyle','none');
h2=show([],elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_principal_max,'NoEdgeColor');
%h2=showQuadtree(elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_principal_max);
set(gca,'fontSize',18); view(2); box on;  caxis auto; % set(gca,'ydir','normal');
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
colormap(jet);  caxis auto; % D Sample 
% colormap(jet); caxis auto % foam
% colormap(jet); caxis([0,0.02]); % Sample 12 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if max(coordinatesFEM(:,1)) < 200,set(gca,'XTick',[]); end
if max(coordinatesFEM(:,2)) < 200,set(gca,'YTick',[]); end
set([ax1,ax2],'Position',[.17 .11 .685 .815]);  
ax1.Visible = 'on'; ax1.TickLabelInterpreter = 'latex'; 
cb2 = colorbar('Position',[.17+0.685+0.012 .11 .03 .815]); cb2.TickLabelInterpreter = 'latex';

xlabel( '$x$ (pixels)','Interpreter','latex'); ylabel('$y$ (pixels)','Interpreter','latex');
title('$Principal strain e_{\max}$','FontWeight','Normal','Interpreter','latex'); set(gcf,'color','w');



%% ====== 5) Strain e_principal_min ======
fig1=figure; ax1=axes; 
try h1=imshow( flipud(imread(CurrentImg)),'InitialMagnification','fit');
catch h1=surf(  flipud( imread(CurrentImg) ),'EdgeColor','none','LineStyle','none');
end

axis on; axis equal; axis tight; box on; set(gca,'fontSize',18); view(2); set(gca,'ydir','normal');
hold on; ax2=axes; %h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_principal_min,'EdgeColor','none','LineStyle','none');
h2=show([],elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_principal_min,'NoEdgeColor');
%h2=showQuadtree(elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_principal_min);
set(gca,'fontSize',18); view(2); box on;  caxis auto; % set(gca,'ydir','normal');
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
colormap(jet);  caxis auto; % D Sample 
% colormap(jet); caxis auto % foam
% colormap(jet); caxis([-0.008,0]); % Sample 12 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if max(coordinatesFEM(:,1)) < 200,set(gca,'XTick',[]); end
if max(coordinatesFEM(:,2)) < 200,set(gca,'YTick',[]); end
set([ax1,ax2],'Position',[.17 .11 .685 .815]);  
ax1.Visible = 'on'; ax1.TickLabelInterpreter = 'latex'; 
cb2 = colorbar('Position',[.17+0.685+0.012 .11 .03 .815]); cb2.TickLabelInterpreter = 'latex';

xlabel( '$x$ (pixels)','Interpreter','latex'); ylabel('$y$ (pixels)','Interpreter','latex');
title('$Principal strain e_{\min}$','FontWeight','Normal','Interpreter','latex'); set(gcf,'color','w');



%% ====== 6) Strain e_max_shear ======
fig1=figure; ax1=axes; 
try h1=imshow( flipud(imread(CurrentImg)),'InitialMagnification','fit');
catch h1=surf(  flipud( imread(CurrentImg) ),'EdgeColor','none','LineStyle','none');
end

axis on; axis equal; axis tight; box on; set(gca,'fontSize',18); view(2); set(gca,'ydir','normal');
hold on; ax2=axes; %h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_maxshear,'EdgeColor','none','LineStyle','none');
h2=show([],elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_maxshear,'NoEdgeColor');
%h2=showQuadtree(elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_maxshear);
set(gca,'fontSize',18); view(2); box on;  caxis auto; % set(gca,'ydir','normal');
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
colormap(jet);  caxis auto; % D Sample 
% colormap(jet); caxis auto % foam
% colormap(jet); caxis([0,0.011]); % Sample 12 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if max(coordinatesFEM(:,1)) < 200,set(gca,'XTick',[]); end
if max(coordinatesFEM(:,2)) < 200,set(gca,'YTick',[]); end
set([ax1,ax2],'Position',[.17 .11 .685 .815]);  
ax1.Visible = 'on'; ax1.TickLabelInterpreter = 'latex'; 
cb2 = colorbar('Position',[.17+0.685+0.012 .11 .03 .815]); cb2.TickLabelInterpreter = 'latex';

xlabel( '$x$ (pixels)','Interpreter','latex'); ylabel('$y$ (pixels)','Interpreter','latex');
title('Max shear strain','FontWeight','Normal','Interpreter','latex'); set(gcf,'color','w');

 
%% ====== 7) von Mises equivalent strain ======
fig1=figure; ax1=axes; 
try h1=imshow( flipud(imread(CurrentImg)),'InitialMagnification','fit');
catch h1=surf(  flipud( imread(CurrentImg) ),'EdgeColor','none','LineStyle','none');
end

axis on; axis equal; axis tight; box on; set(gca,'fontSize',18); view(2);  set(gca,'ydir','normal');
hold on; ax2=axes; % h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_vonMises,'EdgeColor','none','LineStyle','none');
h2=show([],elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_vonMises,'NoEdgeColor');
%h2=showQuadtree(elementsFEM(:,1:4),coordinatesFEMWorldDef,strain_vonMises);
set(gca,'fontSize',18); view(2); box on;  caxis auto;  
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
colormap(jet);  caxis auto; % D Sample 
% colormap(jet); caxis auto % foam
% colormap(jet); caxis([0,0.025]); % Sample 12 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if max(coordinatesFEM(:,1)) < 200,set(gca,'XTick',[]); end
if max(coordinatesFEM(:,2)) < 200,set(gca,'YTick',[]); end
set([ax1,ax2],'Position',[.17 .11 .685 .815]);  
ax1.Visible = 'on'; ax1.TickLabelInterpreter = 'latex'; 
cb2 = colorbar('Position',[.17+0.685+0.012 .11 .03 .815]); cb2.TickLabelInterpreter = 'latex';

xlabel( '$x$ (pixels)','Interpreter','latex');  ylabel('$y$ (pixels)','Interpreter','latex');
title('von Mises equivalent strain','FontWeight','Normal','Interpreter','latex'); set(gcf,'color','w');
 




end
 
 
