% Άσκηση exe_1_2022
clear

% Μεταβλητές και διάβασμα αρχείου Exel.
Wind_Data=xlsread('Wind data.xlsx');
yr_kn_dir=[Wind_Data(:,[1,2,5,6])];

% Τυχαία Επιλογή Έτους.
year1=randi(25) + 1966;
YeCrit=transpose(year1:year1+5);

% Δημιουργία πίνακα δεδομένων συγκεκριμένης περιόδου ετών προς επεξεργασία.
Sel_Per=[];
for i=1:6
    c1=ismember(yr_kn_dir(:,1),YeCrit(i,1),'rows');
    Sel_Per=[Sel_Per ; yr_kn_dir(c1,:)];
end

% Καθορισμός επικρατούσας διεύθυνσης ανέμου καλοκαιρινών μηνών.
yr_mo_dir=[Sel_Per(:,[1,2,4])];
MoCrit=[6;7;8];
Ann_summ_dir=[];
sect=[0 11.25:22.5:348.75 360];

for i=1:3
    tick=ismember(yr_mo_dir(:,2),MoCrit(i,1),'rows');
    Ann_summ_dir=[Ann_summ_dir ; yr_mo_dir(tick,:)];
end

prev_per_st=zeros(6,1) + 348.75;
prev_per_end=zeros(6,1) + 11.25;

for i=1:6
    c2=ismember(Ann_summ_dir(:,1),YeCrit(i,1),'rows');
    Ann_dir=Ann_summ_dir(c2,3);
    temp_dir=Ann_dir(Ann_dir>=sect(1) & Ann_dir<sect(2) | Ann_dir>=sect(16) & Ann_dir<=sect(17));
    n=numel(temp_dir);
    flag=1;
    for j=2:15
        temp_dir=Ann_dir(Ann_dir>=sect(j) & Ann_dir<sect(j+1));
        if numel(temp_dir)>n
            n=numel(temp_dir);
            flag=j;
        end
    end
    if flag~=1
        prev_per_st(i)=sect(flag);
        prev_per_end(i)=sect(flag+1);
    end
end

% Δημιουργία strings για προβολή στο ροδόγραμμα.
disp_period="Περίοδος Μετρήσεων: " + YeCrit(1) + " - " + YeCrit(6);
disp_name="Κασαπάκης Νικόλαος" + newline + "pc: " + getenv('HOSTNAME');
disp_date="Date:     " + newline + "" + date;
for i=1:6
    pst(i)="Επικρατούσα διεύθυνση καλοκαιριού " + YeCrit(i) + ": " + prev_per_st(i) + " - " + prev_per_end(i) + " μοίρες.";
end
prev_str=" " + pst(1) + " " + newline + " " + pst(2) + " " + newline + " " + pst(3) + " " + newline + " " + pst(4) + " " + newline + " " + pst(5) + " " + newline + " " + pst(6) + " ";

% Δημιουργία πινάκων δεδομένων για input στη WindRose.
Spd_SI=Sel_Per(:,3).*0.51;
Dir=Sel_Per(:,4);

% Δημιουργία Ροδογράμματος.
Options={'anglenorth',0,'angleeast',90,'ndirections',8,'radialgridnumber',16,'labels',{disp_period,'','',disp_name,prev_str,disp_date,'',''},'freqlabelangle',30,'scalefactor',0.75};
[figure_handle, count, speeds, directions, Table] = WindRose(Dir, Spd_SI,Options);
