Chapter 8. 날짜 산술
<DB2>
 select hiredate -5 day   as hd_minus_5D,
        hiredate +5 day   as hd_plus_5D,
        hiredate -5 month as hd_minus_5M,
        hiredate +5 month as hd_plus_5M,
        hiredate -5 year  as hd_minus_5Y,
        hiredate +5 year  as hd_plus_5Y
   from emp
  where deptno = 10

<Oracle>
 select hiredate-5                 as hd_minus_5D,
        hiredate+5                 as hd_plus_5D,
        add_months(hiredate,-5)    as hd_minus_5M,
        add_months(hiredate,5)     as hd_plus_5M,
        add_months(hiredate,-5*12) as hd_minus_5Y,
        add_months(hiredate,5*12)  as hd_plus_5Y
   from emp
  where deptno = 10

<PostgreSQL>
 select hiredate - interval '5 day'   as hd_minus_5D,
        hiredate + interval '5 day'   as hd_plus_5D,
        hiredate - interval '5 month' as hd_minus_5M,
        hiredate + interval '5 month' as hd_plus_5M,
        hiredate - interval '5 year'  as hd_minus_5Y,
        hiredate + interval '5 year'  as hd_plus_5Y
   from emp
  where deptno=10

<MySQL>
 select hiredate - interval 5 day   as hd_minus_5D,
        hiredate + interval 5 day   as hd_plus_5D,
        hiredate - interval 5 month as hd_minus_5M,
        hiredate + interval 5 month as hd_plus_5M,
        hiredate - interval 5 year  as hd_minus_5Y,
        hiredate + interval 5 year  as hd_plus_5Y
   from emp
  where deptno=10
--------------------------------------------------------------------
 select date_add(hiredate,interval -5 day)   as hd_minus_5D,
        date_add(hiredate,interval  5 day)   as hd_plus_5D,
        date_add(hiredate,interval -5 month) as hd_minus_5M,
        date_add(hiredate,interval  5 month) as hd_plus_5M,
        date_add(hiredate,interval -5 year)  as hd_minus_5Y,
        date_add(hiredate,interval  5 year)  as hd_plus_5DY
   from emp
  where deptno=10

<SQL Server>
 select dateadd(day,-5,hiredate)   as hd_minus_5D,
        dateadd(day,5,hiredate)    as hd_plus_5D,
        dateadd(month,-5,hiredate) as hd_minus_5M,
        dateadd(month,5,hiredate)  as hd_plus_5M,
        dateadd(year,-5,hiredate)  as hd_minus_5Y,
        dateadd(year,5,hiredate)   as hd_plus_5Y
   from emp
  where deptno = 10

8.2 두 날짜 사이의 일수 알아내기
<DB2>
  select days(ward_hd) - days(allen_hd)
    from (
  select hiredate as ward_hd
    from emp
   where ename = 'WARD'
         ) x,
         (
  select hiredate as allen_hd
    from emp
  where ename = 'ALLEN'
        ) y

<Oracle과 PostgreSQL>
 select ward_hd - allen_hd
    from (
  select hiredate as ward_hd
    from emp
   where ename = 'WARD'
         ) x,
         (
  select hiredate as allen_hd
    from emp
  where ename = 'ALLEN'
        ) y

<MySQL와 SQL Server>
 select datediff(day,allen_hd,ward_hd)
    from (
  select hiredate as ward_hd
    from emp
   where ename = 'WARD'
         ) x,
         (
  select hiredate as allen_hd
    from emp
  where ename = 'ALLEN'
        ) y
--------------------------------------------------------------------
select ward_hd, allen_hd
    from (
select hiredate as ward_hd
  from emp
 where ename = 'WARD'
       ) y,
       (
select hiredate as allen_hd
  from emp
 where ename = 'ALLEN'
       ) x

8.3 두 날짜 사이의 영업일수 알아내기
<DB2>
 select sum(case when dayname(jones_hd+t500.id day -1 day)
                    in ( 'Saturday','Sunday' )
                  then 0 else 1
             end) as days
    from (
  select max(case when ename = 'BLAKE'
                  then hiredate
             end) as blake_hd,
         max(case when ename = 'JONES'
                 then hiredate
            end) as jones_hd
   from emp
  where ename in ( 'BLAKE','JONES' )
        ) x,
        t500
  where t500.id <= blake_hd-jones_hd+1

