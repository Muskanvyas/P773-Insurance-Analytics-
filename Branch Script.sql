create database branchdatadb;
use branchdatadb;
create table brokerage(
client_name varchar(100),
policy_number varchar(100),
policy_status varchar(50),
policy_start_date date,
policy_end_date date,
product_group varchar(50),
Account_Exe_ID int,
Exe_Name varchar(50),
branch_name varchar(50),
solution_group varchar(50),
income_class varchar(50),
Amount decimal(15,2) null,
income_due_date date,
revenue_transaction_type varchar(50),
renewal_status varchar(50),
lapse_reason varchar(100),
last_updated_date date
);
drop table brokerage;
select * from brokerage;

create table fees(
client_name varchar(50),
branch_name varchar(50),
solution_group varchar(70),
Account_Exe_ID int,
Account_Executive varchar(50),
income_class varchar(50),
Amount decimal(15,2),
income_due_date date,
revenue_transaction_type varchar(50)
);
select * from fees;

create table individual_Budgets(
Branch varchar(50),
Account_Exe_ID int,
Employee_Name varchar(50),
New_Role2 varchar(50),
New_Budget decimal(15,2),
Cross_sell_bugdet decimal(15,2),
Renewal_Budget decimal(15,2)
);
select * from individual_Budgets;

create table invoice(
invoice_number int,
invoice_date date,
revenue_transaction_type varchar(50),
branch_name varchar(50),
solution_group varchar(100),
Account_Exe_ID int,
Account_Executive varchar(50),
income_class varchar(50),
Client_Name varchar(50),
policy_number varchar(100),
Amount decimal(15,2),
income_due_date date
);
drop table invoice;
select * from invoice;

create table meeting(
Account_Exe_ID int,
Account_Executive varchar(50),
branch_name varchar(50),
global_attendees varchar(50),
meeting_date date
);
drop table meeting;
select * from meeting;

create table opportunity(
opportunity_name varchar(50),
opportunity_id varchar(50),
Account_Exe_Id int,
Account_Executive varchar(50),
premium_amount decimal(15,2),
revenue_amount decimal(15,2),
closing_date date,
stage varchar(50),
branch varchar(50),
specialty varchar(100),
product_group varchar(50),
product_sub_group varchar(50),
risk_details varchar(100)
);
select * from opportunity;
truncate opportunity;

#KPI-1
select Account_Executive,count(invoice_number) as No_of_Invoice from invoice group by Account_Executive order by No_of_Invoice desc;

#KPI-2
select year(meeting_date) as Year, count(meeting_date) as Meeting_Count from meeting group by year order by Meeting_Count desc;

#KPI-3.1 Cross Sell
select 
concat(format((select sum(Cross_sell_bugdet) from individual_budgets)/1000000,2),'M') as Target,
concat(format((select sum(Amount) from(select Amount as Amount from brokerage where income_class='Cross Sell'
union all
select Amount as Amount from fees where income_class='Cross Sell') as AchievedData)/1000000,2),'M') as Achieved,
concat(format((select sum(Amount) from invoice where income_class='Cross Sell')/1000000,2),'M') as Invoice;

#KPI-3.2 New
select 
concat(format((select sum(New_Budget) from individual_budgets)/1000000,2),'M') as Target,
concat(format((select sum(Amount) from(select Amount as Amount from brokerage where income_class='New'
union all
select Amount as Amount from fees where income_class='New') as AchievedData)/1000000,2),'M') as Achieved,
concat(format((select sum(Amount) from invoice where income_class='New')/1000000,2),'M') as Invoice;

#KPI-3.3 Renewal
select 
concat(format((select sum(Renewal_Budget) from individual_budgets)/1000000,2),'M') as Target,
concat(format((select sum(Amount) from(select Amount as Amount from brokerage where income_class='Renewal'
union all
select Amount as Amount from fees where income_class='Renewal') as AchievedData)/1000000,2),'M') as Achieved,
concat(format((select sum(Amount) from invoice where income_class='Renewal')/1000000,2),'M') as Invoice;

#KPI-4
select stage as Stage,concat(round(sum(revenue_amount)/1000,2),'K') as Revenue from opportunity group by Stage;

#KPI-5
select Account_Executive, count(meeting_date) as No_of_Meeting from meeting group by Account_Executive order by No_of_Meeting desc; 

#KPI-6
select opportunity_name, concat(format(sum(revenue_amount)/1000,0),'K') as Revenue from opportunity group by opportunity_name order by sum(revenue_amount) desc limit 4;

#Opportunity-Product Distribution
select product_group,count(opportunity_name) as Opportunity_Count from opportunity group by product_group order by Opportunity_Count desc;

#Total Opportunities
select count(opportunity_name) as Total_Opportunities from opportunity;

#Total Open Opportunity
select count(stage) as Total_Open_Opportuniy from opportunity where stage in ('Qualify Opportunity','Propose Solution');

#Cross_Sell_plcd_Achvmt_Percentage
select case when(
select sum(Cross_sell_bugdet) from individual_budgets)=0 then 'N/A'
else
concat(format((
(select sum(Amount) from(select Amount as Amount from brokerage where income_class='Cross Sell'
union all
select Amount as Amount from fees where income_class='Cross Sell') as AchievedData)/
(select sum(Cross_sell_bugdet) from individual_budgets))*100,2),'%')
end as Cross_Sell_plcd_Achvmt_Percentage;

#New_plcd_Achvmt_percentage
select case when(
select sum(New_Budget) from individual_budgets)=0 then 'N/A'
else
concat(format((
(select sum(Amount) from(select Amount as Amount from brokerage where income_class='New'
union all
select Amount as Amount from fees where income_class='New') as AchievedData)/
(select sum(New_Budget) from individual_budgets))*100,2),'%')
end as New_plcd_Achvmt_Percentage;

#Renewal_plcd_Achvmt_percentage
select case when(
select sum(Renewal_Budget) from individual_budgets)=0 then 'N/A'
else
concat(format((
(select sum(Amount) from(select Amount as Amount from brokerage where income_class='Renewal'
union all
select Amount as Amount from fees where income_class='Renewal') as AchievedData)/
(select sum(Renewal_Budget) from individual_budgets))*100,2),'%')
end as Renewal_plcd_Achvmt_Percentage;

#Cross_Sell_invoice_Achvmt_percentage
select case when(
select sum(Cross_sell_bugdet) from individual_budgets)=0 then 'N/A'
else
concat(format((
(select sum(Amount) from invoice where income_class='Cross Sell')/
(select sum(Cross_sell_bugdet) from individual_budgets))*100,2),'%')
end as Cross_Sell_invoice_Achvmt_percentage;

#New_invoice_Achvmt_percentage
select case when(
select sum(New_Budget) from individual_budgets)=0 then 'N/A'
else
concat(format((
(select sum(Amount) from invoice where income_class='New')/
(select sum(New_Budget) from individual_budgets))*100,2),'%')
end as New_invoice_Achvmt_percentage;

#Renewal_invoice_Achvmt_percentage
select case when(
select sum(Renewal_Budget) from individual_budgets)=0 then 'N/A'
else
concat(format((
(select sum(Amount) from invoice where income_class='Renewal')/
(select sum(Renewal_Budget) from individual_budgets))*100,2),'%')
end as Renewal_invoice_Achvmt_percentage;


