부록 A. 윈도 함수 리프레셔

A.1 그룹화
select deptno,ename
  from emp
 where deptno=10
--------------------------------------------------------------------
select deptno,
       count(*) as cnt,
       max(sal) as hi_sal,
       min(sal) as lo_sal
  from emp
 where deptno=10
 group by deptno

A.1.1 SQL 그룹의 정의
create table fruits (name varchar(10))
--------------------------------------------------------------------
select name
  from fruits
 group by name
--------------------------------------------------------------------
select count(*) as cnt
  from fruits
 group by name
--------------------------------------------------------------------
select name, count(*) as cnt
  from fruits
 group by name
--------------------------------------------------------------------
insert into fruits values ('Oranges')
insert into fruits values ('Oranges')
insert into fruits values ('Oranges')
insert into fruits values ('Apple')
insert into fruits values ('Peach')
--------------------------------------------------------------------
select *
from fruits
--------------------------------------------------------------------
select name
  from fruits
 group by name
--------------------------------------------------------------------
select name, count(*) as cnt
  from fruits
 group by name

A.1.2 역설
select *
  from fruits
--------------------------------------------------------------------
insert into fruits values (null)
insert into fruits values (null)
insert into fruits values (null)
insert into fruits values (null)
insert into fruits values (null)
--------------------------------------------------------------------
select coalesce(name,'NULL') as name
  from fruits
--------------------------------------------------------------------
select coalesce(name,'NULL') as name,
       count(name) as cnt
  from fruits
 group by name
--------------------------------------------------------------------
select coalesce(name,'NULL') as name,
       count(*) as cnt
  from fruits
 group by name
--------------------------------------------------------------------
select coalesce(name,'NULL') as name,
       count(*) as cnt
  from fruits
 group by name
 union all
select coalesce(name,'NULL') as name,
       count(*) as cnt
  from fruits
 group by name
--------------------------------------------------------------------
select x.*
  from (
select coalesce(name,'NULL') as name,
       count(*) as cnt
  from fruits
 group by name
       ) x,
       (select deptno from dept) y

A.1.3 SELECT와 GROUP BY의 관계
select deptno, count(*) as cnt
  from emp
--------------------------------------------------------------------
select deptno, count(*) as cnt
  from emp
 group by deptno
--------------------------------------------------------------------
select 'hello' as msg,
       1 as num,
       deptno,
       (select count(*) from emp) as total,
       count(*) as cnt
  from emp
 group by deptno
--------------------------------------------------------------------
select deptno, job, count(*) as cnt
  from emp
 group by deptno, job
--------------------------------------------------------------------
select count(*)
  from emp
 group by deptno
--------------------------------------------------------------------
select count(*)
  from emp
 group by deptno,job

A.2 윈도 설정

A.2.1 간단한 예제
select count(*) as cnt
  from emp
--------------------------------------------------------------------
select ename,
       deptno,
       count(*) over() as cnt
  from emp
 order by 2

A.2.2 평가의 순서
select ename,
       deptno,
       count(*) over() as cnt
  from emp
 where deptno = 10
 order by 2

A.2.3 파티션
select ename,
       deptno,
       count(*) over(partition by deptno) as cnt
  from emp
 order by 2
--------------------------------------------------------------------
select e.ename,
       e.deptno,
       (select count(*) from emp d
         where e.deptno=d.deptno) as cnt
  from emp e
 order by 2
--------------------------------------------------------------------
select ename,
       deptno,
       count(*) over(partition by deptno) as dept_cnt,
       job,
       count(*) over(partition by job) as job_cnt
  from emp
 order by 2

A.2.4 NULL의 영향
select coalesce(comm,-1) as comm,
       count(*)over(partition by comm) as cnt
  from emp
--------------------------------------------------------------------
select coalesce(comm,-1) as comm,
       count(comm)over(partition by comm) as cnt
  from emp

A.2.5 정렬이 중요한 경우
select deptno,
       ename,
       hiredate,
       sal,
       sum(sal)over(partition by deptno) as total1,
       sum(sal)over() as total2,
       sum(sal)over(order by hiredate) as running_total
  from emp
 where deptno=10
