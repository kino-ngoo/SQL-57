-- [---JOY_SQL*Alert*QC1211*Check PO*POC0045*Check RCVD qty_pass <> 0 , but RCV dt_process is Null !---]

--sp_helptext zp_rs_QC1211_POC0045

-----------------------------------------------------------------------------------------------------

-- 兩段 SQL 都要檢查，若 expect_received 的 qty_pass <> 0，可能為分批收
-- 若 received 的 qty_iqc 有值，則須把 receive 的 status_receive 改 2
-- 是否為分批收，可查看 popo 對照

IF Object_id('tempdb.dbo.#tmp_qc') is not null DROP TABLE #tmp_qc

SELECT type               = '1. received.qty_pass <> 0'
      ,id_admcomp         = receive.id_admcomp
      ,id_receive_invoice = receive.id_receive_invoice
      ,id_receive         = receive.id_receive
      ,receive_no         = RTRIM(LTRIM(receive.receive_no))
      ,source_code        = RTRIM(LTRIM(receive.source_code))
      ,source_no          = RTRIM(LTRIM(receive.source_no))
      ,source_id          = receive.source_id
      ,invoice_no         = RTRIM(LTRIM(receive.invoice_no))
      ,dt_received        = receive.dt_received
      ,id_ictr            = receive.id_ictr
      ,dt_process         = receive.dt_process
      ,status_receive     = receive.status_receive
      ,id_received        = received.id_received
      ,id_expect_received = received.id_expect_received
      ,id_icim_comp       = received.id_icim_comp
      ,id_icstockroom     = received.id_icstkroom
      ,part_no            = RTRIM(LTRIM(icim_comp.part_no))
      ,model_no           = RTRIM(LTRIM(icim_sale.model_no))
      ,stock_room         = RTRIM(LTRIM(icstockroom.room_code)) + ' / ' + RTRIM(LTRIM(icstockroom.room_name))
--      ,room_code          = RTRIM(LTRIM(icstockroom.room_code))
--      ,room_name          = RTRIM(LTRIM(icstockroom.room_name))
      ,quantity           = received.quantity
      ,qty_pass           = received.qty_pass
      ,qty_iqc            = received.qty_iqc
      ,qty_reject         = received.qty_reject
      ,qty_un_receive     = received.qty_un_receive
      ,up                 = received.up
  INTO #tmp_qc
  FROM receive with(nolock)
      ,received with(nolock)
      ,admcomp with(nolock)
      ,icim_comp with(nolock)
      ,icim_sale with(nolock)
      ,icstockroom with(nolock)
 WHERE receive.id_receive = received.id_receive
   and receive.id_admcomp = admcomp.id_admcomp
   and received.id_icim_comp = icim_comp.id_icim_comp
   and received.id_icim_comp = icim_sale.id_icim_comp
   and received.id_icstkroom = icstockroom.id_icstockroom
   and receive.stat_void = 0
   and received.stat_void = 0
   and admcomp.stat_void = 0
   and icim_comp.stat_void = 0
   and icstockroom.stat_void = 0
   and receive.status_receive IN (6, 7)
   and isnull(receive.dt_process, '') = ''
   and receive.dt_received >= DateAdd(month, -3, GetDate())
   and received.qty_pass <> 0
UNION
SELECT type               = '2. receive.dt_received'
      ,id_admcomp         = receive.id_admcomp
      ,id_receive_invoice = receive.id_receive_invoice
      ,id_receive         = receive.id_receive
      ,receive_no         = RTRIM(LTRIM(receive.receive_no))
      ,source_code        = RTRIM(LTRIM(receive.source_code))
      ,source_no          = RTRIM(LTRIM(receive.source_no))
      ,source_id          = receive.source_id
      ,invoice_no         = RTRIM(LTRIM(receive.invoice_no))
      ,dt_received        = receive.dt_received
      ,id_ictr            = receive.id_ictr
      ,dt_process         = receive.dt_process
      ,status_receive     = receive.status_receive
      ,id_received        = received.id_received
      ,id_expect_received = received.id_expect_received
      ,id_icim_comp       = received.id_icim_comp
      ,id_icstockroom     = received.id_icstkroom
      ,part_no            = RTRIM(LTRIM(icim_comp.part_no))
      ,model_no           = RTRIM(LTRIM(icim_sale.model_no))
      ,stock_room         = RTRIM(LTRIM(icstockroom.room_code)) + ' / ' + RTRIM(LTRIM(icstockroom.room_name))
