Chapter 12 보고서 작성과 재구성하기

12.1 결과셋을 하나의 행으로 피벗하기
 select sum(case when deptno=10 then 1 else 0 end) as deptno_10,
        sum(case when deptno=20 then 1 else 0 end) as deptno_20,
        sum(case when deptno=30 then 1 else 0 end) as deptno_30
   from emp
--------------------------------------------------------------------
select deptno,
       case when deptno=10 then 1 else 0 end as deptno_10,
       case when deptno=20 then 1 else 0 end as deptno_20,
       case when deptno=30 then 1 else 0 end as deptno_30
  from emp
 order by 1
--------------------------------------------------------------------
select deptno,
       sum(case when deptno=10 then 1 else 0 end) as deptno_10,
       sum(case when deptno=20 then 1 else 0 end) as deptno_20,
       sum(case when deptno=30 then 1 else 0 end) as deptno_30
  from emp
 group by deptno
--------------------------------------------------------------------
select sum(case when deptno=10 then 1 else 0 end) as deptno_10,
       sum(case when deptno=20 then 1 else 0 end) as deptno_20,
       sum(case when deptno=30 then 1 else 0 end) as deptno_30
  from emp
--------------------------------------------------------------------
select max(case when deptno=10 then empcount else null end) as deptno_10
       max(case when deptno=20 then empcount else null end) as deptno_20,
       max(case when deptno=10 then empcount else null end) as deptno_30
  from (
select deptno, count(*) as empcount
  from emp
 group by deptno
       ) x

12.2 결과셋을 여러 행으로 피벗하기
  select max(case when job='CLERK'
                   then ename else null end) as clerks,
          max(case when job='ANALYST'
                   then ename else null end) as analysts,
          max(case when job='MANAGER'
                   then ename else null end) as mgrs,
          max(case when job='PRESIDENT'
                   then ename else null end) as prez,
          max(case when job='SALESMAN'
                  then ename else null end) as sales
   from (
 select job,
        ename,
        row_number()over(partition by job order by ename) rn
   from emp
        ) x
  group by rn
--------------------------------------------------------------------
select job,
       ename,
       row_number()over(partition by job order by ename) rn
  from emp
--------------------------------------------------------------------
select max(case when job='CLERK'
                then ename else null end) as clerks,
       max(case when job='ANALYST'
                then ename else null end) as analysts,
       max(case when job='MANAGER'
                then ename else null end) as mgrs,
       max(case when job='PRESIDENT'
                then ename else null end) as prez,
       max(case when job='SALESMAN'
                then ename else null end) as sales
  from emp
--------------------------------------------------------------------
select rn,
       case when job='CLERK'
            then ename else null end as clerks,
       case when job='ANALYST'
            then ename else null end as analysts,
       case when job='MANAGER'
            then ename else null end as mgrs,
       case when job='PRESIDENT'
            then ename else null end as prez,
       case when job='SALESMAN'
            then ename else null end as sales
  from (
select job,
       ename,
       row_number()over(partition by job order by ename) rn
  from emp
       ) x
--------------------------------------------------------------------
select max(case when job='CLERK'
                then ename else null end) as clerks,
       max(case when job='ANALYST'
                then ename else null end) as analysts,
       max(case when job='MANAGER'
                then ename else null end) as mgrs,
       max(case when job='PRESIDENT'
                then ename else null end) as prez,
       max(case when job='SALESMAN'
                then ename else null end) as sales
  from (
select job,
       ename,
       row_number()over(partition by job order by ename) rn
  from emp
       ) x
group by rn
--------------------------------------------------------------------
select deptno dno, job,
       max(case when deptno=10
                then ename else null end) as d10,
       max(case when deptno=20
                then ename else null end) as d20,
       max(case when deptno=30
                then ename else null end) as d30,
       max(case when job='CLERK'
                then ename else null end) as clerks,
       max(case when job='ANALYST'
                then ename else null end) as anals,
       max(case when job='MANAGER'
                then ename else null end) as mgrs,
       max(case when job='PRESIDENT'
                then ename else null end) as prez,
       max(case when job='SALESMAN'
                then ename else null end) as sales
  from (
Select deptno,
       job,
       ename,
       row_number()over(partition by job order by ename) rn_job,
       row_number()over(partition by deptno order by ename) rn_deptno
  from emp
       ) x
 group by deptno, job, rn_deptno, rn_job
 order by 1

