Chapter 2. 쿼리 결과 정렬

2.1 지정한 순서대로 쿼리 결과 반환하기
 select ename,job,sal
   from emp
  where deptno = 10
  order by sal asc

select ename,job,sal
  from emp
 where deptno = 10
 order by sal desc;
--------------------------------------------------------------------
select ename,job,sal
  from emp
 where deptno = 10
 order by 3 desc;.

2.2 다중 필드로 정렬하기
 select empno,deptno,sal,ename,job
   from emp
  order by deptno, sal desc

2.3 부분 문자열로 정렬하기
<DB2, MySQL, Oracle, PostgreSQL>
select ename, job
  from emp
 order by substr(job,length(job)-1)

<SQL Server>
select ename,job
  from emp
 order by substring(job,len(job)-1,2)

2.4 혼합된 영숫자 데이터 정렬하기
create view V
as
  select ename||' '||deptno as data
    from emp

select * from V

<Oracle, SQL Server, PostgreSQL>
/* DEPTNO로 정렬하기 */
 select data
   from V
  order by replace(data,
           replace(
           translate(data,'0123456789','##########'),'#',''),'')
--------------------------------------------------------------------
/* ENAME으로 정렬하기 */
 select data
   from V
  order by replace(
           translate(data,'0123456789','##########'),'#','')

<DB2>
/* DEPTNO로 정렬하기 */
  select *
    from (
  select ename||' '||cast(deptno as char(2)) as data
    from emp
         ) v
   order by replace(data,
             replace(
           translate(data,'##########','0123456789'),'#',''),'')
--------------------------------------------------------------------
/* ENAME으로 정렬하기 */
  select *
    from (
  select ename||' '||cast(deptno as char(2)) as data
    from emp
         ) v
   order by replace(
            translate(data,'##########','0123456789'),'#','')

select data,
       replace(data,
       replace(
     translate(data,'0123456789','##########'),'#',''),'') nums,
       replace(
     translate(data,'0123456789','##########'),'#','') chars
  from V

2.5 정렬할 때 Null 처리하기
 select ename,sal,comm
   from emp
  order by 3
--------------------------------------------------------------------
 select ename,sal,comm
   from emp
  order by 3 desc
<DB2, MySQL, PostgreSQL, SQL Server>
/* NULL이 아닌 COMM을 우선 오름차순 정렬하고, 모든 NULL은 마지막에 나타냄 */
  select ename,sal,comm
    from (
  select ename,sal,comm,
         case when comm is null then 0 else 1 end as is_null
    from emp
         ) x
    order by is_null desc,comm
--------------------------------------------------------------------
/* NULL이 아닌 COMM을 우선 내림차순 정렬하고, 모든 NULL은 마지막에 나타냄 */
  select ename,sal,comm
    from (
  select ename,sal,comm,
         case when comm is null then 0 else 1 end as is_null
    from emp
         ) x
   order by is_null desc,comm desc
--------------------------------------------------------------------

/* NULL을 처음에 나타낸 후, NULL이 아닌 COMM은 오름차순 정렬 */

 select ename,sal,comm
   from (
 select ename,sal,comm,
        case when comm is null then 0 else 1 end as is_null
   from emp
        ) x
  order by is_null,comm
--------------------------------------------------------------------
/* NULL을 처음에 나타낸 후, NULL이 아닌 COMM은 내림차순 정렬 */
  select ename,sal,comm
    from (
  select ename,sal,comm,
         case when comm is null then 0 else 1 end as is_null
    from emp
         ) x
   order by is_null,comm desc

<Oracle>
/* NULL이 아닌 COMM을 우선 오름차순 정렬하고, 모든 NULL은 마지막에 나타냄 */
 select ename,sal,comm
   from emp
  order by comm nulls last
--------------------------------------------------------------------
/* NULL을 처음에 나타낸 후, NULL이 아닌 COMM은 오름차순 정렬 */
 select ename,sal,comm
   from emp
 order by comm nulls first
--------------------------------------------------------------------
/* NULL을 처음에 나타낸 후, NULL이 아닌 COMM은 내림차순 정렬 */
 select ename,sal,comm
   from emp
  order by comm desc nulls first

select ename,sal,comm,
       case when comm is null then 0 else 1 end as is_null
  from emp

2.6 데이터 종속 키 기준으로 정렬하기

 select ename,sal,job,comm
   from emp
  order by case when job = 'SALESMAN' then comm else sal end

select ename,sal,job,comm,
       case when job = 'SALESMAN' then comm else sal end as ordered
  from emp
 order by 5