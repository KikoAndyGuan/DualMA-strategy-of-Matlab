%%此程序用来进行DualMA双均线(日线非日内)策略回测
%%原始数据命名为data，从TB中获取数据，时间为单独分出来的一列，剩下分别是
%%1开盘价 2最高价 3最低价 4收盘价 5成交量 6持仓量
%%样本为Cu888

%% 计算相关指标
[data,date]=xlsread('1.xls');%提取日期数据和数值数据
close=data(:,4);%提取收盘价
high=data(:,2);%提取最高价
open=data(:,1);%提取开盘价
low=data(:,3);%提取最低价
%定义参数
margin_rate=0.1; %定义保证金率
m=length(close);
no_risk_rate=0.02;
shortPeriod=5;%定义收盘价短期（快速）平滑移动平均计算长度
longPeriod=20;%定义收盘价长期（慢速）平滑移动平均计算长度
fee=0.0003; %手续费
weight=5;  %合约的吨数
%建立占位矩阵，提高程序运行效率
shortline=zeros(length(close),1);
longline=zeros(length(close),1);
%用循环语句计算各个指标
for i=1:longPeriod
    shortline(i)=close(i);%初始化shortline第一值
    longline(i)=close(i);%初始化longline第一个值
end
%计算双均线值
M=0;N=0;
for t=longPeriod:length(close)
    %计算短期均线
    M=0;N=0;
    for i=1:shortPeriod
        M=close(t-i+1)+M;
    end
    shortline(t)=M/shortPeriod;
    
    %计算长期均线
    for j=1:longPeriod
        N=close(t-j+1)+N;
    end
    longline(t)=N/longPeriod;

end
%画K线图
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


%% 策略回测仿真
%%一个最简单的策略：1）shortline上穿longline 做多  2）longline下穿shortline 做空
%初始资金1000000元
initial=1000000;
%定义仓位：1表示多头，0表示空仓, -1表示空头
pos=zeros(length(close),1);
%定义收益序列 
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
%策略计算
for t=2:length(close)
    %定义买卖信号
    signalBuy= shortline(t-1)>longline(t-1); 
    signalSell= shortline(t-1)<longline(t-1);
    %如果是买入信号且为零仓，则做多
    if (signalBuy==1 && pos(t-1)==0)
        pos(t)=1;
        text(time(t),close(t),'\leftarrow多');
        plot(time(t),close(t),'go');
        datetick('x',29);
        Timepoint(t-1)=time(t);
        
    %如果是买入信号且为空仓，则平仓后做多
    elseif (signalBuy==1 && pos(t-1)<0)
        pos(t)=1;
        text(time(t),close(t),'\leftarrow平多');
        plot(time(t),close(t),'bo');
        datetick('x',29);
        Timepoint(t-1)=time(t);
        datestr(Timepoint(t),29);
        
     %如果是卖出信号且为零仓，则做空
    elseif (signalSell==1 && pos(t-1)==0)
        pos(t)=-1;
        text(time(t),close(t),'\leftarrow空');
        plot(time(t),close(t),'ro');
        datetick('x',29);
        Timepoint(t-1)=time(t);
        
      %如果是卖出信号且为多仓，则平仓后做空
    elseif (signalSell==1 && pos(t-1)>0)
        pos(t)=-1;
        text(time(t),close(t),'\leftarrow平空');
        plot(time(t),close(t),'yo');
        datetick('x',29);
        Timepoint(t-1)=time(t);
        
        %其它情况一律不进行任何操作
    else    pos(t)=pos(t-1);
        % 最后平所有仓
    end
        if t==length(close)
           text(time(t),close(t),'\leftarrow全部平仓');
           plot(time(t),close(t),'yo');
           datetick('x',29);
           Timepoint(t-1)=time(t);
        end
