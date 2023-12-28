Chapter 11 고급 검색

11.1 결과셋을 페이지로 매기기
select sal
  from (
select row_number() over (order by sal) as rn,
       sal
  from emp
       ) x
 where rn between 1 and 5
--------------------------------------------------------------------
select sal
  from (
select row_number() over (order by sal) as rn,
       sal
  from emp
       ) x
 where rn between 6 and 10

select row_number() over (order by sal) as rn,
       sal
  from emp
--------------------------------------------------------------------
select sal
  from (
select sal, rownum rn
  from (
select sal
  from emp
 order by sal
       )
       )
 where rn between 6 and 10

11.2 테이블에서 n개 행 건너뛰기
  select ename
    from (
  select row_number() over (order by ename) rn,
         ename
    from emp
         ) x
   where mod(rn,2) = 1
--------------------------------------------------------------------
select row_number() over (order by ename) rn, ename
  from emp

11.3 외부 조인을 사용할 때 OR 로직 통합하기
select e.ename, d.deptno, d.dname, d.loc
  from dept d, emp e
 where d.deptno = e.deptno
   and (e.deptno = 10 or e.deptno = 20)
 order by 2
--------------------------------------------------------------------
select e.ename, d.deptno, d.dname, d.loc
  from dept d left join emp e
    on (d.deptno = e.deptno)
 where e.deptno = 10
    or e.deptno = 20
 order by 2
--------------------------------------------------------------------
  select e.ename, d.deptno, d.dname, d.loc
    from dept d left join emp e
      on (d.deptno = e.deptno
         and (e.deptno=10 or e.deptno=20))
   order by 2
--------------------------------------------------------------------
  select e.ename, d.deptno, d.dname, d.loc
    from dept d
    left join
         (select ename, deptno
            from emp
           where deptno in ( 10, 20 )
         ) e on ( e.deptno = d.deptno )
  order by 2

11.4 역수 행 확인하기
select *
  from V
--------------------------------------------------------------------
select distinct v1.*
  from V v1, V v2
 where v1.test1 = v2.test2
   and v1.test2 = v2.test1
   and v1.test1 <= v1.test2
--------------------------------------------------------------------
select v1.*
  from V v1, V v2
 where v1.test1 = v2.test2
   and v1.test2 = v2.test1

11.5 상위 n개 레코드 선택하기
  select ename,sal
   from (
  select ename, sal,
         dense_rank() over (order by sal desc) dr
    from emp
         ) x
   where dr <= 5
--------------------------------------------------------------------
select ename, sal,
       dense_rank() over (order by sal desc) dr
  from emp

11.6 최댓값과 최솟값을 가진 레코드 찾기
<DB2, Oracle, SQL Server>
  select ename
    from (
  select ename, sal,
         min(sal)over() min_sal,
         max(sal)over() max_sal
    from emp
         ) x
   where sal in (min_sal,max_sal)
--------------------------------------------------------------------
<DB2, Oracle, SQL Server>
select ename, sal,
       min(sal)over() min_sal,
       max(sal)over() max_sal
  from emp

11.7 이후 행 조사하기
  select ename, sal, hiredate
    from (
  select ename, sal, hiredate,
         lead(sal)over(order by hiredate) next_sal
    from emp
         ) alias
   where sal < next_sal
--------------------------------------------------------------------
select ename, sal, hiredate,
       lead(sal)over(order by hiredate) next_sal
  from emp
--------------------------------------------------------------------
select ename, sal, hiredate
  from (
select ename, sal, hiredate,
       lead(sal,cnt-rn+1)over(order by hiredate) next_sal
  from (
select ename,sal,hiredate,
       count(*)over(partition by hiredate) cnt,
       row_number()over(partition by hiredate order by empno) rn
  from emp
       )
       )
 where sal < next_sal

11.8 행 값 이동하기
  select ename,sal,
         coalesce(lead(sal)over(order by sal),min(sal)over()) forward,
         coalesce(lag(sal)over(order by sal),max(sal)over()) rewind
    from emp
--------------------------------------------------------------------
select ename,sal,
       lead(sal)over(order by sal) forward,
       lag(sal)over(order by sal) rewind
  from emp
--------------------------------------------------------------------
select ename,sal,
       coalesce(lead(sal)over(order by sal),min(sal)over()) forward,
       coalesce(lag(sal)over(order by sal),max(sal)over()) rewind
  from emp
--------------------------------------------------------------------
select ename,sal,
       lead(sal,3)over(order by sal) forward,
       lag(sal,5)over(order by sal) rewind
  from emp

11.9 순위 결과
 select dense_rank() over(order by sal) rnk, sal
   from emp

11.10 중복 방지하기
  select job
    from (
  select job,
         row_number()over(partition by job order by job) rn
    from emp
         ) x
   where rn = 1
Traditional alternatives
select distinct job
  from emp
--------------------------------------------------------------------
select job
  from emp
 group by job
--------------------------------------------------------------------
<DB2, Oracle, SQL Server>
select job,
       row_number()over(partition by job order by job) rn
  from emp
--------------------------------------------------------------------
select distinct job           select distinct job, deptno
  from emp                      from emp

11.11 기사값 찾기
<DB2와 SQL Server>
  select deptno,
          ename,
          sal,
          hiredate,
          max(latest_sal)over(partition by deptno) latest_sal
     from (
   select deptno,
          ename,
          sal,
         hiredate,
         case
           when hiredate = max(hiredate)over(partition by deptno)
           then sal else 0
         end latest_sal
    from emp
         ) x
   order by 1, 4 desc

<Oracle>
  select deptno,
          ename,
          sal,
          hiredate,
           max(sal)
             keep(dense_rank last order by hiredate)
             over(partition by deptno) latest_sal
    from emp
  order by 1, 4 desc
