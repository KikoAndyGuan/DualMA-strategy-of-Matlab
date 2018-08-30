%% Andy Guan's Project for strategy studying


%% DualMA Strategy(˫���߲��ԡ�������)
% <include>DualMA2.m</include>


%% 
% ��һ��ͼ��������ͼ�Լ�˫���ߣ��ڶ���ͼ��ע������������������ͼ�ó�����ӯ����������ķ�ͼ��ʾ�ֲ����

DualMA2

%% ��Ҫ�ز����
% ������ & ���㾻���� & ���㽻�׳ɱ�
format short g
Yield_rate
net_profit
trade_cost
%%
% ���ձ���
Sharp_rate

%%
%�����껯������
Yield_rate_year

%%
% �������� & ӯ������ & ������� & ��ƽ���� 
number_of_trade
gain
loss
equal

%%
% ӯ������ & ƽ������
gain_rate=gain/number_of_trade
average_profit=vpa(net_profit/number_of_trade,5)

%% ���س� & ���س�����ʱ��
maximum_drawdown
maximum_drawdown_time

%% ���ʹ���ʽ� & ��Ч������ 
max_use
effective_yield=net_profit/max_use

%% ������ & ��������� & ������ձ�
Total_days=time(m)-time(1)+1
return_of_year=net_profit/Total_days*365
rate_of_return_and_risk=return_of_year/maximum_drawdown


%% ��������
% ���Գ������ڵ����ֵ����1��30
result=zeros(900,5);
for i=1:30
    for j=1:30
        if j>i
           [aa,bb,cc,dd,ee]=DualMA_function(i,j);
           result(30*(i-1)+j,1)=aa;
           result(30*(i-1)+j,2)=bb;
           result(30*(i-1)+j,3)=cc;
           result(30*(i-1)+j,4)=dd;
           result(30*(i-1)+j,5)=ee;
        else
           result(30*(i-1)+j,1)=i;
           result(30*(i-1)+j,2)=j;
        end
            
    end
end
result(isnan(result)) = 0;
myown1(result,30,30);
        
        
        
        
        
        

%% end
close all