12.3 결과셋 역피벗하기
create view emp_cnts as
(
select sum(case when deptno=10 then 1 else 0 end) as deptno_10,
          sum(case when deptno=20 then 1 else 0 end) as deptno_20,
          sum(case when deptno=30 then 1 else 0 end) as deptno_30
     from emp
)
--------------------------------------------------------------------
 select dept.deptno,
         case dept.deptno
              when 10 then emp_cnts.deptno_10
              when 20 then emp_cnts.deptno_20
              when 30 then emp_cnts.deptno_30
         end as counts_by_dept
    from emp_cnts cross join
         (select deptno from dept where deptno <= 30) dept
--------------------------------------------------------------------
select dept.deptno,
         emp_cnts.deptno_10,
         emp_cnts.deptno_20,
         emp_cnts.deptno_30
    from (
  Select sum(case when deptno=10 then 1 else 0 end) as deptno_10,
         sum(case when deptno=20 then 1 else 0 end) as deptno_20,
         sum(case when deptno=30 then 1 else 0 end) as deptno_30
    from emp
         ) emp_cnts,
         (select deptno from dept where deptno <= 30) dept
--------------------------------------------------------------------
select dept.deptno,
         case dept.deptno
              when 10 then emp_cnts.deptno_10
              when 20 then emp_cnts.deptno_20
              when 30 then emp_cnts.deptno_30
         end as counts_by_dept
    from (
         emp_cnts
cross join (select deptno from dept where deptno <= 30) dept

12.4 결과셋을 한 열로 역피벗하기
   with four_rows (id)
     as
   (
    select 1
      union all
    select id+1
      from four_rows
      where id < 4
    )
   ,
    x_tab (ename,job,sal,rn )
     as
   (
      select  e.ename,e.job,e.sal,
      row_number()over(partition by e.empno
      order by e.empno)
      from emp e
      join four_rows on 1=1
    )

   select
     case rn
     when 1 then ename
     when 2 then job
     when 3 then cast(sal as char(4))
    end emps
  from x_tab
--------------------------------------------------------------------
select e.ename,e.job,e.sal,
       row_number()over(partition by e.empno
                  order by e.empno) rn
from emp e
 where e.deptno=10
--------------------------------------------------------------------
with four_rows (id)
  as
(select 1
From dual
  union all
  select id+1
  from four_rows
  where id < 4
  )
 select e.ename,e.job,e.sal,
 row_number()over(partition by e.empno
 order by e.empno)
  from emp e
  join four_rows on 1=1
--------------------------------------------------------------------
 with four_rows (id)
  as
(select 1
From dual
  union all
  select id+1
  from four_rows
  where id < 4
  )
  ,
  x_tab (ename,job,sal,rn )
  as
  (select e.ename,e.job,e.sal,
 row_number()over(partition by e.empno
 order by e.empno)
  from emp e
  join four_rows on 1=1)

   select case rn
  when 1 then ename
  when 2 then job
  when 3 then cast(sal as char(4))
 end emps
  from x_tab

12.5 결과셋에서 반복값 숨기기
   select
           case when
              lag(deptno)over(order by deptno) = deptno then null
              else deptno end DEPTNO
       , ename
    from emp
Oracle 
 select to_number(
           decode(lag(deptno)over(order by deptno),
                 deptno,null,deptno)
        ) deptno, ename
   from emp
--------------------------------------------------------------------
select lag(deptno)over(order by deptno) lag_deptno,
       deptno,
       ename
  from emp
--------------------------------------------------------------------
select to_number(
           CASE WHEN (lag(deptno)over(order by deptno)
= deptno THEN null else deptno END deptno,
                 deptno,null,deptno)
        ) deptno, ename
  from emp

12.6 행 간 계산하는 결과셋 피벗하기
select deptno, sum(sal) as sal
  from emp
 group by deptno
--------------------------------------------------------------------
 select d20_sal - d10_sal as d20_10_diff,
        d20_sal - d30_sal as d20_30_diff
   from (
 select sum(case when deptno=10 then sal end) as d10_sal,
        sum(case when deptno=20 then sal end) as d20_sal,
        sum(case when deptno=30 then sal end) as d30_sal
   from emp
        ) totals_by_dept
--------------------------------------------------------------------
with totals_by_dept (d10_sal, d20_sal, d30_sal)
as
(select
          sum(case when deptno=10 then sal end) as d10_sal,
          sum(case when deptno=20 then sal end) as d20_sal,
          sum(case when deptno=30 then sal end) as d30_sal

from emp)

select   d20_sal - d10_sal as d20_10_diff,
         d20_sal - d30_sal as d20_30_diff
  from   totals_by_dept
--------------------------------------------------------------------
select case when deptno=10 then sal end as d10_sal,
       case when deptno=20 then sal end as d20_sal,
       case when deptno=30 then sal end as d30_sal
  from emp
--------------------------------------------------------------------
select sum(case when deptno=10 then sal end) as d10_sal,
       sum(case when deptno=20 then sal end) as d20_sal,
       sum(case when deptno=30 then sal end) as d30_sal
  from emp

12.7 고정 크기의 데이터 버킷 생성하기
 select ceil(row_number()over(order by empno)/5.0) grp,
        empno,
        ename
   from emp
--------------------------------------------------------------------
select row_number()over(order by empno) rn,
       empno,
       ename
  from emp
--------------------------------------------------------------------
select row_number()over(order by empno) rn,
       row_number()over(order by empno)/5.0 division,
       ceil(row_number()over(order by empno)/5.0) grp,
       empno,
       ename
  from emp

12.8. 사전 정의된 수의 버킷 생성하기
 select ntile(4)over(order by empno) grp,
        empno,
        ename
   from emp

12.9. 수평 히스토그램 생성하기
< DB2>
 select deptno,
        repeat('*',count(*)) cnt
   from emp
  group by deptno

<Oracle, PostgreSQL, MySQL>
 select deptno,
        lpad('*',count(*),'*') as cnt
   from emp
  group by deptno

< SQL Server>
 select deptno,
        replicate('*',count(*)) cnt
   from emp
  group by deptno
--------------------------------------------------------------------
select deptno,
       count(*)
  from emp
 group by deptno
--------------------------------------------------------------------
select deptno,
       lpad('*',count(*),'*') as cnt
  from emp
 group by deptno
--------------------------------------------------------------------
select deptno,
       lpad('*',count(*)::integer,'*') as cnt
  from emp
 group by deptno

12.10. 수직 히스토그램 생성하기
 select max(deptno_10) d10,
         max(deptno_20) d20,
         max(deptno_30) d30
    from (
  select row_number()over(partition by deptno order by empno) rn,
         case when deptno=10 then '*' else null end deptno_10,
         case when deptno=20 then '*' else null end deptno_20,
         case when deptno=30 then '*' else null end deptno_30
    from emp
        ) x
  group by rn
  order by 1 desc, 2 desc, 3 desc
--------------------------------------------------------------------
select row_number()over(partition by deptno order by empno) rn,
       case when deptno=10 then '*' else null end deptno_10,
       case when deptno=20 then '*' else null end deptno_20,
       case when deptno=30 then '*' else null end deptno_30
  from emp
--------------------------------------------------------------------
select max(deptno_10) d10,
       max(deptno_20) d20,
       max(deptno_30) d30
  from (
select row_number()over(partition by deptno order by empno) rn,
       case when deptno=10 then '*' else null end deptno_10,
       case when deptno=20 then '*' else null end deptno_20,
       case when deptno=30 then '*' else null end deptno_30
  from emp
       ) x
 group by rn
 order by 1 desc, 2 desc, 3 desc

12.11. 비 GROUP BY 열 반환하기
select ename,max(sal)
  from empgroup by ename
--------------------------------------------------------------------
 select deptno,ename,job,sal,
         case when sal = max_by_dept
              then 'TOP SAL IN DEPT'
              when sal = min_by_dept
              then 'LOW SAL IN DEPT'
         end dept_status,
         case when sal = max_by_job
              then 'TOP SAL IN JOB'
              when sal = min_by_job
             then 'LOW SAL IN JOB'
        end job_status
   from (
 select deptno,ename,job,sal,
        max(sal)over(partition by deptno) max_by_dept,
        max(sal)over(partition by job)   max_by_job,
        min(sal)over(partition by deptno) min_by_dept,
        min(sal)over(partition by job)   min_by_job
   from emp
        ) emp_sals
  where sal in (max_by_dept,max_by_job,
                min_by_dept,min_by_job)
--------------------------------------------------------------------
select deptno,ename,job,sal,
       max(sal)over(partition by deptno) maxDEPT,
       max(sal)over(partition by job) maxJOB,
       min(sal)over(partition by deptno) minDEPT,
       min(sal)over(partition by job) minJOB
  from emp
--------------------------------------------------------------------
select deptno,ename,job,sal,
       case when sal = max_by_dept
            then 'TOP SAL IN DEPT'
            when sal = min_by_dept
            then 'LOW SAL IN DEPT'
       end dept_status,
       case when sal = max_by_job
            then 'TOP SAL IN JOB'
            when sal = min_by_job
            then 'LOW SAL IN JOB'
       end job_status
  from (
select deptno,ename,job,sal,
       max(sal)over(partition by deptno) max_by_dept,
       max(sal)over(partition by job) max_by_job,
       min(sal)over(partition by deptno) min_by_dept,
       min(sal)over(partition by job) min_by_job
  from emp
       ) x
 where sal in (max_by_dept,max_by_job,
               min_by_dept,min_by_job)

12.12 단순 소계 계산하기
<DB2와 Oracle>
 select case grouping(job)
             when 0 then job
             else 'TOTAL'
        end job,
        sum(sal) sal
   from emp
  group by rollup(job)

<SQL Server와 MySQL>
 select coalesce(job,'TOTAL') job,
        sum(sal) sal
   from emp
  group by job with rollup

<PostgreSQL>
select coalesce(job,'TOTAL') job,
        sum(sal) sal
   from emp
  group by rollup(job)

<DB2와 Oracle>
select job, sum(sal) sal
  from emp
 group by job
--------------------------------------------------------------------
select job, sum(sal) sal
  from emp
 group by rollup(job)
--------------------------------------------------------------------
select case grouping(job)
            when 0 then job
            else 'TOTAL'
       end job,
       sum(sal) sal
  from emp
 group by rollup(job)
<SQL Server와 MySQL>
select job, sum(sal) sal
  from emp
 group by job
--------------------------------------------------------------------
select job, sum(sal) sal
  from emp
 group by job with rollup
--------------------------------------------------------------------
select coalesce(job,'TOTAL') job,
       sum(sal) sal
  from emp
 group by job with rollup

12.13 가능한 모든 식 조합의 소계 계산하기
<DB2>
 select deptno,
         job,
         case cast(grouping(deptno) as char(1))||
              cast(grouping(job) as char(1))
              when '00' then 'TOTAL BY DEPT AND JOB'
              when '10' then 'TOTAL BY JOB'
              when '01' then 'TOTAL BY DEPT'
              when '11' then 'TOTAL FOR TABLE'
         end category,
        sum(sal)
   from emp
  group by cube(deptno,job)
  order by grouping(job),grouping(deptno)
Oracle
 select deptno,
         job,
         case grouping(deptno)||grouping(job)
              when '00' then 'TOTAL BY DEPT AND JOB'
              when '10' then 'TOTAL BY JOB'
              when '01' then 'TOTAL BY DEPT'
              when '11' then 'GRAND TOTALFOR TABLE'
         end category,
         sum(sal) sal
   from emp
  group by cube(deptno,job)
  order by grouping(job),grouping(deptno)

<SQL Server>
 select deptno,
         job,
         case cast(grouping(deptno)as char(1))+
              cast(grouping(job)as char(1))
              when '00' then 'TOTAL BY DEPT AND JOB'
              when '10' then 'TOTAL BY JOB'
              when '01' then 'TOTAL BY DEPT'
              when '11' then 'GRAND TOTAL FOR TABLE'
         end category,
        sum(sal) sal
   from emp
  group by deptno,job with cube
  order by grouping(job),grouping(deptno)
<PostgreSQL>
select deptno,job
,case concat(
cast (grouping(deptno) as char(1)),cast (grouping(job) as char(1))
  )
  when '00' then 'TOTAL BY DEPT AND JOB'
               when '10' then 'TOTAL BY JOB'
               when '01' then 'TOTAL BY DEPT'
               when '11' then 'GRAND TOTAL FOR TABLE'
          end category
  , sum(sal) as sal
    from emp
    group by cube(deptno,job)

<MySQL>
 select deptno, job,
         'TOTAL BY DEPT AND JOB' as category,
         sum(sal) as sal
    from emp
   group by deptno, job
   union all
  select null, job, 'TOTAL BY JOB', sum(sal)
    from emp
   group by job
  union all
 select deptno, null, 'TOTAL BY DEPT', sum(sal)
   from emp
  group by deptno
  union all
 select null,null,'GRAND TOTAL FOR TABLE', sum(sal)
  from emp
--------------------------------------------------------------------
<Oracle, DB2, SQL Server>
select deptno, job, sum(sal) sal
  from emp
 group by deptno, job
--------------------------------------------------------------------
select deptno,
       job,
       sum(sal) sal
  from emp
 group by cube(deptno,job)
--------------------------------------------------------------------
select deptno,
       job,
       grouping(deptno) is_deptno_subtotal,
       grouping(job) is_job_subtotal,
       sum(sal) sal
  from emp
 group by cube(deptno,job)
 order by 3,4
--------------------------------------------------------------------
select deptno,
       job,
       case grouping(deptno)||grouping(job)
            when '00' then 'TOTAL BY DEPT AND JOB'
            when '10' then 'TOTAL BY JOB'
            when '01' then 'TOTAL BY DEPT'
            when '11' then 'GRAND TOTAL FOR TABLE'
       end category,
       sum(sal) sal
  from emp
 group by cube(deptno,job)
 order by grouping(job),grouping(deptno)
--------------------------------------------------------------------
select deptno,
       job,
       case grouping(deptno)||grouping(job)
            when '00' then 'TOTAL BY DEPT AND JOB'
            when '10' then 'TOTAL BY JOB'
            when '01' then 'TOTAL BY DEPT'
            when '11' then 'GRAND TOTAL FOR TABLE'
       end category,
       sum(sal) sal
  from emp
 group by grouping sets ((deptno),(job),(deptno,job),())
--------------------------------------------------------------------
/* grand total 제외 */
select deptno,
       job,
       case grouping(deptno)||grouping(job)
            when '00' then 'TOTAL BY DEPT AND JOB'
            when '10' then 'TOTAL BY JOB'
            when '01' then 'TOTAL BY DEPT'
            when '11' then 'GRAND TOTAL FOR TABLE'
       end category,
       sum(sal) sal
  from emp
 group by grouping sets ((deptno),(job),(deptno,job))
--------------------------------------------------------------------
/* DEPTNO별 소계 제거 */
select deptno,
       job,
       case grouping(deptno)||grouping(job)
            when '00' then 'TOTAL BY DEPT AND JOB'
            when '10' then 'TOTAL BY JOB'
            when '01' then 'TOTAL BY DEPT'
            when '11' then 'GRAND TOTAL FOR TABLE'
       end category,
       sum(sal) sal
  from emp
 group by grouping sets ((job),(deptno,job),())
 order by 3

<MySQL>
select deptno, job,
       'TOTAL BY DEPT AND JOB' as category,
       sum(sal) as sal
  from emp
 group by deptno, job
--------------------------------------------------------------------
select deptno, job,
       'TOTAL BY DEPT AND JOB' as category,
       sum(sal) as sal
  from emp
 group by deptno, job
 union all
select null, job, 'TOTAL BY JOB', sum(sal)
  from emp
 group by job
--------------------------------------------------------------------
select deptno, job,
       'TOTAL BY DEPT AND JOB' as category,
       sum(sal) as sal
  from emp
 group by deptno, job
 union all
select null, job, 'TOTAL BY JOB', sum(sal)
  from emp
 group by job
 union all
select deptno, null, 'TOTAL BY DEPT', sum(sal)
  from emp
 group by deptno
--------------------------------------------------------------------
select deptno, job,
       'TOTAL BY DEPT AND JOB' as category,
       sum(sal) as sal
  from emp
 group by deptno, job
 union all
select null, job, 'TOTAL BY JOB', sum(sal)
  from emp
 group by job
 union all
select deptno, null, 'TOTAL BY DEPT', sum(sal)
  from emp
 group by deptno
 union all
select null,null, 'GRAND TOTAL FOR TABLE', sum(sal)
  from emp

12.14 소계가 아닌 행 식별하기
 select deptno, jo) sal,
         grouping(deptno) deptno_subtotals,
         grouping(job) job_subtotals
    from emp
   group by cube(deptno,job)