--------------------------------------------------------------------
select deptno,
       ename,
       hiredate,
       sal,
       sum(sal)over(partition by deptno) as total1,
       sum(sal)over() as total2,
       sum(sal)over(order by hiredate
                    range between unbounded preceding
                      and current row) as running_total
  from emp
 where deptno=10

A.2.6 프레임 절
select deptno,
       ename,
       sal,
       sum(sal)over(order by hiredate
                    range between unbounded preceding
                      and current row) as run_total1,
       sum(sal)over(order by hiredate
                     rows between 1 preceding
                     and current row) as run_total2,
       sum(sal)over(order by hiredate
                    range between current row
                     and unbounded following) as run_total3,
       sum(sal)over(order by hiredate
                     rows between current row
                     and 1 following) as run_total4
  from emp
 where deptno=10

A.2.7 프레임 총정리
select ename,
       sal,
       min(sal)over(order by sal) min1,
       max(sal)over(order by sal) max1,
       min(sal)over(order by sal
                    range between unbounded preceding
                      and unbounded following) min2,
       max(sal)over(order by sal
                    range between unbounded preceding
                      and unbounded following) max2,
       min(sal)over(order by sal
                    range between current row
                      and current row) min3,
       max(sal)over(order by sal
                    range between current row
                      and current row) max3,
       max(sal)over(order by sal
                     rows between 3 preceding
                      and 3 following) max4
  from emp

A.2.8 가독성 + 성능 = 역량
select deptno,
       job,
       count(*) over (partition by deptno) as emp_cnt,
       count(job) over (partition by deptno,job) as job_cnt,
       count(*) over () as total
  from emp
--------------------------------------------------------------------
select a.deptno, a.job,
       (select count(*) from emp b
         where b.deptno = a.deptno) as emp_cnt,
       (select count(*) from emp b
         where b.deptno = a.deptno and b.job = a.job) as job_cnt,
       (select count(*) from emp) as total
  from emp a
 order by 1,2

A.2.9 기반 자료 피벗하기
select deptno,
       emp_cnt as dept_total,
       total,
       max(case when job = 'CLERK'
                then job_cnt else 0 end) as clerks,
       max(case when job = 'MANAGER'
                then job_cnt else 0 end) as mgrs,
       max(case when job = 'PRESIDENT'
                then job_cnt else 0 end) as prez,
       max(case when job = 'ANALYST'
                then job_cnt else 0 end) as anals,
       max(case when job = 'SALESMAN'
                then job_cnt else 0 end) as smen
  from (
select deptno,
       job,
       count(*) over (partition by deptno) as emp_cnt,
       count(job) over (partition by deptno,job) as job_cnt,
       count(*) over () as total	
  from emp
       ) x
 group by deptno, emp_cnt, total
--------------------------------------------------------------------
select ename as name,
       sal,
       max(sal)over(partition by deptno) as hiDpt,
       min(sal)over(partition by deptno) as loDpt,
       max(sal)over(partition by job) as hiJob,
       min(sal)over(partition by job) as loJob,
       max(sal)over() as hi,
       min(sal)over() as lo,
       sum(sal)over(partition by deptno
                        order by sal,empno) as dptRT,
       sum(sal)over(partition by deptno) as dptSum,
       sum(sal)over() as ttl
  from emp
 order by deptno,dptRT

부록 B 공통 테이블 식
B.1 서브쿼리
select max(HeadCount) as HighestJobHeadCount from
(select job,count(empno) as HeadCount
from emp
group by job) head_count_tab

B.2 공통 테이블 표현식
with head_count_tab (job,HeadCount) as

(select job,count(empno)
from emp
group by job)

select max(HeadCount) as HighestJobHeadCount
from head_count_tab
--------------------------------------------------------------------
with recursive workingTable ( fibNum, NextNumber, index1)
as
(select 0,1,1
union all
select fibNum+nextNumber,fibNUm,index1+1
from anchor
where index1<20)

select fibNum from workingTable as fib

