Chapter 3. 다중 테이블 작업

3.1 행 집합을 다른 행 위에 추가하기
  select ename as ename_and_dname, deptno
    from emp
   where deptno = 10
   union all
  select '----------', null
    from t1
   union all
  select dname, deptno
    from dept

select deptno
  from emp
 union
select deptno
  from dept
--------------------------------------------------------------------
select distinct deptno
  from (
select deptno
  from emp
 union all
select deptno
  from dept
         )

3.2 연관된 여러 행 결합하기
 select e.ename, d.loc
   from emp e, dept d
  where e.deptno = d.deptno
    and e.deptno = 10

select e.ename, d.loc,
       e.deptno as emp_deptno,
       d.deptno as dept_deptno
  from emp e, dept d
 where e.deptno = 10
--------------------------------------------------------------------
select e.ename, d.loc,
       e.deptno as emp_deptno,
       d.deptno as dept_deptno
  from emp e, dept d
 where e.deptno = d.deptno
   and e.deptno = 10
--------------------------------------------------------------------
select e.ename, d.loc
  from emp e inner join dept d
    on (e.deptno = d.deptno)
 where e.deptno = 10

3.3 두 테이블 간에 공통 행 찾기
create view V
as
select ename,job,sal
  from emp
 where job = 'CLERK'
--------------------------------------------------------------------
  select * from V
 
<MySQL과 SQL Server>
 select e.empno,e.ename,e.job,e.sal,e.deptno
   from emp e, V
  where e.ename = v.ename
    and e.job   = v.job
    and e.sal   = v.sal
--------------------------------------------------------------------
 select e.empno,e.ename,e.job,e.sal,e.deptno
   from emp e join V
     on (e.ename   = v.ename
        and e.job  = v.job
        and e.sal  = v.sal )

<DB2, Oracle, PostgreSQL>
 select empno,ename,job,sal,deptno
   from emp
  where (ename,job,sal) in (
   select ename,job,sal from emp
  intersect
   select ename,job,sal from V
  )

3.4 한 테이블에서 다른 테이블에 존재하지 않는 값 검색하기
DB2, PostgreSQL, SQL Server>
 select deptno from dept
 except
 select deptno from emp

<Oracle>
 select deptno from dept
 minus
 select deptno from emp

<MySQL>
 select deptno
   from dept
  where deptno not in (select deptno from emp)

<MySQL>
select distinct deptno
  from dept
 where deptno not in (select deptno from emp)
--------------------------------------------------------------------
create table new_dept(deptno integer)
insert into new_deptvalues (10)
insert into new_dept values (50)
insert into new_dept values (null)
--------------------------------------------------------------------
select *
  from dept
 where deptno not in (select deptno from new_dept)
--------------------------------------------------------------------
select deptno
  from dept
 where deptno in ( 10,50,null )
--------------------------------------------------------------------
select deptno
  from dept
 where (deptno=10 or deptno=50 or deptno=null);
--------------------------------------------------------------------
select deptno
  from dept
 where deptno not in ( 10,50,null )
--------------------------------------------------------------------
select deptno
  from dept
 where not (deptno=10 or deptno=50 or deptno=null)
--------------------------------------------------------------------
select d.deptno
  from dept d
 where not exists (
   select 1
     from emp e
    where d.deptno = e.deptno
)
--------------------------------------------------------------------
select d.deptno
  from dept d
 where not exists (
   select 1
     from new_dept nd
    where d.deptno = nd.deptno
)

3.5 다른 테이블 행과 일치하지 않는 행 검색하기
<DB2, MySQL, PostgreSQL, SQL Server>
 select d.*
   from dept d left outer join emp e
     on (d.deptno = e.deptno)
  where e.deptno is null
--------------------------------------------------------------------
select e.ename, e.deptno as emp_deptno, d.*
  from dept d left join emp e
    on (d.deptno = e.deptno)
 