--------------------------------------------------------------------
  select deptno, job, sum(sal) sal,
         grouping(deptno) deptno_subtotals,
         grouping(job) job_subtotals
    from emp
   group by deptno,job with cube

12.15 Case 표현식으로 행 플래그 지정하기
 select ename,
         case when job = 'CLERK'
              then 1 else 0
         end as is_clerk,
         case when job = 'SALESMAN'
              then 1 else 0
         end as is_sales,
         case when job = 'MANAGER'
              then 1 else 0
        end as is_mgr,
        case when job = 'ANALYST'
             then 1 else 0
        end as is_analyst,
        case when job = 'PRESIDENT'
             then 1 else 0
        end as is_prez
   from emp
  order by 2,3,4,5,6
--------------------------------------------------------------------
select ename,
       job,
       case when job = 'CLERK'
            then 1 else 0
       end as is_clerk,
       case when job = 'SALESMAN'
            then 1 else 0
       end as is_sales,
       case when job = 'MANAGER'
            then 1 else 0
       end as is_mgr,
       case when job = 'ANALYST'
           then 1 else 0
       end as is_analyst,
       case when job = 'PRESIDENT'
           then 1 else 0
       end as is_prez
  from emp
 order by 2

12.16 희소행렬 만들기
 select case deptno when 10 then ename end as d10,
         case deptno when 20 then ename end as d20,
         case deptno when 30 then ename end as d30,
         case job when 'CLERK' then ename end as clerks,
         case job when 'MANAGER' then ename end as mgrs,
         case job when 'PRESIDENT' then ename end as prez,
         case job when 'ANALYST' then ename end as anals,
         case job when 'SALESMAN' then ename end as sales
    from emp
