%%�˳�����������DualMA˫����(���߷�����)���Իز�
%%ԭʼ��������Ϊdata����TB�л�ȡ���ݣ�ʱ��Ϊ�����ֳ�����һ�У�ʣ�·ֱ���
%%1���̼� 2��߼� 3��ͼ� 4���̼� 5�ɽ��� 6�ֲ���
%%����ΪCu888

%% �������ָ��
[data,date]=xlsread('1.xls');%��ȡ�������ݺ���ֵ����
close=data(:,4);%��ȡ���̼�
high=data(:,2);%��ȡ��߼�
open=data(:,1);%��ȡ���̼�
low=data(:,3);%��ȡ��ͼ�
%�������
margin_rate=0.1; %���屣֤����
m=length(close);
no_risk_rate=0.02;
shortPeriod=5;%�������̼۶��ڣ����٣�ƽ���ƶ�ƽ�����㳤��
longPeriod=20;%�������̼۳��ڣ����٣�ƽ���ƶ�ƽ�����㳤��
fee=0.0003; %������
weight=5;  %��Լ�Ķ���
%����ռλ������߳�������Ч��
shortline=zeros(length(close),1);
longline=zeros(length(close),1);
%��ѭ�����������ָ��
for i=1:longPeriod
    shortline(i)=close(i);%��ʼ��shortline��һֵ
    longline(i)=close(i);%��ʼ��longline��һ��ֵ
end
%����˫����ֵ
M=0;N=0;
for t=longPeriod:length(close)
    %������ھ���
    M=0;N=0;
    for i=1:shortPeriod
        M=close(t-i+1)+M;
    end
    shortline(t)=M/shortPeriod;
    
    %���㳤�ھ���
    for j=1:longPeriod
        N=close(t-j+1)+N;
    end
    longline(t)=N/longPeriod;

end
%��K��ͼ
figure(1);
set(gcf,'units','normalized','position',[0 0 1 1]);
time=datenum(date);
candle(high,low,close,open,'b',date,'XXXX/YY/ZZ');
% plot(time,close,'b');
datetick('x',29);
xlabel('Date');
ylabel('Close Price');
title('Time Series of Stock');
hold on;
plot(time,longline,'r');
datetick('x',29);
hold on;
plot(time,shortline,'g');
datetick('x',29);
grid on;
legend('close','up','down','longline','shortline')


%% ���Իز����
%%һ����򵥵Ĳ��ԣ�1��shortline�ϴ�longline ����  2��longline�´�shortline ����
%��ʼ�ʽ�1000000Ԫ
initial=1000000;
%�����λ��1��ʾ��ͷ��0��ʾ�ղ�, -1��ʾ��ͷ
pos=zeros(length(close),1);
%������������ 
Long=zeros(length(close),1);
Short=zeros(length(close),1);
Timepoint=zeros(length(close),1);
Account=zeros(length(close),1);
Total=zeros(length(close),1);
Fee=zeros(length(close),1);
figure(2);
set(gcf,'units','normalized','position',[0 0 1 1]);
plot(time,close,'r');
datetick('x',29);
xlabel('Date');
ylabel('Close Price');
title('Time Series of Stock');
grid on;
hold on;
%���Լ���
for t=2:length(close)
    %���������ź�
    signalBuy= shortline(t-1)>longline(t-1); 
    signalSell= shortline(t-1)<longline(t-1);
    %����������ź���Ϊ��֣�������
    if (signalBuy==1 && pos(t-1)==0)
        pos(t)=1;
        text(time(t),close(t),'\leftarrow��');
        plot(time(t),close(t),'go');
        datetick('x',29);
        Timepoint(t-1)=time(t);
        
    %����������ź���Ϊ�ղ֣���ƽ�ֺ�����
    elseif (signalBuy==1 && pos(t-1)<0)
        pos(t)=1;
        text(time(t),close(t),'\leftarrowƽ��');
        plot(time(t),close(t),'bo');
        datetick('x',29);
        Timepoint(t-1)=time(t);
        datestr(Timepoint(t),29);
        
     %����������ź���Ϊ��֣�������
    elseif (signalSell==1 && pos(t-1)==0)
        pos(t)=-1;
        text(time(t),close(t),'\leftarrow��');
        plot(time(t),close(t),'ro');
        datetick('x',29);
        Timepoint(t-1)=time(t);
        
      %����������ź���Ϊ��֣���ƽ�ֺ�����
    elseif (signalSell==1 && pos(t-1)>0)
        pos(t)=-1;
        text(time(t),close(t),'\leftarrowƽ��');
        plot(time(t),close(t),'yo');
        datetick('x',29);
        Timepoint(t-1)=time(t);
        
        %�������һ�ɲ������κβ���
    else    pos(t)=pos(t-1);
        % ���ƽ���в�
    end
        if t==length(close)
           text(time(t),close(t),'\leftarrowȫ��ƽ��');
           plot(time(t),close(t),'yo');
           datetick('x',29);
           Timepoint(t-1)=time(t);
        end