3.6 다른 조인을 방해하지 않고 쿼리에 조인 추가하기
select * from emp_bonus
--------------------------------------------------------------------
select e.ename, d.loc
  from emp e, dept d
 where e.deptno=d.deptno
--------------------------------------------------------------------
select e.ename, d.loc,eb.received
  from emp e, dept d, emp_bonus eb
 where e.deptno=d.deptno
   and e.empno=eb.empno
--------------------------------------------------------------------
 select e.ename, d.loc, eb.received
   from emp e join dept d
     on (e.deptno=d.deptno)
   left join emp_bonus eb
     on (e.empno=eb.empno)
  order by 2
--------------------------------------------------------------------
 select e.ename, d.loc,
        (select eb.received from emp_bonus eb
          where eb.empno=e.empno) as received
   from emp e, dept d
  where e.deptno=d.deptno
  order by 2

3.7 두 테이블에 같은 데이터가 있는지 확인하기
create view V
as
select * from emp where deptno != 10
 union all
select * from emp where ename = 'WARD'
--------------------------------------------------------------------
select * from V
--------------------------------------------------------------------
<DB2 and PostgreSQL>
  (
   select empno,ename,job,mgr,hiredate,sal,comm,deptno,
          count(*) as cnt
     from V
    group by empno,ename,job,mgr,hiredate,sal,comm,deptno
   except
   select empno,ename,job,mgr,hiredate,sal,comm,deptno,
          count(*) as cnt
     from emp
    group by empno,ename,job,mgr,hiredate,sal,comm,deptno
   )
    union all
   (
   select empno,ename,job,mgr,hiredate,sal,comm,deptno,
          count(*) as cnt
     from emp
    group by empno,ename,job,mgr,hiredate,sal,comm,deptno
   except
   select empno,ename,job,mgr,hiredate,sal,comm,deptno,
          count(*) as cnt
     from v
    group by empno,ename,job,mgr,hiredate,sal,comm,deptno
  )

<Oracle>
  (
   select empno,ename,job,mgr,hiredate,sal,comm,deptno,
          count(*) as cnt
     from  V
    group by empno,ename,job,mgr,hiredate,sal,comm,deptno
    minus
   select empno,ename,job,mgr,hiredate,sal,comm,deptno,
          count(*) as cnt
     from emp
    group by empno,ename,job,mgr,hiredate,sal,comm,deptno
   )
     union all
   (
   select empno,ename,job,mgr,hiredate,sal,comm,deptno,
          count(*) as cnt
     from emp
    group by empno,ename,job,mgr,hiredate,sal,comm,deptno
    minus
   select empno,ename,job,mgr,hiredate,sal,comm,deptno,
          count(*) as cnt
     from v
    group by empno,ename,job,mgr,hiredate,sal,comm,deptno
  )

<MySQL and SQL Server>
  select *
    from (
  select e.empno,e.ename,e.job,e.mgr,e.hiredate,
         e.sal,e.comm,e.deptno, count(*) as cnt
    from emp e
   group by empno,ename,job,mgr,hiredate,
           sal,comm,deptno
         ) e
   where not exists (
  select null
    from (
  select v.empno,v.ename,v.job,v.mgr,v.hiredate,
         v.sal,v.comm,v.deptno, count(*) as cnt
    from v
   group by empno,ename,job,mgr,hiredate,
            sal,comm,deptno
         ) v
    where v.empno     = e.empno
       and v.ename    = e.ename
       and v.job      = e.job
       and coalesce(v.mgr,0) = coalesce(e.mgr,0)
       and v.hiredate = e.hiredate
       and v.sal      = e.sal
       and v.deptno   = e.deptno
       and v.cnt      = e.cnt
       and coalesce(v.comm,0) = coalesce(e.comm,0)
  )
     union all
    select *
      from (
    select v.empno,v.ename,v.job,v.mgr,v.hiredate,
           v.sal,v.comm,v.deptno, count(*) as cnt
      from v
    group by empno,ename,job,mgr,hiredate,
             sal,comm,deptno
          ) v
    where not exists (
   select null
     from (
   select e.empno,e.ename,e.job,e.mgr,e.hiredate,
          e.sal,e.comm,e.deptno, count(*) as cnt
     from emp e
    group by empno,ename,job,mgr,hiredate,
             sal,comm,deptno
          ) e
    where v.empno     = e.empno
      and v.ename     = e.ename
      and v.job       = e.job
      and coalesce(v.mgr,0) = coalesce(e.mgr,0)
      and v.hiredate  = e.hiredate
      and v.sal       = e.sal
      and v.deptno    = e.deptno
      and v.cnt       = e.cnt
      and coalesce(v.comm,0) = coalesce(e.comm,0)
  )