<MySQL>
 select sum(case when date_format(
                          date_add(jones_hd,
                                   interval t500.id-1 DAY),'%a')
                    in ( 'Sat','Sun' )
                  then 0 else 1
             end) as days
    from (
  select max(case when ename = 'BLAKE'
                  then hiredate
            end) as blake_hd,
        max(case when ename = 'JONES'
                 then hiredate
             end) as jones_hd
   from emp
  where ename in ( 'BLAKE','JONES' )
        ) x,
        t500
  where t500.id <= datediff(blake_hd,jones_hd)+1

<Oracle>
 select sum(case when to_char(jones_hd+t500.id-1,'DY')
                    in ( 'SAT','SUN' )
                  then 0 else 1
             end) as days
    from (
  select max(case when ename = 'BLAKE'
                  then hiredate
             end) as blake_hd,
         max(case when ename = 'JONES'
                 then hiredate
            end) as jones_hd
   from emp
  where ename in ( 'BLAKE','JONES' )
        ) x,
        t500
  where t500.id <= blake_hd-jones_hd+1

<PostgreSQL>
 select sum(case when trim(to_char(jones_hd+t500.id-1,'DAY'))
                    in ( 'SATURDAY','SUNDAY' )
                  then 0 else 1
             end) as days
    from (
  select max(case when ename = 'BLAKE'
                  then hiredate
             end) as blake_hd,
         max(case when ename = 'JONES'
                 then hiredate
            end) as jones_hd
   from emp
  where ename in ( 'BLAKE','JONES' )
        ) x,
        t500
  where t500.id <= blake_hd-jones_hd+1

<SQL Server>
 select sum(case when datename(dw,jones_hd+t500.id-1)
                    in ( 'SATURDAY','SUNDAY' )
                   then 0 else 1
             end) as days
    from (
  selectmax(case when ename = 'BLAKE'
                  then hiredate
             end) as blake_hd,
         max(case when ename = 'JONES'
                 then hiredate
            end) as jones_hd
   from emp
  where ename in ( 'BLAKE','JONES' )
        ) x,
        t500
  where t500.id <= datediff(day,jones_hd-blake_hd)+1
--------------------------------------------------------------------
select case when ename = 'BLAKE'
            then hiredate
       end as blake_hd,
       case when ename = 'JONES'
            then hiredate
       end as jones_hd
  from emp
 where ename in ( 'BLAKE','JONES' )
--------------------------------------------------------------------
select max(case when ename = 'BLAKE'
            then hiredate
       end) as blake_hd,
       max(case when ename = 'JONES'
            then hiredate
       end) as jones_hd
  from emp
 where ename in ( 'BLAKE','JONES' )
--------------------------------------------------------------------
select x.*, t500.*, jones_hd+t500.id-1
  from (
select max(case when ename = 'BLAKE'
                then hiredate
           end) as blake_hd,
       max(case when ename = 'JONES'
                then hiredate
           end) as jones_hd
  from emp
 where ename in ( 'BLAKE','JONES' )
       ) x,
       t500
 where t500.id <= blake_hd-jones_hd+1

8.4 두 날짜 사이의 월 또는 년 수 알아내기
<DB2와 MySQL>
 select mnth, mnth/12
   from (
 select (year(max_hd) - year(min_hd))*12 +
        (month(max_hd) - month(min_hd)) as mnth
   from (
 select min(hiredate) as min_hd, max(hiredate) as max_hd
   from emp
        ) x
        ) y

<Oracle>
 select months_between(max_hd,min_hd),
        months_between(max_hd,min_hd)/12
   from (
 select min(hiredate) min_hd, max(hiredate) max_hd
   from emp
        ) x

<PostgreSQL>
  select mnth, mnth/12
    from (
  select ( extract(year from max_hd)
           extract(year from min_hd) ) * 12
         +
         ( extract(month from max_hd)
           extract(month from min_hd) ) as mnth
    from (
  select min(hiredate) as min_hd, max(hiredate) as max_hd
   from emp
        ) x
        ) y

<SQL Server>
 select datediff(month,min_hd,max_hd),
        datediff(year,min_hd,max_hd)
   from (
 select min(hiredate) min_hd, max(hiredate) max_hd
   from emp
        ) x
--------------------------------------------------------------------
<DB2, MySQL, PostgreSQL>
select min(hiredate) as min_hd,
       max(hiredate) as max_hd
  from emp
--------------------------------------------------------------------
select year(max_hd) as max_yr, year(min_hd) as min_yr,
       month(max_hd) as max_mon, month(min_hd) as min_mon
  from (
select min(hiredate) as min_hd, max(hiredate) as max_hd
  from emp
       ) x

