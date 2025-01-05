% Ασκήσεις exe.2 - B
clear
clf

% Υπολογισμός αναλογίας σωματιδίων
EP=sum(double('KASAPAKIS'));
ON=sum(double('NIKOS'));

if EP>ON
    ratio=[ON/EP];
else
    ratio=[EP/ON];
end

N=[800 15000 150000];
x=0:1:150000;

% Προσομοίωση
for i=1:3
    y2=N(i)/2*(1+exp(-2*x./N(i)));
    N1=[N(i) ; N(i)/(1+1/ratio)];
    for j=1:2
        for t=1:150000
            c=randi(N(i));
            if c>N1(j,t) 
                N1(j,t+1)=N1(j,t)+1;
            else
                N1(j,t+1)=N1(j,t)-1;
            end
        end
    end
    p(i,:)=N1(1,:);
    th(i,:)=y2;
    pr(i,:)=N1(2,:);
end

% Plots
for i=1:3
    subplot(3,1,i)
    hold on
    plot(x,p(i,:),'LineWidth',1,'Color','k');
    plot(x,pr(i,:),'LineWidth',1,'Color','g');
    plot(x,th(i,:),'LineWidth',2,'Color','r');
    legend('Simulation1','Simulation2','Theoretical','Location','northeast','Color',[0.45,0.45,0.45]);
    set(gca,'Color','y');
    axis([0 150000 0.3*N(i) N(i)])
    xlabel('Time (s)')
    ylabel('Na(t)')
    grid on
    hold off
end