Chapter 9. 날짜 조작기법

9.1 연도의 윤년 여부 결정하기
<DB2>
   with x (dy,mth)
      as (
  select dy, month(dy)
    from (
  select (current_date -
           dayofyear(current_date) days +1 days)
            +1 months as dy
    from t1
         ) tmp1
  union all
 select dy+1 days, mth
   from x
  where month(dy+1 day) = mth
 )
 select max(day(dy))
   from x

<Oracle>
 select to_char(
          last_day(add_months(trunc(sysdate,'y'),1)),
         'DD')
   from t1

<PostgreSQL>
 select max(to_char(tmp2.dy+x.id,'DD')) as dy
    from (
  select dy, to_char(dy,'MM') as mth
    from (
  select cast(cast(
              date_trunc('year',current_date) as date)
                         + interval '1 month' as date) as dy
    from t1
         ) tmp1
        ) tmp2, generate_series (0,29) x(id)
  where to_char(tmp2.dy+x.id,'MM') = tmp2.mth

<MySQL>
 select day(
        last_day(
        date_add(
        date_add(
        date_add(current_date,
                 interval -dayofyear(current_date) day),
                 interval 1 day),
                 interval 1 month))) dy
   from t1

<SQL Server>
select coalesce
        (day
            (cast(concat
            (year(getdate()),'-02-29')
            as date))
            ,28);
--------------------------------------------------------------------
<DB2>
select (current_date
           dayofyear(current_date) days +1 days) +1 months as dy
   from t1
--------------------------------------------------------------------
select dy, month(dy) as mth
  from (
select (current_date
          dayofyear(current_date) days +1 days) +1 months as dy
  from t1
       ) tmp1
--------------------------------------------------------------------
  with x (dy,mth)
    as (
select dy, month(dy)
  from (
select (current_date -
         dayofyear(current_date) days +1 days) +1 months as dy
  from t1
       ) tmp1
 union all
 select dy+1 days, mth
   from x
  where month(dy+1 day) = mth
 )
 select dy,mth
   from x
<Oracle>
select trunc(sysdate,'y')
from t1
--------------------------------------------------------------------
select add_months(trunc(sysdate,'y'),1) dy
  from t1
--------------------------------------------------------------------
select last_day(add_months(trunc(sysdate,'y'),1)) dy
  from t1
<PostgreSQL>
select cast(date_trunc('year',current_date) as date) as dy
  from t1
--------------------------------------------------------------------
select cast(cast(
            date_trunc('year',current_date) as date)
                       + interval '1 month' as date) as dy
  from t1
--------------------------------------------------------------------
select dy, to_char(dy,'MM') as mth
   from (
 select cast(cast(
             date_trunc('year',current_date) as date)
                        + interval '1 month' as date) as dy
   from t1
        ) tmp1
--------------------------------------------------------------------
select tmp2.dy+x.id as dy, tmp2.mth
  from (
select dy, to_char(dy,'MM') as mth
  from (
select cast(cast(
            date_trunc('year',current_date) as date)
                       + interval '1 month' as date) as dy
  from t1
       ) tmp1
       ) tmp2, generate_series (0,29) x(id)
 where to_char(tmp2.dy+x.id,'MM') = tmp2.mth

<MySQL>
select date_add(
       date_add(current_date,
                interval -dayofyear(current_date) day),
                interval 1 day) dy
  from t1
--------------------------------------------------------------------
select date_add(
       date_add(
       date_add(current_date,
                interval -dayofyear(current_date) day),
                interval 1 day),
                interval 1 month) dy
  from t1
--------------------------------------------------------------------
select last_day(
       date_add(
       date_add(
       date_add(current_date,
                interval -dayofyear(current_date) day),
                interval 1 day),
                interval 1 month)) dy
  from t1

9.2 연도의 날짜 수 알아내기
<DB2>
 select days((curr_year + 1 year)) - days(curr_year)
   from (
 select (current_date -
         dayofyear(current_date) day +
          1 day) curr_year
   from t1
        ) x

<Oracle>
 select add_months(trunc(sysdate,'y'),12) - trunc(sysdate,'y')
   from dual
<PostgreSQL>
 select cast((curr_year + interval '1 year') as date) - curr_year
   from (
 select cast(date_trunc('year',current_date) as date) as curr_year
   from t1
        ) x

<MySQL>
 select datediff((curr_year + interval 1 year),curr_year)
   from (
 select adddate(current_date,-dayofyear(current_date)+1) curr_year
   from t1
        ) x

<SQL Server>
 select datediff(d,curr_year,dateadd(yy,1,curr_year))
   from (
 select dateadd(d,-datepart(dy,getdate())+1,getdate()) curr_year
   from t1
        ) x
--------------------------------------------------------------------
<DB2>
select (current_date
        dayofyear(current_date) day +
         1 day) curr_year
  from t1

<Oracle>
select select trunc(sysdate,'y') curr_year
  from dual

<PostgreSQL>
select cast(date_trunc('year',current_date) as date) as curr_year
  from t1

<MySQL>
select adddate(current_date,-dayofyear(current_date)+1) curr_year
  from t1

<SQL Server>
select dateadd(d,-datepart(dy,getdate())+1,getdate()) curr_year
  from t1

9.3 날짜에서 시간 단위 추출하기
<DB2>
 select    hour( current_timestamp ) hr,
         minute( current_timestamp ) min,
         second( current_timestamp ) sec,
            day( current_timestamp ) dy,
          month( current_timestamp ) mth,
            year( current_timestamp ) yr
   from t1