<Oracle과 SQL Server>
select min(hiredate) as min_hd, max(hiredate) as max_hd
  from emp

8.5 두 날짜 사이의 시, 분, 초 알아내기
<DB2>
 select dy*24 hr, dy*24*60 min, dy*24*60*60 sec
   from (
  select ( days(max(case when ename = 'WARD'
                    then hiredate
               end)) -
           days(max(case when ename = 'ALLEN'
                    then hiredate
               end))
         ) as dy
   from emp
        ) x

<MySQL>
 select datediff(day,allen_hd,ward_hd)*24 hr,
         datediff(day,allen_hd,ward_hd)*24*60 min,
         datediff(day,allen_hd,ward_hd)*24*60*60 sec
    from (
  select max(case when ename = 'WARD'
                   then hiredate
             end) as ward_hd,
         max(case when ename = 'ALLEN'
                  then hiredate
            end) as allen_hd
   from emp
        ) x

<SQL Server>
 select datediff(day,allen_hd,ward_hd,hour) as hr,
         datediff(day,allen_hd,ward_hd,minute) as min,
         datediff(day,allen_hd,ward_hd,second) as sec
    from (
  select max(case when ename = 'WARD'
                   then hiredate
             end) as ward_hd,
         max(case when ename = 'ALLEN'
                  then hiredate
            end) as allen_hd
   from emp
        ) x

<Oracle과 PostgreSQL>
 select dy*24 as hr, dy*24*60 as min, dy*24*60*60 as sec
    from (
  select (max(case when ename = 'WARD'
                  then hiredate
             end) -
         max(case when ename = 'ALLEN'
                  then hiredate
             end)) as dy
    from emp
        ) x
--------------------------------------------------------------------
select max(case when ename = 'WARD'
                 then hiredate
           end) as ward_hd,
       max(case when ename = 'ALLEN'
                then hiredate
           end) as allen_hd
  from emp

8.6. 1년 중 평일 발생 횟수 계산하기
<DB2>
 with x (start_date,end_date)
  as (
  select start_date,
         start_date + 1 year end_date
    from (
  select (current_date
          dayofyear(current_date) day)
          +1 day as start_date
    from t1
        ) tmp
  union all
 select start_date + 1 day, end_date
   from x
  where start_date + 1 day < end_date
 )
 select dayname(start_date),count(*)
   from x
  group by dayname(start_date)

<MySQL>
 select date_format(
            date_add(
                cast(
              concat(year(current_date),'-01-01')
                     as date),
                     interval t500.id-1 day),
                     '%W') day,
         count(*)
    from t500
  where t500.id <= datediff(
                          cast(
                        concat(year(current_date)+1,'-01-01')
                               as date),
                          cast(
                        concat(year(current_date),'-01-01')
                               as date))
 group by date_format(
             date_add(
                 cast(
               concat(year(current_date),'-01-01')
                      as date),
                      interval t500.id-1 day),
                      '%W')

<Oracle>
 with x as (
  select level lvl
    from dual
   connect by level <= (
     add_months(trunc(sysdate,'y'),12)-trunc(sysdate,'y')
   )
  )
  select to_char(trunc(sysdate,'y')+lvl-1,'DAY'), count(*)
    from x
  group by to_char(trunc(sysdate,'y')+lvl-1,'DAY')

<PostgreSQL>
 select to_char(
            cast(
      date_trunc('year',current_date)
                 as date) + gs.id-1,'DAY'),
         count(*)
    from generate_series(1,366) gs(id)
   where gs.id <= (cast
                       ( date_trunc('year',current_date) +
                            interval '12 month' as date) -
 cast(date_trunc('year',current_date)
                       as date))
  group by to_char(
              cast(
        date_trunc('year',current_date)
           as date) + gs.id-1,'DAY')

<SQL Server>
 with x (start_date,end_date)
  as (
  select start_date,
         dateadd(year,1,start_date) end_date
    from (
  select cast(
         cast(year(getdate()) as varchar) + '-01-01'
              as datetime) start_date
   from t1
        ) tmp
 union all
 select dateadd(day,1,start_date), end_date
   from x
  where dateadd(day,1,start_date) < end_date
 )
 select datename(dw,start_date),count(*)
   from x
  group by datename(dw,start_date)
 OPTION (MAXRECURSION 366)
--------------------------------------------------------------------
<DB2>
select (current_date
        dayofyear(current_date) day)
        +1 day as start_date
  from t1
