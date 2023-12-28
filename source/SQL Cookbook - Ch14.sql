Chapter 14 기타 다양한 기법들

14.1 SQL Server의 PIVOT 연산자로 교차 분석 보고서 생성하기
 select [10] as dept_10,
        [20] as dept_20,
        [30] as dept_30,
        [40] as dept_40
   from (select deptno, empno from emp) driver
  pivot (
     count(driver.empno)
     for driver.deptno in ( [10],[20],[30],[40] )
  ) as empPivot
--------------------------------------------------------------------
select sum(case deptno when 10 then 1 else 0 end) as dept_10,
       sum(case deptno when 20 then 1 else 0 end) as dept_20,
       sum(case deptno when 30 then 1 else 0 end) as dept_30,
       sum(case deptno when 40 then 1 else 0 end) as dept_40
  from emp
--------------------------------------------------------------------
select * from dept
--------------------------------------------------------------------
select [ACCOUNTING] as ACCOUNTING,
       [SALES]      as SALES,
       [RESEARCH]   as RESEARCH,
       [OPERATIONS] as OPERATIONS
  from (
          select d.dname, e.empno
            from emp e,dept d
           where e.deptno=d.deptno

        ) driver
  pivot (
   count(driver.empno)
   for driver.dname in ([ACCOUNTING],[SALES],[RESEARCH],[OPERATIONS])
  ) as empPivot

14.2 SQL Server의 UNPIVOT 연산자로 교차 분석 보고서의 피벗 해제하기
   select DNAME, CNT
      from (
        select [ACCOUNTING] as ACCOUNTING,
               [SALES]      as SALES,
               [RESEARCH]   as RESEARCH,
               [OPERATIONS] as OPERATIONS
          from (
                  select d.dname, e.empno
                    from emp e,dept d
                  where e.deptno=d.deptno

               ) driver
         pivot (
           count(driver.empno)
           for driver.dname in ([ACCOUNTING],[SALES],[RESEARCH],[OPERATIONS])
         ) as empPivot
  )  new_driver
  unpivot (cnt for dname in (ACCOUNTING,SALES,RESEARCH,OPERATIONS)
) as un_pivot
--------------------------------------------------------------------
select DNAME, CNT
  from (
    select [ACCOUNTING] as ACCOUNTING,
           [SALES]      as SALES,
           [RESEARCH]   as RESEARCH,
           [OPERATIONS] as OPERATIONS
      from (
              select d.dname, e.empno
                from emp e,dept d
               where e.deptno=d.deptno

           )  driver
     pivot (
       count(driver.empno)
       for driver.dname in ( [ACCOUNTING],[SALES],[RESEARCH],[OPERATIONS] )
     ) as empPivot
) new_driver
unpivot (cnt for dname in (ACCOUNTING,SALES,RESEARCH,OPERATIONS)
) as un_pivot

14.3. Oracle의 MODEL 절로 결과셋 전송하기
select deptno, count(*) cnt
  from emp
 group by deptno
--------------------------------------------------------------------
select max(d10) d10,
       max(d20) d20,
       max(d30) d30
  from (
select d10,d20,d30
  from ( select deptno, count(*) cnt from emp group by deptno )
 model
  dimension by(deptno d)
   measures(deptno, cnt d10, cnt d20, cnt d30)
   rules(
     d10[any] = case when deptno[cv()]=10 then d10[cv()] else 0 end,
     d20[any] = case when deptno[cv()]=20 then d20[cv()] else 0 end,
     d30[any] = case when deptno[cv()]=30 then d30[cv()] else 0 end
  )
  )
--------------------------------------------------------------------
select deptno, count(*) cnt
  from emp
 group by deptno
select deptno, d10,d20,d30
  from ( select deptno, count(*) cnt from emp group by deptno )
 model
  dimension by(deptno d)
   measures(deptno, cnt d10, cnt d20, cnt d30)
   rules(
     d10[any] = case when deptno[cv()]=10 then d10[cv()] else 0 end,
     d20[any] = case when deptno[cv()]=20 then d20[cv()] else 0 end,
     d30[any] = case when deptno[cv()]=30 then d30[cv()] else 0 end
  )