--      ,room_code          = RTRIM(LTRIM(icstockroom.room_code))
--      ,room_name          = RTRIM(LTRIM(icstockroom.room_name))
      ,quantity           = received.quantity
      ,qty_pass           = received.qty_pass
      ,qty_iqc            = received.qty_iqc
      ,qty_reject         = received.qty_reject
      ,qty_un_receive     = received.qty_un_receive
      ,up                 = received.up
  FROM receive with(nolock)
      ,received with(nolock)
      ,admcomp with(nolock)
      ,icim_comp with(nolock)
      ,icim_sale with(nolock)
      ,icstockroom with(nolock)
 WHERE receive.id_receive = received.id_receive
   and receive.id_admcomp = admcomp.id_admcomp
   and received.id_icim_comp = icim_comp.id_icim_comp
   and received.id_icim_comp = icim_sale.id_icim_comp
   and received.id_icstkroom = icstockroom.id_icstockroom
   and receive.stat_void = 0
   and received.stat_void = 0
   and admcomp.stat_void = 0
   and icim_comp.stat_void = 0
   and icstockroom.stat_void = 0
   and receive.status_receive IN (6, 7)
   and isnull(receive.dt_process, '') = ''
   and receive.dt_received >= DateAdd(month, -3, GetDate())
ORDER BY type, receive.id_admcomp, receive.id_receive, received.id_received

SELECT * FROM #tmp_qc

/*
SELECT id_popo, id_popod, id_poprd, id_expect_received, status_popod, qty_apply, qty_buy, qty_release, qty_shipped, qty_receive, qty_pass, qty_iqc, qty_reject, stat_no_charge, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM popod with(nolock)
 WHERE id_expect_received IN (2605366)
ORDER BY 4

SELECT id_oesod, id_oesosch, id_expect_received, status_received, id_shipmentd, qty_req, qty_promise, qty_ship, qty_received, qty_packing, status_oesosch, status_shipment, dt_schedule, dt_ship, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM oesosch with(nolock)
 WHERE id_expect_received IN (2605366)
ORDER BY 3

SELECT id_expect_receive, id_expect_received, status_received, source_id, qty_expect_receive, qty_received, qty_pass, qty_iqc, qty_reject, nocharge, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM expect_received with(nolock)
 WHERE id_expect_received IN ('2605366')
ORDER BY 2

SELECT id_receive, id_received, id_expect_received, source_id, quantity, qty_pass, qty_iqc, qty_reject, qty_un_receive, invoice_no, id_apinv, nocharge, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM received with(nolock)
 WHERE id_expect_received IN ('2605366')
ORDER BY 3

SELECT id_expect_receive, status_receive, expect_receive_no, source_no, source_id, source_code, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM expect_receive with(nolock)
 WHERE id_expect_receive IN (92984685)
ORDER BY 1

SELECT id_receive_invoice, id_receive, id_expect_receive, status_receive, id_ictr, dt_process, receive_no, source_no, source_id, source_code, invoice_no, create_by, dt_create, update_by, dt_update, stat_void, *
--UPDATE receive SET status_receive = 2, update_by = 'micky - POC0045', dt_update = GetDate()
  FROM receive with(nolock)
 WHERE id_receive IN ('2604205')
ORDER BY 1, 2

SELECT id_receive, id_received, id_expect_received, source_id, id_icstkroom, id_icim_comp, quantity, qty_pass, qty_iqc, qty_reject, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM received with(nolock)
 WHERE id_receive IN ('2604205')
ORDER BY 1, 2

SELECT id_ictr, id_ictrd, id_icstockroom, id_icim_comp, id_reference, qty_apply, qty_actual, up, sign, id_admslip_reason, id_glsubject_db, id_glsubject_cr, partno, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM ictrd with(nolock)
 WHERE id_reference IN ('1883228','1883334') --> received.id_received
   and dt_create >= DATEADD(YEAR, -1, GetDate())
ORDER BY 1, 2

SELECT id_ictr, id_admslip, tran_type, apply_no, dt_process, id_glvh, id_reference, ref_no, source_code, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM ictr with(nolock)
 WHERE id_ictr IN ('5845155','5845718')
ORDER BY 1

SELECT id_ictr, id_ictrd, id_icstockroom, id_icim_comp, id_reference, qty_apply, qty_actual, up, sign, id_admslip_reason, id_glsubject_db, id_glsubject_cr, partno, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM ictrd with(nolock)
 WHERE id_ictr IN (22425127)
ORDER BY 1, 2

SELECT *
  FROM icstockroom with(nolock)
 WHERE id_icstockroom IN ()

select a.tran_type,a.dt_process,a.stat_void,b.stat_void,e.room_name,qty = b.sign * b.qty_actual,b.* 
from ictr a(nolock)
      ,ictrd b(nolock)
	  ,received c(nolock)
	  ,receive d(nolock)
	  ,icstockroom e(nolock)
	  where a.id_ictr = b.id_ictr 
	  and b.id_reference = c.id_received 
	  and c.id_receive = d.id_receive
	  and b.id_icstockroom = e.id_icstockroom 
	  and a.stat_void = 0 
and b.stat_void = 0 
and c.stat_void = 0 
and d.stat_void = 0 
and a.tran_type in ('EXPIC','RCVIC','EXPRET','IQCREJ    ') 
and d.id_receive in ('2604205')
--and d.receive_no in ('LRI17120148_1','LRI17120149_1','LRI17120150_1')
*/