--------------------------------------------------------------------
select start_date,
       start_date + 1 year end_date
  from (
select (current_date
        dayofyear(current_date) day)
        +1 day as start_date
  from t1
       ) tmp
--------------------------------------------------------------------
with x (start_date,end_date)
as (
select start_date,
       start_date + 1 year end_date
  from (
select (current_date -
        dayofyear(current_date) day)
        +1 day as start_date
  from t1
       ) tmp
 union all
select start_date + 1 day, end_date
  from x
 where start_date + 1 day < end_date
)
select * from x
--------------------------------------------------------------------
with x (start_date,end_date)
as (
select start_date,
       start_date + 1 year end_date
  from (
select (
             current_date -
        dayofyear(current_date) day)
        +1 day as start_date
  from t1
       ) tmp
 union all
select start_date + 1 day, end_date
  from x
 where start_date + 1 day < end_date
)
select dayname(start_date),count(*)
  from x
 group by dayname(start_date)

<MySQL>
select concat(year(current_date),'-01-01')
  from t1
--------------------------------------------------------------------
select date_format(
          date_add(
              cast(
            concat(year(current_date),'-01-01')
                   as date),
                   interval t500.id-1 day),
                   '%W') day
  from t500
 where t500.id <= datediff(
                         cast(
                       concat(year(current_date)+1,'-01-01')
                              as date),
                         cast(
                       concat(year(current_date),'-01-01')
                             as date))
--------------------------------------------------------------------
select date_format(
          date_add(
              cast(
            concat(year(current_date),'-01-01')
                   as date),
                   interval t500.id-1 day),
                   '%W') day,
       count(*)
  from t500
 where t500.id <= datediff(
                         cast(
                       concat(year(current_date)+1,'-01-01')
                              as date),
                         cast(
                       concat(year(current_date),'-01-01')
                              as date))
 group by date_format(
             date_add(
                 cast(
               concat(year(current_date),'-01-01')
                      as date),
                     interval t500.id-1 day),
                     '%W')
<Oracle>
/* Oracle 9i 이상 버전 */
with x as (
select level lvl
  from dual
 connect by level <= (
   add_months(trunc(sysdate,'y'),12)-trunc(sysdate,'y')
 )
)
select trunc(sysdate,'y')+lvl-1	  from x
--------------------------------------------------------------------
/* Oracle 8i 이하 버전 */
select trunc(sysdate,'y')+rownum-1 start_date
  from t500
 where rownum <= (add_months(trunc(sysdate,'y'),12)
                     - trunc(sysdate,'y'))
--------------------------------------------------------------------
/* Oracle 9i 이상 버전 */
with x as (
select level lvl
  from dual
 connect by level <= (
   add_months(trunc(sysdate,'y'),12)-trunc(sysdate,'y')
 )
)
select to_char(trunc(sysdate,'y')+lvl-1,'DAY'), count(*)
  from x
 group by to_char(trunc(sysdate,'y')+lvl-1,'DAY')
--------------------------------------------------------------------
/* Oracle 8i 이하 버전 */
select to_char(trunc(sysdate,'y')+rownum-1,'DAY') start_date,
       count(*)
  from t500
 where rownum <= (add_months(trunc(sysdate,'y'),12)
                     - trunc(sysdate,'y'))
 group by to_char(trunc(sysdate,'y')+rownum-1,'DAY')

<PostgreSQL>
select cast(
         date_trunc('year',current_date)
         as date) as start_date
  from t1
--------------------------------------------------------------------
select cast( date_trunc('year',current_date)
               as date) + gs.id-1 as start_date
  from generate_series (1,366) gs(id)
 where gs.id <= (cast
                     ( date_trunc('year',current_date) +
                          interval '12 month' as date) -
     cast(date_trunc('year',current_date)
                      as date))
--------------------------------------------------------------------
select to_char(
          cast(
    date_trunc('year',current_date)
               as date) + gs.id-1,'DAY') as start_dates,
       count(*)
  from generate_series(1,366) gs(id)
 where gs.id <= (cast
                     ( date_trunc('year',current_date) +
                         interval '12 month' as date) -
     cast(date_trunc('year',current_date)
                      as date))
 group by to_char(
             cast(
       date_trunc('year',current_date)
          as date) + gs.id-1,'DAY')

<SQL Server>
select cast(
       cast(year(getdate()) as varchar) + '-01-01'
            as datetime) start_date
  from t1