--------------------------------------------------------------------
select count(*)
  from emp
 union
select count(*)
  from dept

<DB2, Oracle, PostgreSQL>
(
  select empno,ename,job,mgr,hiredate,sal,comm,deptno,
         count(*) as cnt
    from V
   group by empno,ename,job,mgr,hiredate,sal,comm,deptno
  except
  select empno,ename,job,mgr,hiredate,sal,comm,deptno,
         count(*) as cnt
    from emp
  group by empno,ename,job,mgr,hiredate,sal,comm,deptno
)
--------------------------------------------------------------------
(
  select empno,ename,job,mgr,hiredate,sal,comm,deptno,
         count(*) as cnt
    from emp
   group by empno,ename,job,mgr,hiredate,sal,comm,deptno
   minus
  select empno,ename,job,mgr,hiredate,sal,comm,deptno,
         count(*) as cnt
    from v
   group by empno,ename,job,mgr,hiredate,sal,comm,deptno
)

<MySQL and SQL Server>
select *
   from (
 select e.empno,e.ename,e.job,e.mgr,e.hiredate,
        e.sal,e.comm,e.deptno, count(*) as cnt
   from emp e
  group by empno,ename,job,mgr,hiredate,
           sal,comm,deptno
        ) e
  where not exists (
select null
  from (
select v.empno,v.ename,v.job,v.mgr,v.hiredate,
       v.sal,v.comm,v.deptno, count(*) as cnt
  from v
 group by empno,ename,job,mgr,hiredate,
          sal,comm,deptno
       ) v
  where v.empno    = e.empno
    and v.ename    = e.ename
    and v.job      = e.job
    and v.mgr      = e.mgr
    and v.hiredate = e.hiredate
    and v.sal      = e.sal
    and v.deptno   = e.deptno
    and v.cnt      = e.cnt
    and coalesce(v.comm,0) = coalesce(e.comm,0)
 )
--------------------------------------------------------------------
select *
  from (
select v.empno,v.ename,v.job,v.mgr,v.hiredate,
       v.sal,v.comm,v.deptno, count(*) as cnt
  from v
 group by empno,ename,job,mgr,hiredate,
          sal,comm,deptno
       ) v
  where not exists (
select null
  from (
 select e.empno,e.ename,e.job,e.mgr,e.hiredate,
        e.sal,e.comm,e.deptno, count(*) as cnt
   from emp e
  group by empno,ename,job,mgr,hiredate,
           sal,comm,deptno
       ) e
  where v.empno    = e.empno
    and v.ename    = e.ename
    and v.job      = e.job
    and v.mgr      = e.mgr
    and v.hiredate = e.hiredate
    and v.sal      = e.sal
    and v.deptno   = e.deptno
    and v.cnt      = e.cnt
    and coalesce(v.comm,0) = coalesce(e.comm,0)
)

3.8 데카르트 곱 식별 및 방지하기
select e.ename, d.loc
  from emp e, dept d
 where e.deptno = 10
