-- DDL Script was generated by Orange for ORACLE
-- using session 'TSQL@NGMS1' on '2015/01/06 14:23:21'.

CREATE OR REPLACE package body pinetri
is
--    type t_tf_row as object (id number, gen_dt date, logrds number); --package에서 정의가 안된다.
--    type t_tf_row is record (id number, gen_dt date, logrds number);
--    type t_tf_tab is table of t_tf_row;

--    l_row t_tf_row; --package variable
--    l_row_p t_tf_row;

    function get_perf(v_sid in number) return t_tf_row
    is
        l_return t_tf_row;
    begin

        if v_sid = 0 then
--            select sysdate,
--                   value
--              into
--                   l_return.gen_dt,
--                   l_return.logrds
--            from   v$sysstat
--            where  STATISTIC# in (12,588);
            select systimestamp, logrds, exec
               into l_return.gen_dt, l_return.logrds, l_return.exec
            from (
                select *
                from (
                    select statistic#,
                           value
                    from   v$sysstat
                    where  STATISTIC# in (12,588)
                )
                pivot (sum(value) for (statistic#) in (12 as logrds, 588 as exec))
            ) a
            ;

            select sum(decode(status, 'ACTIVE', 1, 0)) ats
              into l_return.ats
              from v$session where username is not null;

            select nvl(sum(seconds_in_wait),0) apco
              into l_return.apco
              from v$session_wait where state='WAITING' and wait_class in ('Application', 'Concurrency');

            select nvl(sum(used_urec),0)
              into l_return.undo_rec
              from v$transaction;

            select evt
              into l_return.event
              from (
                 select event || '(' || to_char(count(event)) || ')' evt
                  from v$session
                 where status = 'ACTIVE'
                 group by event
                 order by count(event) desc
             ) where rownum = 1
             ;
        else
            select systimestamp, logrds, exec
               into l_return.gen_dt, l_return.logrds, l_return.exec
            from (
                select *
                from (
                    select statistic#,
                           sum(value) sv
                    from   v$sesstat
                    where  STATISTIC# in (12,588)
                      and  (sid in (select sid from v$px_session where qcsid = v_sid) or sid = v_sid)
                    group by statistic#
                )
                pivot (sum(sv) for (statistic#) in (12 as logrds, 588 as exec))
            ) a
            ;

            select sum(decode(status, 'ACTIVE', 1, 0)) ats
              into l_return.ats
              from v$session where username is not null --except the backgrounds?
               and  (sid in (select sid from v$px_session where qcsid = v_sid) or sid = v_sid)
               ;

            select nvl(sum(seconds_in_wait),0) apco
              into l_return.apco
              from v$session_wait where state='WAITING' and wait_class in ('Application', 'Concurrency')
               and (sid in (select sid from v$px_session where qcsid = v_sid) or sid = v_sid)
              ;

            select nvl(sum(t.used_urec), 0)
              into l_return.undo_rec
              from v$transaction t, v$session s
             where s.taddr = t.addr
               and (s.sid in (select sid from v$px_session where qcsid = v_sid) or s.sid = v_sid)
               ;

            select event into l_return.event
              from v$session where  sid = v_sid;

        end if;
--        dbms_output.put_line(to_char(l_return.gen_dt) || ',' || to_char(l_return.logrds));
        return l_return;
    end;

    function get_delta(after in t_tf_row, before in t_tf_row) return t_tf_row
    is
        l_delta number;
        l_return t_tf_row;
    begin
        select extract(second from (after.gen_dt-before.gen_dt)) into l_delta from dual;

        -- dbms_output.put_line('delta-seconds:' || to_char(l_delta));
        -- l_return := after - before;
        l_return.logrds := round((after.logrds - before.logrds)/l_delta);
        l_return.exec := round((after.exec - before.exec)/l_delta);

        l_return.ats := after.ats;
        l_return.apco := after.apco;
        l_return.gen_dt := after.gen_dt;
        l_return.undo_rec := after.undo_rec;
        l_return.event := after.event;
        return l_return;
    end;

--    procedure get_perf(l_return out nocopy t_tf_row)
--    is
--    begin
--        select
--               value
--          into
--               l_return.logrds
--        from   v$sysstat
--        where  STATISTIC#=12;
--    end;

    function get(p_sid in number, p_rows in number, p_interval in number) return t_tf_tab pipelined
    is
        l_first t_tf_row  := null;
        l_last t_tf_row   := null;
        l_return t_tf_row := null;
    begin

        l_first := get_perf(p_sid);

        for idx in 1..p_rows
        loop
            dbms_lock.sleep(p_interval);
            l_last := get_perf(p_sid);
            l_return := get_delta(l_last, l_first);
            l_return.id := idx;

            pipe row(l_return);
            --pipe row(t_tf_row(..)); 이 형태로는 동작하지 않는다

            l_first := l_last;
        end loop;
    end;

end pinetri;