--------------------------------------------------------------------
select deptno, d10,d20,d30
  from ( select deptno, count(*) cnt from emp group by deptno )
 model
  dimension by(deptno d)
   measures(deptno, cnt d10, cnt d20, cnt d30)
   rules(
    /*
     d10[any] = case when deptno[cv()]=10 then d10[cv()] else 0 end,
     d20[any] = case when deptno[cv()]=20 then d20[cv()] else 0 end,
     d30[any] = case when deptno[cv()]=30 then d30[cv()] else 0 end
    */
  )
--------------------------------------------------------------------
select deptno, count(*) d10, count(*) d20, count(*) d30
  from emp
 group by deptno
--------------------------------------------------------------------
select max(d10) d10,
       max(d20) d20,
       max(d30) d30
  from (
select d10,d20,d30
  from ( select deptno, count(*) cnt from emp group by deptno )
 model
  dimension by(deptno d)
   measures(deptno, cnt d10, cnt d20, cnt d30)
   rules(
     d10[any] = case when deptno[cv()]=10 then d10[cv()] else 0 end,
     d20[any] = case when deptno[cv()]=20 then d20[cv()] else 0 end,
     d30[any] = case when deptno[cv()]=30 then d30[cv()] else 0 end
  )
  )

14.4 고정되지 않은 위치에서 문자열 요소 추출하기
create view V
as
select 'xxxxxabc[867]xxx[-]xxxx[5309]xxxxx' msg
    from dual
   union all
  select 'xxxxxtime:[11271978]favnum:[4]id:[Joe]xxxxx' msg
    from dual
   union all
  select 'call:[F_GET_ROWS()]b1:[ROSEWOOD…SIR]b2:[44400002]77.90xxxxx' msg
    from dual
   union all
  select 'film:[non_marked]qq:[unit]tailpipe:[withabanana?]80sxxxxx' msg
    from dual
--------------------------------------------------------------------
  select substr(msg,
          instr(msg,'[',1,1)+1,
          instr(msg,']',1,1)-instr(msg,'[',1,1)-1) first_val,
         substr(msg,
          instr(msg,'[',1,2)+1,
          instr(msg,']',1,2)-instr(msg,'[',1,2)-1) second_val,
         substr(msg,
          instr(msg,'[',-1,1)+1,
          instr(msg,']',-1,1)-instr(msg,'[',-1,1)-1) last_val
  from V
--------------------------------------------------------------------
select instr(msg,'[',1,1) "1st_[",
                  instr(msg,']',1,1) "]_1st",
                  instr(msg,'[',1,2) "2nd_[",
                  instr(msg,']',1,2) "]_2nd",
                  instr(msg,'[',-1,1) "3rd_[",
                  instr(msg,']',-1,1) "]_3rd"
             from V
--------------------------------------------------------------------
select substr(msg,
        instr(msg,'[',1,1),
        instr(msg,']',1,1)-instr(msg,'[',1,1)) first_val,
       substr(msg,
        instr(msg,'[',1,2),
        instr(msg,']',1,2)-instr(msg,'[',1,2)) second_val,
       substr(msg,
        instr(msg,'[',-1,1),
        instr(msg,']',-1,1)-instr(msg,'[',-1,1)) last_val
  from V
--------------------------------------------------------------------
select substr(msg,
        instr(msg,'[',1,1)+1,
        instr(msg,']',1,1)-instr(msg,'[',1,1)) first_val,
   substr(msg,
    instr(msg,'[',1,2)+1,
    instr(msg,']',1,2)-instr(msg,'[',1,2)) second_val,
    substr(msg,
    instr(msg,'[',-1,1)+1,
    instr(msg,']',-1,1)-instr(msg,'[',-1,1)) last_val
  from V

14.5 연간 일수 찾기(Oracle용 대체 )
 select 'Days in 2021: '||
        to_char(add_months(trunc(sysdate,'y'),12)-1,'DDD')
        as report
   from dual
 union all
 select 'Days in 2020: '||
        to_char(add_months(trunc(
        to_date('01-SEP-2020'),'y'),12)-1,'DDD')
   from dual
--------------------------------------------------------------------
select trunc(to_date('01-SEP-2020'),'y')
  from dual
