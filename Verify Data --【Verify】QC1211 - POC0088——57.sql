 -- [---JOY_SQL*Alert*QC1211*Check PO*POC0088*Check Receive IQC Exists ,but ictr EXPIC not Exists---]

--sp_helptext zp_rs_QC1211_POC0088

-----------------------------------------------------------------------------------------------------

IF Object_id('tempdb.dbo.#tmp_qc') is not null DROP TABLE #tmp_qc

SELECT id_admcomp         = receive.id_admcomp
      ,id_receive_invoice = receive.id_receive_invoice
      ,id_receive         = receive.id_receive
      ,receive_no         = RTRIM(LTRIM(receive.receive_no))
      ,source_no          = RTRIM(LTRIM(receive.source_no))
      ,invoice_no         = RTRIM(LTRIM(receive.invoice_no))
      ,source_code        = RTRIM(LTRIM(receive.source_code))
      ,id_received        = received.id_received
      ,id_icstockroom     = icstockroom.id_icstockroom
      ,id_icim_comp       = icim_comp.id_icim_comp
      ,room_code          = RTRIM(LTRIM(icstockroom.room_code))
      ,room_name          = RTRIM(LTRIM(icstockroom.room_name))
      ,part_no            = RTRIM(LTRIM(icim_comp.part_no))
      ,quantity           = received.quantity
      ,qty_iqc            = received.qty_iqc
      ,qty_pass           = received.qty_pass
      ,qty_reject         = received.qty_reject
      ,qty_un_receive     = received.qty_un_receive
      ,id_expect_received = received.id_expect_received
  INTO #tmp_qc
  FROM receive with(nolock)
      ,received with(nolock)
      ,icstockroom with(nolock)
      ,icim_comp with(nolock)
 WHERE receive.id_receive = received.id_receive
   and received.id_icstkroom = icstockroom.id_icstockroom
   and received.id_icim_comp = icim_comp.id_icim_comp
   and receive.stat_void = 0
   and received.stat_void = 0
   and icstockroom.stat_void = 0
   and icim_comp.stat_void = 0
   and receive.dt_create >= DateAdd(month, -3, GetDate())
   and receive.source_code = 'PO'
   and received.qty_iqc > 0
   and not exists(SELECT 1
                    FROM ictrd with(nolock)
                        ,ictr with(nolock)
                   WHERE received.id_received = ictrd.id_reference
                     and ictrd.id_ictr = ictr.id_ictr
                     and ictrd.stat_void = 0
                     and ictr.stat_void = 0
                     and ictr.tran_type = 'EXPIC')
ORDER BY receive.id_receive_invoice, receive.id_admcomp, receive.id_receive, received.id_received, icstockroom.id_icstockroom

SELECT * FROM #tmp_qc

/*
1. Check IF "receive_invoice.stat_void <> 0" & "id_receive_invoice < 0"
   => Insert New "receive_invoice"
   => Update "receive.id_receive_invoice"
   => Add New "admprocess_queue"

2. Check IF "admprocess_queue" Failed
   => zp_admprocess_processing_receive_to_iqc

3. Check IF "admprocess_queue" Not Exists
   => Add New "admprocess_queue"
*/

/*
SELECT *
  FROM admprocess_queue with(nolock)
 WHERE source_id IN (751274) -- id_receive_invoice
ORDER BY id_admprocess_queue

SELECT *
  FROM admprocess_log with(nolock)
 WHERE source_id IN (751274) -- id_receive_invoice
ORDER BY id_admprocess_queue, dt_complete
*/

