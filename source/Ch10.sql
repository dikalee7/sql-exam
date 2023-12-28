Chapter 10 범위 관련 작업하기

10.1 연속 값의 범위 찾기
select *
  from V
--------------------------------------------------------------------
 select proj_id, proj_start, proj_end
   from (
 select proj_id, proj_start, proj_end,
        lead(proj_start)over(order by proj_id) next_proj_start
   from V
        ) alias
 where next_proj_start = proj_end
--------------------------------------------------------------------
<DB2, MySQL, PostgreSQL, SQL Server, Oracle>
select *
  from (
select proj_id, proj_start, proj_end,
       lead(proj_start)over(order by proj_id) next_proj_start
  from v
       )
 where proj_id in ( 1, 4 )
--------------------------------------------------------------------
select *
  from V
 where proj_id <= 5
--------------------------------------------------------------------
select proj_id, proj_start, proj_end
  from (
select proj_id, proj_start, proj_end, 
       lead(proj_start)over(order by proj_id) next_start
  from V
where proj_id <= 5
      )
where proj_end = next_start
--------------------------------------------------------------------
select proj_id, proj_start, proj_end
  from (
select proj_id, proj_start, proj_end, 
       lead(proj_start)over(order by proj_id) next_start,
       lag(proj_end)over(order by proj_id) last_end
  from V
where proj_id <= 5
      )
where proj_end = next_start
   or proj_start = last_end

10.2 같은 그룹 또는 파티션의 행 간 차이 찾기
  with next_sal_tab (deptno,ename,sal,hiredate,next_sal)
  as
  (select deptno, ename, sal, hiredate,
        lead(sal)over(partition by deptno
                          order by hiredate) as next_sal
   from emp )

     select deptno, ename, sal, hiredate
  ,    coalesce(cast(sal-next_sal as char), 'N/A') as diff
    from next_sal_tab
--------------------------------------------------------------------
select deptno,ename,sal,hiredate,
       lead(sal)over(partition by deptno order by hiredate) as next_sal
  from emp
--------------------------------------------------------------------
select deptno,ename,sal,hiredate, sal-next_sal diff
  from (
select deptno,ename,sal,hiredate,
       lead(sal)over(partition by deptno order by hiredate) next_sal
  from emp
       )
--------------------------------------------------------------------
select deptno,ename,sal,hiredate,
       nvl(to_char(sal-next_sal),'N/A') diff
  from (
select deptno,ename,sal,hiredate,
       lead(sal)over(partition by deptno order by hiredate) next_sal
  from emp
       )
--------------------------------------------------------------------
select deptno,ename,sal,hiredate,
       lpad(nvl(to_char(sal-next_sal),'N/A'),10) diff
  from (
select deptno,ename,sal,hiredate,
       lead(sal)over(partition by deptno
                         order by hiredate) next_sal
  from emp
 where deptno=10 and empno > 10
       )
--------------------------------------------------------------------
insert into emp (empno,ename,deptno,sal,hiredate)
values (1,'ant',10,1000,to_date('17-NOV-2006'))

insert into emp (empno,ename,deptno,sal,hiredate)
values (2,'joe',10,1500,to_date('17-NOV-2006'))

insert into emp (empno,ename,deptno,sal,hiredate)
values (3,'jim',10,1600,to_date('17-NOV-2006'))

insert into emp (empno,ename,deptno,sal,hiredate)
values (4,'jon',10,1700,to_date('17-NOV-2006'))

select deptno,ename,sal,hiredate,
       lpad(nvl(to_char(sal-next_sal),'N/A'),10) diff
  from (
select deptno,ename,sal,hiredate,
       lead(sal)over(partition by deptno
                         order by hiredate) next_sal
  from emp
 where deptno=10
       )
--------------------------------------------------------------------
select deptno,ename,sal,hiredate,
       lpad(nvl(to_char(sal-next_sal),'N/A'),10) diff
  from (
select deptno,ename,sal,hiredate,
       lead(sal,cnt-rn+1)over(partition by deptno
                         order by hiredate) next_sal
  from (
select deptno,ename,sal,hiredate,
       count(*)over(partition by deptno,hiredate) cnt,
       row_number()over(partition by deptno,hiredate order by sal) rn
  from emp
 where deptno=10
       )
       )
--------------------------------------------------------------------
select deptno,ename,sal,hiredate,
       count(*)over(partition by deptno,hiredate) cnt,
       row_number()over(partition by deptno,hiredate order by sal) rn
  from emp
 where deptno=10
--------------------------------------------------------------------
select deptno,ename,sal,hiredate,
       lead(sal)over(partition by deptno
                         order by hiredate) incorrect,
       cnt-rn+1 distance,
       lead(sal,cnt-rn+1)over(partition by deptno
                         order by hiredate) correct
  from (
select deptno,ename,sal,hiredate,
       count(*)over(partition by deptno,hiredate) cnt,
       row_number()over(partition by deptno,hiredate
                            order by sal) rn
  from emp
 where deptno=10
       )