--------------------------------------------------------------------
select
        extract(hour from current_timestamp)
      , extract(minute from current_timestamp
      , extract(second from current_timestamp)
      , extract(day from current_timestamp)
      , extract(month from current_timestamp)
      , extract(year from current_timestamp)

<Oracle>
  select to_number(to_char(sysdate,'hh24')) hour,
         to_number(to_char(sysdate,'mi')) min,
         to_number(to_char(sysdate,'ss')) sec,
         to_number(to_char(sysdate,'dd')) day,
         to_number(to_char(sysdate,'mm')) mth,
         to_number(to_char(sysdate,'yyyy')) year
   from dual

<PostgreSQL>
 select to_number(to_char(current_timestamp,'hh24'),'99') as hr,
        to_number(to_char(current_timestamp,'mi'),'99') as min,
        to_number(to_char(current_timestamp,'ss'),'99') as sec,
        to_number(to_char(current_timestamp,'dd'),'99') as day,
        to_number(to_char(current_timestamp,'mm'),'99') as mth,
        to_number(to_char(current_timestamp,'yyyy'),'9999') as yr
   from t1

<MySQL>
 select date_format(current_timestamp,'%k') hr,
        date_format(current_timestamp,'%i') min,
        date_format(current_timestamp,'%s') sec,
        date_format(current_timestamp,'%d') dy,
        date_format(current_timestamp,'%m') mon,
        date_format(current_timestamp,'%Y') yr
   from t1

<SQL Server>
 select datepart( hour, getdate()) hr,
        datepart( minute,getdate()) min,
        datepart( second,getdate()) sec,
        datepart( day, getdate()) dy,
        datepart( month, getdate()) mon,
        datepart( year, getdate()) yr
   from t1

9.4 월의 첫 번째 요일과 마지막 요일 알아내기
<DB2>
 select (date(current_date) - day(date(current_date)) day + 1 day) firstday,
        (date(current_date)+1 month
         - day(date(current_date)+1 month) day) lastday
   from t1

<Oracle>
 select trunc(sysdate,'mm') firstday,
        last_day(sysdate) lastday
   from dual

<PostgreSQL>
 select firstday,
        cast(firstday + interval '1 month'
                      - interval '1 day' as date) as lastday
   from (
 select cast(date_trunc('month',current_date) as date) as firstday
   from t1
        ) x

<MySQL>
 select date_add(current_date,
                 interval -day(current_date)+1 day) firstday,
        last_day(current_date) lastday
   from t1

<SQL Server>
 select dateadd(day,-day(getdate())+1,getdate()) firstday,
        dateadd(day,
                -day(dateadd(month,1,getdate())),
                dateadd(month,1,getdate())) lastday
   from t1

9.5 연도의 특정 요일의 모든 날짜 알아내기
<DB2>
   with x (dy,yr)
      as (
  select dy, year(dy) yr
    from (
  select (current_date -
           dayofyear(current_date) days +1 days) as dy
    from t1
         ) tmp1
   union all
  select dy+1 days, yr
    from x
   where year(dy +1 day) = yr
  )
  select dy
    from x
   where dayname(dy) = 'Friday'
<Oracle>
   with x
     as (
 select trunc(sysdate,'y')+level-1 dy
   from t1
   connect by level <=
      add_months(trunc(sysdate,'y'),12)-trunc(sysdate,'y')
 )
 select *
   from x
  where to_char( dy, 'dy') = 'fri'

<PostgreSQL>
   with recursive cal (dy)
   as (
   select current_date
    -(cast
     (extract(doy from current_date) as integer)
    -1)
    union all
    select dy+1
    from cal
   where extract(year from dy)=extract(year from (dy+1))
     )

   select dy,extract(dow from dy) from cal
   where cast(extract(dow from dy) as integer) = 5

<MySQL>
	  with recursive cal (dy,yr)
   as
     (
     select dy, extract(year from dy) as yr
   from
     (select adddate
             (adddate(current_date, interval - dayofyear(current_date)
   day), interval 1 day) as dy) as tmp1
   union all
     select date_add(dy, interval 1 day), yr
  from cal
  where extract(year from date_add(dy, interval 1 day)) = yr
  )
     select dy from cal
     where dayofweek(dy) = 6

<SQL Server>
   with x (dy,yr)
     as (
  select dy, year(dy) yr
    from (
  select getdate()-datepart(dy,getdate())+1 dy
    from t1
         ) tmp1
   union all
  select dateadd(dd,1,dy), yr
   from x
  where year(dateadd(dd,1,dy)) = yr
 )
 select x.dy
   from x
  where datename(dw,x.dy) = 'Friday'
 option (maxrecursion 400)
--------------------------------------------------------------------
<DB2>
select (current_date
         dayofyear(current_date) days +1 days) as dy
  from t1
--------------------------------------------------------------------
 with x (dy,yr)
   as (
select dy, year(dy) yr
  from (
select (current_date
         dayofyear(current_date) days +1 days) as dy
  from t1
        ) tmp1
union all
select dy+1 days, yr
  from x
 where year(dy +1 day) = yr
)
select dy
  from x
<Oracle>
select trunc(sysdate,'y') dy
  from t1
--------------------------------------------------------------------
with x
   as (
select trunc(sysdate,'y')+level-1 dy
from t1
 connect by level <=
    add_months(trunc(sysdate,'y'),12)-trunc(sysdate,'y')
)
select *
from x

<MySQL>
select adddate(
       adddate(current_date,
               interval -dayofyear(current_date) day),
               interval 1 day ) dy
  from t1
--------------------------------------------------------------------
with cal (dy) as
(select current

union all
select dy+1

<SQL Server>
select getdate()-datepart(dy,getdate())+1 dy
  from t1
--------------------------------------------------------------------
with x (dy,yr)
  as (
select dy, year(dy) yr
  from (
select getdate()-datepart(dy,getdate())+1 dy
  from t1
       ) tmp1
 union all
select dateadd(dd,1,dy), yr
  from x
 where year(dateadd(dd,1,dy)) = yr
)
select x.dy
  from x
option (maxrecursion 400)

9.6 월의 특정 요일의 첫 번째 및 마지막 발생일 알아내기
<DB2>
   with x (dy,mth,is_monday)
      as (
  select dy,month(dy),
         case when dayname(dy)='Monday'
               then 1 else 0
         end
    from (
  select (current_date-day(current_date) day +1 day) dy
    from t1
        ) tmp1
  union all
 select (dy +1 day), mth,
        case when dayname(dy +1 day)='Monday'
             then 1 else 0
        end
   from x
  where month(dy +1 day) = mth
 )
 select min(dy) first_monday, max(dy) last_monday
   from x
  where is_monday = 1

<Oracle>
select next_day(trunc(sysdate,'mm')-1,'MONDAY') first_monday,
       next_day(last_day(trunc(sysdate,'mm'))-7,'MONDAY') last_monday
  from dual

<PostgreSQL>
 select first_monday,
         case to_char(first_monday+28,'mm')
              when mth then first_monday+28
                       else first_monday+21
         end as last_monday
    from (
  select case sign(cast(to_char(dy,'d') as integer)-2)
              when 0
              then dy
             when -1
             then dy+abs(cast(to_char(dy,'d') as integer)-2)
             when 1
             then (7-(cast(to_char(dy,'d') as integer)-2))+dy
        end as first_monday,
        mth
   from (
 select cast(date_trunc('month',current_date) as date) as dy,
        to_char(current_date,'mm') as mth
   from t1
        ) x
        ) y

<MySQL>
 select first_monday,
         case month(adddate(first_monday,28))
              when mth then adddate(first_monday,28)
                       else adddate(first_monday,21)
         end last_monday
   from (
  select case sign(dayofweek(dy)-2)
              when 0 then dy
              when -1 then adddate(dy,abs(dayofweek(dy)-2))
             when 1 then adddate(dy,(7-(dayofweek(dy)-2)))
        end first_monday,
        mth
   from (
 select adddate(adddate(current_date,-day(current_date)),1) dy,
        month(current_date) mth
   from t1
        ) x
        ) y

<SQL Server>
   with x (dy,mth,is_monday)
      as (
  select dy,mth,
         case when datepart(dw,dy) = 2
              then 1 else 0
         end
    from (
  select dateadd(day,1,dateadd(day,-day(getdate()),getdate())) dy,
         month(getdate()) mth
   from t1
        ) tmp1
  union all
 select dateadd(day,1,dy),
        mth,
        case when datepart(dw,dateadd(day,1,dy)) = 2
             then 1 else 0
        end
   from x
  where month(dateadd(day,1,dy)) = mth
 )
 select min(dy) first_monday,
        max(dy) last_monday
   from x
  where is_monday = 1
--------------------------------------------------------------------
<DB와 SQL Server>
select (current_date-day(current_date) day +1 day) dy
  from t1
--------------------------------------------------------------------
select dy, month(dy) mth,
        case when dayname(dy)='Monday'
             then 1 else 0
        end is_monday
  from  (
select  (current_date-day(current_date) day +1 day) dy
  from  t1
        ) tmp1
--------------------------------------------------------------------
with x (dy,mth,is_monday)
     as (
 select dy,month(dy) mth,
        case when dayname(dy)='Monday'
             then 1 else 0
        end is_monday
   from (
 select (current_date-day(current_date) day +1 day) dy
   from t1
        ) tmp1
  union all
 select (dy +1 day), mth,
        case when dayname(dy +1 day)='Monday'
             then 1 else 0
        end
   from x
  where month(dy +1 day) = mth
 )
 select *
   from x

<Oracle>
select trunc(sysdate,'mm')-1 dy
  from dual
--------------------------------------------------------------------
select next_day(trunc(sysdate,'mm')-1,'MONDAY') first_monday
  from dual
--------------------------------------------------------------------
select trunc(sysdate,'mm') dy
  from dual
--------------------------------------------------------------------
select last_day(trunc(sysdate,'mm'))-7 dy
  from dual
--------------------------------------------------------------------
select next_day(last_day(trunc(sysdate,'mm'))-7,'MONDAY') last_monday
  from dual

9.7 달력 만들기
<DB2>
   with x(dy,dm,mth,dw,wk)
    as (
  select (current_date -day(current_date) day +1 day) dy,
          day((current_date -day(current_date) day +1 day)) dm,
          month(current_date) mth,
          dayofweek(current_date -day(current_date) day +1 day) dw,
          week_iso(current_date -day(current_date) day +1 day) wk
    from t1
   union all
 select dy+1 day, day(dy+1 day), mth,
         dayofweek(dy+1 day), week_iso(dy+1 day)
   from x
  where month(dy+1 day) = mth
  )
  select max(case dw when 2 then dm end) as Mo,
         max(case dw when 3 then dm end) as Tu,
         max(case dw when 4 then dm end) as We,
         max(case dw when 5 then dm end) as Th,
         max(case dw when 6 then dm end) as Fr,
         max(case dw when 7 then dm end) as Sa,
         max(case dw when 1 then dm end) as Su
   from x
  group by wk
  order by wk

<Oracle>
  with x
     as (
  select *
    from (
  select to_char(trunc(sysdate,'mm')+level-1,'iw') wk,
         to_char(trunc(sysdate,'mm')+level-1,'dd') dm,
         to_number(to_char(trunc(sysdate,'mm')+level-1,'d')) dw,
         to_char(trunc(sysdate,'mm')+level-1,'mm') curr_mth,
         to_char(sysdate,'mm') mth
   from dual
  connect by level <= 31
        )
  where curr_mth = mth
 )
 select max(case dw when 2 then dm end) Mo,
        max(case dw when 3 then dm end) Tu,
        max(case dw when 4 then dm end) We,
        max(case dw when 5 then dm end) Th,
        max(case dw when 6 then dm end) Fr,
        max(case dw when 7 then dm end) Sa,
        max(case dw when 1 then dm end) Su
   from x
  group by wk
  order by wk

<PostgreSQL>
 select max(case dw when 2 then dm end) as Mo,
         max(case dw when 3 then dm end) as Tu,
         max(case dw when 4 then dm end) as We,
         max(case dw when 5 then dm end) as Th,
         max(case dw when 6 then dm end) as Fr,
         max(case dw when 7 then dm end) as Sa,
         max(case dw when 1 then dm end) as Su
    from (
  select *
   from (
 select cast(date_trunc('month',current_date) as date)+x.id,
        to_char(
           cast(
     date_trunc('month',current_date)
                as date)+x.id,'iw') as wk,
        to_char(
           cast(
     date_trunc('month',current_date)
                as date)+x.id,'dd') as dm,
        cast(
     to_char(
        cast(
   date_trunc('month',current_date)
                 as date)+x.id,'d') as integer) as dw,
         to_char(
            cast(
     date_trunc('month',current_date)
                 as date)+x.id,'mm') as curr_mth,
         to_char(current_date,'mm') as mth
   from generate_series (0,31) x(id)
        ) x
  where mth = curr_mth
        ) y
  group by wk
  order by wk

<MySQL>
with recursive  x(dy,dm,mth,dw,wk)
      as (
  select dy,
         day(dy) dm,
         datepart(m,dy) mth,
         datepart(dw,dy) dw,
         case when datepart(dw,dy) = 1
              then datepart(ww,dy)-1
              else datepart(ww,dy)
        end wk
   from (
 select date_add(day,-day(getdate())+1,getdate()) dy
   from t1
        ) x
  union all
  select dateadd(d,1,dy), day(date_add(d,1,dy)), mth,
         datepart(dw,dateadd(d,1,dy)),
         case when datepart(dw,date_add(d,1,dy)) = 1
              then datepart(wk,date_add(d,1,dy))-1
              else datepart(wk,date_add(d,1,dy))
         end
    from x
   where datepart(m,date_add(d,1,dy)) = mth
 )
 select max(case dw when 2 then dm end) as Mo,
        max(case dw when 3 then dm end) as Tu,
        max(case dw when 4 then dm end) as We,
        max(case dw when 5 then dm end) as Th,
        max(case dw when 6 then dm end) as Fr,
        max(case dw when 7 then dm end) as Sa,
        max(case dw when 1 then dm end) as Su
   from x
  group by wk
  order by wk;

<SQL Server>
   with x(dy,dm,mth,dw,wk)
      as (
  select dy,
         day(dy) dm,
         datepart(m,dy) mth,
         datepart(dw,dy) dw,
         case when datepart(dw,dy) = 1
              then datepart(ww,dy)-1
              else datepart(ww,dy)
        end wk
   from (
 select dateadd(day,-day(getdate())+1,getdate()) dy
   from t1
        ) x
  union all
  select dateadd(d,1,dy), day(dateadd(d,1,dy)), mth,
         datepart(dw,dateadd(d,1,dy)),
         case when datepart(dw,dateadd(d,1,dy)) = 1
              then datepart(wk,dateadd(d,1,dy))  -1
              else datepart(wk,dateadd(d,1,dy))
         end
    from x
   where datepart(m,dateadd(d,1,dy)) = mth
 )
 select max(case dw when 2 then dm end) as Mo,
        max(case dw when 3 then dm end) as Tu,
        max(case dw when 4 then dm end) as We,
        max(case dw when 5 then dm end) as Th,
        max(case dw when 6 then dm end) as Fr,
        max(case dw when 7 then dm end) as Sa,
        max(case dw when 1 then dm end) as Su
   from x
  group by wk
  order by wk
--------------------------------------------------------------------
<DB2>
select (current_date -day(current_date) day +1 day) dy,
       day((current_date -day(current_date) day +1 day)) dm,
       month(current_date) mth,
       dayofweek(current_date -day(current_date) day +1 day) dw,
       week_iso(current_date -day(current_date) day +1 day) wk
  from t1
--------------------------------------------------------------------
with x(dy,dm,mth,dw,wk)
  as (
select (current_date -day(current_date) day +1 day) dy,
       day((current_date -day(current_date) day +1 day)) dm,
       month(current_date) mth,
       dayofweek(current_date -day(current_date) day +1 day) dw,
       week_iso(current_date -day(current_date) day +1 day) wk
  from t1
 union all
 select dy+1 day, day(dy+1 day), mth,
        dayofweek(dy+1 day), week_iso(dy+1 day)
   from x
  where month(dy+1 day) = mth
)
select *
  from x
--------------------------------------------------------------------
with x(dy,dm,mth,dw,wk)
  as (
select (current_date -day(current_date) day +1 day) dy,
       day((current_date -day(current_date) day +1 day)) dm,
       month(current_date) mth,
       dayofweek(current_date -day(current_date) day +1 day) dw,
       week_iso(current_date -day(current_date) day +1 day) wk
  from t1
 union all
 select dy+1 day, day(dy+1 day), mth,
        dayofweek(dy+1 day), week_iso(dy+1 day)
   from x
  where month(dy+1 day) = mth
 )
 select wk,
        case dw when 2 then dm end as Mo,
        case dw when 3 then dm end as Tu,
        case dw when 4 then dm end as We,
        case dw when 5 then dm end as Th,
        case dw when 6 then dm end as Fr,
        case dw when 7 then dm end as Sa,
        case dw when 1 then dm end as Su
   from x
--------------------------------------------------------------------
with x(dy,dm,mth,dw,wk)
  as (
select (current_date -day(current_date) day +1 day) dy,
       day((current_date -day(current_date) day +1 day)) dm,
       month(current_date) mth,
       dayofweek(current_date -day(current_date) day +1 day) dw,
       week_iso(current_date -day(current_date) day +1 day) wk
  from t1
 union all
 select dy+1 day, day(dy+1 day), mth,
        dayofweek(dy+1 day), week_iso(dy+1 day)
   from x
  where month(dy+1 day) = mth
)
select max(case dw when 2 then dm end) as Mo,
       max(case dw when 3 then dm end) as Tu,
       max(case dw when 4 then dm end) as We,
       max(case dw when 5 then dm end) as Th,
       max(case dw when 6 then dm end) as Fr,
       max(case dw when 7 then dm end) as Sa,
       max(case dw when 1 then dm end) as Su
  from x
 group by wk
 order by wk
<Oracle>
select trunc(sysdate,'mm') dy,
       to_char(trunc(sysdate,'mm'),'dd') dm,
       to_char(sysdate,'mm') mth,
       to_number(to_char(trunc(sysdate,'mm'),'d')) dw,
       to_char(trunc(sysdate,'mm'),'iw') wk
  from dual
--------------------------------------------------------------------
with x
  as (
select *
  from (
select trunc(sysdate,'mm')+level-1 dy,
       to_char(trunc(sysdate,'mm')+level-1,'iw') wk,
       to_char(trunc(sysdate,'mm')+level-1,'dd') dm,
       to_number(to_char(trunc(sysdate,'mm')+level-1,'d')) dw,
       to_char(trunc(sysdate,'mm')+level-1,'mm') curr_mth,
       to_char(sysdate,'mm') mth
  from dual
 connect by level <= 31
       )
 where curr_mth = mth
)
select *
  from x
--------------------------------------------------------------------
with x
  as (
select *
  from (
select trunc(sysdate,'mm')+level-1 dy,
       to_char(trunc(sysdate,'mm')+level-1,'iw') wk,
       to_char(trunc(sysdate,'mm')+level-1,'dd') dm,
       to_number(to_char(trunc(sysdate,'mm')+level-1,'d')) dw,
       to_char(trunc(sysdate,'mm')+level-1,'mm') curr_mth,
       to_char(sysdate,'mm') mth
  from dual
 connect by level <= 31
       )
 where curr_mth = mth
)
select wk,
       case dw when 2 then dm end as Mo,
       case dw when 3 then dm end as Tu,
       case dw when 4 then dm end as We,
       case dw when 5 then dm end as Th,
       case dw when 6 then dm end as Fr,
       case dw when 7 then dm end as Sa,
       case dw when 1 then dm end as Su
  from x
--------------------------------------------------------------------
with x
  as (
select *
  from (
select to_char(trunc(sysdate,'mm')+level-1,'iw') wk,
       to_char(trunc(sysdate,'mm')+level-1,'dd') dm,
       to_number(to_char(trunc(sysdate,'mm')+level-1,'d')) dw,
       to_char(trunc(sysdate,'mm')+level-1,'mm') curr_mth,
       to_char(sysdate,'mm') mth
  from dual
 connect by level <= 31
       )
 where curr_mth = mth
)
select max(case dw when 2 then dm end) Mo,
       max(case dw when 3 then dm end) Tu,
       max(case dw when 4 then dm end) We,
       max(case dw when 5 then dm end) Th,
       max(case dw when 6 then dm end) Fr,
       max(case dw when 7 then dm end) Sa,
       max(case dw when 1 then dm end) Su
  from x
 group by wk
 order by wk

<MySQL, PostgreSQL, SQL Server>
select dy,
       day(dy) dm,
       datepart(m,dy) mth,
       datepart(dw,dy) dw,
       case when datepart(dw,dy) = 1
            then datepart(ww,dy)-1
            else datepart(ww,dy)
       end wk
  from (
select dateadd(day,-day(getdate())+1,getdate()) dy
  from t1
       ) x
--------------------------------------------------------------------
  with x(dy,dm,mth,dw,wk)
    as (
select dy,
       day(dy) dm,
       datepart(m,dy) mth,
       datepart(dw,dy) dw,
       case when datepart(dw,dy) = 1
            then datepart(ww,dy)-1
            else datepart(ww,dy)
       end wk
  from (
select dateadd(day,-day(getdate())+1,getdate()) dy
  from t1
       ) x
 union all
 select dateadd(d,1,dy), day(dateadd(d,1,dy)), mth,
        datepart(dw,dateadd(d,1,dy)),
        case when datepart(dw,dateadd(d,1,dy)) = 1
             then datepart(wk,dateadd(d,1,dy))-1
             else datepart(wk,dateadd(d,1,dy))
        end
  from x
 where datepart(m,dateadd(d,1,dy)) = mth
)
select *
  from x
--------------------------------------------------------------------
  with x(dy,dm,mth,dw,wk)
    as (
select dy,
       day(dy) dm,
       datepart(m,dy) mth,
       datepart(dw,dy) dw,
       case when datepart(dw,dy) = 1
            then datepart(ww,dy)-1
            else datepart(ww,dy)
       end wk
  from (
select dateadd(day,-day(getdate())+1,getdate()) dy
  from t1
       ) x
 union all
 select dateadd(d,1,dy), day(dateadd(d,1,dy)), mth,
        datepart(dw,dateadd(d,1,dy)),
        case when datepart(dw,dateadd(d,1,dy)) = 1
             then datepart(wk,dateadd(d,1,dy))-1
             else datepart(wk,dateadd(d,1,dy))
        end
   from x
  where datepart(m,dateadd(d,1,dy)) = mth
)
select case dw when 2 then dm end as Mo,
       case dw when 3 then dm end as Tu,
       case dw when 4 then dm end as We,
       case dw when 5 then dm end as Th,
       case dw when 6 then dm end as Fr,
       case dw when 7 then dm end as Sa,
       case dw when 1 then dm end as Su
  from x
--------------------------------------------------------------------
with x(dy,dm,mth,dw,wk)
    as (
select dy,
       day(dy) dm,
       datepart(m,dy) mth,
       datepart(dw,dy) dw,
       case when datepart(dw,dy) = 1
            then datepart(ww,dy)-1
            else datepart(ww,dy)
       end wk
  from (
select dateadd(day,-day(getdate())+1,getdate()) dy
  from t1
       ) x
 union all
 select dateadd(d,1,dy), day(dateadd(d,1,dy)), mth,
        datepart(dw,dateadd(d,1,dy)),
        case when datepart(dw,dateadd(d,1,dy)) = 1
             then datepart(wk,dateadd(d,1,dy))-1
             else datepart(wk,dateadd(d,1,dy))
        end
   from x
  where datepart(m,dateadd(d,1,dy)) = mth
)
select max(case dw when 2 then dm end) as Mo,
       max(case dw when 3 then dm end) as Tu,
       max(case dw when 4 then dm end) as We,
       max(case dw when 5 then dm end) as Th,
       max(case dw when 6 then dm end) as Fr,
       max(case dw when 7 then dm end) as Sa,
       max(case dw when 1 then dm end) as Su
  from x
 group by wk
 order by wk

9.8 해당 연도의 분기 시작일 및 종료일 나열하기
<DB2>
 select quarter(dy-1 day) QTR,
         dy-3 month Q_start,
         dy-1 day Q_end
    from (
  select (current_date -
           (dayofyear(current_date)-1) day
             + (rn*3) month) dy
    from (
  select row_number()over() rn
   from emp
  fetch first 4 rows only
         ) x
         ) y

<Oracle>
 select rownum qtr,
        add_months(trunc(sysdate,'y'),(rownum-1)*3) q_start,
        add_months(trunc(sysdate,'y'),rownum*3)-1 q_end
   from emp
  where rownum <= 4

<PostgreSQL>
with recursive x (dy,cnt)
     as (
  select
        current_date -cast(extract(day from current_date)as integer) +1 dy
        , id
    from t1
   union all
  select cast(dy  + interval '3 months' as date) , cnt+1
    from x
   where cnt+1 <= 4
 )
 select  cast(dy - interval '3 months' as date) as Q_start
        , dy-1 as Q_end
		from x

<MySQL>
	      with recursive x (dy,cnt)
     as (
	         select
         adddate(current_date,(-dayofyear(current_date))+1) dy
           ,id
	     from t1
	   union all
	         select adddate(dy, interval 3 month ), cnt+1
	         from x
         where cnt+1 <= 4
        )

       select quarter(adddate(dy,-1)) QTR
    ,  date_add(dy, interval -3 month) Q_start
    ,  adddate(dy,-1)  Q_end
     from x
     order by 1;

<SQL Server>
  with x (dy,cnt)
     as (
  select dateadd(d,-(datepart(dy,getdate())-1),getdate()),
         1
    from t1
   union all
  select dateadd(m,3,dy), cnt+1
    from x
   where cnt+1 <= 4
 )
 select datepart(q,dateadd(d,-1,dy)) QTR,
         dateadd(m,-3,dy) Q_start,
        dateadd(d,-1,dy) Q_end
   from x
 order by 1
--------------------------------------------------------------------
<DB2>
select row_number()over() rn
  from emp
 fetch first 4 rows only
--------------------------------------------------------------------
select (current_date
        (dayofyear(current_date)-1) day
          + (rn*3) month) dy 
  from (
select row_number()over() rn
  from emp
 fetch first 4 rows only
       ) x

<PostgreSQL, MySQL, SQL Server>
with x (dy,cnt)
   as (
select dateadd(d,-(datepart(dy,getdate())-1),getdate()),
       1
  from t1
 union all
select dateadd(m,3,dy), cnt+1
  from x
 where cnt+1 <= 4
)
select dy
  from x

9.9 지정 분기의 시작일 및 종료일 알아내기
select 20051 as yrq from t1 union all
select 20052 as yrq from t1 union all
select 20053 as yrq from t1 union all
select 20054 as yrq from t1

<DB2>
 select (q_end-2 month) q_start,
         (q_end+1 month)-1 day q_end
    from (
  select date(substr(cast(yrq as char(4)),1,4) ||'-'||
         rtrim(cast(mod(yrq,10)*3 as char(2))) ||'-1') q_end
    from (
  select 20051 yrq from t1 union all
  select 20052 yrq from t1 union all
  select 20053 yrq from t1 union all
 select 20054 yrq from t1
        ) x
        ) y

<Oracle>
 select add_months(q_end,-2) q_start,
         last_day(q_end) q_end
    from (
  select to_date(substr(yrq,1,4)||mod(yrq,10)*3,'yyyymm') q_end
    from (
  select 20051 yrq from dual union all
  select 20052 yrq from dual union all
  select 20053 yrq from dual union all
  select 20054 yrq from dual
        ) x
        ) y

<PostgreSQL>
 select date(q_end-(2*interval '1 month')) as q_start,
         date(q_end+interval '1 month'-interval '1 day') as q_end
    from (
  select to_date(substr(yrq,1,4)||mod(yrq,10)*3,'yyyymm') as q_end
    from (
  select 20051 as yrq from t1 union all
  select 20052 as yrq from t1 union all
  select 20053 as yrq from t1 union all
  select 20054 as yrq from t1
        ) x
        ) y

<MySQL>
 select date_add(
          adddate(q_end,-day(q_end)+1),
                 interval -2 month) q_start,
         q_end
    from (
  select last_day(
      str_to_date(
           concat(
           substr(yrq,1,4),mod(yrq,10)*3),'%Y%m')) q_end
   from (
 select 20051 as yrq from t1 union all
 select 20052 as yrq from t1 union all
 select 20053 as yrq from t1 union all
 select 20054 as yrq from t1
        ) x
        ) y

<SQL Server>
 select dateadd(m,-2,q_end) q_start,
         dateadd(d,-1,dateadd(m,1,q_end)) q_end
    from (
  select cast(substring(cast(yrq as varchar),1,4)+'-'+
         cast(yrq%10*3 as varchar)+'-1' as datetime) q_end
    from (
  select 20051 as yrq from t1 union all
  select 20052 as yrq from t1 union all
  select 20052 as yrq from t1 union all
 select 20054 as yrq from t1
        ) x
        ) y
--------------------------------------------------------------------
<DB2>
select substr(cast(yrq as char(4)),1,4) yr,
       mod(yrq,10)*3 mth
  from (
select 20051 yrq from t1 union all
select 20052 yrq from t1 union all
select 20053 yrq from t1 union all
select 20054 yrq from t1
       ) x
--------------------------------------------------------------------
select date(substr(cast(yrq as char(4)),1,4) ||'-'||
       rtrim(cast(mod(yrq,10)*3 as char(2))) ||'-1') q_end
  from (
select 20051 yrq from t1 union all
select 20052 yrq from t1 union all
select 20053 yrq from t1 union all
select 20054 yrq from t1
       ) x

<Oracle>
select substr(yrq,1,4) yr, mod(yrq,10)*3 mth
  from (
select 20051 yrq from t1 union all
select 20052 yrq from t1 union all
select 20053 yrq from t1 union all
select 20054 yrq from t1
       ) x
----------------------------------------------------------------
select to_date(substr(yrq,1,4)||mod(yrq,10)*3,'yyyymm') q_end
  from (
select 20051 yrq from t1 union all
select 20052 yrq from t1 union all
select 20053 yrq from t1 union all
select 20054 yrq from t1
       ) x

<PostgreSQL>
select substr(cast(yrq as varchar),1,4) yr, mod(yrq,10)*3 mth
  from (
select 20051 yrq from t1 union all
select 20052 yrq from t1 union all
select 20053 yrq from t1 union all
select 20054 yrq from t1
       ) x
--------------------------------------------------------------------
select to_date(substr(yrq,1,4)||mod(yrq,10)*3,'yyyymm') q_end
  from (
select 20051 yrq from t1 union all
select 20052 yrq from t1 union all
select 20053 yrq from t1 union all
select 20054 yrq from t1
       ) x

<MySQL>
select substr(cast(yrq as varchar),1,4) yr, mod(yrq,10)*3 mth
  from (
select 20051 yrq from t1 union all
select 20052 yrq from t1 union all
select 20053 yrq from t1 union all
select 20054 yrq from t1
       ) x
--------------------------------------------------------------------
select last_day(
    str_to_date(
         concat(
         substr(yrq,1,4),mod(yrq,10)*3),'%Y%m')) q_end
  from (
select 20051 as yrq from t1 union all
select 20052 as yrq from t1 union all
select 20053 as yrq from t1 union all
select 20054 as yrq from t1
       ) x

<SQL Server>
select substring(yrq,1,4) yr, yrq%10*3 mth
  from (
select 20051 yrq from t1 union all
select 20052 yrq from t1 union all
select 20053 yrq from t1 union all
select 20054 yrq from t1
       ) x
--------------------------------------------------------------------
select cast(substring(cast(yrq as varchar),1,4)+'-'+
       cast(yrq%10*3 as varchar)+'-1' as datetime) q_end
  from (
select 20051 yrq from t1 union all
select 20052 yrq from t1 union all
select 20053 yrq from t1 union all
select 20054 yrq from t1
       ) x

9.10 누락된 날짜 채우기
select distinct
       extract(year from hiredate) as year
  from emp
-------------------------------------------------------------------- 
<DB2>
   with x (start_date,end_date)
      as (
  select (min(hiredate)
           dayofyear(min(hiredate)) day +1 day) start_date,
         (max(hiredate)
           dayofyear(max(hiredate)) day +1 day) +1 year end_date
    from emp
   union all
  select start_date +1 month, end_date
   from x
  where (start_date +1 month) < end_date
 )
 select x.start_date mth, count(e.hiredate) num_hired
   from x left join emp e
     on (x.start_date = (e.hiredate-(day(hiredate)-1) day))
  group by x.start_date
  order by 1

<Oracle>
   with x
      as (
  select add_months(start_date,level-1) start_date
    from (
  select min(trunc(hiredate,'y')) start_date,
         add_months(max(trunc(hiredate,'y')),12) end_date
    from emp
         )
   connect by level <= months_between(end_date,start_date)
 )
 select x.start_date MTH, count(e.hiredate) num_hired
   from x left join emp e
     on (x.start_date = trunc(e.hiredate,'mm'))
  group by x.start_date
  order by 1

<PostgreSQL>
with recursive x (start_date, end_date)
as
(
    select
    cast(min(hiredate) - (cast(extract(day from min(hiredate))
    as integer) - 1) as date)
    , max(hiredate)
    from emp
  union all
    select cast(start_date + interval '1 month' as date)
    , end_date
    from x
    where start_date < end_date
 )

 select x.start_date,count(hiredate)
 from x left join emp
  on (extract(month from start_date) =
            extract(month from emp.hiredate)
        and extract(year from start_date)
        = extract(year from emp.hiredate))
      group by x.start_date
      order by 1

<MySQL>
with recursive x (start_date,end_date)
     as
    (
      select
          adddate(min(hiredate),
          -dayofyear(min(hiredate))+1)  start_date
          ,adddate(max(hiredate),
          -dayofyear(max(hiredate))+1)  end_date
          from emp
       union all
          select date_add(start_date,interval 1 month)
          , end_date
          from x
          where date_add(start_date, interval 1 month) < end_date
      )

       select x.start_date mth, count(e.hiredate) num_hired
      from x left join emp e
      on (extract(year_month from start_date)
          =
          extract(year_month from e.hiredate))
      group by x.start_date
      order by 1;

<SQL Server>
   with x (start_date,end_date)
     as (
 select (min(hiredate) -
          datepart(dy,min(hiredate))+1) start_date,
        dateadd(yy,1,
         (max(hiredate) -
          datepart(dy,max(hiredate))+1)) end_date
   from emp
  union all
 select dateadd(mm,1,start_date), end_date
   from x
  where dateadd(mm,1,start_date) < end_date
 )
 select x.start_date mth, count(e.hiredate) num_hired
   from x left join emp e
     on (x.start_date =
            dateadd(dd,-day(e.hiredate)+1,e.hiredate))
 group by x.start_date
 order by 1
--------------------------------------------------------------------
<DB2>
select (min(hiredate)
         dayofyear(min(hiredate)) day +1 day) start_date,
       (max(hiredate)
         dayofyear(max(hiredate)) day +1 day) +1 year end_date
  from emp
--------------------------------------------------------------------
with x (start_date,end_date)
  as (
select (min(hiredate)
         dayofyear(min(hiredate)) day +1 day) start_date,
       (max(hiredate)
         dayofyear(max(hiredate)) day +1 day) +1 year end_date
  from emp
 union all
select start_date +1 month, end_date
  from x
 where (start_date +1 month) < end_date
)
select *
  from x

<Oracle>
select min(trunc(hiredate,'y')) start_date,
       add_months(max(trunc(hiredate,'y')),12) end_date
  from emp
--------------------------------------------------------------------
with x as (
select add_months(start_date,level-1) start_date
  from (
select min(trunc(hiredate,'y')) start_date,
       add_months(max(trunc(hiredate,'y')),12) end_date
  from emp
       )
 connect by level <= months_between(end_date,start_date)
)
select *
  from x

<MySQL>
with recursive x (start_date,end_date)
     as (
          select
           adddate(min(hiredate),
          -dayofyear(min(hiredate))+1)  start_date
          ,adddate(max(hiredate),
          -dayofyear(max(hiredate))+1)  end_date
          from emp
       union all
       select date_add(start_date,interval 1 month)
       , end_date
       from x
       where date_add(start_date, interval 1 month) < end_date
         )
 select * from x
--------------------------------------------------------------------
select adddate(min(hiredate),-dayofyear(min(hiredate))+1) min_hd,
       adddate(max(hiredate),-dayofyear(max(hiredate))+1) max_hd
  from emp

<SQL Server>
select (min(hiredate) -
         datepart(dy,min(hiredate))+1) start_date,
       dateadd(yy,1,
        (max(hiredate) -
         datepart(dy,max(hiredate))+1)) end_date
from emp
-------------------------------------------------------------------
with x (start_date,end_date)
  as (
select (min(hiredate) -
         datepart(dy,min(hiredate))+1) start_date,
       dateadd(yy,1,
        (max(hiredate) -
         datepart(dy,max(hiredate))+1)) end_date
  from emp
 union all
select dateadd(mm,1,start_date), end_date
  from x
 where dateadd(mm,1,start_date) < end_date
)
select *
  from x

9.11 특정 시간 단위 검색하기
<DB2와 MySQL>
 select ename
   from emp
 where monthname(hiredate) in ('February','December')
    or dayname(hiredate) = 'Tuesday'

<Oracle과 PostgreSQL>
 select ename
   from emp
 where rtrim(to_char(hiredate,'month')) in ('february','december')
    or rtrim(to_char(hiredate,'day')) = 'tuesday'

<SQL Server>
 select ename
   from emp
 where datename(m,hiredate) in ('February','December')
    or datename(dw,hiredate) = 'Tuesday'
-------------------------------------------------------------------- 
select ename,datename(m,hiredate) mth,datename(dw,hiredate) dw
  from emp
 where deptno = 10

9.12 날짜의 특정 부분으로 레코드 비교하기
<DB2>
 select a.ename ||
        ' was hired on the same month and weekday as '||
        b.ename msg
   from emp a, emp b
 where (dayofweek(a.hiredate),monthname(a.hiredate)) =
       (dayofweek(b.hiredate),monthname(b.hiredate))
   and a.empno < b.empno
 order by a.ename

<Oracle과 PostgreSQL>
 select a.ename ||
        ' was hired on the same month and weekday as '||
        b.ename as msg
   from emp a, emp b
 where to_char(a.hiredate,'DMON') =
       to_char(b.hiredate,'DMON')
   and a.empno < b.empno
 order by a.ename

<MySQL>
 select concat(a.ename,
        ' was hired on the same month and weekday as ',
        b.ename) msg
   from emp a, emp b
  where date_format(a.hiredate,'%w%M') =
        date_format(b.hiredate,'%w%M')
    and a.empno < b.empno
 order by a.ename

<SQL Server>
 select a.ename +
        ' was hired on the same month and weekday as '+
        b.ename msg
  from emp a, emp b
 where datename(dw,a.hiredate) = datename(dw,b.hiredate)
   and datename(m,a.hiredate) = datename(m,b.hiredate)
   and a.empno < b.empno
 order by a.ename
--------------------------------------------------------------------
select a.ename as scott, a.hiredate as scott_hd,
       b.ename as other_emps, b.hiredate as other_hds
  from emp a, emp b
 where a.ename = 'SCOTT'
   and a.empno != b.empno
--------------------------------------------------------------------
select a.ename as emp1, a.hiredate as emp1_hd,
       b.ename as emp2, b.hiredate as emp2_hd
  from emp a, emp b
 where to_char(a.hiredate,'DMON') =
       to_char(b.hiredate,'DMON')
   and a.empno != b.empno
 order by 1
--------------------------------------------------------------------
select a.ename as emp1, b.ename as emp2
  from emp a, emp b
 where to_char(a.hiredate,'DMON') =
       to_char(b.hiredate,'DMON')
   and a.empno < b.empno
 order by 1

9.13 중복 날짜 범위 식별하기
select *
  from emp_project
--------------------------------------------------------------------
DB2, PostgreSQL, Oracle
 select a.empno,a.ename,
        'project '||b.proj_id||
        ' overlaps project '||a.proj_id as msg
   from emp_project a,
        emp_project b
  where a.empno = b.empno
    and b.proj_start >= a.proj_start
    and b.proj_start <= a.proj_end
    and a.proj_id != b.proj_id

<MySQL>
 select a.empno,a.ename,
        concat('project ',b.proj_id,
         ' overlaps project ',a.proj_id) as msg
   from emp_project a,
        emp_project b
  where a.empno = b.empno
    and b.proj_start >= a.proj_start
    and b.proj_start <= a.proj_end
    and a.proj_id != b.proj_id

<SQL Server>
 select a.empno,a.ename,
        'project '+b.proj_id+
        ' overlaps project '+a.proj_id as msg
   from emp_project a,
        emp_project b
  where a.empno = b.empno
    and b.proj_start >= a.proj_start
    and b.proj_start <= a.proj_end
    and a.proj_id != b.proj_id
--------------------------------------------------------------------
select a.ename,
       a.proj_id as a_id,
       a.proj_start as a_start,
       a.proj_end as a_end,
       b.proj_id as b_id,
       b.proj_start as b_start
  from emp_project a,
       emp_project b
 where a.ename = 'KING'
   and a.empno = b.empno
   and a.proj_id != b.proj_id
order by 2
--------------------------------------------------------------------
select empno,
       ename,
       proj_id,
       proj_start,
       proj_end,
       case
       when lead(proj_start,1)over(order by proj_start)
            between proj_start and proj_end
       then lead(proj_id)over(order by proj_start)
       when lead(proj_start,2)over(order by proj_start)
            between proj_start and proj_end
       then lead(proj_id)over(order by proj_start)
       when lead(proj_start,3)over(order by proj_start)
            between proj_start and proj_end
       then lead(proj_id)over(order by proj_start)
       when lead(proj_start,4)over(order by proj_start)
            between proj_start and proj_end
       then lead(proj_id)over(order by proj_start)
       end is_overlap
  from emp_project
 where ename = 'KING'
--------------------------------------------------------------------
select empno,ename,
       'project '||is_overlap||
       ' overlaps project '||proj_id msg
  from (
select empno,
       ename,
       proj_id,
       proj_start,
       proj_end,
       case
       when lead(proj_start,1)over(order by proj_start)
            between proj_start and proj_end
       then lead(proj_id)over(order by proj_start)
       when lead(proj_start,2)over(order by proj_start)
            between proj_start and proj_end
       then lead(proj_id)over(order by proj_start)
       when lead(proj_start,3)over(order by proj_start)
            between proj_start and proj_end
       then lead(proj_id)over(order by proj_start)
       when lead(proj_start,4)over(order by proj_start)
            between proj_start and proj_end
       then lead(proj_id)over(order by proj_start)
       end is_overlap
  from emp_project
 where ename = 'KING'
       )
 where is_overlap is not null
--------------------------------------------------------------------
select empno,ename,
       'project '||is_overlap||
       ' overlaps project '||proj_id msg
  from (
select empno,
       ename,
       proj_id,
       proj_start,
       proj_end,
       case
       when lead(proj_start,1)over(partition by ename
                                       order by proj_start)
            between proj_start and proj_end
       then lead(proj_id)over(partition by ename
                                  order by proj_start)
       when lead(proj_start,2)over(partition by ename
                                       order by proj_start)
            between proj_start and proj_end
       then lead(proj_id)over(partition by ename
                                  order by proj_start)
       when lead(proj_start,3)over(partition by ename
                                       order by proj_start)
            between proj_start and proj_end
       then lead(proj_id)over(partition by ename
                                  order by proj_start)
       when lead(proj_start,4)over(partition by ename
                                       order by proj_start)
            between proj_start and proj_end
       then lead(proj_id)over(partition by ename
                                  order by proj_start)
       end is_overlap
 from emp_project
      )
where is_overlap is not null