--------------------------------------------------------------------
select max(case deptno when 10 then ename end) d10,
       max(case deptno when 20 then ename end) d20,
       max(case deptno when 30 then ename end) d30,
       max(case job when 'CLERK' then ename end) clerks,
       max(case job when 'MANAGER' then ename end) mgrs,
       max(case job when 'PRESIDENT' then ename end) prez, 
       max(case job when 'ANALYST' then ename end) anals, 
       max(case job when 'SALESMAN' then ename end) sales
  from ( 
select deptno, job, ename,
       row_number()over(partition by deptno order by empno) rn 
  from emp 
       ) x 
 group by rn

12.17 시간 단위로 행 그룹화하기
select trx_id,
       trx_date,
       trx_cnt
from trx_log
--------------------------------------------------------------------
 select ceil(trx_id/5.0) as grp,
         min(trx_date)    as trx_start,
         max(trx_date)    as trx_end,
         sum(trx_cnt)     as total
    from trx_log
  group by ceil(trx_id/5.0)
--------------------------------------------------------------------
select trx_id,
       trx_date,
       trx_cnt,
       trx_id/5.0 as val,
       ceil(trx_id/5.0) as grp
from trx_log
--------------------------------------------------------------------
select ceil(trx_id/5.0) as grp,
       min(trx_date) as trx_start,
       max(trx_date) as trx_end,
       sum(trx_cnt) as total
  from trx_log
 group by ceil(trx_id/5.0)
