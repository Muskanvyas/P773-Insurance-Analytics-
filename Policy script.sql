create database PolicyDataDB;
use PolicyDataDB;
create table Policy_Details(
Policy_ID varchar(100),
Policy_Type varchar(100),
Coverage_Amount float,
Premium_Amount float,
Policy_Start_Date date,
Policy_End_Date date,
Payment_Frequency varchar(100),
Status varchar(100),
Customer_ID varchar(100)
);
drop table Policy_Details;
select * from Policy_Details;

create table Payment_History(
Payment_ID varchar(100),
Date_of_Payment date,
Amount_Paid float,
Payment_Method varchar(100),
Payment_Status varchar(100),
Policy_ID varchar(100)
);
drop table Payment_History;
select * from Payment_History;

create table Customer_Information(
Customer_ID varchar(100),
Name varchar(100),
Gender varchar(50),
Age int,
Occupation varchar(100),
Marital_Status varchar(50),
Address varchar(500)
);
select * from Customer_Information;

create table Claims(
Claim_ID varchar(100),
Date_of_Claim date,
Claim_Amount int,
Claim_Status varchar(100),
Reason_for_Claim varchar(5000),

Policy_ID varchar(100)
);
drop table Claims;
select * from Claims;


create table Additional_Fields(
Agent_ID varchar(100),
Renewal_Status varchar(100),
Policy_Discounts int,
Risk_Score int,
Policy_ID varchar(100)
);
drop table Additional_Fields;
select * from Additional_Fields;


#KPI-1
select count(*) as Total_Policy, 
sum(case when Status='Active' then 1 else 0 end) as Active,
sum(case when Status in('Terminated','Lapsed') then 1 else 0 end) as Inactive
from policy_details;

#KPI-2
select policy_count,count(*) as customer_count from(
select customer_id,count(Policy_ID) as policy_count from policy_details group by Customer_ID
) as customer_policy_counts 
group by policy_count order by policy_count;

#KPI-3
select case
when c.Age between 18 and 25 then '18-25'
when c.Age between 26 and 35 then '26-35'
when c.Age between 36 and 45 then '36-45'
when c.Age between 46 and 55 then '46-55'
when c.Age between 56 and 65 then '56-65'
when c.Age between 66 and 75 then '66-75'
when c.Age between 76 and 85 then '76-85'
end as Age_Bucket,count(p.Policy_ID) as policy_count
from customer_information c inner join
policy_details p on c.Customer_ID=p.Customer_ID
group by Age_Bucket order by Age_Bucket;

#KPI-4
select count(*) as Total_Policy, 
sum(case when Gender='Male' then 1 else 0 end) as Male,
sum(case when Gender='Female' then 1 else 0 end) as Female,
sum(case when Gender='Other' then 1 else 0 end) as Other
from customer_information;

#KPI-5
select count(*) as Total_Policy, 
sum(case when Policy_Type='Auto' then 1 else 0 end) as Auto,
sum(case when Policy_Type='Property' then 1 else 0 end) as Property,
sum(case when Policy_Type='Health' then 1 else 0 end) as Health,
sum(case when Policy_Type='Life' then 1 else 0 end) as Life
from policy_details;

#KPI-6
select count(*) as policy_expiring_this_Year 
from policy_details where 
year(Policy_End_Date)=year(curdate());

#KPI-7
select year(Policy_Start_Date) as Year, round(sum(Premium_Amount),2) as Total_Premium_Amount,
concat(
round(
(sum(Premium_Amount)-lag(sum(Premium_Amount)) over(order by year(Policy_Start_Date)))/lag(sum(Premium_Amount)) over(order by year(Policy_Start_Date))*100,2
),'%'
) as Premium_growth_rate from policy_details
group by year(Policy_Start_Date) order by Year;

#KPI-8
select count(*) as Total_Policy, 
sum(case when Claim_Status='Approved' then 1 else 0 end) as Approved,
sum(case when Claim_Status='Pending' then 1 else 0 end) as Pending,
sum(case when Claim_Status='Denied' then 1 else 0 end) as Rejected
from claims;

select case
when Claim_Status='Approved' then 'Approved'
when Claim_Status='Pending' then 'Pending'
when Claim_Status='Denied' then 'Rejected'
end as Claim_Status,count(Policy_ID) as policy_count
from Claims group by Claim_Status;
#KPI-9
select case
when a.Renewal_Status='Renewed' then 'Paid'
when a.Renewal_Status='Not Renewed' then 'Overdue'
when a.Renewal_Status='Pending' then 'Pending'
end as Payment_Status,count(distinct p.Policy_ID) as policy_count
from additional_fields a inner join policy_details p on a.Policy_ID=p.Policy_ID
group by payment_Status;

#KPI-10
select concat(ROUND(SUM(Claim_Amount) / 1000000, 2),'M')  as Total_Claim_Amount 
from claims;