--------------------------------------------------------------------
select add_months(
         trunc(to_date('01-SEP-2020'),'y'),
         12) before_subtraction,
       add_months(
         trunc(to_date('01-SEP-2020'),'y'),
         12)-1 after_subtraction
  from dual
--------------------------------------------------------------------
select to_char(
         add_months(
           trunc(to_date('01-SEP-2020'),'y'),
           12)-1,'DDD') num_days_in_2020
  from dual

14.6 영숫자 혼합 문자열 검색하기
with v as (
  select 'ClassSummary' strings from dual union
  select '3453430278'           from dual union
  select 'findRow 55'           from dual union
  select '1010 switch'          from dual union
  select '333'                  from dual union
  select 'threes'               from dual
  )
  select strings
    from (
  select strings,
  translate(
  strings,
  'abcdefghijklmnopqrstuvwxyz0123456789',
           rpad('#',26,'#')||rpad('*',10,'*')) translated
  from v
) x
whereinstr(translated,'#') > 0
and instr(translated,'*') > 0
--------------------------------------------------------------------
with v as (
select 'ClassSummary' strings from dual union
select '3453430278'           from dual union
select 'findRow 55'           from dual union
select '1010 switch'          from dual union
select '333'                  from dual union
select 'threes'               from dual
)
select strings,
       translate(
         strings,
         'abcdefghijklmnopqrstuvwxyz0123456789',
         rpad('#',26,'#')||rpad('*',10,'*')) translated
  from v
--------------------------------------------------------------------
with v as (
select 'ClassSummary' strings from dual union
select '3453430278'           from dual union
select 'findRow 55'           from dual union
select '1010 switch'          from dual union
select '333'                  from dual union
select 'threes'               from dual
)
select strings, translated
  from (
select strings,
       translate(
         strings,
         'abcdefghijklmnopqrstuvwxyz0123456789',
         rpad('#',26,'#')||rpad('*',10,'*')) translated
  from v
       )
 where instr(translated,'#') > 0
   and instr(translated,'*') > 0

14.7 Oracle에서 정수를 이진수로 변환하기
 select ename,
         sal,
         (
         select bin
           from dual
          model
          dimension by ( 0 attr )
          measures ( sal num,
                     cast(null as varchar2(30)) bin,
                   '0123456789ABCDEF' hex
                  )
         rules iterate (10000) until (num[0] <= 0) (
           bin[0] = substr(hex[cv()],mod(num[cv()],2)+1,1)||bin[cv()],
           num[0] = trunc(num[cv()]/2)
         )
        ) sal_binary
   from emp
--------------------------------------------------------------------
select bin
  from dual
 model
 dimension by ( 0 attr )
 measures ( 2 num,
            cast(null as varchar2(30)) bin,
            '0123456789ABCDEF' hex
          )
 rules iterate (10000) until (num[0] <= 0) (
   bin[0] = substr (hex[cv()],mod(num[cv()],2)+1,1)||bin[cv()],
   num[0] = trunc(num[cv()]/2)
 )
--------------------------------------------------------------------
select 2 start_val,
       '0123456789ABCDEF' hex,
       substr('0123456789ABCDEF',mod(2,2)+1,1) ||
       cast(null as varchar2(30)) bin,
       trunc(2/2) num
  from dual
--------------------------------------------------------------------
select num start_val,
       substr('0123456789ABCDEF',mod(1,2)+1,1) || bin bin,
       trunc(1/2) num
  from (
select 2 start_val,
       '0123456789ABCDEF' hex,
       substr('0123456789ABCDEF',mod(2,2)+1,1) ||
       cast(null as varchar2(30)) bin,
       trunc(2/2) num
  from dual
       )
--------------------------------------------------------------------
select 2 orig_val, num, bin
  from dual
 model
 dimension by ( 0 attr )
 measures ( 2 num,
            cast(null as varchar2(30)) bin,
           '0123456789ABCDEF' hex
          )
 rules (
   bin[0] = substr (hex[cv()],mod(num[cv()],2)+1,1)||bin[cv()],
   num[0] = trunc(num[cv()]/2),
   bin[1] = substr (hex[0],mod(num[0],2)+1,1)||bin[0],
   num[1] = trunc(num[0]/2)
 )