end
%计算资金变化情况，交易成本假设为单边千分之三
Account(1)=initial; %现金金额
Long(1)=0;        %多头价值
Short(1)=0;       %空头价值
Total(1)=initial;
for t=2:length(close)
    %1.零仓且没有买入信号
    if pos(t)==0 && pos(t-1)==0
        Account(t)=Account(t-1);
        Long(t)=Long(t-1);
        Short(t)=Short(t-1);
        continue;
    end
    
    %2.做多
    if pos(t)==1 && pos(t-1)==0
        Account(t)=Account(t-1)-open(t)*weight*(1+fee);
        Long(t)=Long(t-1)+weight*open(t);
        Short(t)=Short(t-1);
        Fee(t)=open(t)*weight*fee;
        continue;
    end
    
    %3.做空
    if pos(t)==-1 && pos(t-1)==0
        Account(t)=Account(t-1)+open(t)*weight*(1-fee);
        Long(t)=Long(t-1);
        Short(t)=Short(t-1)+weight*open(t);
        Fee(t)=open(t)*weight*fee;
        continue;
    end    
    
    %4.持多仓并且无卖出信号
    if pos(t)==1 && pos(t-1)==1
        Long(t)=Long(t-1)+weight*open(t)-weight*open(t-1);
        Short(t)=Short(t-1);
        Account(t)=Account(t-1);
        continue;
    end

    %5.持多仓反转
    if pos(t)==-1 && pos(t-1)==1
        Long(t)=Long(t-1)-weight*open(t-1);
        Short(t)=Short(t-1)+weight*open(t);
        Account(t)=Account(t-1)+weight*open(t)*(1-fee)*2;
        Fee(t)=open(t)*weight*fee*2;
        continue;
    end    
    
    
    %6.持多仓平仓
    if pos(t)==0 && pos(t-1)==1
        Long(t)=Long(t-1)-weight*open(t-1);
        Short(t)=Short(t-1);
        Account(t)=Account(t-1)+weight*open(t)*(1-fee);
        Fee(t)=open(t)*weight*fee;
        continue;
    end    
    
    
    %7.持空仓并且无卖出信号
    if pos(t)==-1 && pos(t-1)==-1
        Long(t)=Long(t-1);
        Short(t)=Short(t-1)+weight*open(t)-weight*open(t-1);
        Account(t)=Account(t-1);
        continue;
    end    
    
    %8.持空仓反转
    if pos(t)==1 && pos(t-1)==-1
        Long(t)=Long(t-1)+weight*open(t);
        Short(t)=Short(t-1)-weight*open(t-1);
        Account(t)=Account(t-1)-weight*open(t)*(1+fee)*2;
        Fee(t)=open(t)*weight*fee*2;
        continue;
    end        
    
    %9.持空仓平仓
    if pos(t)==0 && pos(t-1)==-1
        Long(t)=Long(t-1);
        Short(t)=Short(t-1)-weight*open(t-1);
        Account(t)=Account(t-1)-weight*open(t)*(1+fee);
        Fee(t)=open(t)*weight*fee;
        continue;
    end    
end
% 处理最后时刻平仓
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
%找出所有交易时间
Timepoint_plus=Timepoint;
Timepoint(find(Timepoint(:,1)==0),:)=[]; %删除0值
TimePoint=datestr(Timepoint,29);
%% 模型评价：收益率，夏普比率，最大回撤等一些列指标，这里只画资金变化曲线
%画出资金变化曲线
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

%画出持仓情况
figure(4);
set(gcf,'units','normalized','position',[0 0 1 1]);
plot(time,pos,'o');
datetick('x',29);
xlabel('Date');
ylabel('The state of your account');
grid on

%计算收益率
[m,~]=size(Total);
for i=1:m
yield(i)=Total(i)/initial;
end
Yield_rate=yield(m);

%计算净利润
net_profit=Total(m);


%计算交易成本

trade_cost=sum(Fee);


%交易手数
[number_of_trade,~]=size(Timepoint);


%计算年化收益率

Yield_rate_year=Yield_rate/number_of_trade*365;


%% 计算盈亏
profit=zeros(length(close),1); %初始化利润矩阵
holding=zeros(length(close),1);  %初始化持仓矩阵
price_end=0; %初始化最终价格
price_start=0;  %初始化最初价格
price=zeros(length(close),2);  %交易价格矩阵
gain=0;  %初始化盈利次数
loss=0;  %初始化亏损次数
equal=0; %初始化相等次数

%处理盈亏
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

%处理最后平仓
if pos(m)==0
    
elseif pos(m)>0
       profit(m+1)=(open(m)-price_end)*weight-(open(m)+price_end)*weight*fee;
elseif pos(m)<0
       profit(m+1)=-(open(m)-price_end)*weight-(open(m)+price_end)*weight*fee;
end

%计算盈利手数
for i=1:m+1
    if profit(i)>0
       gain=gain+1;
    elseif profit(i)<0
        loss=loss+1;
    end    
end

%处理最后平仓
profit(find(profit(:,1)==0),:)=[];
%修正最后一步数据
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

%计算夏普比率
day_rate=zeros(m-1,1);
for i=2:m
    day_rate(i-1)=(Total(i)-Total(i-1))/(Total(i-1)+initial);
end
net_day_rate=(day_rate-no_risk_rate/365);
Sharp_rate=sqrt(365)*mean(net_day_rate)/sqrt(var(net_day_rate));


    
%计算最大回撤
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

%计算最大使用资金=最大收盘价计算的持仓保证金
max_use=max(close)*weight*margin_rate;
    