--------------------------------------------------------------------
 select e.ename, d.loc
   from emp e, dept d
  where e.deptno = 10
    and d.deptno = e.deptno
--------------------------------------------------------------------
select * from dept

3.9. 집계를 사용할 때 조인 수행하기
--------------------------------------------------------------------
select * from emp_bonus
--------------------------------------------------------------------
select e.empno,
       e.ename,
       e.sal,
       e.deptno,
       e.sal*case when eb.type = 1 then .1
                  when eb.type = 2 then .2
                  else .3
             end as bonus
 from emp e, emp_bonus eb
where e.empno  = eb.empno
  and e.deptno = 10
--------------------------------------------------------------------
select deptno,
       sum(sal) as total_sal,
       sum(bonus) as total_bonus
  from (
select e.empno,
       e.ename,
       e.sal,
       e.deptno,
       e.sal*case when eb.type = 1 then .1
                  when eb.type = 2 then .2
                  else .3
             end as bonus
  from emp e, emp_bonus eb
 where e.empno  = eb.empno
   and e.deptno = 10
       ) x
 group by deptno
--------------------------------------------------------------------
select sum(sal)
  from emp 
 where deptno=10
--------------------------------------------------------------------
select e.ename,
       e.sal
  from emp e, emp_bonus eb
 where e.empno  = eb.empno
   and e.deptno = 10
--------------------------------------------------------------------
<MySQL and PostgreSQL>
  select deptno,
         sum(distinct sal) as total_sal,
         sum(bonus) as total_bonus
    from (
  select e.empno,
         e.ename,
         e.sal,
         e.deptno,
         e.sal*case when eb.type = 1 then .1
                   when eb.type = 2 then .2
                   else .3
               end as bonus
   from emp e, emp_bonus eb
   where e.empno = eb.empno
    and e.deptno = 10
        ) x
  group by deptno

<DB2, Oracle, SQL Server>
 select distinct deptno,total_sal,total_bonus
   from (
 select e.empno,
        e.ename,
        sum(distinct e.sal) over
        (partition by e.deptno) as total_sal,
         e.deptno,
         sum(e.sal*case when eb.type = 1 then .1
                        when eb.type = 2 then .2
                        else .3 end) over
         (partition by deptno) as total_bonus
    from emp e, emp_bonus eb
   where e.empno = eb.empno
     and e.deptno = 10
         ) x
--------------------------------------------------------------------
<MySQL과 PostgreSQL>
select d.deptno,
       d.total_sal,
       sum(e.sal*case when eb.type = 1 then .1
                      when eb.type = 2 then .2
                      else .3 end) as total_bonus
  from emp e,
       emp_bonus eb,
       (
select deptno, sum(sal) as total_sal
  from emp
 where deptno = 10
 group by deptno
        ) d
 where e.deptno = d.deptno
   and e.empno = eb.empno
 group by d.deptno,d.total_sal

<DB2, Oracle, SQL Server>
select e.empno,
          e.ename,
          sum(distinct e.sal) over
          (partition by e.deptno) as total_sal,
          e.deptno,
          sum(e.sal*case when eb.type = 1 then .1
                         when eb.type = 2 then .2
                        else .3 end) over
         (partition by deptno) as total_bonus
    from emp e, emp_bonus eb
   where e.empno  = eb.empno
     and e.deptno = 10

3.10 집계 사용 시 외부 조인 수행하기
select *
  from emp_bonus
--------------------------------------------------------------------
select deptno,
       sum(sal) as total_sal,
       sum(bonus) as total_bonus
  from (
select e.empno,
       e.ename,
       e.sal,
       e.deptno,
       e.sal*case when eb.type = 1 then .1
                  when eb.type = 2 then .2
                  else .3 end as bonus
  from emp e, emp_bonus eb
 where e.empno  = eb.empno
   and e.deptno = 10
       )
 group by deptno