14.8 순위 결과셋 피벗하기
 select max(case grp when 1 then rpad(ename,6) ||
                      ' ('|| sal ||')' end) top_3,
        max(case grp when 2 then rpad(ename,6) ||
                     ' ('|| sal ||')' end) next_3,
        max(case grp when 3 then rpad(ename,6) ||
                      ' ('|| sal ||')' end) rest
    from (
  select ename,
         sal,
        rnk,
        case when rnk <= 3 then 1
             when rnk <= 6 then 2
             else                  3
        end grp,
        row_number()over (
          partition by case when rnk <= 3 then 1
                            when rnk <= 6 then 2
                            else                 3
                       end
              order by sal desc, ename
        ) grp_rnk
   from (
 select ename,
        sal,
        dense_rank()over(order by sal desc) rnk
   from emp
        ) x
        ) y
  group by grp_rnk
--------------------------------------------------------------------
select ename,
       sal,
       dense_rank()over(order by sal desc) rnk
  from emp
--------------------------------------------------------------------
select ename,
       sal,
       rnk,
       case when rnk <= 3 then 1
            when rnk <= 6 then 2
            else                  3
       end grp,
       row_number()over (
         partition by case when rnk <= 3 then 1
                           when rnk <= 6 then 2
                           else                  3
                       end
             order by sal desc, ename
       ) grp_rnk
  from (
select ename,
       sal,
       dense_rank()over(order by sal desc) rnk
  from emp
       ) x
--------------------------------------------------------------------
select max(case grp when 1 then rpad(ename,6) ||
                    ' ('|| sal ||')' end) top_3,
       max(case grp when 2 then rpad(ename,6) ||
                    ' ('|| sal ||')' end) next_3,
       max(case grp when 3 then rpad(ename,6) ||
                    ' ('|| sal ||')' end) rest
  from (
select ename,
       sal,
       rnk,
       case when rnk <= 3 then 1
            when rnk <= 6 then 2
            else                   3
       end grp,
       row_number()over (
         partition by case when rnk <= 3 then 1
                           when rnk <= 6 then 2
                           else                  3
                       end
             Order by sal desc, ename
       ) grp_rnk
  from (
select ename,
       sal,
       dense_rank()over(order by sal desc) rnk
  from emp
       ) x
       ) y
group by grp_rnk

14.9 이중 피벗 결과셋에 열 머리글 추가하기
select * from it_research
--------------------------------------------------------------------
select * from it_apps
--------------------------------------------------------------------
create table IT_research (deptno number, ename varchar2(20))
--------------------------------------------------------------------
insert into IT_research values (100,'HOPKINS')
insert into IT_research values (100,'JONES')
insert into IT_research values (100,'TONEY')
insert into IT_research values (200,'MORALES')
insert into IT_research values (200,'P.WHITAKER')
insert into IT_research values (200,'MARCIANO')
insert into IT_research values (200,'ROBINSON')
insert into IT_research values (300,'LACY')
insert into IT_research values (300,'WRIGHT')
insert into IT_research values (300,'J.TAYLOR')
--------------------------------------------------------------------
create table IT_apps (deptno number, ename varchar2(20))
--------------------------------------------------------------------
insert into IT_apps values (400,'CORRALES')
insert into IT_apps values (400,'MAYWEATHER')
insert into IT_apps values (400,'CASTILLO')
insert into IT_apps values (400,'MARQUEZ')
insert into IT_apps values (400,'MOSLEY')
insert into IT_apps values (500,'GATTI')
insert into IT_apps values (500,'CALZAGHE')
insert into IT_apps values (600,'LAMOTTA')
insert into IT_apps values (600,'HAGLER')
insert into IT_apps values (600,'HEARNS')
insert into IT_apps values (600,'FRAZIER')
insert into IT_apps values (700,'GUINN')
insert into IT_apps values (700,'JUDAH')
insert into IT_apps values (700,'MARGARITO')
--------------------------------------------------------------------
  select max(decode(flag2,0,it_dept)) research,
         max(decode(flag2,1,it_dept)) apps
    from (
  select sum(flag1)over(partition by flag2
                            order by flag1,rownum) flag,
         it_dept, flag2
    from (
  select 1 flag1, 0 flag2,
         decode(rn,1,to_char(deptno),' '||ename) it_dept
   from (
 select x.*, y.id,
        row_number()over(partition by x.deptno order by y.id) rn
   from (
 select deptno,
        ename,
        count(*)over(partition by deptno) cnt
   from it_research
        ) x,
        (select level id from dual connect by level <= 2) y
        )
  where rn <= cnt+1
 union all
 select 1 flag1, 1 flag2,
        decode(rn,1,to_char(deptno),' '||ename) it_dept
   from (
 select x.*, y.id,
        row_number()over(partition by x.deptno order by y.id) rn
   from (
 select deptno,
        ename,
        count(*)over(partition by deptno) cnt
   from it_apps
        ) x,
        (select level id from dual connect by level <= 2) y
        )
  where rn <= cnt+1
        ) tmp1
        ) tmp2
  group by flag