10.3 연속 값 범위의 시작과 끝 찾기
select *
  from V
--------------------------------------------------------------------
 select proj_grp, min(proj_start), max(proj_end)
    from (
  select proj_id,proj_start,proj_end,
         sum(flag)over(order by proj_id) proj_grp
    from (
  select proj_id,proj_start,proj_end,
         case when
              lag(proj_end)over(order by proj_id) = proj_start
              then 0 else 1
        end flag
   from V
        ) alias1
        ) alias2
  group by proj_grp

select proj_id,proj_start,proj_end,
      lag(proj_end)over(order by proj_id) prior_proj_end
  from V
--------------------------------------------------------------------
select proj_id,proj_start,proj_end,
       sum(flag)over(order by proj_id) proj_grp
  from (
select proj_id,proj_start,proj_end,
       case when
            lag(proj_end)over(order by proj_id) = proj_start
            then 0 else 1
       end flag
  from V
       )

10.4 값 범위에서 누락된 값 채우기
<DB2>
 select x.yr, coalesce(y.cnt,0) cnt
    from (
  select year(min(hiredate)over()) -
         mod(year(min(hiredate)over()),10) +
         row_number()over()-1 yr
    from emp fetch first 10 rows only
         ) x
    left join
         (
 select year(hiredate) yr1, count(*) cnt
   from emp
  group by year(hiredate)
        ) y
     on ( x.yr = y.yr1 )

<Oracle>
 select x.yr, coalesce(cnt,0) cnt
    from (
  select extract(year from min(hiredate)over()) -
         mod(extract(year from min(hiredate)over()),10) +
         rownum-1 yr
    from emp
   where rownum <= 10
         ) x
    left join
        (
 select to_number(to_char(hiredate,'YYYY')) yr, count(*) cnt
   from emp
  group by to_number(to_char(hiredate,'YYYY'))
        ) y
     on ( x.yr = y.yr )

<PostgreSQL과 MySQL>
 select y.yr, coalesce(x.cnt,0) as cnt
    from (
  selectmin_year-mod(cast(min_year as int),10)+rn as yr
    from (
  select (select min(extract(year from hiredate))
            from emp) as min_year,
         id-1 as rn
    from t10
         ) a
        ) y
   left join
        (
 select extract(year from hiredate) as yr, count(*) as cnt
   from emp
  group by extract(year from hiredate)
        ) x
     on ( y.yr = x.yr )

<SQL Server>
 select x.yr, coalesce(y.cnt,0) cnt
   from (
  select top (10)
         (year(min(hiredate)over()) -
          year(min(hiredate)over())%10)+
          row_number()over(order by hiredate)-1 yr
    from emp
         ) x
    left join
        (
 select year(hiredate) yr, count(*) cnt
   from emp
  group by year(hiredate)
        ) y
     on ( x.yr = y.yr )
--------------------------------------------------------------------
select year(min(hiredate)over()) -
       mod(year(min(hiredate)over()),10) +
       row_number()over()-1 yr,
       year(min(hiredate)over()) min_year,
       mod(year(min(hiredate)over()),10) mod_yr,
       row_number()over()-1 rn
  from emp fetch first 10 rows only
--------------------------------------------------------------------
select min_year-mod(min_year,10)+rn as yr,
       min_year,
       mod(min_year,10) as mod_yr
       rn
  from (
select (select min(extract(year from hiredate))
          from emp) as min_year,
        id-1 as rn
  from t10
       ) x
--------------------------------------------------------------------
select year(hiredate) yr, count(*) cnt
  from emp
 group by year(hiredate)

10.5 연속된 숫자 값 생성하기
<DB2와 SQL Server>
 with x (id)
  as (
  select 1
   union all
  select id+1
    from x
   where id+1 <= 10
  )
  select * from x

<Oracle>
 select array id
   from dual
  model
    dimension by (0 idx)
    measures(1 array)
    rules iterate (10) (
      array[iteration_number] = iteration_number+1
    )

<PostgreSQL>
 select id
   from generate_series (1, 10) x(id)
--------------------------------------------------------------------
<Oracle>
select array id
  from dual
model
  dimension by (0 idx)
  measures(1 array)
  rules ()
--------------------------------------------------------------------
select 'array['||idx||'] = '||array as output
  from dual
 model
   dimension by (0 idx)
   measures(1 array)
   rules iterate (10) (
     array[iteration_number] = iteration_number+1
   )

<PostgreSQL>
select id
  from generate_series(
         (select min(deptno) from emp),
         (select max(deptno) from emp),
         5
       ) x(id)