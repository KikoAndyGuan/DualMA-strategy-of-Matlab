%% Andy Guan's Project for strategy studying


%% DualMA Strategy(双均线策略—非日内)
% <include>DualMA2.m</include>


%% 
% 第一幅图画出行情图以及双均线，第二幅图标注多空买卖情况，第三幅图得出最终盈亏结果，第四幅图表示持仓情况

DualMA2

%% 重要回测参数
% 收益率 & 计算净利润 & 计算交易成本
format short g
Yield_rate
net_profit
trade_cost
%%
% 夏普比率
Sharp_rate

%%
%计算年化收益率
Yield_rate_year

%%
% 交易手数 & 盈利次数 & 亏损次数 & 持平次数 
number_of_trade
gain
loss
equal

%%
% 盈利比例 & 平均利润
gain_rate=gain/number_of_trade
average_profit=vpa(net_profit/number_of_trade,5)

%% 最大回撤 & 最大回撤发生时间
maximum_drawdown
maximum_drawdown_time

%% 最大使用资金 & 有效收益率 
max_use
effective_yield=net_profit/max_use

%% 总天数 & 年度收益率 & 收益风险比
Total_days=time(m)-time(1)+1
return_of_year=net_profit/Total_days*365
rate_of_return_and_risk=return_of_year/maximum_drawdown


%% 参数分析
% 测试长短周期的最佳值：从1到30
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