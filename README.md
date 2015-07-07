# pinetri

--getting perf-stat
select * from table(pinetri.get(0, 10, 3));

--getting perf-stat for specific sid
select sid from v$mystat where rownum=1; --sid 144
select * from table(pinetri.get(144, 10, 3);