--------------------------------------------------------------------
select start_date,
        dateadd(year,1,start_date) end_date
  from (
select cast(
       cast(year(getdate()) as varchar) + '-01-01'
            as datetime) start_date
  from t1
       ) tmp
--------------------------------------------------------------------
with x (start_date,end_date)
 as (
 select start_date,
        dateadd(year,1,start_date) end_date
   from (
 select cast(
        cast(year(getdate()) as varchar) + '-01-01'
             as datetime) start_date
   from t1
        ) tmp
 union all
 select dateadd(day,1,start_date), end_date
   from x
  where dateadd(day,1,start_date) < end_date
 )
 select * from x
 OPTION (MAXRECURSION 366)
--------------------------------------------------------------------
with x(start_date,end_date)
 as (
 select start_date,
        dateadd(year,1,start_date) end_date
   from (
 select cast(
        cast(year(getdate()) as varchar) + '-01-01'
             as datetime) start_date
   from t1
        ) tmp
 union all
 select dateadd(day,1,start_date), end_date
   from x
  where dateadd(day,1,start_date) < end_date
 )
 select datename(dw,start_date), count(*)
   from x
  group by datename(dw,start_date)
 OPTION (MAXRECURSION 366)

8.7 현재 레코드와 다음 레코드 간의 날짜 차이 알아내기
<DB2>
 select x.*,
        days(x.next_hd) - days(x.hiredate) diff
   from (
 select e.deptno, e.ename, e.hiredate,
        lead(hiredate)over(order by hiredate) next_hd
   from emp e
  where e.deptno = 10
        ) x

<MySQL과 SQL Server>
 select x.ename, x.hiredate, x.next_hd,
        datediff(x.hiredate,x.next_hd,day) as diff
   from (
 select deptno, ename, hiredate,
        lead(hiredate)over(order by hiredate) as next_hd
   from emp e
        ) x
  where e.deptno=10

<Oracle>
 select ename, hiredate, next_hd,
        next_hd - hiredate diff
   from (
 select deptno, ename, hiredate,
        lead(hiredate)over(order by hiredate) next_hd
   from emp
        )
  where deptno=10

<PostgreSQL>
 select x.*,
        x.next_hd - x.hiredate as diff
   from (
 select e.deptno, e.ename, e.hiredate,
        lead(hiredate)over(order by hiredate) as next_hd
   from emp e
  where e.deptno = 10
        ) x
--------------------------------------------------------------------
select ename, hiredate
  from emp
 where deptno=10
 order by 2
--------------------------------------------------------------------
insert into emp (empno,ename,deptno,hiredate)
values (1,'ant',10,to_date('17-NOV-2006'))
--------------------------------------------------------------------
insert into emp (empno,ename,deptno,hiredate)
values (2,'joe',10,to_date('17-NOV-2006'))
--------------------------------------------------------------------
insert into emp (empno,ename,deptno,hiredate)
values (3,'jim',10,to_date('17-NOV-2006'))
--------------------------------------------------------------------
insert into emp (empno,ename,deptno,hiredate)
values (4,'choi',10,to_date('17-NOV-2006'))
--------------------------------------------------------------------
select ename, hiredate
  from emp
 where deptno=10
 order by 2
--------------------------------------------------------------------
select ename, hiredate, next_hd,
       next_hd - hiredate diff
  from (
select deptno, ename, hiredate,
       lead(hiredate)over(order by hiredate) next_hd
  from emp
 where deptno=10
        )
--------------------------------------------------------------------
select ename, hiredate, next_hd,
       next_hd - hiredate diff
  from (
select deptno, ename, hiredate,
       lead(hiredate,cnt-rn+1)over(order by hiredate) next_hd
  from (
select deptno,ename,hiredate,
       count(*)over(partition by hiredate) cnt,
       row_number()over(partition by hiredate order by empno) rn
  from emp
 where deptno=10
        )
        )
--------------------------------------------------------------------
select deptno,ename,hiredate,
       count(*)over(partition by hiredate) cnt,
       row_number()over(partition by hiredate order by empno) rn
  from emp
 where deptno=10
--------------------------------------------------------------------
select deptno, ename, hiredate,
       cnt-rn+1 distance_to_miller,
       lead(hiredate,cnt-rn+1)over(order by hiredate) next_hd
  from (
select deptno,ename,hiredate,
       count(*)over(partition by hiredate) cnt,
       row_number()over(partition by hiredate order by empno) rn
  from emp
 where deptno=10
        )