--------------------------------------------------------------------
select trx_date,trx_cnt,
       to_number(to_char(trx_date,'hh24')) hr,
       ceil(to_number(to_char(trx_date-1/24/60/60,'miss'))/5.0) grp
  from trx_log
--------------------------------------------------------------------
select hr,grp,sum(trx_cnt) total
  from (
select trx_date,trx_cnt,
       to_number(to_char(trx_date,'hh24')) hr,
       ceil(to_number(to_char(trx_date-1/24/60/60,'miss'))/5.0) grp
  from trx_log
       ) x
 group by hr,grp
--------------------------------------------------------------------
select trx_id, trx_date, trx_cnt,
       sum(trx_cnt)over(partition by ceil(trx_id/5.0)
                        order by trx_date
                        range between unbounded preceding
                          and current row) runing_total,
       sum(trx_cnt)over(partition by ceil(trx_id/5.0)) total,
       case when mod(trx_id,5.0) = 0 then 'X' end grp_end
  from trx_log

12.18 여러 그룹/파티션 집계를 동시 수행하기
select ename,
       deptno,
       count(*)over(partition by deptno) deptno_cnt,
       job,
       count(*)over(partition by job) job_cnt,
       count(*)over() total
  from emp
--------------------------------------------------------------------
count(*)over(partition by deptno)
--------------------------------------------------------------------
count(*)over(partition by job)
--------------------------------------------------------------------
count(*)over()