--------------------------------------------------------------------
select 1 flag1, 1 flag2,
       decode(rn,1,to_char(deptno),' '||ename) it_dept
  from (
select x.*, y.id,
       row_number()over(partition by x.deptno order by y.id) rn
  from (
select deptno,
       ename,
       count(*)over(partition by deptno) cnt
  from it_apps
       ) x,
       (select level id from dual connect by level <= 2) y
       ) z
 where rn <= cnt+1
--------------------------------------------------------------------
select deptno deptno,
       ename,
       count(*)over(partition by deptno) cnt
  from it_apps
--------------------------------------------------------------------
select *
  from (
select deptno deptno,
       ename,
       count(*)over(partition by deptno) cnt
  from it_apps
       ) x,
       (select level id from dual connect by level <= 2) y
 order by 2
--------------------------------------------------------------------
select x.*, y.id,
       row_number()over(partition by x.deptno order by y.id) rn
  from (
select deptno deptno,
       ename,
       count(*)over(partition by deptno) cnt
  from it_apps
       ) x,
       (select level id from dual connect by level <= 2) y
--------------------------------------------------------------------
select 1 flag1, 1 flag2,
       decode(rn,1,to_char(deptno),' '||ename) it_dept
  from (
select x.*, y.id,
       row_number()over(partition by x.deptno order by y.id) rn
  from (
select deptno deptno,
       ename,
       count(*)over(partition by deptno) cnt
  from it_apps
       ) x,
       (select level id from dual connect by level <= 2) y
       ) z
 where rn <= cnt+1
--------------------------------------------------------------------
select 1 flag1, 0 flag2,
       decode(rn,1,to_char(deptno),' '||ename) it_dept
  from (
select x.*, y.id,
       row_number()over(partition by x.deptno order by y.id) rn
  from (
select deptno,
       ename,
       count(*)over(partition by deptno) cnt
  from it_research
       ) x,
       (select level id from dual connect by level <= 2) y
       )
 where rn <= cnt+1
union all
select 1 flag1, 1 flag2,
       decode(rn,1,to_char(deptno),' '||ename) it_dept
  from (
select x.*, y.id,
       row_number()over(partition by x.deptno order by y.id) rn
  from (
select deptno deptno,
       ename,
       count(*)over(partition by deptno) cnt
  from it_apps
       ) x,
       (select level id from dual connect by level <= 2) y
       )
 where rn <= cnt+1
--------------------------------------------------------------------
select sum(flag1)over(partition by flag2
                      order by flag1,rownum) flag,
       it_dept, flag2
  from (
select 1 flag1, 0 flag2,
       decode(rn,1,to_char(deptno),' '||ename) it_dept
  from (
select x.*, y.id,
       row_number()over(partition by x.deptno order by y.id) rn
  from (
select deptno,
       ename,
       count(*)over(partition by deptno) cnt
  from it_research
       ) x,
       (select level id from dual connect by level <= 2) y
       )
 where rn <= cnt+1
union all
select 1 flag1, 1 flag2,
       decode(rn,1,to_char(deptno),' '||ename) it_dept
    from (
select x.*, y.id,
       row_number()over(partition by x.deptno order by y.id) rn
  from (
select deptno deptno,
       ename,
       count(*)over(partition by deptno) cnt
  from it_apps
       ) x,
       (select level id from dual connect by level <= 2) y
       )
 where rn <= cnt+1
       ) tmp1
