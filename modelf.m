% define function which we execute in matlab command window
function par=modelf;

global Rv
       Rv=461.51;
%global StatH
%       StatH=1120;

dbusername='meteo';
dbpass='m3t30d4t4';
dbname='dev_suada_4';
%-------------------------------------------------INPUT---------------------------------------------------------------------


   oioi = strcat('~/work/suada/model2.dat')
   fid=fopen(oioi);
   prec = fscanf(fid, '%f', [1 1]);
   fclose(fid);


   aiai = strcat('~/work/suada/model.dat')
   fid=fopen(aiai);
   model = fscanf(fid, '%d %d %4d-%2d-%2d %2d:%2d:%2d %f %f %f %f %f', [13 100]);
   fclose(fid);

   model(14,:) = datenum(model(3,:), model(4,:), model(5,:), model(6,:), model(7,:), model(8,:));

   model(15,:) = model(11,:) * 100; % Pressure from hPa in Pa
   model(16,:) = model(12,:) / 1000; % WV mixing ratio from kg/kg in g/kg


   [s1,s2]= size(model)

   %model(1,:)=stationid
   %model(2,:)=sourceid	
   %model(3,:)=year					
   %model(4,:)=month					
   %model(5,:)=day of the month			
   %model(6,:)=hour					
   %model(7,:)=minute 				
   %model(8,:)=second
   %model(9,:)=height [m]				
   %model(10,:)=temperature [K]
   %model(11,:)=pressure [hPa]			
   %model(12,:)=mixingratio [kg/kg]
   %model(13,:)=level
   %model(14,:)=datetime matlab format
   %model(15,:)=pressure [Pa]			
   %model(16,:)=mixingratio [g/kg]

%-------------------------------------------------IWV CALCULATIONS---------------------------------------------------------------------

    for m=1:s2
        pr=0;
        nx=0;
        height=0;
        % k is always l + 1 (this is the next level index)
        k = m+1;
        if k<=44   
        % Level                 
                q1 = ((model(16,m)/(model(16,m)+1))); %specific humidity from mixing ratio
                q2 = ((model(16,k)/(model(16,k)+1))); %specific humidity from mixing ratio

                e(m) = (model(15,m)*q1)/(0.622+(0.378*q1)); %water vapour partial pressure
                      ro(m) = e(m)/(Rv*(model(10,m))); %density of water vapour

                e(k) = (model(15,k)*q2)/(0.622+(0.378*q2)); %water vapour partial pressure
                      ro(k) = e(k)/(Rv*(model(10,k))); %density of water vapour

                pr=model(9,m);
                nx=model(9,k);
                height = abs(pr - nx); %height difference
                IWV(m) = ((ro(m)+ro(k))/2)*height;    % calculate IWV using TRAPZ

        end;
        continue;
    end;
       
        stat = model(1,1);
	source = model(2,1);
	year = model(3,1);
	month = model(4,1);
	day = model(5,1);
	hour = model(6,1);
	minute = model(7,1);
	second = model(8,1);
	iwv = sum(IWV(:));
    

    maxh = model(9,1);
    s = 1;
    for m=1:(s2-1)
        if model(9,m)>=500
            IWV500(m)=IWV(m);
        end;
        if IWV(m)>IWV(s)
            maxh = (model(9,m)+model(9,m+1))/2;
            s = m;
        end;
    end;

    iwv500 = sum(IWV500(:));
        
    H=2.11;
    a=1.02;

    iwv_swiss=a*iwv*exp(((model(9,1)/1000)-0.5 )/H)
    

    pe=prec/iwv*100 %pe by bordi
    
    
%-------------------------------------------------OUTPUT---------------------------------------------------------------------

   ready = strcat('~/work/suada/fin.dat')
   fid=fopen(ready,'w');
   fprintf(fid,'%d %d %d %d %d %d %d %d %f %f %f %f %f \n', stat, source, year, month, day, hour, minute, second, iwv, iwv500, iwv_swiss, maxh, pe);
   fclose(fid);

   clear all;
