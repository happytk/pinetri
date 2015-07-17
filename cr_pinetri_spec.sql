/*
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
*/
CREATE OR REPLACE package pinetri
is
    --package내부에서는 object선언이 불가능?
--    type t_tf_row as object (id number, gen_dt date, logrds number);
    type t_tf_row is record (
    	id number,
    	gen_dt timestamp,
    	logrds number,
    	phyrds number,
    	exec number,
    	ats number,
        cpu number,
        cpu_idle number,
        cpu_busy number,
    	tx_cnt number,
    	ap number,
    	co number,
    	undo_rec number,
    	pga_mb number,
    	event varchar2(255)
    );
    type t_tf_tab is table of t_tf_row;

    --procedure보다는 function이 더 직관적이므로
--    procedure get_perf(l_out out nocopy t_tf_row);
    function get_perf(v_sid in number) return t_tf_row;
    function get_delta(after in t_tf_row, before in t_tf_row) return t_tf_row;

    function get(p_sid in number, p_rows in number, p_interval in number) return t_tf_tab pipelined;
end pinetri;