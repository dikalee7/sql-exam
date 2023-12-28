/* Statement 1. 
EMP 테이블의 상위 테이블이 될 DEPT 테이블 생성*/
create table dept(  
  deptno     number(2,0),  
  dname      varchar2(14),  
  loc        varchar2(13),  
  constraint pk_dept primary key (deptno)  
);

create table dept(  
  deptno     numeric(2,0),  
  dname      varchar2(14),  
  loc        varchar2(13),  
  constraint pk_dept primary key (deptno)  
);


/* Statement 2. 
DEPT 테이블에 대한 외래 키 참조가 있는 EMP 테이블 생성. 
외래 키를 사용하려면 EMP 테이블의 DEPTNO가 DEPT 테이블의 DEPTNO 열에 있어야 합니다.*/

create table emp(  
  empno    number(4,0),  
  ename    varchar2(10),  
  job      varchar2(9),  
  mgr      number(4,0),  
  hiredate date,  
  sal      number(7,2),  
  comm     number(7,2),  
  deptno   number(2,0),  
  constraint pk_emp primary key (empno),  
  constraint fk_deptno foreign key (deptno) references dept (deptno)  
);

create table emp(  
  empno    numeric(4,0),  
  ename    varchar(10),  
  job      varchar(9),  
  mgr      numeric(4,0),  
  hiredate date,  
  sal      numeric(7,2),  
  comm     numeric(7,2),  
  deptno   numeric(2,0),  
  constraint pk_emp primary key (empno),  
  constraint fk_deptno foreign key (deptno) references dept (deptno)  
);


/* Statement 3. DEPT 테이블에 행을 삽입 */
insert into DEPT (DEPTNO, DNAME, LOC)
values(10, 'ACCOUNTING', 'NEW YORK');

insert into DEPT 
values(20, 'RESEARCH', 'DALLAS');

insert into DEPT 
values(30, 'SALES', 'CHICAGO'); 

insert into DEPT 
values(40, 'OPERATIONS', 'BOSTON');

/* Statement 4. 
TO_DATE 함수를 사용하여 EMP 행 삽입 */

insert into emp  
values(  
 7839, 'KING', 'PRESIDENT', null,  
 to_date('17-11-1981','dd-mm-yyyy'),  
 5000, null, 10  
);

insert into emp  
values(  
 7698, 'BLAKE', 'MANAGER', 7839,  
 to_date('1-5-1981','dd-mm-yyyy'),  
 2850, null, 30  
);


insert into emp  
values(  
 7782, 'CLARK', 'MANAGER', 7839,  
 to_date('9-6-1981','dd-mm-yyyy'),  
 2450, null, 10  
);

insert into emp  
values(  
 7566, 'JONES', 'MANAGER', 7839,  
 to_date('2-4-1981','dd-mm-yyyy'),  
 2975, null, 20  
);


insert into emp  
values(  
 7788, 'SCOTT', 'ANALYST', 7566,  
 to_date('13-JUL-87','dd-mm-rr') - 85,  
 3000, null, 20  
);

insert into emp  
values(  
 7902, 'FORD', 'ANALYST', 7566,  
 to_date('3-12-1981','dd-mm-yyyy'),  
 3000, null, 20  
);


insert into emp  
values(  
 7369, 'SMITH', 'CLERK', 7902,  
 to_date('17-12-1980','dd-mm-yyyy'),  
 800, null, 20  
);

insert into emp  
values(  
 7499, 'ALLEN', 'SALESMAN', 7698,  
 to_date('20-2-1981','dd-mm-yyyy'),  
 1600, 300, 30  
);

insert into emp  
values(  
 7521, 'WARD', 'SALESMAN', 7698,  
 to_date('22-2-1981','dd-mm-yyyy'),  
 1250, 500, 30  
);

insert into emp  
values(  
 7654, 'MARTIN', 'SALESMAN', 7698,  
 to_date('28-9-1981','dd-mm-yyyy'),  
 1250, 1400, 30  
);

insert into emp  
values(  
 7844, 'TURNER', 'SALESMAN', 7698,  
 to_date('8-9-1981','dd-mm-yyyy'),  
 1500, 0, 30  
);

insert into emp  
values(  
 7876, 'ADAMS', 'CLERK', 7788,  
 to_date('13-JUL-87', 'dd-mm-rr') - 51,  
 1100, null, 20  
);

insert into emp  
values(  
 7900, 'JAMES', 'CLERK', 7698,  
 to_date('3-12-1981','dd-mm-yyyy'),  
 950, null, 30  
);

insert into emp  
values(  
 7934, 'MILLER', 'CLERK', 7782,  
 to_date('23-1-1982','dd-mm-yyyy'),  
 1300, null, 10  
);

/* Statement 5. 
DEPT 테이블 DEPTNO의 기본 키와 EMP 테이블의 DEPTNO 외래 키를 기반으로 하는 DEPT와 EMP 테이블 간의 단순 조인 구문으로 입력된 값 확인 */

select ename, dname, job, empno, hiredate, loc  
from emp, dept  
where emp.deptno = dept.deptno  
order by ename; 