--------------------------------------------------------------------
<DB2와 SQL Server>
select deptno,
       ename,
       sal,
       hiredate,
       case
           when hiredate = max(hiredate)over(partition by deptno)
           then sal else 0
       end latest_sal
  from emp
--------------------------------------------------------------------
select deptno,
       ename,
       sal,
       hiredate,
       max(latest_sal)over(partition by deptno) latest_sal
  from (
select deptno,
       ename,
       sal,
       hiredate,
       case
           when hiredate = max(hiredate)over(partition by deptno)
           then sal else 0
       end latest_sal
  from emp
       ) x
 order by 1, 4 desc

<Oracle>
select deptno,
       ename,
       sal,
       hiredate,
       max(sal) over(partition by deptno) latest_sal
  from emp
 order by 1, 4 desc
--------------------------------------------------------------------
select deptno,
       ename,
       sal,
       hiredate,
       max(sal)
         keep(dense_rank last order by hiredate)
         over(partition by deptno) latest_sal
  from emp
 order by 1, 4 desc
--------------------------------------------------------------------
select deptno,
       ename,
       sal,
       hiredate,
       max(sal)
         keep(dense_rank first order by hiredate desc)
         over(partition by deptno) latest_sal
  from emp
 order by 1, 4 desc

11.12 간단한 예측 생성하기
<DB2, MySQL, SQL Server>
  with nrows(n) as (
   select 1 from t1 union all
   select n+1 from nrows where n+1 <= 3
   )
   select id,
          order_date,
          process_date,
          case when nrows.n >= 2
               then process_date+1
              else null
         end as verified,
         case when nrows.n = 3
              then process_date+2
              else null
         end as shipped
    from (
  select nrows.n id,
         getdate()+nrows.n   as order_date,
         getdate()+nrows.n+2 as process_date
    from nrows
         ) orders, nrows
   order by 1

<Oracle>
  with nrows as (
   select level n
     from dual
   connect by level <= 3
   )
   select id,
          order_date,
          process_date,
          case when nrows.n >= 2
              then process_date+1
              else null
         end as verified,
         case when nrows.n = 3
              then process_date+2
              else null
         end as shipped
  from (
 select nrows.n id,
        sysdate+nrows.n as order_date,
        sysdate+nrows.n+2 as process_date
   from nrows
        ) orders, nrows

<PostgreSQL>
 select id,
         order_date,
         process_date,
         case when gs.n >= 2
              then process_date+1
              else null
         end as verified,
         case when gs.n = 3
              then process_date+2
             else null
        end as shipped
  from (
 select gs.id,
        current_date+gs.id as order_date,
        current_date+gs.id+2 as process_date
   from generate_series(1,3) gs (id)
        ) orders,
          generate_series(1,3)gs(n)
--------------------------------------------------------------------
<DB2, MySQL, SQL Server>
with nrows(n) as (
select 1 from t1 union all
select n+1 from nrows where n+1 <= 3
)
select nrows.n id,getdate()+nrows.n   as order_date,
       getdate()+nrows.n+2 as process_date
  from nrows
--------------------------------------------------------------------
with nrows(n) as (
select 1 from t1 union all
select n+1 from nrows where n+1 <= 3
)
select nrows.n,
       orders.*
  from (
select nrows.n id,
       getdate()+nrows.n    as order_date,
        getdate()+nrows.n+2 as process_date
  from nrows
       ) orders, nrows
 order by 2,1
--------------------------------------------------------------------
with nrows(n) as (
select 1 from t1 union all
select n+1 from nrows where n+1 <= 3
)
select id,
       order_date,
       process_date,
       case when nrows.n >= 2
            then process_date+1
            else null

       end as verified,
       case when nrows.n = 3
           then process_date+2
           else null
       end as shipped
  from (
select nrows.n id,
       getdate()+nrows.n   as order_date,
       getdate()+nrows.n+2 as process_date
  from nrows
       ) orders, nrows
 order by 1

<Oracle>
with nrows as (
select level n
  from dual
connect by level <= 3
)
select nrows.n id,
       sysdate+nrows.n order_date,
       sysdate+nrows.n+2 process_date
  from nrows
--------------------------------------------------------------------
with nrows as (
select level n
  from dual
connect by level <= 3
)
select nrows.n,
       orders.*
  from (
select nrows.n id,
       sysdate+nrows.n order_date,
       sysdate+nrows.n+2 process_date
  from nrows
  ) orders, nrows
--------------------------------------------------------------------
with nrows as (
select level n
  from dual
connect by level <= 3
)
select id,
       order_date,
       process_date,
       case when nrows.n >= 2
            then process_date+1
            else null
       end as verified,
       case when nrows.n = 3
            then process_date+2
            else null
       end as shipped
  from (
select nrows.n id,
       sysdate+nrows.n order_date,
       sysdate+nrows.n+2 process_date
  from nrows
       ) orders, nrows

<PostgreSQL>
select gs.id,
       current_date+gs.id as order_date,
       current_date+gs.id+2 as process_date
 from generate_series(1,3) gs (id)
--------------------------------------------------------------------
select gs.n,
       orders.*
  from (
select gs.id,
       current_date+gs.id as order_date,
       current_date+gs.id+2 as process_date
  from generate_series(1,3) gs (id)
       ) orders,
         generate_series(1,3)gs(n)
--------------------------------------------------------------------
select id,
       order_date,
       process_date,
       case when gs.n >= 2
            then process_date+1
            else null
       end as verified,
       case when gs.n = 3
            then process_date+2
            else null
       end as shipped
  from (
select gs.id,
       current_date+gs.id as order_date,
       current_date+gs.id+2 as process_date
  from generate_series(1,3) gs(id)
       ) orders,
         generate_series(1,3)gs(n)