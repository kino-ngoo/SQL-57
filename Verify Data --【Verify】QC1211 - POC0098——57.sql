-- [---MISSQL*Urgent*QC1211*Check SO*POC0098*IQC Reject But Not Exists ictr ( IQCREJ )---]

--sp_helptext zp_rs_QC1211_POC0098

-----------------------------------------------------------------------------------------------------

IF Object_id('tempdb.dbo.#tmp_qc') is not null DROP TABLE #tmp_qc

SELECT id_admcomp   = id_admcomp
      ,id_iqcmaster = id_iqcmaster
      ,inspect_no   = RTRIM(LTRIM(inspect_no))
      ,part_no      = RTRIM(LTRIM(part_no))
      ,dt_inspect   = dt_inspect
      ,request_by   = RTRIM(LTRIM(request_by))
      ,inspect_by   = RTRIM(LTRIM(inspect_by))
      ,qty_inspect  = qty_inspect
      ,release_no   = RTRIM(LTRIM(release_no))
      ,ref_no       = RTRIM(LTRIM(ref_no))
      ,notes        = RTRIM(LTRIM(notes))
  INTO #tmp_qc
  FROM iqc_master with(nolock)
 WHERE dt_inspect >= '2018-01-01'
   and qty_reject > 0
 --and ref_no = 'RI18011710_1'
 --and id_iqcmaster = 2176159 
   and not exists(SELECT 1
                    FROM ictr with(nolock)
                   WHERE iqc_master.ref_no = ictr.ref_no
                     and ictr.stat_void = 0
                     and ictr.tran_type = 'IQCREJ')
ORDER BY id_admcomp, id_iqcmaster

SELECT * FROM #tmp_qc

/*--SELECT * FROM admuser WHERE user_id = 'J1640290'
SELECT id_iqcmaster, inspect_no, release_no, ref_no, part_no, qty_reject, dt_inspect, request_by, inspect_by, qty_inspect, notes, *
  FROM iqc_master with(nolock)
 --WHERE id_iqcmaster IN ('1451940')
 WHERE ref_no = 'RI18011710_1'
ORDER BY 1

SELECT *
  FROM iqc_detail wit(nolock)
 WHERE id_iqcmaster IN ('1451940')

SELECT id_receive_invoice, id_receive, receive_no, source_code, source_no, source_id, id_icim_comp, qty_receive, qty_inspect, qty_reject, dt_received, invoice_no, dt_ap, status_receive, id_ictr, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM receive with(nolock)
 WHERE receive_no IN ('RI18011710_1') -- iqc_master.inspect_no
ORDER BY 1, 2

SELECT *
  FROM receive_relation with(nolock)
 WHERE id_relation = 2530995 --receive.id_receive
SELECT *
  FROM rec_ic with(nolock)
 WHERE id_rec_id = --receive_relation.ref_id

select a.tran_type,a.dt_process,c.* 
from ictr a(nolock)
      ,ictrd b(nolock)
	  ,received c(nolock)
	  ,receive d(nolock)
	  where a.id_ictr = b.id_ictr 
	  and b.id_reference = c.id_received 
	  and c.id_receive = d.id_receive
	  and a.stat_void = 0 
and b.stat_void = 0 
and c.stat_void = 0 
and d.stat_void = 0 
and a.tran_type in ('EXPIC','RCVIC','EXPRET','IQCREJ    ') 
--and c.id_receive = 2530995-- 2530994
and d.receive_no = 'RI18011710_1 '

SELECT *
  FROM expect_received with(nolock)
 WHERE id_expect_receive = 92951147
--id_expect_received = 2525253

SELECT *
  FROM expect_receive with(nolock)
 WHERE id_expect_receive = 92951147
*/

/*

BEGIN TRAN
--ROLLBACK
--COMMIT

SELECT *
FROM expect_receive WHERE id_expect_receive = 620720

SELECT status_received ,*
--update expect_received set qty_pass = 0 ,qty_iqc = 200 ,qty_reject = 0 ,update_by = 'micky - POC0098' ,dt_update = getdate()
  FROM expect_received
 WHERE id_expect_received = 4130428

SELECT status_receive ,id_ictr ,dt_process ,*
--update receive set status_receive = 1 ,qty_inspect = 200 ,qty_reject = 0 ,dt_process = NULL ,update_by = 'micky - POC0098' ,dt_update = getdate()
  FROM receive
 WHERE id_receive = 3303340 

 --select * from receive where receive_no = 'RI18011710_1'

 SELECT *
--update received set qty_iqc = 200 ,qty_pass = 0 ,qty_reject = 0 ,update_by = 'micky - POC0098' ,dt_update = getdate()
  FROM received
 WHERE id_receive = 3303340

 SELECT *
--delete
   FROM iqc_master
 WHERE ref_no = 'RI18011710_1'

SELECT *
--delete
  FROM iqc_detail 
 WHERE id_iqcmaster = 2205552
-- --IN ('1451940')

SELECT *
  FROM ictr

 --select * from reason where reason_code= 41413

 --select * from receive_invoice where receive_no = 'RI17121660A'

 --select * from  icstockroom  where room_code = 'ACCIQC'
*/

 /*
 select a.tran_type,a.dt_process,a.* 
from ictr a(nolock)
      ,ictrd b(nolock)
	  ,received c(nolock)
	  ,receive d(nolock)
	  where a.id_ictr = b.id_ictr 
	  and b.id_reference = c.id_received 
	  and c.id_receive = d.id_receive
	  and a.stat_void = 0 
and b.stat_void = 0 
and c.stat_void = 0 
and d.stat_void = 0 
and a.tran_type in ('EXPIC','RCVIC','EXPRET','IQCREJ    ') 
and d.receive_no = 'RI18011710_1'


SELECT *
FROM ictr with(nolock)
    ,iqc_master with(nolock)
WHERE iqc_master.inspect_no = ictr.ref_no
and ictr.stat_void = 0
and ictr.tran_type = 'IQCREJ'
and iqc_master.inspect_no = 'QC180104173J'
 */