12.19 값의 이동 범위에 대한 집계 수행하기
<DB2>
    select hiredate,
           sal,
           sum(sal)over(order by days(hiredate)
                          range between 90 preceding
                             and current row) spending_pattern
      from emp e

<Oracle>
    select hiredate,
           sal,
           sum(sal)over(order by hiredate
                           range between 90 preceding
                             and current row) spending_pattern
      from emp e

<MySQL>
  select hiredate,
          sal,
          sum(sal)over(order by hiredate
              range interval 90 day preceding ) spending_pattern
  from emp e

<PostgreSQL과 SQL Server>
 select e.hiredate,
         e.sal,
         (select sum(sal) from emp d
           whered.hiredate between e.hiredate-90
                               and e.hiredate) as spending_pattern
    from emp e
   order by 1

<DB2, MySQL, Oracle>
select distinct
       dense_rank()over(order by e.hiredate) window,
       e.hiredate current_hiredate,
       d.hiredate hiredate_within_90_days,
       d.sal sals_used_for_sum
  from emp e,
       emp d
where d.hiredate between e.hiredate-90 and e.hiredate
--------------------------------------------------------------------
select current_hiredate,
       sum(sals_used_for_sum) spending_pattern
  from (
select distinct
       dense_rank()over(order by e.hiredate) window,
       e.hiredate current_hiredate,
       d.hiredate hiredate_within_90_days,
       d.sal sals_used_for_sum
  from emp e,
       emp d
  where d.hiredate between e.hiredate-90 and e.hiredate
        ) x
  group by current_hiredate

