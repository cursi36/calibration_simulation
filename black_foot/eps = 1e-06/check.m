


clear all
close all

load 'C_ref'

[~,~,off_free,Sigma] = sensfree_cleaning;

  windowsize = 5;
    b = 1/windowsize*ones(1,windowsize);
    a = 1;

sets = ['sens_1.txt';'sens_2.txt';'sens_3.txt';'sens_4.txt';'sens_5.txt';'sens_6.txt'];
[s_sets,~] = size(sets);

C(:,:,1)= load ('C_sample_1.txt');

C(:,:,2) = load ('C_sample_2.txt');

C(:,:,3) = load ('C_sample_3.txt');

C(:,:,4) = load ('C_sample_4.txt');

C(:,:,5) = load ('C_sample_5.txt');

C(:,:,6) = load ('C_sample_6.txt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C_Tot(:,:,1) = load ('C_tot_1.txt');

C_Tot(:,:,2) = load ('C_tot_2.txt');

C_Tot(:,:,3) = load ('C_tot_3.txt');

C_Tot(:,:,4) = load ('C_tot_4.txt');

C_Tot(:,:,5) = load ('C_tot_5.txt');

C_Tot(:,:,6) = load ('C_tot_6.txt');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C_Pinv(:,:,1) = load ('C_pinv_1.txt');

C_Pinv(:,:,2) = load ('C_pinv_2.txt');

C_Pinv(:,:,3) = load ('C_pinv_3.txt');

C_Pinv(:,:,4) = load ('C_pinv_4.txt');

C_Pinv(:,:,5) = load ('C_pinv_5.txt');

C_Pinv(:,:,6) = load ('C_pinv_6.txt');


height=0.16;
T=eye(6,6);
T(4,2)=-height;  T(5,1)=height;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Validation set


R = zeros(6,s_sets,s_sets); % R(:,ii,i) on set i by matrix ii

% for i = 1:s_sets
%     
%     S = load(sets(i,:));
%     F_ref = T*S(:,8:13).';
%     C_Pinv(:,:,i) = F_ref*pinv(S(:,2:7).');
% end

for i = 1:s_sets
    
    S = load(sets(i,:));
     S(:,2:13) = filter(b,a,S(:,2:13));
      S(:,2:13) = S(:,2:13)-repmat(off_free(1,:),length(S),1);
    F_ref = T*S(:,8:13).';
    
    F_ref_col = reshape(F_ref',6*length(S),1);
    
    for ii = 1:s_sets
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Optimal Solution
        F_calib = C(:,:,ii)*S(:,2:7).';
        R(:,ii,i) = R_sqr2(F_ref.',F_calib);
        
        F = blkdiag([F_calib(1,:).' ], [F_calib(2,:).' ], [F_calib(3,:).' ] ...
            ,[F_calib(4,:).' ], [F_calib(5,:).' ], [F_calib(6,:).' ]);
        A(:,ii,i) = pinv(F)*F_ref_col;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Pinv
        F_calib = C_Pinv(:,:,ii)*S(:,2:7).';
        R_Pinv(:,ii,i) = R_sqr2(F_ref.',F_calib);
        
        F = blkdiag([F_calib(1,:).' ], [F_calib(2,:).' ], [F_calib(3,:).' ] ...
            ,[F_calib(4,:).' ], [F_calib(5,:).' ], [F_calib(6,:).' ]);
        A_Pinv(:,ii,i) = pinv(F)*F_ref_col;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Tot
        F_calib = C_Tot(:,:,ii)*S(:,2:7).';
        R_Tot(:,ii,i) = R_sqr2(F_ref.',F_calib);
        
        F = blkdiag([F_calib(1,:).' ], [F_calib(2,:).' ], [F_calib(3,:).' ] ...
            ,[F_calib(4,:).' ], [F_calib(5,:).' ], [F_calib(6,:).' ]);
        A_Tot(:,ii,i) = pinv(F)*F_ref_col;
        
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Variances of matrices

C_mean = sum(C,3)/s_sets;
C_Pinv_mean = sum(C_Pinv,3)/s_sets;
C_Tot_mean = sum(C_Tot,3)/s_sets;

% Standard Deviations
var_C = sqrt(sum((C-repmat(C_mean,1,1,s_sets)).^2,3)/s_sets);
var_C_Pinv = sqrt(sum((C_Pinv-repmat(C_Pinv_mean,1,1,s_sets)).^2,3)/s_sets);
var_C_Tot = sqrt(sum((C_Tot-repmat(C_Tot_mean,1,1,s_sets)).^2,3)/s_sets);

perc_var_opt = var_C./C_mean*100;
perc_var_Pinv = var_C_Pinv./C_Pinv_mean*100;
perc_var_Tot = var_C_Tot./C_Tot_mean*100;


m = max(abs(C_ref),[],2);
C_ref_scal = C_ref./repmat(m,1,6);

for i = 1:s_sets
m = max(abs(C(:,:,i)),[],2);
C_scal(:,:,i) = C(:,:,i)./repmat(m,1,6);
Err(1,i) = sqrt(immse(abs(C_ref_scal),abs(C_scal(:,:,i))));
m = max(abs(C_Pinv(:,:,i)),[],2);
C_Pinv_scal(:,:,i) = C_Pinv(:,:,i)./repmat(m,1,6);
Err(2,i) = sqrt(immse(abs(C_ref_scal),abs(C_Pinv_scal(:,:,i))));
m = max(abs(C_Tot(:,:,i)),[],2);
C_Tot_scal(:,:,i) = C_Tot(:,:,i)./repmat(m,1,6);
Err(3,i) = sqrt(immse(abs(C_ref_scal),abs(C_Tot_scal(:,:,i))));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Best Matrix
R_best = sum(sum(R,3),1);
R_best = R_best/(6*s_sets);

col = find(R_best == max(R_best));

C_final = C(:,:,col);
R_final = R(:,col,:);

S_sample = inv(C_final);

limits = [300;300;300;25; 25; 25];
res = ones(6,1);


sigmaV = Sigma(1:6).';

for i = 1:s_sets

    S = load(sets(i,:));
    S(:,2:13) = filter(b,a,S(:,2:13));
     S(:,2:13) = S(:,2:13)-repmat(off_free(1,:),length(S),1);
    F_ref = T*S(:,8:13).';
    F_calib = C_final*S(:,2:7).';
% %     [n_in(:,:,i),Inliers,Pop,Spread] = distance_inliers_normal(F_ref,S_sample,S,sigmaV,limits,res);
% figure()
% for ii = 1:6
% subplot(3,2,ii)
% plot(F_ref(ii,:),F_calib(ii,:),'.')
% hold on
% plot(F_ref(ii,:),F_ref(ii,:),'.r')
% axis equal
% end
   
end

figure()
imagesc(abs(C_scal(:,:,col)))
colormap('jet')

Sens = load ('sens_Fz_2Kg.txt');
Sens(:,2:13) = filter(b,a,Sens(:,2:13));
 Sens(:,2:13) = Sens(:,2:13)-repmat(off_free(1,:),length(Sens),1);
F_ref = T*Sens(:,8:13).';
F_calib = C_final*Sens(:,2:7).';

R_sqr2(F_ref.',F_calib);


figure()
for i = 1:6
    subplot(3,2,i)
    hold on
    plot(Sens(:,1),F_ref(i,:),'r')
    plot(Sens(:,1),F_calib(i,:),'b')
end


