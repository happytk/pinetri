# pinetri

```sql
--getting perf-stat (10 times, 3s interval)
select * from table(pinetri.get(0, 10, 3));

--getting perf-stat for specific sid (10 times, 3s interval)
select sid from v$mystat where rownum=1; --sid 144
select * from table(pinetri.get(144, 10, 3);
```

# install

```sql

SQL> create user pinetri identified by pinetri;
SQL> grant create session to pinetri;
SQL> grant create procedure to pinetri;
SQL> grant select on v_$sysstat to pinetri;
SQL> grant select on v_$sesstat to pinetri;
SQL> grant select on v_$session to pinetri;
SQL> grant select on v_$session_wait to pinetri;
SQL> grant select on v_$transaction to pinetri;
SQL> grant select on v_$statname to pinetri;
SQL> grant select on v_$px_session to pinetri;
SQL> grant execute on sys.dbms_lock to pinetri;
SQL> conn pinetri/pinetri
SQL> @cr_pinetri_spec
SQL> @cr_pinetri_body

```

