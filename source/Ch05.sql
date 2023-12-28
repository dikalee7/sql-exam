Chapter 5. 메타 데이터 쿼리

5.1 스키마의 테이블 목록 보기
<DB2>
 select tabname
   from syscat.tables
  where tabschema = 'SMEAGOL'

<Oracle>
select table_name
  from all_tables
 where owner = 'SMEAGOL'

<PostgreSQL, MySQL, SQL Server>
 select table_name
   from information_schema.tables
  where table_schema = 'SMEAGOL'

5.2. 테이블의 열 나열하기
<DB2>
 select colname, typename, colno
   from syscat.columns
  where tabname   = 'EMP'
    and tabschema = 'SMEAGOL'

<Oracle>
 select column_name, data_type, column_id
   from all_tab_columns
  where owner      = 'SMEAGOL'
    and table_name = 'EMP'

<PostgreSQL, MySQL, SQL Server>
 select column_name, data_type, ordinal_position
   from information_schema.columns
  where table_schema = 'SMEAGOL'
    and table_name   = 'EMP'

5.3 테이블의 인덱싱된 열 나열하기
<DB2>
  select a.tabname, b.indname, b.colname, b.colseq
    from syscat.indexes a,
         syscat.indexcoluse b
   where a.tabname   = 'EMP'
     and a.tabschema = 'SMEAGOL'
     and a.indschema = b.indschema
     and a.indname   = b.indname

<Oracle>
select table_name, index_name, column_name, column_position
  from sys.all_ind_columns
 where table_name  = 'EMP'
   and table_owner = 'SMEAGOL'

<PostgreSQL>
  select a.tablename,a.indexname,b.column_name
    from pg_catalog.pg_indexes a,
         information_schema.columns b
   where a.schemaname = 'SMEAGOL'
     and a.tablename  = b.table_name

<MySQL>
show index from emp

<SQL Server>
  select a.name table_name,
         b.name index_name,
         d.name column_name,
         c.index_column_id
    from sys.tables a,
         sys.indexes b,
         sys.index_columns c,
         sys.columns d
  where a.object_id = b.object_id
    and b.object_id = c.object_id
    and b.index_id  = c.index_id
    and c.object_id = d.object_id
    and c.column_id = d.column_id
    and a.name      = 'EMP'

5.4 테이블의 제약조건 나열하기
<DB2>
  select a.tabname, a.constname, b.colname, a.type
    from syscat.tabconst a,
         syscat.columns b
   where a.tabname   = 'EMP'
     and a.tabschema = 'SMEAGOL'
     and a.tabname   = b.tabname
     and a.tabschema = b.tabschema

<Oracle>
  select a.table_name,
         a.constraint_name,
         b.column_name,
         a.constraint_type
    from all_constraints a,
         all_cons_columns b
   where a.table_name      = 'EMP'
     and a.owner           = 'SMEAGOL'
     and a.table_name      = b.table_name
     and a.owner           = b.owner
     and a.constraint_name = b.constraint_name

<PostgreSQL, MySQL, SQL Server>
  select a.table_name,
         a.constraint_name,
         b.column_name,
         a.constraint_type
    from information_schema.table_constraints a,
         information_schema.key_column_usage b
   where a.table_name      = 'EMP'
     and a.table_schema    = 'SMEAGOL'
     and a.table_name      = b.table_name
     and a.table_schema    = b.table_schema
     and a.constraint_name = b.constraint_name

5.5. 관련 인덱스가 없는 외래 키 나열하기
<DB2>
   select fkeys.tabname,
          fkeys.constname,
          fkeys.colname,
          ind_cols.indname
     from (
   select a.tabschema, a.tabname, a.constname, b.colname
     from syscat.tabconst a,
          syscat.keycoluse b
    where a.tabname    = 'EMP'
     and a.tabschema  = 'SMEAGOL'
     and a.type       = 'F'
     and a.tabname    = b.tabname
     and a.tabschema  = b.tabschema
         ) fkeys
         left join
         (
  select a.tabschema,
         a.tabname,
         a.indname,
         b.colname
    from syscat.indexes a,
         syscat.indexcoluse b
  where a.indschema  = b.indschema
    and a.indname    = b.indname
        ) ind_cols
     on (fkeys.tabschema = ind_cols.tabschema
          and fkeys.tabname   = ind_cols.tabname
          and fkeys.colname   = ind_cols.colname )
  where ind_cols.indname is null

