Chapter 4. 삽입, 갱신 및 삭제하기

4.1 새로운 레코드 삽입하기
--------------------------------------------------------------------
insert into dept (deptno,dname,loc)
values (50,'PROGRAMMING','BALTIMORE')
--------------------------------------------------------------------
/* 여러 행 삽입 */
insert into dept (deptno,dname,loc)
values (1,'A','B'),
       (2,'B','C')
--------------------------------------------------------------------
insert into dept
values (50,'PROGRAMMING','BALTIMORE')

4.2 기본값 삽입하기
--------------------------------------------------------------------
create table D (id integer default 0)
--------------------------------------------------------------------
insert into D values (default)
--------------------------------------------------------------------
insert into D (id) values (default)
<MySQL >
insert into D values ()
<PostgreSQL 및 SQL Server>
insert into D default values
--------------------------------------------------------------------
create table D (id integer default 0, foo varchar(10))
--------------------------------------------------------------------
insert into D (name) values ('Bar')

4.3. NULL로 기본값 오버라이딩하기
create table D (id integer default 0, foo VARCHAR(10))
--------------------------------------------------------------------
insert into d (id, foo) values (null, 'Brighten')
--------------------------------------------------------------------
insert into d (foo) values ('Brighten')

4.4. 한 테이블에서 다른 테이블로 행 복사하기
 insert into dept_east (deptno,dname,loc)
 select deptno,dname,loc
   from dept
  where loc in ( 'NEW YORK','BOSTON' )

4.5. 테이블 정의 복사하기
<DB2>
create table dept_2 like dept

<Oracle, MySQL, PostgreSQL>
 create table dept_2
 as
 select *
   from dept
  where 1 = 0

<SQL Server>
 select *
   into dept_2
   from dept
  where 1 = 0

4.6. 한 번에 여러 테이블에 삽입하기
<Oracle>
   insert all
     when loc in ('NEW YORK','BOSTON') then
     into dept_east (deptno,dname,loc) values (deptno,dname,loc)
     when loc = 'CHICAGO' then
       into dept_mid (deptno,dname,loc) values (deptno,dname,loc)
     else
       into dept_west (deptno,dname,loc) values (deptno,dname,loc)
     select deptno,dname,loc
       from dept

<DB2>
create table dept_east
( deptno integer,
  dname  varchar(10),
loc    varchar(10) check (loc in ('NEW YORK','BOSTON')))
--------------------------------------------------------------------
create table dept_mid
( deptno integer,
  dname  varchar(10),
loc    varchar(10) check (loc = 'CHICAGO'))
--------------------------------------------------------------------
create table dept_west
( deptno integer,
  dname  varchar(10),
loc    varchar(10) check (loc = 'DALLAS'))
--------------------------------------------------------------------
insert into (
  select * from dept_west union all
  select * from dept_east union all
  select * from dept_mid
) select * from dept

4.7 특정 열에 대한 삽입 차단하기
create view new_emps as
select empno, ename, job
  from emp
--------------------------------------------------------------------
insert into new_emps
   (empno ename, job)
values (1, 'Jonathan', 'Editor')
--------------------------------------------------------------------
insert into emp
   (empno ename, job)
values (1, 'Jonathan', 'Editor')
--------------------------------------------------------------------
insert into
  (select empno, ename, job
     from emp)
values (1, 'Jonathan', 'Editor')

4.8 테이블에서 레코드 수정하기
select deptno,ename,sal
  from emp
 where deptno = 20
 order by 1,3
--------------------------------------------------------------------
 update emp
    set sal = sal*1.10
  where deptno = 20
--------------------------------------------------------------------
select deptno,
       ename,
       sal      as orig_sal,
       sal*.10  as amt_to_add,
       sal*1.10 as new_sal
  from emp
 where deptno=20
 order by 1,5

4.9 일치하는 행이 있을 때 업데이트하기
select empno, ename
  from emp_bonus
--------------------------------------------------------------------
 update emp
    set sal=sal*1.20
  where empno in ( select empno from emp_bonus )
--------------------------------------------------------------------
update emp
   set sal = sal*1.20
 where exists ( select null
                  from emp_bonus
                 where emp.empno=emp_bonus.empno )

4.10 다른 테이블 값으로 업데이트하기
select *
  from new_sal