end
%�����ʽ�仯��������׳ɱ�����Ϊ����ǧ��֮��
Account(1)=initial; %�ֽ���
Long(1)=0;        %��ͷ��ֵ
Short(1)=0;       %��ͷ��ֵ
Total(1)=initial;
for t=2:length(close)
    %1.�����û�������ź�
    if pos(t)==0 && pos(t-1)==0
        Account(t)=Account(t-1);
        Long(t)=Long(t-1);
        Short(t)=Short(t-1);
        continue;
    end
    
    %2.����
    if pos(t)==1 && pos(t-1)==0
        Account(t)=Account(t-1)-open(t)*weight*(1+fee);
        Long(t)=Long(t-1)+weight*open(t);
        Short(t)=Short(t-1);
        Fee(t)=open(t)*weight*fee;
        continue;
    end
    
    %3.����
    if pos(t)==-1 && pos(t-1)==0
        Account(t)=Account(t-1)+open(t)*weight*(1-fee);
        Long(t)=Long(t-1);
        Short(t)=Short(t-1)+weight*open(t);
        Fee(t)=open(t)*weight*fee;
        continue;
    end    
    
    %4.�ֶ�ֲ����������ź�
    if pos(t)==1 && pos(t-1)==1
        Long(t)=Long(t-1)+weight*open(t)-weight*open(t-1);
        Short(t)=Short(t-1);
        Account(t)=Account(t-1);
        continue;
    end

    %5.�ֶ�ַ�ת
    if pos(t)==-1 && pos(t-1)==1
        Long(t)=Long(t-1)-weight*open(t-1);
        Short(t)=Short(t-1)+weight*open(t);
        Account(t)=Account(t-1)+weight*open(t)*(1-fee)*2;
        Fee(t)=open(t)*weight*fee*2;
        continue;
    end    
    
    
    %6.�ֶ��ƽ��
    if pos(t)==0 && pos(t-1)==1
        Long(t)=Long(t-1)-weight*open(t-1);
        Short(t)=Short(t-1);
        Account(t)=Account(t-1)+weight*open(t)*(1-fee);
        Fee(t)=open(t)*weight*fee;
        continue;
    end    
    
    
    %7.�ֿղֲ����������ź�
    if pos(t)==-1 && pos(t-1)==-1
        Long(t)=Long(t-1);
        Short(t)=Short(t-1)+weight*open(t)-weight*open(t-1);
        Account(t)=Account(t-1);
        continue;
    end    
    
    %8.�ֿղַ�ת
    if pos(t)==1 && pos(t-1)==-1
        Long(t)=Long(t-1)+weight*open(t);
        Short(t)=Short(t-1)-weight*open(t-1);
        Account(t)=Account(t-1)-weight*open(t)*(1+fee)*2;
        Fee(t)=open(t)*weight*fee*2;
        continue;
    end        
    
    %9.�ֿղ�ƽ��
    if pos(t)==0 && pos(t-1)==-1
        Long(t)=Long(t-1);
        Short(t)=Short(t-1)-weight*open(t-1);
        Account(t)=Account(t-1)-weight*open(t)*(1+fee);
        Fee(t)=open(t)*weight*fee;
        continue;
    end    
end
% �������ʱ��ƽ��
   if pos(m)==0
       
   elseif pos(m)>0
          Long(m+1)=Long(m)-weight*open(m);
          Short(m+1)=Short(m);
          Account(m+1)=Account(m)+weight*open(m)*(1-fee);
          Fee(m+1)=open(m)*weight*fee;
   elseif pos(m)<0
          Long(m+1)=Long(m);
          Short(m+1)=Short(m)-weight*open(m);
          Account(m+1)=Account(m)-weight*open(m)*(1+fee);
          Fee(m+1)=open(m)*weight*fee;  
          end



           
           
           
