Chapter 1. 레코드 검색

1.1 테이블의 모든 행과 열 검색하기

select *  from emp

select empno,ename,job,sal,mgr,hiredate,comm,deptno
  from emp

1.2 테이블에서 행의 하위 집합 검색하기

 select *
   from emp
  where deptno = 10

1.3 여러 조건을 만족하는 행 찾기

 select *
   from emp
  where deptno = 10
     or comm is not null
     or sal <= 2000 and deptno=20

select *
 from emp
where ( deptno = 10
        or comm is not null
        or sal <= 2000
      )
  and deptno=20

1.4 테이블에서 열의 하위 집합 검색하기
 select ename,deptno,sal
   from emp

1.5 열에 의미 있는 이름 지정하기
 select sal,comm
   from emp

 select sal as salary, comm as commission
   from emp

1.6 WHERE 절에서 별칭이 지정된 열 참조하기
select sal as salary, comm as commission
  from emp
 where salary < 5000

 select *
   from (
 select sal as salary, comm as commission
   from emp
        ) x
  where salary < 5000

1.7 열 값 이어붙이기

select ename, job
  from emp
 where deptno = 10

<DB2, Oracle, PostgreSQL>
 select ename||' WORKS AS A '||job as msg
   from emp
  where deptno=10

<MySQL>
 select concat(ename, ' WORKS AS A ',job) as msg
   from emp
  where deptno=10

<SQL Server>
 select ename + ' WORKS AS A ' + job as msg
   from emp
  where deptno=10

1.8 SELECT 문에서 조건식 사용하기
 select ename,sal,
        case when sal <= 2000 then 'UNDERPAID'
             when sal >= 4000 then 'OVERPAID'
             else 'OK'
        end as status
   from emp

1.9 반환되는 행 수 제한하기
<DB2>
 select *
   from emp fetch first 5 rows only

<MySQL과 PostgreSQL>
 select *
   from emp limit 5

<Oracle>
 select *
   from emp
  where rownum <= 5

<SQL Server>
 select top 5 *
   from emp

1.10. 테이블에서 n개의 무작위 레코드 반환하기
select ename, job
  from emp

<DB2>
 select ename,job
   from emp
  order by rand() fetch first 5 rows only

<MySQL>
 select ename,job
   from emp
  order by rand() limit 5

<PostgreSQL>
 select ename,job
   from emp
  order by random() limit 5

<Oracle>
 select *
   from (
  select ename, job
    from emp
   order by dbms_random.value()
        )
   where rownum <= 5

<SQL Server>
 select top 5 ename,job
   from emp
  order by newid()

1.11 Null 값 찾기
 select *
   from emp
  where comm is null

1.12 Null을 실젯값으로 변환하기
 select coalesce(comm,0)
   from emp

select case
       when comm is not null then comm
       else 0
       end
  from emp

1.13 패턴 검색하기
select ename, job
  from emp
 where deptno in (10,20)

 select ename, job
   from emp
  where deptno in (10,20)
    and (ename like '%I%' or job like '%ER')