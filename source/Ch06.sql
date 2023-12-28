Chapter 6. 문자열 작업

6.1 문자열 짚어보기
 select substr(e.ename,iter.pos,1) as C
   from (select ename from emp where ename = 'KING') e,
        (select id as pos from t10) iter
  where iter.pos <= length(e.ename)
--------------------------------------------------------------------
select ename, iter.pos
  from (select ename from emp where ename = 'KING') e,
       (select id as pos from t10) iter
--------------------------------------------------------------------
select ename, iter.pos
  from (select ename from emp where ename = 'KING') e,
       (select id as pos from t10) iter
 where iter.pos <= length(e.ename)
--------------------------------------------------------------------
select substr(e.ename,iter.pos) a,
       substr(e.ename,length(e.ename)-iter.pos+1) b
  from (select ename from emp where ename = 'KING') e,
       (select id pos from t10) iter
 where iter.pos <= length(e.ename)

6.2 문자열에 따옴표 포함하기
 select 'g''day mate' qmarks from t1 union all
 select 'beavers'' teeth'    from t1 union all
 select ''''                 from t1
--------------------------------------------------------------------
select 'apples core', 'apple''s core',
        case when '' is null then 0 else 1 end
  from t1

6.3. 문자열에서 특정 문자의 발생 횟수 계산하기
 select (length('10,CLARK,MANAGER')-
        length(replace('10,CLARK,MANAGER',',','')))/length(',')
        as cnt
   from t1
--------------------------------------------------------------------
select
       (length('HELLO HELLO')-
       length(replace('HELLO HELLO','LL','')))/length('LL')
       as correct_cnt,
       (length('HELLO HELLO')-
       length(replace('HELLO HELLO','LL',''))) as incorrect_cnt
  from t1

6.4. 문자열에서 원하지 않는 문자 제거하기
<DB2, Oracle, PostgreSQL, SQL Server>
 select ename,
        replace(translate(ename,'aaaaa','AEIOU'),'a','') as stripped1,
        sal,
        replace(cast(sal as char(4)),'0','') as stripped2
   from emp

<MySQL>
 select ename,
        replace(
        replace(
        replace(
        replace(
        replace(ename,'A',''),'E',''),'I',''),'O',''),'U','')
        as stripped1,
        sal,
        replace(sal,0,'') stripped2
   from emp

6.5 숫자 및 문자 데이터 분리하기
<DB2>
  select replace(
       translate(data,'0000000000','0123456789'),'0','') ename,
         cast(
       replace(
     translate(lower(data),repeat('z',26),
            'abcdefghijklmnopqrstuvwxyz'),'z','') as integer) sal
    from (
  select ename||cast(sal as char(4)) data
    from emp
        ) x

<Oracle>
  select replace(
       translate(data,'0123456789','0000000000'),'0') ename,
       to_number(
         replace(
         translate(lower(data),
                   'abcdefghijklmnopqrstuvwxyz',
                    rpad('z',26,'z')),'z')) sal
    from (
  select ename||sal data
   from emp
        )

<PostgreSQL>
 select replace(
       translate(data,'0123456789','0000000000'),'0','') as ename,
            cast(
         replace(
       translate(lower(data),
                 'abcdefghijklmnopqrstuvwxyz',
                 rpad('z',26,'z')),'z','') as integer) as sal
    from (
  select ename||sal as data
   from emp
        ) x

<SQL Server>
  select replace(
       translate(data,'0123456789','0000000000'),'0','') as ename,
            cast(
         replace(
       translate(lower(data),
                 'abcdefghijklmnopqrstuvwxyz',
                 replicate('z',26),'z','') as integer) as sal
    from (
  select concat(ename,sal) as data
   from emp
        ) x
--------------------------------------------------------------------
select data,
       translate(lower(data),
                'abcdefghijklmnopqrstuvwxyz',
                rpad('z',26,'z')) sal
  from (select ename||sal data from emp)
--------------------------------------------------------------------
select data,
       to_number(
         replace(
       translate(lower(data),
                 'abcdefghijklmnopqrstuvwxyz',
                 rpad('z',26,'z')),'z')) sal
  from (select ename||sal data from emp)
--------------------------------------------------------------------
select data,
       translate(data,'0123456789','0000000000') ename
  from (select ename||sal data from emp)
--------------------------------------------------------------------
select data,
       replace(translate(data,'0123456789','0000000000'),'0') ename
  from (select ename||sal data from emp)

6.6 문자열의 영숫자 여부 확인하기
create view V as
select ename as data
  from emp
 where deptno=10
 union all
select ename||', $'|| cast(sal as char(4)) ||'.00' as data
  from emp
 where deptno=20
 union all
select ename|| cast(deptno as char(4)) as data
  from emp
 where deptno=30
--------------------------------------------------------------------
<DB2>
 select data
   from V
  where translate(lower(data),
                  repeat('a',36),
                  '0123456789abcdefghijklmnopqrstuvwxyz') =
                  repeat('a',length(data))

<MySQL>
create view V as
select ename as data
  from emp
 where deptno=10
 union all
select concat(ename,', $',sal,'.00') as data
  from emp
 where deptno=20
 union all
select concat(ename,deptno) as data
  from emp
 where deptno=30
--------------------------------------------------------------------
 select data
   from V
  where data regexp '[^0-9a-zA-Z]' = 0

<Oracle과 PostgreSQL>
 select data
   from V
  where translate(lower(data),
                  '0123456789abcdefghijklmnopqrstuvwxyz',
                  rpad('a',36,'a')) = rpad('a',length(data),'a')

<SQL Server>
 select data
   from V
  where translate(lower(data),
                  '0123456789abcdefghijklmnopqrstuvwxyz',
                  replicate('a',36)) = replicate('a',len(data))
--------------------------------------------------------------------
<DB2, Oracle, PostgreSQL, SQL Server>
select data, translate(lower(data),
                  '0123456789abcdefghijklmnopqrstuvwxyz',
                   rpad('a',36,'a'))
  from V
--------------------------------------------------------------------
select data, translate(lower(data),
                  '0123456789abcdefghijklmnopqrstuvwxyz',
                   rpad('a',36,'a')) translated,
        rpad('a',length(data),'a') fixed
  from V

6.7. 이름에서 이니셜 추출하기
<DB2>
 select replace(
        replace(
        translate(replace('Stewie Griffin', '.', ''),
                  repeat('#',26),
                  'abcdefghijklmnopqrstuvwxyz'),
                   '#','' ), ' ','.' )
                  ||'.'
   from t1

<MySQL>
 select case
           when cnt = 2 then
             trim(trailing '.' from
                  concat_ws('.',
                   substr(substring_index(name,' ',1),1,1),
                   substr(name,
                          length(substring_index(name,' ',1))+2,1),
                   substr(substring_index(name,' ',-1),1,1),
                   '.'))
          else
            trim(trailing '.' from
                 concat_ws('.',
                  substr(substring_index(name,' ',1),1,1),
                  substr(substring_index(name,' ',-1),1,1)
                  ))
          end as initials
   from (
 select name,length(name)-length(replace(name,' ','')) as cnt
   from (
 select replace('Stewie Griffin','.','') as name from t1
        )y
        )x

<Oracle과 PostgreSQL>
 select replace(
        replace(
        translate(replace('Stewie Griffin', '.', ''),
                  'abcdefghijklmnopqrstuvwxyz',
                  rpad('#',26,'#') ), '#','' ),' ','.' ) ||'.'
   from t1

<SQL Server>
 select replace(
        replace(
        translate(replace('Stewie Griffin', '.', ''),
                  'abcdefghijklmnopqrstuvwxyz',
                  replicate('#',26) ), '#','' ),' ','.' ) + '.'
   from t1
--------------------------------------------------------------------
<DB2>
select translate(replace('Stewie Griffin', '.', ''),
                 repeat('#',26),
                 'abcdefghijklmnopqrstuvwxyz')
  from t1
--------------------------------------------------------------------
select replace(
       translate(replace('Stewie Griffin', '.', ''),
                  repeat('#',26),
                  'abcdefghijklmnopqrstuvwxyz'),'#','')
  from t1
--------------------------------------------------------------------
select replace(
       replace(
       translate(replace('Stewie Griffin', '.', ''),
                 repeat('#',26),
                'abcdefghijklmnopqrstuvwxyz'),'#',''),' ','.') || '.'
  from t1

<Oracle과 PostgreSQL>
select translate(replace('Stewie Griffin','.',''),
                 'abcdefghijklmnopqrstuvwxyz',
                 rpad('#',26,'#'))
  from t1
--------------------------------------------------------------------
select replace(
       translate(replace('Stewie Griffin','.',''),
                 'abcdefghijklmnopqrstuvwxyz',
                  rpad('#',26,'#')),'#','')
  from t1
--------------------------------------------------------------------
select replace(
       replace(
     translate(replace('Stewie Griffin','.',''),
               'abcdefghijklmnopqrstuvwxyz',
               rpad('#',26,'#') ),'#',''),' ','.') || '.'
  from t1


MySQL
select substr(substring_index(name, ' ',1),1,1) as a,
       substr(substring_index(name,' ',-1),1,1) as b
  from (select 'Stewie Griffin' as name from t1) x
--------------------------------------------------------------------
select concat_ws('.',
                 substr(substring_index(name, ' ',1),1,1),
                 substr(substring_index(name,' ',-1),1,1),
                 '.' ) a
  from (select 'Stewie Griffin' as name from t1) x

6.8 문자열 일부를 정렬하기
<DB2, Oracle, MySQL, PostgreSQL>
 select ename
   from emp
  order by substr(ename,length(ename)-1,)

<SQL Server>
 select ename
   from emp
  order by substring(ename,len(ename)-1,2)

6.9 문자열의 숫자로 정렬하기
create view V as
select e.ename ||' '||
        cast(e.empno as char(4))||' '||
        d.dname as data
  from emp e, dept d
 where e.deptno=d.deptno
--------------------------------------------------------------------
<DB2>
 select data
   from V
  order by
         cast(
      replace(
    translate(data,repeat('#',length(data)),
      replace(
    translate(data,'##########','0123456789'),
             '#','')),'#','') as integer)

<Oracle>
 select data
   from V
  order by
         to_number(
           replace(
         translate(data,
           replace(
         translate(data,'0123456789','##########'),
                  '#'),rpad('#',20,'#')),'#'))

<PostgreSQL>
 select data
   from V
  order by
         cast(
      replace(
    translate(data,
      replace(
    translate(data,'0123456789','##########'),
             '#',''),rpad('#',20,'#')),'#','') as integer)

--------------------------------------------------------------------
select data,
       translate(data,'0123456789','##########') as tmp
  from V
--------------------------------------------------------------------
select data,
replace(
translate(data,'0123456789','##########'),'#') as tmp
  from V
--------------------------------------------------------------------
select data, translate(data,
             replace(
             translate(data,'0123456789','##########'),
             '#'),
             rpad('#',length(data),'#')) as tmp
  from V
--------------------------------------------------------------------
select data, replace(
             translate(data,
             replace(
           translate(data,'0123456789','##########'),
                     '#'),
                     rpad('#',length(data),'#')),'#') as tmp
  from V
--------------------------------------------------------------------
select data, to_number(
              replace(
             translate(data,
             replace(
       translate(data,'0123456789','##########'),
                 '#'),
                 rpad('#',length(data),'#')),'#')) as tmp
  from V
--------------------------------------------------------------------
select data
  from V
 order by
        to_number(
          replace(
        translate( data,
          replace(
        translate( data,'0123456789','##########'),
                  '#'),rpad('#',length(data),'#')),'#'))

6.10 테이블 행으로 구분된 목록 만들기
<DB2>
 select deptno,
        list_agg(ename ',') within GROUP(Order by 0) as emps
   from emp
  group by deptno

<MySQL>
 select deptno,
        group_concat(ename order by empno separator, ',') as emps
   from emp
  group by deptno

<Oracle>
 select deptno,
         ltrim(sys_connect_by_path(ename,','),',') emps
    from (
  select deptno,
         ename,
         row_number() over
                  (partition by deptno order by empno) rn,
         count(*) over
                  (partition by deptno) cnt
   from emp
        )
  where level = cnt
  start with rn = 1
 connect by prior deptno = deptno and prior rn = rn-1
<PostgreSQL과 SQL Server>
 select deptno,
        string_agg(ename order by empno separator, ',') as emps
   from emp
  group by deptno
--------------------------------------------------------------------
<Oracle>
select deptno,
        ename,
        row_number() over
                  (partition by deptno order by empno) rn,
        count(*) over (partition by deptno) cnt
  from emp

6.11 구분된 데이터를 다중값 IN-목록으로 변환하기
select ename,sal,deptno
  from emp
 where empno in ( '7654,7698,7782,7788' )
--------------------------------------------------------------------
<DB2>
 select empno,ename,sal,deptno
    from emp
   where empno in (
  select cast(substr(c,2,locate(',',c,2)-2) as integer) empno
    from (
  select substr(csv.emps,cast(iter.pos as integer)) as c
    from (select ','||'7654,7698,7782,7788'||',' emps
           from t1) csv,
         (select id as pos
           from t100 ) iter
  where iter.pos <= length(csv.emps)
        ) x
  where length(c) > 1
    and substr(c,1,1) = ','
        )

<MySQL>
  select empno, ename, sal, deptno
    from emp
   where empno in
         (
  select substring_index(
         substring_index(list.vals,',',iter.pos),',',-1) empno
    from (select id pos from t10) as iter,
         (select '7654,7698,7782,7788' as vals
            from t1) list
   where iter.pos <=
        (length(list.vals)-length(replace(list.vals,',','')))+1
        )

<Oracle>
  select empno,ename,sal,deptno
    from emp
   where empno in (
         select to_number(
                    rtrim(
                  substr(emps,
                   instr(emps,',',1,iter.pos)+1,
                   instr(emps,',',1,iter.pos+1)
                   instr(emps,',',1,iter.pos)),',')) emps
          from (select ','||'7654,7698,7782,7788'||',' emps from t1) csv,
               (select rownum pos from emp) iter
         where iter.pos <= ((length(csv.emps)-
                   length(replace(csv.emps,',')))/length(','))-1
 )

<PostgreSQL>
 select ename,sal,deptno
    from emp
   where empno in (
  select cast(empno as integer) as empno
    from (
  select split_part(list.vals,',',iter.pos) as empno
    from (select id as pos from t10) iter,
         (select ','||'7654,7698,7782,7788'||',' as vals
            from t1) list
  where iter.pos <=
        length(list.vals)-length(replace(list.vals,',',''))
        ) z
  where length(empno) > 0
        )

<SQL Server>
 select empno,ename,sal,deptno
   from emp
  where empno in (select substring(c,2,charindex(',',c,2)-2) as empno
    from (
  select substring(csv.emps,iter.pos,len(csv.emps)) as c
    from (select ','+'7654,7698,7782,7788'+',' as emps
            from t1) csv,
         (select id as pos
           from t100) iter
  where iter.pos <= len(csv.emps)
       ) x
  where len(c) > 1
    and substring(c,1,1) = ','
       )
--------------------------------------------------------------------
<Oracle>
select emps,pos
  from (select ','||'7654,7698,7782,7788'||',' emps
          from t1) csv,
       (select rownum pos from emp) iter
 where iter.pos <=
 ((length(csv.emps)-length(replace(csv.emps,',')))/length(','))-1
--------------------------------------------------------------------
select substr(emps,
       instr(emps,',',1,iter.pos)+1,
       instr(emps,',',1,iter.pos+1)
       instr(emps,',',1,iter.pos)) emps
  from (select ','||'7654,7698,7782,7788'||',' emps
          from t1) csv,
       (select rownum pos from emp) iter
 where iter.pos <=
  ((length(csv.emps)-length(replace(csv.emps,',')))/length(','))-1

<PostgreSQL>
select list.vals,
       split_part(list.vals,',',iter.pos) as empno,
       iter.pos
  from (select id as pos from t10) iter,
       (select ','||'7654,7698,7782,7788'||',' as vals
          from t1) list
 where iter.pos <=
       length(list.vals)-length(replace(list.vals,',',''))

6.12 문자열을 알파벳 순서로 정렬하기
--------------------------------------------------------------------
<DB2>
 select ename,
        listagg(c,'')  WITHIN GROUP( ORDER BY c)
    from (
          select a.ename,
          substr(a.ename,iter.pos,1
          ) as c
          from emp a,
         (select id as pos from t10) iter
         where iter.pos <= length(a.ename)
        order by 1,2
       ) x
        Group By c

<MySQL>
 select ename, group_concat(c order by c separator '')
   from (
 select ename, substr(a.ename,iter.pos,1) c
   from emp a,
        ( select id pos from t10 ) iter
  where iter.pos <= length(a.ename)
        ) x
  group by ename

<Oracle>
 select old_name, new_name
    from (
  select old_name, replace(sys_connect_by_path(c,' '),' ') new_name
    from (
  select e.ename old_name,
         row_number() over(partition by e.ename
                          order by substr(e.ename,iter.pos,1)) rn,
         substr(e.ename,iter.pos,1) c
    from emp e,
        ( select rownum pos from emp ) iter
  where iter.pos <= length(e.ename)
  order by 1
         ) x
  start with rn = 1
 connect by prior rn = rn-1 and prior old_name = old_name
         )
  where length(old_name) = length(new_name)

<PostgreSQL>
select ename, string_agg(c , ''
                      ORDER BY c)
from (
 select a.ename,
        substr(a.ename,iter.pos,1) as c
   from emp a,
        (select id as pos from t10) iter
  where iter.pos <= length(a.ename)
  order by 1,2
        ) x
        Group By c

<SQL Server>
 select ename,
            max(case when pos=1 then c else '' end)+
            max(case when pos=2 then c else '' end)+
            max(case when pos=3 then c else '' end)+
            max(case when pos=4 then c else '' end)+
            max(case when pos=5 then c else '' end)+
            max(case when pos=6 then c else '' end)
       from (
     select e.ename,
         substring(e.ename,iter.pos,1) as c,
         row_number() over (
          partition by e.ename
              order by substring(e.ename,iter.pos,1)) as pos
    from emp e,
         (select row_number()over(order by ename) as pos
            from emp) iter
   where iter.pos <= len(e.ename)
          ) x
   group by ename

6.13 숫자로 취급할 수 있는 문자열 식별하기
create view V as
select replace(mixed,' ','') as mixed
  from (
select substr(ename,1,2)||
       cast(deptno as char(4))||
       substr(ename,3,2) as mixed
  from emp
 where deptno = 10
 union all
select cast(empno as char(4)) as mixed
  from emp
 where deptno = 20
 union all
select ename as mixed
  from emp
 where deptno = 30
       ) x
select * from v
--------------------------------------------------------------------
<DB2>
 select mixed old,
         cast(
           case
           when
             replace(
            translate(mixed,'9999999999','0123456789'),'9','') = ''
           then
              mixed
           else replace(
            translate(mixed,
               repeat('#',length(mixed)),
             replace(
              translate(mixed,'9999999999','0123456789'),'9','')),
                      '#','')
          end as integer ) mixed
   from V
  where posstr(translate(mixed,'9999999999','0123456789'),'9') > 0

<MySQL>
create view V as
select concat(
         substr(ename,1,2),
         replace(cast(deptno as char(4)),' ',''),
         substr(ename,3,2)
       ) as mixed
  from emp
 where deptno = 10
 union all
select replace(cast(empno as char(4)), ' ', '')
  from emp where deptno = 20
 union all
select ename from emp where deptno = 30
--------------------------------------------------------------------
  select cast(group_concat(c order by pos separator '') as unsigned)
         as MIXED1
    from (
  select v.mixed, iter.pos, substr(v.mixed,iter.pos,1) as c
    from V,
         ( select id pos from t10 ) iter
   where iter.pos <= length(v.mixed)
     and ascii(substr(v.mixed,iter.pos,1)) between 48 and 57
         ) y
  group by mixed
  order by 1

<Oracle>
 select to_number (
          case
          when
             replace(translate(mixed,'0123456789','9999999999'),'9')
            is not null
          then
               replace(
             translate(mixed,
               replace(
            translate(mixed,'0123456789','9999999999'),'9'),
                     rpad('#',length(mixed),'#')),'#')
         else
              mixed
         end
         ) mixed
   from V
  where instr(translate(mixed,'0123456789','9999999999'),'9') > 0

<PostgreSQL>
 select cast(
         case
         when
          replace(translate(mixed,'0123456789','9999999999'),'9','')
          is not null
         then
            replace(
         translate(mixed,
            replace(
        translate(mixed,'0123456789','9999999999'),'9',''),
                 rpad('#',length(mixed),'#')),'#','')
        else
          mixed
        end as integer ) as mixed
    from V
  where strpos(translate(mixed,'0123456789','9999999999'),'9') > 0
--------------------------------------------------------------------
<DB2, Oracle, PostgreSQL>
select mixed as orig,
translate(mixed,'0123456789','9999999999') as mixed1,
replace(translate(mixed,'0123456789','9999999999'),'9','') as mixed2,
 translate(mixed,
 replace(
 translate(mixed,'0123456789','9999999999'),'9',''),
          rpad('#',length(mixed),'#')) as mixed3, 
 replace(
 translate(mixed,
 replace( 
translate(mixed,'0123456789','9999999999'),'9',''),
          rpad('#',length(mixed),'#')),'#','') as mixed4
  from V 
 where strpos(translate(mixed,'0123456789','9999999999'),'9') > 0

<MySQL>
select v.mixed, iter.pos, substr(v.mixed,iter.pos,1) as c
  from V,
      ( select id pos from t10 ) iter
 where iter.pos <= length(v.mixed) 
 order by 1,2
--------------------------------------------------------------------
select v.mixed, iter.pos, substr(v.mixed,iter.pos,1) as c
   from V,
       ( select id pos from t10 ) iter
 where iter.pos <= length(v.mixed)
  and ascii(substr(v.mixed,iter.pos,1)) between 48 and 57
 order by 1,2
--------------------------------------------------------------------
select cast(group_concat(c order by pos separator '') as unsigned)
         as MIXED1
  from ( 
select v.mixed, iter.pos, substr(v.mixed,iter.pos,1) as c 
  from V, 
      ( select id pos from t10 ) iter 
 where iter.pos <= length(v.mixed) 
  and ascii(substr(x.mixed,iter.pos,1)) between 48 and 57
       ) y
  group by mixed
  order by 1

6.14 n번째로 구분된 부분 문자열 추출하기
create view V as
select 'mo,larry,curly' as name
  from t1
 union all
select 'tina,gina,jaunita,regina,leena' as name
  from t1
--------------------------------------------------------------------
<DB2>
 select substr(c,2,locate(',',c,2)-2)
   from (
  select pos, name, substr(name, pos) c,
         row_number() over( partition by name
                        order by length(substr(name,pos)) desc) rn
    from (
  select ',' ||csv.name|| ',' as name,
          cast(iter.pos as integer) as pos
    from V csv,
        (select row_number() over() pos from t100 ) iter
  where iter.pos <= length(csv.name)+2
        ) x
  where length(substr(name,pos)) > 1
    and substr(substr(name,pos),1,1) = ','
        ) y
  where rn = 2

<MySQL>
select name
    from (
  select iter.pos,
         substring_index(
         substring_index(src.name,',',iter.pos),',',-1) name
    from V src,
         (select id pos from t10) iter,
   where iter.pos <=
         length(src.name)-length(replace(src.name,',',''))
        ) x
  where pos = 2

<Oracle>
  select sub
    from (
  select iter.pos,
         src.name,
         substr( src.name,
          instr( src.name,',',1,iter.pos )+1,
          instr( src.name,',',1,iter.pos+1 ) -
          instr( src.name,',',1,iter.pos )-1) sub
    from (select ','||name||',' as name from V) src,
        (select rownum pos from emp) iter
  where iter.pos < length(src.name)-length(replace(src.name,','))
        )
  where pos = 2

<PostgreSQL>
  select name
    from (
  select iter.pos, split_part(src.name,',',iter.pos) as name
    from (select id as pos from t10) iter,
         (select cast(name as text) as name from v) src
   where iter.pos <=
          length(src.name)-length(replace(src.name,',',''))+1
         ) x
  where pos = 2

<SQL Server>
 with agg_tab(name)
     as
     (select STRING_AGG(name,',') from V)
 select value from
     STRING_SPLIT(
     (select name from agg_tab),',')
--------------------------------------------------------------------
<DB2>
select ','||csv.name|| ',' as name,
        iter.pos
  from v csv,
        (select row_number() over() pos from t100 ) iter
 where iter.pos <= length(csv.name)+2
--------------------------------------------------------------------
select pos, name, substr(name, pos) c,
       row_number() over(partition by name
                        order by length(substr(name, pos)) desc) rn
  from (
select ','||csv.name||',' as name,
       cast(iter.pos as integer) as pos
  from v csv,
      (select row_number() over() pos from t100 ) iter
 where iter.pos <= length(csv.name)+2
       ) x
 where length(substr(name,pos)) > 1
--------------------------------------------------------------------
select pos, name, substr(name,pos) c,
       row_number() over(partition by name
                       order by length(substr(name, pos)) desc) rn
  from (
select ','||csv.name||',' as name,
       cast(iter.pos as integer) as pos
  from v csv,
       (select row_number() over() pos from t100 ) iter 
 where iter.pos <= length(csv.name)+2
       ) x 
 where length(substr(name,pos)) > 1 
   and substr(substr(name,pos),1,1) = ','

<MySQL>
select iter.pos, src.name
  from (select id pos from t10) iter,
       V src
 where iter.pos <=
       length(src.name)-length(replace(src.name,',',''))
--------------------------------------------------------------------
select iter.pos,src.name name1,
         substring_index(src.name,',',iter.pos) name2,
         substring_index(
           substring_index(src.name,',',iter.pos),',',-1) name3
  from (select id pos from t10) iter,
       V src
 where iter.pos <=
         length(src.name)-length(replace(src.name,',',''))

<Oracle>
select iter.pos, src.name,
       substr( src.name,
         instr( src.name,',',1,iter.pos )+1,
         instr( src.name,',',1,iter.pos+1 )
         instr( src.name,',',1,iter.pos )-1) sub
  from (select ','||name||',' as name from v) src,
       (select rownum pos from emp) iter
 where iter.pos < length(src.name)-length(replace(src.name,','))
PostgreSQL
select iter.pos, src.name as name1,
         split_part(src.name,',',iter.pos) as name2
  from (select id as pos from t10) iter,
         (select cast(name as text) as name from v) src
 where iter.pos <=
         length(src.name)-length(replace(src.name,',',''))+1

6.15 IP 주소 파싱하기
<DB2>
 with x (pos,ip) as (
    values (1,'.92.111.0.222')
    union all
   select pos+1,ip from x where pos+1 <= 20
  )
  select max(case when rn=1 then e end) a,
         max(case when rn=2 then e end) b,
         max(case when rn=3 then e end) c,
         max(case when rn=4 then e end) d
   from (
 select pos,c,d,
        case when posstr(d,'.') > 0 then substr(d,1,posstr(d,'.')-1)
             else d
        end as e,
        row_number() over( order by pos desc) rn
   from (
 select pos, ip,right(ip,pos) as c, substr(right(ip,pos),2) as d
   from x
  where pos <= length(ip)
   and substr(right(ip,pos),1,1) = '.'
      ) x
      ) y

<MySQL>
 select substring_index(substring_index(y.ip,'.',1),'.',-1) a,
        substring_index(substring_index(y.ip,'.',2),'.',-1) b,
        substring_index(substring_index(y.ip,'.',3),'.',-1) c,
        substring_index(substring_index(y.ip,'.',4),'.',-1) d
   from (select '92.111.0.2' as ip from t1) y

<Oracle>
 select ip,
        substr(ip, 1, instr(ip,'.')-1 ) a,
        substr(ip, instr(ip,'.')+1,
                    instr(ip,'.',1,2)-instr(ip,'.')-1 ) b,
        substr(ip, instr(ip,'.',1,2)+1,
                    instr(ip,'.',1,3)-instr(ip,'.',1,2)-1 ) c,
        substr(ip, instr(ip,'.',1,3)+1 ) d
   from (select '92.111.0.2' as ip from t1)

<PostgreSQL>
 select split_part(y.ip,'.',1) as a,
        split_part(y.ip,'.',2) as b,
        split_part(y.ip,'.',3) as c,
        split_part(y.ip,'.',4) as d
   from (select cast('92.111.0.2' as text) as ip from t1) as y

<SQL Server>
   with x (pos,ip) as (
    select 1 as pos,'.92.111.0.222' as ip from t1
     union all
    select pos+1,ip from x where pos+1 <= 20
   )
   select max(case when rn=1 then e end) a,
          max(case when rn=2 then e end) b,
          max(case when rn=3 then e end) c,
          max(case when rn=4 then e end) d
    from (
  select pos,c,d,
         case when charindex('.',d) > 0
            then substring(d,1,charindex('.',d)-1)
            else d
         end as e,
         row_number() over(order by pos desc) rn
    from (
  select pos, ip,right(ip,pos) as c,
         substring(right(ip,pos),2,len(ip)) as d
    from x
   where pos <= len(ip)
     and substring(right(ip,pos),1,1) = '.'
       ) x
       ) y

6.16. 소리로 문자열 비교하기
 select an1.a_name as name1, an2.a_name as name2,
 SOUNDEX(an1.a_name) as Soundex_Name
 from author_names an1
 join author_names an2
 on (SOUNDEX(an1.a_name)=SOUNDEX(an2.a_name)
 and an1.a_name not like an2.a_name)

6.17 패턴과 일치하지 않는 텍스트 찾기
select emp_id, text
  from employee_comment.
--------------------------------------------------------------------
select emp_id, text
  from employee_comment
 where regexp_like(text, '[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}')
   and regexp_like(
         regexp_replace(text,
            '[0-9]{3}([-. ])[0-9]{3}\1[0-9]{4}','***'),
            '[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}')