--------------------------------------------------------------------
select max(decode(flag2,0,it_dept)) research,
       max(decode(flag2,1,it_dept)) apps
  from (
select sum(flag1)over(partition by flag2
                          order by flag1,rownum) flag,
       it_dept, flag2
  from (
select 1 flag1, 0 flag2,
       decode(rn,1,to_char(deptno),' '||ename) it_dept
  from (
select x.*, y.id,
       row_number()over(partition by x.deptno order by y.id) rn
  from (
select deptno,
       ename,
       count(*)over(partition by deptno) cnt
  from it_research
       ) x,
       (select level id from dual connect by level <= 2) y
       )
 where rn <= cnt+1
union all
select 1 flag1, 1 flag2,
       decode(rn,1,to_char(deptno),' '||ename) it_dept
  from (
select x.*, y.id,
       row_number()over(partition by x.deptno order by y.id) rn
  from (
select deptno deptno,
       ename,
       count(*)over(partition by deptno) cnt
  from it_apps
       ) x,
       (select level id from dual connect by level <= 2) y
       )
 where rn <= cnt+1
       ) tmp1
       ) tmp2
 group by flag

14.10 Oracle에서 스칼라 서브쿼리를 복합 서브쿼리로 변환하기
select e.deptno,
       e.ename,
       e.sal,
       (select d.dname,d.loc,sysdate today
          from dept d
         where e.deptno=d.deptno)
  from emp e
--------------------------------------------------------------------
create type generic_obj
    as object (
    val1 varchar2(10),
    val2 varchar2(10),
    val3 date
 );
--------------------------------------------------------------------
  select x.deptno,
         x.ename,
         x.multival.val1 dname,
         x.multival.val2 loc,
         x.multival.val3 today
   from (
 select e.deptno,
        e.ename,
        e.sal,
       (select generic_obj(d.dname,d.loc,sysdate+1)
          from dept d
         where e.deptno=d.deptno) multival
  from emp e
       ) x
--------------------------------------------------------------------
select e.deptno,
       e.ename,
       e.sal,
       (select generic_obj(d.dname,d.loc,sysdate-1)
          from dept d
       where e.deptno=d.deptno) multival
from emp e

14.11 직렬화된 데이터를 행으로 구문 분석하기
create view V
    as
select 'entry:stewiegriffin:lois:brian:' strings
  from dual
 union all
select 'entry:moe::sizlack:'
  from dual
 union all
select 'entry:petergriffin:meg:chris:'
  from dual
 union all
select 'entry:willie:'
  from dual
 union all
select 'entry:quagmire:mayorwest:cleveland:'
  from dual
 union all
select 'entry:::flanders:'
  from dual
 union all
select 'entry:robo:tchi:ken:'
  from dual
--------------------------------------------------------------------
   with cartesian as (
   select level id
     from dual
    connect by level <= 100
   )
   select max(decode(id,1,substr(strings,p1+1,p2-1))) val1,
          max(decode(id,2,substr(strings,p1+1,p2-1))) val2,
          max(decode(id,3,substr(strings,p1+1,p2-1))) val3
    from (
 select v.strings,
        c.id,
        instr(v.strings,':',1,c.id) p1,
        instr(v.strings,':',1,c.id+1)-instr(v.strings,':',1,c.id) p2
   from v, cartesian c
  where c.id <= (length(v.strings)-length(replace(v.strings,':')))-1
        )
  group by strings
  order by 1
--------------------------------------------------------------------
with cartesian as (
select level id
  from dual
 connect by level <= 100
)
select v.strings,
     c.id
  from v,cartesian c
 where c.id <= (length(v.strings)-length(replace(v.strings,':')))-1
--------------------------------------------------------------------
with cartesian as (
select level id
  from dual
  connect by level <= 100
)
select v.strings,
       c.id,
       instr(v.strings,':',1,c.id) p1,
       instr(v.strings,':',1,c.id+1)-instr(v.strings,':',1,c.id) p2
       from v,cartesian c
      where c.id <= (length(v.strings)-length(replace(v.strings,':')))-1
      order by 1
