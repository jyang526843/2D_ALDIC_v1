function [x2,y2,disp_u,disp_v,dudx,dvdx,dudy,dvdy,strain_exx,strain_exy,strain_eyy, ...
    strain_principal_max,strain_principal_min,strain_maxshear,strain_vonMises] = Plotstrain( ...
    U,F,Rad,x0,y0,sizeOfImg,CurrentImg,DICpara)
%PLOTSTRAIN: to compute and plot DIC solved strain fields on the original DIC images
%   [x2,y2,disp_u,disp_v,dudx,dvdx,dudy,dvdy,strain_exx,strain_exy,strain_eyy, ...
%   strain_principal_max,strain_principal_min,strain_maxshear,strain_vonMises] = Plotstrain( ...
%   U,Rad,F,x0,y0,sizeOfImg,CurrentImg,DICpara)
%
%   INPUT: U                DIC solved displacement fields
%          F                DIC solved deformation gradient tensor
%          Rad              Parameter used to compute the final F. If we use the direct
%                           output from the ALDIC code, Rad=0. If we apply a finite  
%                           difference or plane fitting of the U to compute the F, Rad>0.
%          x0,y0            x and y coordinates of each points on the image domain
%          SizeOfImg        Size of the DIC raw image
%          CurrentImg       File name of current deformed image
%          DICpara          DIC para in the ALDIC code
%
%   OUTPUT: x2,y2                   x- and y-coordinates of points whose strain values are computed
%           disp_u,disp_v           Interpolated dispu and dispv at points {x2,y2}
%           dudx,dvdx,dudy,dvdy     E.g., dudx = d(disp_u)/dx at points {x2,y2}
%           strain_exx              strain xx-compoent
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
%
% Author: Jin Yang  (jyang526@wisc.edu)
% Last date modified: 2020.11.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
warning off; load('./plotFiles/colormap_RdYlBu.mat','cMap');
OrigDICImgTransparency = DICpara.OrigDICImgTransparency; % Original raw DIC image transparency
Image2PlotResults = DICpara.Image2PlotResults; % Choose image to plot over (first only, second and next images)

x = x0(1+Rad:end-Rad,1+Rad:end-Rad); 
y = y0(1+Rad:end-Rad,1+Rad:end-Rad);

M = size(x,1); N = size(x,2);
u_x = F(1:4:end); v_x = F(2:4:end);
u_y = F(3:4:end); v_y = F(4:4:end);
 
u_x = reshape(u_x,M,N); v_x = reshape(v_x,M,N);
u_y = reshape(u_y,M,N); v_y = reshape(v_y,M,N);

u = U(1:2:end); v = U(2:2:end);
u0 = reshape(u,M+2*Rad,N+2*Rad); v0 = reshape(v,M+2*Rad,N+2*Rad);
u = u0(1+Rad:end-Rad,1+Rad:end-Rad); v = v0(1+Rad:end-Rad,1+Rad:end-Rad);

% imagesc([x(1,1) x(end,1)], [y(1,1) y(1,end)], flipud(g)); hold on;
if M < 9,x2 = x(:,1)'; else x2 = interp(x(:,1)',4); end
if N < 9,y2 = y(1,:);  else y2 = interp(y(1,:),4);  end


%% Compute displacement components to manipulate the reference image
disp_u = gridfit(reshape(x,M*N,1),reshape(y,M*N,1),reshape(u,M*N,1),x2,y2);
disp_v = gridfit(reshape(x,M*N,1),reshape(y,M*N,1),reshape(v,M*N,1),x2,y2);
 

%% Compute strain components
dudx = gridfit(reshape(x,M*N,1),reshape(y,M*N,1),reshape(u_x,M*N,1),x2,y2);
dvdx = gridfit(reshape(x,M*N,1),reshape(y,M*N,1),reshape(v_x,M*N,1),x2,y2);
dudy = gridfit(reshape(x,M*N,1),reshape(y,M*N,1),reshape(u_y,M*N,1),x2,y2);
dvdy = gridfit(reshape(x,M*N,1),reshape(y,M*N,1),reshape(v_y,M*N,1),x2,y2);

strain_exx = dudx;
strain_exy = 0.5*(dvdx + dudy);
strain_eyy = dvdy;

strain_maxshear = sqrt((0.5*(strain_exx-strain_eyy)).^2 + strain_exy.^2);
% Principal strain
strain_principal_max = 0.5*(strain_exx+strain_eyy) + strain_maxshear;
strain_principal_min = 0.5*(strain_exx+strain_eyy) - strain_maxshear;
% equivalent von Mises strain
strain_vonMises = sqrt(strain_principal_max.^2 + strain_principal_min.^2 - ...
             strain_principal_max.*strain_principal_min + 3*strain_maxshear.^2);
 