<Oracle>
   select a.table_name,
          a.constraint_name,
          a.column_name,
          c.index_name
     from all_cons_columns a,
          all_constraints b,
          all_ind_columns c
    where a.table_name      = 'EMP'
      and a.owner           = 'SMEAGOL'
     and b.constraint_type = 'R'
     and a.owner           = b.owner
     and a.table_name      = b.table_name
     and a.constraint_name = b.constraint_name
     and a.owner           = c.table_owner (+)
     and a.table_name      = c.table_name (+)
     and a.column_name     = c.column_name (+)
     and c.index_name      is null

<PostgreSQL>
  select fkeys.table_name,
         fkeys.constraint_name,
         fkeys.column_name,
         ind_cols.indexname
    from (
  select a.constraint_schema,
         a.table_name,
         a.constraint_name,
         a.column_name
    from information_schema.key_column_usage a,
        information_schema.referential_constraints b
   where a.constraint_name   = b.constraint_name
     and a.constraint_schema = b.constraint_schema
     and a.constraint_schema = 'SMEAGOL'
     and a.table_name        = 'EMP'
         ) fkeys
         left join
         (
  select a.schemaname, a.tablename, a.indexname, b.column_name
    from pg_catalog.pg_indexes a,
         information_schema.columns b
   where a.tablename  = b.table_name
     and a.schemaname = b.table_schema
         ) ind_cols
      on (  fkeys.constraint_schema = ind_cols.schemaname
           and fkeys.table_name     = ind_cols.tablename
           and fkeys.column_name    = ind_cols.column_name )
   where ind_cols.indexname is null

<SQL Server>
  select fkeys.table_name,
         fkeys.constraint_name,
         fkeys.column_name,
         ind_cols.index_name
    from (
  select a.object_id,
         d.column_id,
         a.name table_name,
         b.name constraint_name,
         d.name column_name
    from sys.tables a
         join
         sys.foreign_keys b
      on ( a.name          = 'EMP'
           and a.object_id = b.parent_object_id
         )
         join
         sys.foreign_key_columns c
     on (  b.object_id = c.constraint_object_id )
        join
        sys.columns d
     on (    c.constraint_column_id = d.column_id
         and a.object_id            = d.object_id
        )
        ) fkeys
        left join
        (
 select a.name index_name,
        b.object_id,
        b.column_id
   from sys.indexes a,
        sys.index_columns b
  where a.index_id = b.index_id
        ) ind_cols
     on (     fkeys.object_id = ind_cols.object_id
          and fkeys.column_id = ind_cols.column_id )
  where ind_cols.index_name is null

5.6 SQL로 SQL 생성하기
/* 여러분 스키마의 모든 테이블에서 모든 행의 수를 세는 SQL 생성 */
select 'select count(*) from '||table_name||';' cnts
  from user_tables;
--------------------------------------------------------------------
/* 모든 테이블의 외래 키를 비활성화하기 */
select 'alter table '||table_name||
       ' disable constraint '||constraint_name||';' cons
  from user_constraints
 where constraint_type = 'R';
--------------------------------------------------------------------
/* EMP 테이블의 일부 열에 삽입하는 스크립트 생성하기 */
select 'insert into emp(empno,ename,hiredate) '||chr(10)||
       'values( '||empno||','||''''||ename
       ||''',to_date('||''''||hiredate||''') );' inserts
  from emp
 where deptno = 10;

5.7. Oracle 데이터베이스에서 데이터 딕셔너리 뷰 확인하기
select table_name, comments
  from dictionary
  order by table_name;
--------------------------------------------------------------------
select column_name, comments
  from dict_columns
 where table_name = 'ALL_TAB_COLUMNS';