/* 아래와 같은 값이 조회됨  
ENAME	DNAME	JOB	EMPNO	HIREDATE	LOC
ADAMS	RESEARCH	CLERK	7876	23-MAY-87	DALLAS
ALLEN	SALES	SALESMAN	7499	20-FEB-81	CHICAGO
BLAKE	SALES	MANAGER	7698	01-MAY-81	CHICAGO
CLARK	ACCOUNTING	MANAGER	7782	09-JUN-81	NEW YORK
FORD	RESEARCH	ANALYST	7902	03-DEC-81	DALLAS
JAMES	SALES	CLERK	7900	03-DEC-81	CHICAGO
JONES	RESEARCH	MANAGER	7566	02-APR-81	DALLAS
KING	ACCOUNTING	PRESIDENT	7839	17-NOV-81	NEW YORK
MARTIN	SALES	SALESMAN	7654	28-SEP-81	CHICAGO
MILLER	ACCOUNTING	CLERK	7934	23-JAN-82	NEW YORK
SCOTT	RESEARCH	ANALYST	7788	19-APR-87	DALLAS
SMITH	RESEARCH	CLERK	7369	17-DEC-80	DALLAS
TURNER	SALES	SALESMAN	7844	08-SEP-81	CHICAGO
WARD	SALES	SALESMAN	7521	22-FEB-81	CHICAGO
*/

/* Statement 6. 
SQL 문의 GROUP BY 절은 그룹화되지 않은 열의 집계 함수를 허용합니다. 
조인은 내부 조인이므로 직원이 없는 부서는 표시되지 않습니다. */

select dname, count(*) count_of_employees
from dept, emp
where dept.deptno = emp.deptno
group by DNAME
order by 2 desc;

/* 그 외 테이블 생성 */

CREATE TABLE T1 (ID INTEGER);

INSERT INTO T1 VALUES (1);

CREATE TABLE T10 (ID INTEGER);

INSERT INTO T10 VALUES (1);
INSERT INTO T10 VALUES (2);
INSERT INTO T10 VALUES (3);
INSERT INTO T10 VALUES (4);
INSERT INTO T10 VALUES (5);
INSERT INTO T10 VALUES (6);
INSERT INTO T10 VALUES (7);
INSERT INTO T10 VALUES (8);
INSERT INTO T10 VALUES (9);
INSERT INTO T10 VALUES (10);


CREATE TABLE T100 (ID INTEGER);

insert into t100 values (1);
insert into t100 values (2);
insert into t100 values (3);
insert into t100 values (4);
insert into t100 values (5);
insert into t100 values (6);
insert into t100 values (7);
insert into t100 values (8);
insert into t100 values (9);
insert into t100 values (10);
insert into t100 values (11);
insert into t100 values (12);
insert into t100 values (13);
insert into t100 values (14);
insert into t100 values (15);
insert into t100 values (16);
insert into t100 values (17);
insert into t100 values (18);
insert into t100 values (19);
insert into t100 values (20);
insert into t100 values (21);
insert into t100 values (22);
insert into t100 values (23);
insert into t100 values (24);
insert into t100 values (25);
insert into t100 values (26);
insert into t100 values (27);
insert into t100 values (28);
insert into t100 values (29);
insert into t100 values (30);
insert into t100 values (31);
insert into t100 values (32);
insert into t100 values (33);
insert into t100 values (34);
insert into t100 values (35);
insert into t100 values (36);
insert into t100 values (37);
insert into t100 values (38);
insert into t100 values (39);
insert into t100 values (40);
insert into t100 values (41);
insert into t100 values (42);
insert into t100 values (43);
insert into t100 values (44);
insert into t100 values (45);
insert into t100 values (46);
insert into t100 values (47);
insert into t100 values (48);
insert into t100 values (49);
insert into t100 values (50);
insert into t100 values (51);
insert into t100 values (52);
insert into t100 values (53);
insert into t100 values (54);
insert into t100 values (55);
insert into t100 values (56);
insert into t100 values (57);
insert into t100 values (58);
insert into t100 values (59);
insert into t100 values (60);
insert into t100 values (61);
insert into t100 values (62);
insert into t100 values (63);
insert into t100 values (64);
insert into t100 values (65);
insert into t100 values (66);
insert into t100 values (67);
insert into t100 values (68);
insert into t100 values (69);
insert into t100 values (70);
insert into t100 values (71);
insert into t100 values (72);
insert into t100 values (73);
insert into t100 values (74);
insert into t100 values (75);
insert into t100 values (76);
insert into t100 values (77);
insert into t100 values (78);
insert into t100 values (79);
insert into t100 values (80);
insert into t100 values (81);
insert into t100 values (82);
insert into t100 values (83);
insert into t100 values (84);
insert into t100 values (85);
insert into t100 values (86);
insert into t100 values (87);
insert into t100 values (88);
insert into t100 values (89);
insert into t100 values (90);
insert into t100 values (91);
insert into t100 values (92);
insert into t100 values (93);
insert into t100 values (94);
insert into t100 values (95);
insert into t100 values (96);
insert into t100 values (97);
insert into t100 values (98);
insert into t100 values (99);
insert into t100 values (100);