--------------------------------------------------------------------
select deptno,ename,sal,comm
  from emp
 order by 1
--------------------------------------------------------------------
<DB2>
 update emp e set (e.sal,e.comm) = (select ns.sal, ns.sal/2
                                      from new_sal ns
                                     where ns.deptno=e.deptno)
  where exists ( select *
                   from new_sal ns
                  where ns.deptno = e.deptno )

<MySQL>
 update emp e, new_sal ns
 set e.sal=ns.sal,
     e.comm=ns.sal/2
 where e.deptno=ns.deptno

<Oracle>
 update (
  select e.sal as emp_sal, e.comm as emp_comm,
         ns.sal as ns_sal, ns.sal/2 as ns_comm
    from emp e, new_sal ns
   where e.deptno = ns.deptno
 ) set emp_sal = ns_sal, emp_comm = ns_comm

<PostgreSQL>
 update emp
    set sal = ns.sal,
        comm = ns.sal/2
   from new_sal ns
  where ns.deptno = emp.deptno

<SQL Server>
 update e
    set e.sal  = ns.sal,
        e.comm = ns.sal/2
   from emp e,
        new_sal ns
  where ns.deptno = e.deptno
--------------------------------------------------------------------
<Oracle>
select e.empno, e.deptno e_dept, ns.sal, ns.deptno ns_deptno
  from emp e, new_sal ns
 where e.deptno = ns.deptno

4.11 레코드 병합하기
select deptno,empno,ename,comm
  from emp
 order by 1
--------------------------------------------------------------------
select deptno,empno,ename,comm
  from emp_commission
 order by 1
--------------------------------------------------------------------
  merge into emp_commission ec
  using (select * from emp) emp
     on (ec.empno=emp.empno)
   when matched then
        update set ec.comm = 1000
        delete where (sal < 2000)
   when not matched then
        insert (ec.empno,ec.ename,ec.deptno,ec.comm)
        values (emp.empno,emp.ename,emp.deptno,emp.comm)

4.12 테이블에서 모든 레코드 삭제하기
delete from emp

4.13 특정 레코드 삭제하기
delete from emp where deptno = 10

4.14 단일 레코드 삭제하기
delete from emp where empno = 7782

4.15 참조 무결성 위반 삭제하기
delete from emp
 where not exists (
   select * from dept
    where dept.deptno = emp.deptno
)
--------------------------------------------------------------------
delete from emp
where deptno not in (select deptno from dept)

4.16. 중복 레코드 삭제하기
create table dupes (id integer, name varchar(10))
--------------------------------------------------------------------
insert into dupes values (1, 'NAPOLEON')
insert into dupes values (2, 'DYNAMITE')
insert into dupes values (3, 'DYNAMITE')
insert into dupes values (4, 'SHE SELLS')
insert into dupes values (5, 'SEA SHELLS')
insert into dupes values (6, 'SEA SHELLS')
insert into dupes values (7, 'SEA SHELLS')
--------------------------------------------------------------------
select * from dupes order by 1
--------------------------------------------------------------------
  delete from dupes
   where id not in ( select min(id)
                        from dupes
                       group by name )
--------------------------------------------------------------------
   delete from dupes
    where id not in
          (select min(id)
    from (select id,name from dupes) tmp
           group by name)
--------------------------------------------------------------------
select min(id)
  from dupes
 group by name
--------------------------------------------------------------------
select name, min(id)
  from dupes
 group by name

4.17. 다른 테이블에서 참조된 레코드 삭제하기
create table dept_accidents
( deptno         integer,
  accident_name  varchar(20) )
--------------------------------------------------------------------
insert into dept_accidents values (10,'BROKEN FOOT')
insert into dept_accidents values (10,'FLESH WOUND')
insert into dept_accidents values (20,'FIRE')
insert into dept_accidents values (20,'FIRE')
insert into dept_accidents values (20,'FLOOD')
insert into dept_accidents values (30,'BRUISED GLUTE')
--------------------------------------------------------------------
select * from dept_accidents
--------------------------------------------------------------------
 delete from emp
  where deptno in ( select deptno
                      from dept_accidents
                     group by deptno
                    having count(*) >= 3 )
--------------------------------------------------------------------
select deptno
  from dept_accidents
 group by deptno
having count(*) >= 3