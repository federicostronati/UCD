clc; clear all;

% Read in data
Fred = readtable('FRED-MD.xlsx') ;
oil    = Fred.OILPRICEx(2:end);
indpro    = Fred.INDPRO(2:end);
avgwh = Fred.AWHMAN(2:end);

d_oil = diff(oil);
d_indpro = diff(indpro);
d_avgwh = diff(avgwh);

% GRAPH ORIGINAL VALUES

startdate        = datenum('01-01-1959','dd-mm-yyyy');
enddate          = datenum('01-08-2024','dd-mm-yyyy');
graphenddate     = datenum('01-08-2024','dd-mm-yyyy');

date = linspace(startdate+1,enddate,length(oil))';

% Graph the series
figure(1)
subplot(1,3,1)
plot(date, oil);
xlim([startdate, graphenddate]);
datetick('x','yyyy','keeplimits');
title('Oil Price');

subplot(1,3,2)
plot(date, indpro);
xlim([startdate, graphenddate]);
datetick('x','yyyy','keeplimits');
title('Industrial Production Index');

subplot(1,3,3)
plot(date, avgwh);
xlim([startdate, graphenddate]);
datetick('x','yyyy','keeplimits');
title('Average weekly hours - Manufacturing');

% STATIONARY GRAPHS - DIFFs

date = date(2:end);   % drop the first date so length matches diff()

figure(3)
subplot(1,3,1)
plot(date, d_oil);
xlim([startdate, graphenddate]);
datetick('x','yyyy','keeplimits');
title('Oil price');

subplot(1,3,2)
plot(date, d_indpro);
xlim([startdate, graphenddate]);
datetick('x','yyyy','keeplimits');
title('Industrial Production Index');

subplot(1,3,3)
plot(date, d_avgwh);
xlim([startdate, graphenddate]);
datetick('x','yyyy','keeplimits');
title('Avg weekly hours - Manufacturing');

%% GRAPH IMFs - FIRST ORDERING

% Define the VAR. Estimate model, IRFs and error bands
% By default, the identification is a Cholesky decomposition
% The last variable is affected contemporaneously by the first two variables. 
% The second variable is affected contemporaneously by the first variable but not the third.
% The first variable is not affected contemporaneously by the other two
% variables
% on the first but not the third. The first
% This uses 500 bootstrap replications and a 90% confidence interval
N = 3;
Nlags = 4;
Nhorizon = 49;

X = [d_indpro d_oil d_avgwh];
Mdl = varm(N,Nlags);
[EstMdl,EstSE,LogL,E] = estimate(Mdl,X);
summarize(EstMdl)
[Response,Lower,Upper] = irf(EstMdl,"E",E,"NumPaths",500,"Confidence",0.9,"NumObs",Nhorizon);

Names = ["IPI", "Oil Price" ,  "Avg W.H."];

% Graph IRFs
figure;
for i=1:N
  for j=1:N
subplot(N,N,(i-1)*N+j)
h1 = plot(0:size(Response,1)-1,Response(:,i,j),'Linewidth',2);
hold on
h2 = plot(0:size(Response,1)-1,[Lower(:,i,j) Upper(:,i,j)],'r--','Linewidth',2);
xlabel("Time")
ylabel("Response")
titletext = append('Response of ',Names(j),' to a Shock to ',Names(i) );
title(titletext)
grid on
hold off 
  end 
end

%% %% GRAPH IMFs - SECOND ORDERING

N = 3;
Nlags = 4;
Nhorizon = 49;

X = [d_indpro d_oil d_avgwh];
Mdl = varm(N,Nlags);
[EstMdl,EstSE,LogL,E] = estimate(Mdl,X);
summarize(EstMdl)
[Response,Lower,Upper] = irf(EstMdl,"E",E,"NumPaths",500,"Confidence",0.9,"NumObs",Nhorizon);

Names = ["IPI", "Oil Price" ,  "Avg W.H."];

% Graph IRFs
figure;
for i=1:N
  for j=1:N
subplot(N,N,(i-1)*N+j)
h1 = plot(0:size(Response,1)-1,Response(:,i,j),'Linewidth',2);
hold on
h2 = plot(0:size(Response,1)-1,[Lower(:,i,j) Upper(:,i,j)],'r--','Linewidth',2);
xlabel("Time")
ylabel("Response")
titletext = append('Response of ',Names(j),' to a Shock to ',Names(i) );
title(titletext)
grid on
hold off 
  end 
end