<PostgreSQL과 SQL Server>
select e.hiredate,
       e.sal,
       sum(d.sal) as spending_pattern
  from emp e, emp d
 where d.hiredate
       between e.hiredate-90 and e.hiredate
 group by e.hiredate,e.sal
 order by 1
--------------------------------------------------------------------
select e.hiredate,
       e.sal,
       d.sal,
       d.hiredate
  from emp e, emp d
--------------------------------------------------------------------
select e.hiredate,
       e.sal,
       d.sal sal_to_sum,
       d.hiredate within_90_days
  from emp e, emp d
 where d.hiredate
       between e.hiredate-90 and e.hiredate
 order by 1

select e.hiredate,
       e.sal,
       sum(d.sal) as spending_pattern
  from emp e, emp d
 where d.hiredate
       between e.hiredate-90 and e.hiredate
 group by e.hiredate,e.sal
 order by 1
--------------------------------------------------------------------
select e.hiredate,
       e.sal,
       (select sum(sal) from emp d
        where d.hiredate between e.hiredate-90
                             and e.hiredate) as spending_pattern
  from emp e
 order by 1

12.20 소계를 사용한 결과셋 피벗하기
<DB2와 Oracle>
 select mgr,
         sum(case deptno when 10 then sal else 0 end) dept10,
         sum(case deptno when 20 then sal else 0 end) dept20,
         sum(case deptno when 30 then sal else 0 end) dept30,
         sum(case flag when '11' then sal else null end) total
    from (
  select deptno,mgr,sum(sal) sal,
         cast(grouping(deptno) as char(1))||
         cast(grouping(mgr) as char(1)) flag
   from emp
  where mgr is not null
  group by rollup(deptno,mgr)
        ) x
  group by mgr