/*
SELECT id_receive_invoice, receive_no, id_admslip, receive_type, invoice_no, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM receive_invoice with(nolock)
 WHERE id_receive_invoice IN (751274) 
ORDER BY 1, 2

SELECT id_receive, id_receive_invoice, id_expect_receive, receive_no, status_receive, dt_received, invoice_no, id_ictr, dt_process, qty_receive, qty_inspect, qty_reject, source_code, source_no, source_id, create_by, dt_create, update_by, dt_update, stat_void, *
--UPDATE receive SET stat_void = 9, update_by = 'saktt - POC0088', dt_update = GetDate()
  FROM receive with(nolock)
 WHERE id_receive IN (3289760)
-- WHERE id_receive_invoice IN ()
ORDER BY 1, 2

SELECT id_receive, id_received, id_expect_received, source_id, quantity, qty_pass, qty_iqc, qty_reject, qty_un_receive, nocharge, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM received with(nolock)
 WHERE id_receive IN (3289760)
-- WHERE id_received IN ()
ORDER BY 1, 2

SELECT *
  FROM iqc_master with(nolock)
 WHERE ref_no IN ('RI17124374_1   ') -- receive.receive_no
-- WHERE dt_inspect >= ''
ORDER BY ref_no, id_iqcmaster

SELECT *
  FROM iqc_detail with(nolock)
 WHERE id_iqcmaster IN (2194711)
ORDER BY id_iqcmaster, id_iqcdetail

SELECT id_expect_receive, expect_receive_no, source_code, source_id, source_no, receive_type, dt_apply, dt_receiveschedule, status_receive, stat_hold, dt_close, create_by, dt_create, update_by, dt_update, stat_void, record_info, *
  FROM expect_receive with(nolock)
 WHERE id_expect_receive IN (618924)
ORDER BY 1

SELECT id_expect_receive, id_expect_received, source_id, id_icim_comp, id_icstkroom, qty_expect_receive, qty_received, qty_pass, qty_iqc, qty_reject, up, nocharge, status_received, stat_hold, dt_close, dt_schedule, create_by, dt_create, update_by, dt_update, stat_void, record_info, *
  FROM expect_received with(nolock)
 WHERE id_expect_received IN (4103715)
ORDER BY 1, 2

SELECT id_popo, id_popr, po_no, tax_rate, amt_orig_po, amt_orig_ap, status_po, status_popo, dt_need, create_by, dt_create, update_by, dt_update, stat_void, record_info, *
  FROM popo with(nolock)
 WHERE id_popo IN (401624)
ORDER BY 1

SELECT id_popo, id_popod, id_poprd, id_expect_received, id_shipmentd, status_popod, id_icim_comp, id_icstockroom, qty_apply, qty_buy, qty_release, qty_shipped, qty_receive, qty_pass, qty_iqc, qty_reject, up, stat_gotoshipping, stat_gotoreceiving, dt_need, dt_forceclose, dt_shipped, create_by, dt_create, update_by, dt_update, stat_void, record_info, *
  FROM popod with(nolock)
 WHERE id_popod IN (2799683)
-- WHERE id_expect_received IN ()
ORDER BY 1, 2

SELECT id_ictr, id_ictrd, id_icim_comp, id_reference, qty_apply, qty_actual, up, sign, id_admslip_reason, id_glsubject_db, id_glsubject_cr, partno, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM ictrd with(nolock)
 WHERE id_reference IN (4239268) -- received.id_received
ORDER BY 1, 2

SELECT id_ictr, id_admslip, tran_type, apply_no, dt_process, id_glvh, id_reference, ref_no, source_code, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM ictr with(nolock)dongmu
 WHERE id_ictr IN (12855451)
ORDER BY 1

SELECT id_ictr, id_ictrd, id_icim_comp, id_reference, qty_apply, qty_actual, up, sign, id_admslip_reason, id_glsubject_db, id_glsubject_cr, partno, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM ictrd with(nolock)
 WHERE id_ictr IN ()
ORDER BY 1, 2
*/

