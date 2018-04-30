-- [---JOY_SQL*Urgent*QC1211*Check PO*POC0053*duplicable POPO in expect_receive---]

--sp_helptext zp_rs_QC1211_POC0053

-----------------------------------------------------------------------------------------------------

IF Object_id('tempdb.dbo.#tmp_aa') is not null DROP TABLE #tmp_aa

SELECT source_id
  INTO #tmp_aa
  FROM expect_receive with(nolock)
 WHERE stat_void = 0
   and source_code = 'PO'
--   and status_receive < 7
   and (status_receive < 7 or status_receive = 10)
   and dt_create >= DateAdd(Month, -3, GetDate())
GROUP BY source_id
HAVING count(*) > 1

--SELECT '#tmp_aa', * FROM #tmp_aa

-- For Same PO has different id_expect_receive
IF Object_id('tempdb.dbo.#tmp_bb') is not null DROP TABLE #tmp_bb

SELECT expect_receive.source_id
      ,expect_receive.id_admcomp
      ,expect_receive.id_expect_receive
  INTO #tmp_bb
  FROM expect_receive with(nolock)
      ,#tmp_aa
 WHERE expect_receive.source_id = #tmp_aa.source_id
   and expect_receive.stat_void = 0
   and expect_receive.source_code = 'PO'
   and (expect_receive.status_receive < 7 or expect_receive.status_receive = 10)
GROUP BY expect_receive.source_id, expect_receive.id_admcomp, expect_receive.id_expect_receive

--SELECT '#tmp_bb', * FROM #tmp_bb

IF Object_id('tempdb.dbo.#tmp_cc') is not null DROP TABLE #tmp_cc

SELECT source_id
  INTO #tmp_cc
  FROM #tmp_bb
GROUP BY source_id
HAVING count(*) > 1

--SELECT '#tmp_cc', * FROM #tmp_cc

IF Object_id('tempdb.dbo.#tmp_qc') is not null DROP TABLE #tmp_qc

SELECT type               = 'Same PO has duplicate expect_receive data'
      ,id_admcomp         = expect_receive.id_admcomp
      ,id_expect_receive  = expect_receive.id_expect_receive
      ,source_id          = expect_receive.source_id
      ,source_no          = RTRIM(LTRIM(expect_receive.source_no))
      ,expect_receive_no  = RTRIM(LTRIM(expect_receive.expect_receive_no))
      ,id_expect_received = expect_received.id_expect_received
  INTO #tmp_qc
  FROM expect_receive with(nolock)
      ,expect_received with(nolock)
      ,#tmp_aa
 WHERE expect_receive.id_expect_receive = expect_received.id_expect_receive
   and expect_receive.source_id = #tmp_aa.source_id
   and expect_receive.stat_void = 0
   and expect_received.stat_void = 0
   and expect_receive.source_code = 'PO'
   and (expect_receive.status_receive < 7 or expect_receive.status_receive = 10)
   and expect_received.qty_received = 0
   and not exists(SELECT 1
                    FROM popo with(nolock)
                        ,popod with(nolock)
                   WHERE expect_receive.source_id = popo.id_popo
                     and expect_received.id_expect_received = popod.id_expect_received
                     and popo.id_popo = popod.id_popo
                     and popo.stat_void = 0
                     and popod.stat_void = 0)
UNION
SELECT type               = 'Same PO has different id_expect_receive'
      ,id_admcomp         = expect_receive.id_admcomp
      ,id_expect_receive  = expect_receive.id_expect_receive
      ,source_id          = expect_receive.source_id
      ,source_no          = RTRIM(LTRIM(expect_receive.source_no))
      ,expect_receive_no  = RTRIM(LTRIM(expect_receive.expect_receive_no))
--      ,id_expect_received = 0
      ,id_expect_received = expect_received.id_expect_received
  FROM expect_receive with(nolock)
         LEFT JOIN expect_received with(nolock) on expect_receive.id_expect_receive = expect_received.id_expect_receive and expect_received.stat_void = 0
      ,#tmp_cc
 WHERE expect_receive.source_id = #tmp_cc.source_id
   and expect_receive.source_code = 'PO'
   and expect_receive.stat_void = 0
   and (expect_receive.status_receive < 7 or expect_receive.status_receive = 10)
ORDER BY type, expect_receive.id_admcomp, expect_receive.source_id, expect_receive.id_expect_receive

SELECT * FROM #tmp_qc where id_expect_received not in ('4138682','4138683','4138684','4138685',
'4138686','4138687','4138688')

/*--micky 用expect_receive.source_id = popo.id_popo去找相同的單，再
begin tran
--rollback
--commit
--update expect_receive set stat_void = 9 ,update_by = 'micky' ,dt_update = getdate() where id_expect_receive = 622121 ,622122
*/
/*
SELECT id_expect_receive, expect_receive_no, source_no, source_id, source_code, status_receive, create_by, dt_create, update_by, dt_update, stat_void, *
--UPDATE expect_receive SET stat_void = 9, update_by = 'saktt - POC0053', dt_update = GetDate()
  FROM expect_receive with(nolock)
 WHERE id_expect_receive IN ('622121','622113','622122')
ORDER BY 1

SELECT id_expect_receive, id_expect_received, source_id, qty_expect_receive, qty_received, qty_pass, qty_iqc, qty_reject, status_received, create_by, dt_create, update_by, dt_update, stat_void, *
--UPDATE expect_received SET id_expect_receive = ?, update_by = 'saktt - POC0053', dt_update = GetDate()
--UPDATE expect_received SET stat_void = 9, update_by = 'saktt - POC0053', dt_update = GetDate()
  FROM expect_received with(nolock)
 WHERE id_expect_receive IN ('622121','622113','622122')
ORDER BY 1, 2

SELECT id_popo, id_popod, id_poprd, id_expect_received, status_popod, qty_apply, qty_buy, qty_release, qty_shipped, qty_receive, qty_pass, qty_iqc, qty_reject, stat_no_charge, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM popod with(nolock)
 WHERE id_expect_received IN ('4138672','4138682','4138683','4138684',
'4138685','4138686','4138687','4138688')
-- WHERE id_popod IN ()
ORDER BY 4

SELECT id_receive, id_received, id_expect_received, source_id, quantity, qty_pass, qty_iqc, qty_reject, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM received with(nolock)
 WHERE id_expect_received IN ()
ORDER BY 3

SELECT id_receive_invoice, id_receive, id_expect_receive, receive_no, status_receive, dt_received, invoice_no, id_ictr, dt_process, source_code, source_no, source_id, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM receive with(nolock)
 WHERE id_receive IN ()
ORDER BY 1, 2

SELECT id_receive_invoice, receive_no, receive_type, dt_receive_invoice, invoice_no, invoice_type, tax_type, amt_invoice, amt_tax, delivery_no, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM receive_invoice with(nolock)
 WHERE id_receive_invoice IN ()
ORDER BY 1
*/