<SQL Server>
 select mgr,
         sum(case deptno when 10 then sal else 0 end) dept10,
         sum(case deptno when 20 then sal else 0 end) dept20,
         sum(case deptno when 30 then sal else 0 end) dept30,
         sum(case flag when '11' then sal else null end) total
    from (
  select deptno,mgr,sum(sal) sal,
         cast(grouping(deptno) as char(1))+
         cast(grouping(mgr) as char(1)) flag
   from emp
  where mgr is not null
  group by deptno,mgr with rollup
        ) x
  group by mgr

<PostgreSQL>
   select mgr,
           sum(case deptno when 10 then sal else 0 end) dept10,
           sum(case deptno when 20 then sal else 0 end) dept20,
           sum(case deptno when 30 then sal else 0 end) dept30,
           sum(case flag when '11' then sal else null end) total
      from (
    select deptno,mgr,sum(sal) sal,
           concat(cast (grouping(deptno) as char(1)),
           cast(grouping(mgr) as char(1))) flag
   from emp
   where mgr is not null
   group by rollup (deptno,mgr)
        ) x
   group by mgr

<MySQL>
    select mgr,
          sum(case deptno when 10 then sal else 0 end) dept10,
          sum(case deptno when 20 then sal else 0 end) dept20,
          sum(case deptno when 30 then sal else 0 end) dept30,
          sum(case flag when '11' then sal else null end) total
     from (
    select  deptno,mgr,sum(sal) sal,
            concat( cast(grouping(deptno) as char(1)) ,
            cast(grouping(mgr) as char(1))) flag
   from emp
  where mgr is not null
   group by deptno,mgr with rollup
         ) x
   group by mgr;
--------------------------------------------------------------------
select deptno,mgr,sum(sal) sal
  from emp
 where mgr is not null
 group by mgr,deptno
 order by 1,2
--------------------------------------------------------------------
select deptno,mgr,sum(sal) sal
  from emp
 where mgr is not null
 group by deptno,mgr with rollup
--------------------------------------------------------------------
select deptno,mgr,sum(sal) sal,
       cast(grouping(deptno) as char(1))+
       cast(grouping(mgr) as char(1)) flag
  from emp
 where mgr is not null
 group by deptno,mgr with rollup
--------------------------------------------------------------------
select mgr,
       sum(case deptno when 10 then sal else 0 end) dept10,
       sum(case deptno when 20 then sal else 0 end) dept20,
       sum(case deptno when 30 then sal else 0 end) dept30,
       sum(case flag when '11' then sal else null end) total
  from (
select deptno,mgr,sum(sal) sal,
       cast(grouping(deptno) as char(1))+
       cast(grouping(mgr) as char(1)) flag
  from emp
 where mgr is not null
 group by deptno,mgr with rollup
       ) x
 group by mgr
 order by coalesce(mgr,9999)