--------------------------------------------------------------------
select e.empno,
       e.ename,
       e.sal,
       e.deptno,
       e.sal*case when eb.type = 1 then .1
                  when eb.type = 2 then .2
             else .3 end as bonus
  from emp e, emp_bonus eb
 where e.empno = eb.empno
   and e.deptno = 10
--------------------------------------------------------------------
<DB2, MySQL, PostgreSQL, SQL Server>
  select deptno,
         sum(distinct sal) as total_sal,
         sum(bonus) as total_bonus
    from (
  select e.empno,
         e.ename,
         e.sal,
         e.deptno,
         e.sal*case when eb.type is null then 0
                   when eb.type = 1 then .1
                   when eb.type = 2 then .2
                   else .3 end as bonus
   from emp e left outer join emp_bonus eb
     on (e.empno = eb.empno)
  where e.deptno = 10
        )
  group by deptno
--------------------------------------------------------------------
 select distinct deptno,total_sal,total_bonus
   from (
 select e.empno,
        e.ename,
        sum(distinct e.sal) over
        (partition by e.deptno) as total_sal,
        e.deptno,
        sum(e.sal*case when eb.type is null then 0
                       when eb.type = 1 then .1
                       when eb.type = 2 then .2
                       else .3
                  end) over
        (partition by deptno) as total_bonus
   from emp e left outer join emp_bonus eb
     on (e.empno = eb.empno)
  where e.deptno = 10
        ) x
--------------------------------------------------------------------
select d.deptno,
       d.total_sal,
       sum(e.sal*case when eb.type = 1 then .1
                      when eb.type = 2 then .2
                      else .3 end) as total_bonus
  from emp e,
       emp_bonus eb,
      (
select deptno, sum(sal) as total_sal
  from emp
 where deptno = 10
 group by deptno
       ) d
 where e.deptno = d.deptno
   and e.empno = eb.empno
 group by d.deptno,d.total_sal

3.11. 여러 테이블에서 누락된 데이터 반환하기
--------------------------------------------------------------------
select d.deptno,d.dname,e.ename
  from dept d left outer join emp e
    on (d.deptno=e.deptno)
--------------------------------------------------------------------
insert into emp (empno,ename,job,mgr,hiredate,sal,comm,deptno)
select 1111,'YODA','JEDI',null,hiredate,sal,comm,null
  from emp
 where ename = 'KING'
--------------------------------------------------------------------
select d.deptno,d.dname,e.ename
  from dept d right outer join emp e
    on (d.deptno=e.deptno
--------------------------------------------------------------------
<DB2, MySQL, PostgreSQL, SQL Server>
 select d.deptno,d.dname,e.ename
  from dept d full outer join emp e
    on (d.deptno=e.deptno)
--------------------------------------------------------------------
 select d.deptno,d.dname,e.ename
   from dept d right outer join emp e
     on (d.deptno=e.deptno)
  union
 select d.deptno,d.dname,e.ename
   from dept d left outer join emp e
     on (d.deptno=e.deptno)

<Oracle>
 select d.deptno,d.dname,e.ename
   from dept d, emp e
  where d.deptno = e.deptno(+)
  union
 select d.deptno,d.dname,e.ename
   from dept d, emp e
  where d.deptno(+) = e.deptno
--------------------------------------------------------------------
select d.deptno,d.dname,e.ename
  from dept d left outer join emp e
    on (d.deptno = e.deptno)
--------------------------------------------------------------------
select d.deptno,d.dname,e.ename
  from dept d right outer join emp e
    on (d.deptno = e.deptno)

3.12 연산 및 비교에서 NULL 사용하기
 select ename,comm
   from emp
  where coalesce(comm,0) < ( select comm
                               from emp
                              where ename = 'WARD' )
--------------------------------------------------------------------
select ename,comm,coalesce(comm,0)
  from emp
 where coalesce(comm,0) < ( select comm
                              from emp
                             where ename = 'WARD' )