/*
-- Check IF "receive_invoice.stat_void <> 0" & "id_receive_invoice < 0"

BEGIN TRAN

DECLARE @arg_id_receive_invoice Int
       ,@id_receive_invoice Int

SELECT @arg_id_receive_invoice =  744824-- ☆★☆★☆★☆★☆★☆★

IF Object_id('tempdb.dbo.#tmp_receive_invoice') is not null DROP TABLE #tmp_receive_invoice

SELECT *
  INTO #tmp_receive_invoice
  FROM receive_invoice with(nolock)
 WHERE id_receive_invoice = @arg_id_receive_invoice

UPDATE receive_invoice
   SET receive_no = RTRIM(LTRIM(receive_no)) + '_v'
      ,invoice_no = RTRIM(LTRIM(invoice_no)) + '_v'
  FROM receive_invoice with(nolock)
 WHERE id_receive_invoice = @arg_id_receive_invoice

exec @id_receive_invoice = zp_pub_GetIdentityvalue 'receive_invoice', 'id_receive_invoice', 0
-- zp_pub_GetIdentityvalue
  --> 第一個參數為資料表名稱
  --> 第二個參數為欄位名稱
  --> 第三個參數傳 0，則 @id_receive_invoice 會接收到 receive_invoice 裡 id_receive_invoice 欄位中最大值為多少
  --> 第三個參數傳 1，則 @id_receive_invoice 會接收到 receive_invoice 裡 id_receive_invoice 欄位中最大值 + 1 的結果
  --> 第三個參數 Default = 1

SELECT '@id_receive_invoice' = @id_receive_invoice

INSERT INTO receive_invoice (
       id_receive_invoice
      ,invoice_no
      ,id_vendor
      ,dt_invoice
      ,amt_invoice
      ,amt_tax
      ,invoice_type
      ,tax_type
      ,create_by
      ,dt_create
      ,update_by
      ,dt_update
      ,stat_void
      ,receive_no
      ,receive_type
      ,dt_receive_invoice
      ,delivery_no
      ,id_admslip
      ,ref_id
      ,buf_no
      ,custom_apply_no
      ,stat_frozen
      ,table_partition
      ,shipper_name
)
SELECT id_receive_invoice = @id_receive_invoice + 1
      ,invoice_no         = invoice_no
      ,id_vendor          = id_vendor
      ,dt_invoice         = dt_invoice
      ,amt_invoice        = amt_invoice
      ,amt_tax            = amt_tax
      ,invoice_type       = invoice_type
      ,tax_type           = tax_type
      ,create_by          = create_by
      ,dt_create          = dt_create
      ,update_by          = update_by
      ,dt_update          = dt_update
      ,stat_void          = 0
      ,receive_no         = receive_no
      ,receive_type       = receive_type
      ,dt_receive_invoice = dt_receive_invoice
      ,delivery_no        = delivery_no
      ,id_admslip         =  -- ☆★☆★☆★☆★☆★☆★
      ,ref_id             = ref_id
      ,buf_no             = buf_no
      ,custom_apply_no    = custom_apply_no
      ,stat_frozen        = stat_frozen
      ,table_partition    = table_partition
      ,shipper_name       = shipper_name
  FROM #tmp_receive_invoice

UPDATE receive
   SET id_receive_invoice = @id_receive_invoice + 1
  FROM receive with(nolock)
 WHERE id_receive_invoice = @arg_id_receive_invoice

INSERT INTO admprocess_queue (
       action_code
      ,source_code
      ,destination_code
      ,source_id
      ,id_processer
      ,stat_needfeedback
      ,feedback_message
      ,error_counter
)
SELECT DISTINCT
       action_code       = 'processing'
      ,source_code       = 'receive'
      ,destination_code  = 'iqc'
      ,source_id         = receive.id_receive_invoice
      ,id_processer      = admuser.id_admuser
      ,stat_needfeedback = 0
      ,feedback_message  = ''
      ,error_counter     = 0
  FROM receive with(nolock)
         LEFT JOIN admuser with(nolock) on receive.create_by = admuser.user_id and admuser.stat_void = 0
 WHERE receive.id_receive_invoice = @id_receive_invoice + 1

---------------------------------------------------------------------------------------------------

SELECT id_receive_invoice, receive_no, id_admslip, receive_type, invoice_no, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM receive_invoice with(nolock)
 WHERE id_receive_invoice IN (@arg_id_receive_invoice, @id_receive_invoice + 1)
ORDER BY 1, 2

SELECT id_receive, id_receive_invoice, id_expect_receive, receive_no, status_receive, dt_received, invoice_no, id_ictr, dt_process, source_code, source_no, source_id, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM receive with(nolock)
 WHERE id_receive_invoice = @id_receive_invoice + 1
ORDER BY 1, 2

SELECT *
  FROM admprocess_queue with(nolock)
 WHERE source_code = 'receive'
   and destination_code = 'iqc'
   and source_id = @id_receive_invoice + 1

ROLLBACK
COMMIT
*/

/* Check IF "admprocess_queue" Not Exists => Add New "admprocess_queue"
INSERT INTO admprocess_queue (
       action_code
      ,source_code
      ,destination_code
      ,source_id
      ,id_processer
      ,stat_needfeedback
      ,feedback_message
      ,error_counter
)
SELECT DISTINCT
       action_code       = 'processing'
      ,source_code       = 'receive'
      ,destination_code  = 'iqc'
      ,source_id         = receive.id_receive_invoice
      ,id_processer      = admuser.id_admuser
      ,stat_needfeedback = 0
      ,feedback_message  = ''
      ,error_counter     = 0
  FROM receive with(nolock)
         LEFT JOIN admuser with(nolock) on receive.create_by = admuser.user_id and admuser.stat_void = 0
 WHERE receive.id_receive_invoice = 751274

SELECT *
  FROM admprocess_queue with(nolock)
 WHERE source_id IN ('751263','751427')  -- id_receive_invoice
ORDER BY id_admprocess_queue

SELECT *
  FROM admprocess_log with(nolock)
 WHERE source_id IN ('751263','751427')  -- id_receive_invoice
ORDER BY id_admprocess_queue, dt_complete
*/
--select * from admuser where user_id = 'J098641'
/*
select * from receive_relation where id_relation in (3263024) --receive.id_receive
select * from rec_ic where id_rec_ic = 1677983  --receive_relation.ref_id

select a.tran_type,a.dt_process,b.* 
from ictr a(nolock)
      ,ictrd b(nolock)
	  ,received c(nolock)
	  where a.id_ictr = b.id_ictr 
	  and b.id_reference = c.id_received 
	  and a.stat_void = 0 
and b.stat_void = 0 
and c.stat_void = 0 
and a.tran_type in ('EXPIC','RCVIC','EXPRET','IQCREJ    ') 
and c.id_receive  IN ('3289760')
*/
