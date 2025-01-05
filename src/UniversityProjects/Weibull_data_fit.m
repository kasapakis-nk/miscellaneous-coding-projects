% Άσκηση exe_2_2022
clear
clf

% Αναγνώριση ΑΕΜ
AEM=222222222;
if mod(AEM,2)==0
    disp("Το ΑΕΜ είναι άρτιος αριθμός.")
else
    disp("Το ΑΕΜ είναι περιττός αριθμός.")
end

% Δημιουργία πίνακα δεδομένων προς επεξεργασία και μεταβλητές.
W=xlsread('Weibull data.xlsx','station_1');
W(:,6)=W(:,6).*0.51;
year_min=min(W(:,1));
year_max=max(W(:,1));
A=year_min:1:year_max-3;
year1=A(randi(numel(A)));
YeCrit=transpose(year1:year1+5);
Sel_Per=[];

for i=1:4
    c1=ismember(W(:,1),YeCrit(i,1),'rows');
    Sel_Per=[Sel_Per ; W(c1,:)];
end

% Επιλέγω να διώξω τα 0 δεδομένα ταχύτητας για τρεις λόγους:
% Υπολογιστικά, δεν επιτρέπουν στη histfit για Weibull να λειτουργήσει,
% ακόμα και με 0+eps παρουσιάζει προβλήματα.
% Λογικά, γιατί το να μετρά ο σταθμός μηδενική ταχύτητα ανέμου δεν είναι
% δυνατό και μάλιστα με τέτοια συχνότητα. Είτε τα δεδομένα είναι λανθασμένα
% είτε τα όργανα δεν έχουν καλή διακριτική ικανότητα για να μετρούν
% ταχύτητες κοντά στο 0 αλλά μη μηδενικές και πρόκειται για
% στρογγυλοποιημένα δεδομένα προς το 0.
% Μαθηματικά, γιατί καθώς το 0 είναι πάντα το στοιχείο με το μεγαλύτερο
% count, δεν έχω εξαρχής ελπίδα τα στοιχεία μου να αντιπροσωπεύονται απο
% κατανομή Weibull. Θα έπρεπε να αναζητήσω διαφορετική κατανομή για να
% περιγράψω τα δεδομένα.
S_P=Sel_Per(:,6);
S_P(S_P==0)=[];

% Καθορισμός παραμέτρων κατανομής για να γίνει fitting.
U=unique(S_P);
NU=length(U);

% Δίνω μέγεθος στους πίνακες της for για να κερδίσω υπολογιστικό χρόνο.
N=zeros(1,NU);
P=zeros(1,NU);
Sf=zeros(1,NU);
f=0;

for i=1:NU
    N(i)=length(S_P(S_P==U(i)));
    P(i)=N(i)./length(S_P);
    f=P(i) + f;
    Sf(i)=f;
end

% Διόρθωση bug όπου σε ορισμένες περιπτώσεις δεν εμφανίζει graph.
Sf(end)=1-0.0001;

% Fitting ΕΕΤ και προσδιορισμός παραμέτρων Weibull.
pms=polyfit(log(U),log(-log(1-Sf))',1);
b=pms(2);
k=pms(1);
c=exp(-b/k);
fW=(k/c).*(U/c).^(k-1).*exp(-(U/c).^k);

% Δημιουργία graph + histogram.
axes('Position',[0 0 1 1],'Visible','off');
axes('Position',[.24 0.12 .7 .8])
histogram(S_P,ceil(max(S_P)),'Normalization','probability','FaceColor','red');
hold on
plot(U,fW,'LineWidth',2,'Color','k')
hold off
set(gca,'Color','y');
title("Περίοδος Μετρήσεων: " + YeCrit(1) + " - " + YeCrit(6) + newline + "Αριθμός Μετρήσεων: " + length(S_P));
xlabel('Wind speed (m/s)');
ylabel('Probability');

% Δημιουργία ζητούμενων strings για προβολή .
str1="Νικόλαος" + newline + "Κασαπάκης";
str3="k=" + k + newline + "c=" + c;
annotation('textbox',[0 0.18 0.1 0.1],'String',str1);
annotation('textbox',[0.75 0.8 0.1 0.1],'String',str3);