--------------------------------------------------------------------
with cartesian as (
  select level id
    from dual
   connect by level <= 100
  )
  select decode(id,1,substr(strings,p1+1,p2-1)) val1,
         decode(id,2,substr(strings,p1+1,p2-1)) val2,
         decode(id,3,substr(strings,p1+1,p2-1)) val3
    from (
  select v.strings,
         c.id,
         instr(v.strings,':',1,c.id) p1,
         instr(v.strings,':',1,c.id+1)-instr(v.strings,':',1,c.id) p2
    from v,cartesian c
   where c.id <= (length(v.strings)-length(replace(v.strings,':')))-1
         )
   order by 1
--------------------------------------------------------------------
with cartesian as (
select level id
  from dual
 connect by level <= 100
)
select max(decode(id,1,substr(strings,p1+1,p2-1))) val1,
       max(decode(id,2,substr(strings,p1+1,p2-1))) val2,
       max(decode(id,3,substr(strings,p1+1,p2-1))) val3
  from (
select v.strings,
       c.id,
       instr(v.strings,':',1,c.id) p1,
       instr(v.strings,':',1,c.id+1)-instr(v.strings,':',1,c.id) p2
 from v,cartesian c
where c.id <= (length(v.strings)-length(replace(v.strings,':')))-1
       )
group by strings
order by 1

14.12 합계에 대한 백분율 계산하기
  select job,num_emps,sum(round(pct)) pct_of_all_salaries
   from (
  select job,
         count(*)over(partition by job) num_emps,
         ratio_to_report(sal)over()*100 pct
    from emp
         )
   group by job,num_emps
14.12.3 
select job,
       count(*)over(partition by job) num_emps,
       ratio_to_report(sal)over()*100 pct
  from emp
--------------------------------------------------------------------
select job,num_emps,sum(round(pct)) pct_of_all_salaries
  from (
select job,
       count(*)over(partition by job) num_emps,
       ratio_to_report(sal)over()*100 pct
  from emp
       )
 group by job,num_emps

14.13 그룹 내 값의 존재 여부 테스트하기
create view V
as
select 1 student_id,
       1 test_id,
       2 grade_id,
       1 period_id,
       to_date('02/01/2020','MM/DD/YYYY') test_date,
       0 pass_fail
  from dual union all
select 1, 2, 2, 1, to_date('03/01/2020','MM/DD/YYYY'), 1 from dual union all
select 1, 3, 2, 1, to_date('04/01/2020','MM/DD/YYYY'), 0 from dual union all
select 1, 4, 2, 2, to_date('05/01/2020','MM/DD/YYYY'), 0 from dual union all
select 1, 5, 2, 2, to_date('06/01/2020','MM/DD/YYYY'), 0 from dual union all
select 1, 6, 2, 2, to_date('07/01/2020','MM/DD/YYYY'), 0 from dual
--------------------------------------------------------------------
select *
  from V
--------------------------------------------------------------------
  select student_id,
          test_id,
          grade_id,
          period_id,
          test_date,
          decode( grp_p_f,1,lpad('+',6),lpad('-',6) ) metreq,
          decode( grp_p_f,1,0,
                  decode( test_date,last_test,1,0 ) ) in_progress
    from (
 select V.*,
        max(pass_fail)over(partition by
                      student_id,grade_id,period_id) grp_p_f,
        max(test_date)over(partition by
                      student_id,grade_id,period_id) last_test
   from V
        ) x
--------------------------------------------------------------------
select V.*,
       max(pass_fail)over(partition by
                      student_id,grade_id,period_id) grp_pass_fail
  from V
--------------------------------------------------------------------
select V.*,
       max(pass_fail)over(partition by
                      student_id,grade_id,period_id) grp_p_f,
       max(test_date)over(partition by
                      student_id,grade_id,period_id) last_test
  from V
--------------------------------------------------------------------
select student_id,
       test_id,
       grade_id,
       period_id,
       test_date,
       decode( grp_p_f,1,lpad('+',6),lpad('-',6) ) metreq,
       decode( grp_p_f,1,0,
               decode( test_date,last_test,1,0 ) ) in_progress
  from (
select V.*,
       max(pass_fail)over(partition by
                      student_id,grade_id,period_id) grp_p_f,
       max(test_date)over(partition by
                      student_id,grade_id,period_id) last_test
  from V
       ) x