% Please don't delete this line, to deal with the image and physical world coordinates       
[x2,y2]=ndgrid(x2,y2); x2=x2'; y2=y2';


%% ====== 1) Strain exx ======
fig1=figure; ax1=axes; 
try h1=imshow( flipud(imread(CurrentImg) ),'InitialMagnification','fit');
catch h1=surf( flipud( imread(CurrentImg) ),'EdgeColor','none','LineStyle','none');
end

axis on; axis equal; axis tight; box on; set(gca,'fontSize',18); view(2); set(gca,'ydir','normal');
hold on; ax2=axes; h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_exx,'EdgeColor','none','LineStyle','none');
set(gca,'fontSize',18); view(2); box on; caxis auto; % set(gca,'ydir','normal');
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
% colormap(jet); %caxis([-0.025,0.025]); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if x(M,N) < 200,set(gca,'XTick',[]); end
if y(M,N) < 200,set(gca,'YTick',[]); end
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
hold on; ax2=axes; h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_exy,'EdgeColor','none','LineStyle','none');
set(gca,'fontSize',18); view(2); box on;  caxis auto; % set(gca,'ydir','normal');
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
% colormap(jet); caxis([-0.008,0.008]); % caxis([-0.025,0.025]); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if x(M,N) < 200,set(gca,'XTick',[]); end
if y(M,N) < 200,set(gca,'YTick',[]); end
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
hold on; ax2=axes; h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_eyy,'EdgeColor','none','LineStyle','none');
set(gca,'fontSize',18); view(2); box on;  caxis auto; % set(gca,'ydir','normal');
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
% colormap(jet); caxis([-0.002,0.014]); %caxis([-0.015,0.015]); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if x(M,N) < 200,set(gca,'XTick',[]); end
if y(M,N) < 200,set(gca,'YTick',[]); end
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
hold on; ax2=axes; h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_principal_max,'EdgeColor','none','LineStyle','none');
set(gca,'fontSize',18); view(2); box on;  caxis auto; % set(gca,'ydir','normal');
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
%  colormap(jet); % caxis([-0.002,0.014]) % caxis([-0.025,0.025]); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if x(M,N) < 200,set(gca,'XTick',[]); end
if y(M,N) < 200,set(gca,'YTick',[]); end
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
hold on; ax2=axes; h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_principal_min,'EdgeColor','none','LineStyle','none');
set(gca,'fontSize',18); view(2); box on;  caxis auto; % set(gca,'ydir','normal');
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
% colormap(jet); % caxis([-0.025,0.025]); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if x(M,N) < 200,set(gca,'XTick',[]); end
if y(M,N) < 200,set(gca,'YTick',[]); end
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
hold on; ax2=axes; h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_maxshear,'EdgeColor','none','LineStyle','none');
set(gca,'fontSize',18); view(2); box on;  caxis auto; % set(gca,'ydir','normal');
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
% colormap(jet); caxis([-0.0,0.01]); % caxis([-0.025,0.025]); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if x(M,N) < 200,set(gca,'XTick',[]); end
if y(M,N) < 200,set(gca,'YTick',[]); end
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
hold on; ax2=axes; h2=surf(x2+Image2PlotResults*disp_u,sizeOfImg(2)+1-(y2-Image2PlotResults*disp_v),strain_vonMises,'EdgeColor','none','LineStyle','none');
set(gca,'fontSize',18); view(2); box on;  caxis auto;  
alpha(h2,OrigDICImgTransparency);  axis equal;  axis tight; colormap jet; colormap(cMap);
%%%%%% TODO: manually modify colormap and caxis %%%%%%
% colormap(jet); caxis([-0.0,0.022]) % caxis([-0.025,0.025]); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkaxes([ax1,ax2]);  %%Link them together
ax2.Visible = 'off';ax2.XTick = [];ax2.YTick = []; %%Hide the top axes
colormap(ax1,'gray'); % %%Give each one its own colormap

if x(M,N) < 200,set(gca,'XTick',[]); end
if y(M,N) < 200,set(gca,'YTick',[]); end
set([ax1,ax2],'Position',[.17 .11 .685 .815]);  
ax1.Visible = 'on'; ax1.TickLabelInterpreter = 'latex'; 
cb2 = colorbar('Position',[.17+0.685+0.012 .11 .03 .815]); cb2.TickLabelInterpreter = 'latex';

xlabel( '$x$ (pixels)','Interpreter','latex');  ylabel('$y$ (pixels)','Interpreter','latex');
title('von Mises equivalent strain','FontWeight','Normal','Interpreter','latex'); set(gcf,'color','w');
 




end
 
 