Total=Account+Long-Short-initial;
%�ҳ����н���ʱ��
Timepoint_plus=Timepoint;
Timepoint(find(Timepoint(:,1)==0),:)=[]; %ɾ��0ֵ
TimePoint=datestr(Timepoint,29);
%% ģ�����ۣ������ʣ����ձ��ʣ����س���һЩ��ָ�꣬����ֻ���ʽ�仯����
%�����ʽ�仯����
Total_plus=Total;
Total(m)=Total(m+1);
Total(m+1)=[];
hold off;
figure(3);
set(gcf,'units','normalized','position',[0 0 1 1]);
plot(time,Total,'r');
datetick('x',29);
xlabel('Date');
ylabel('Your Money');
title('The Return of Stock');
grid on

%�����ֲ����
figure(4);
set(gcf,'units','normalized','position',[0 0 1 1]);
plot(time,pos,'o');
datetick('x',29);
xlabel('Date');
ylabel('The state of your account');
grid on

%����������
[m,~]=size(Total);
for i=1:m
yield(i)=Total(i)/initial;
end
Yield_rate=yield(m);

%���㾻����
net_profit=Total(m);


%���㽻�׳ɱ�

trade_cost=sum(Fee);


%��������
[number_of_trade,~]=size(Timepoint);


%�����껯������

Yield_rate_year=Yield_rate/number_of_trade*365;


%% ����ӯ��
profit=zeros(length(close),1); %��ʼ���������
holding=zeros(length(close),1);  %��ʼ���ֲ־���
price_end=0; %��ʼ�����ռ۸�
price_start=0;  %��ʼ������۸�
price=zeros(length(close),2);  %���׼۸����
gain=0;  %��ʼ��ӯ������
loss=0;  %��ʼ���������
equal=0; %��ʼ����ȴ���

%����ӯ��
for i=2:m
    if pos(i)==pos(i-1)
        holding(i)=1;
    elseif pos(i)<pos(i-1)
       price_end=open(i);
       profit(i)=(price_end-price_start)*weight-(price_end+price_start)*weight*fee;
       price(i,1)=price_start;
       price(i,2)=price_end;
       price_start=price_end;
    elseif pos(i)>pos(i-1)
       price_end=open(i);
       profit(i)=-(price_end-price_start)*weight-(price_end+price_start)*weight*fee;
       price(i,1)=price_start;
       price(i,2)=price_end;
       price_start=price_end;
    end
end

%�������ƽ��
if pos(m)==0
    
elseif pos(m)>0
       profit(m+1)=(open(m)-price_end)*weight-(open(m)+price_end)*weight*fee;
elseif pos(m)<0
       profit(m+1)=-(open(m)-price_end)*weight-(open(m)+price_end)*weight*fee;
end

%����ӯ������
for i=1:m+1
    if profit(i)>0
       gain=gain+1;
    elseif profit(i)<0
        loss=loss+1;
    end    
end

%�������ƽ��
profit(find(profit(:,1)==0),:)=[];
%�������һ������
if profit(1)>0
    gain=gain-1;
else
    loss=loss-1;
end
    
profit(1)=[];
price(find(price(:,1)==0),:)=[];
price(number_of_trade,1)=price_end;
price(number_of_trade,2)=open(m);
profit';
equal=number_of_trade-(gain+loss);

%�������ձ���
day_rate=zeros(m-1,1);
for i=2:m
    day_rate(i-1)=(Total(i)-Total(i-1))/(Total(i-1)+initial);
end
net_day_rate=(day_rate-no_risk_rate/365);
Sharp_rate=sqrt(365)*mean(net_day_rate)/sqrt(var(net_day_rate));


    
%�������س�
max_total=zeros(m,1);
max_total(1)=Total(1);
for i=2:m
    if Total(i)>max_total(i-1)
        max_total(i)=Total(i);
    else
        max_total(i)=max_total(i-1);
    end
end
max_total;
difff=max_total-Total;
[maximum_drawdown,p]=max(difff);
maximum_drawdown;
maximum_drawdown_time=datestr(time(p-1),29);

%�������ʹ���ʽ�=������̼ۼ���ĳֱֲ�֤��
max_use=max(close)*weight*margin_rate;
    






