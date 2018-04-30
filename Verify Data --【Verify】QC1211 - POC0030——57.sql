-- [---ECA_SQL*Alert*QC1211*Check PO*POC0030*Check PR qty_buy <> PO sum(qty) !---]

--sp_helptext zp_rs_QC1211_POC0030

-----------------------------------------------------------------------------------------------------

IF Object_id('tempdb.dbo.#tmp_qc') is not null DROP TABLE #tmp_qc

SELECT id_admcomp     = popo.id_admcomp
      ,id_poprd       = popod.id_poprd
	  ,part_no        = icim_comp.part_no
      ,poprd_qty_buy  = poprd.qty_buy
      ,popod_qty_buy  = SUM(popod.qty_buy)
      ,id_icstockroom = poprd.id_icstockroom
--      ,room_code      = RTRIM(LTRIM(icstockroom.room_code))
--      ,room_name      = RTRIM(LTRIM(icstockroom.room_name))
    --,stock_room     = RTRIM(LTRIM(icstockroom.room_code)) + ' / ' + RTRIM(LTRIM(icstockroom.room_name))
  INTO #tmp_qc
  FROM popo with(nolock)
      ,popod with(nolock)
      ,poprd with(nolock)
	  ,icim_comp with(nolock)
    -- LEFT JOIN icstockroom with(nolock) on poprd.id_icstockroom = icstockroom.id_icstockroom and icstockroom.stat_void = 0
 WHERE popo.id_popo = popod.id_popo
   and popod.id_poprd = poprd.id_poprd
   and popo.stat_void = 0
   and popod.stat_void = 0
   and poprd.stat_void = 0
   and poprd.dt_forceclose is null
   and poprd.dt_create >= DATEADD(month, -3, GetDate())
   and icim_comp.id_icim_comp = poprd.id_icim_comp
 --and popo.id_admcomp = @id_admcomp
 --and popod.status_popod < 8
 --and popo.status_po < 8
GROUP BY popo.id_admcomp
        ,popod.id_poprd
        ,poprd.qty_buy
        ,poprd.id_icstockroom
		,icim_comp.part_no
      --,RTRIM(LTRIM(icstockroom.room_code)) + ' / ' + RTRIM(LTRIM(icstockroom.room_name))
HAVING poprd.qty_buy <> SUM(popod.qty_buy)
ORDER BY popo.id_admcomp, popod.id_poprd, SUM(popod.qty_buy)

SELECT * FROM #tmp_qc

/*
SELECT id_popr, id_poprd, id_icstockroom, id_icim_comp, qty_apply, qty_buy, up, dt_forceclose, dt_close, qty_apply_original, create_by, dt_create, update_by, dt_update, stat_void, record_info, *
--UPDATE poprd SET qty_buy = 2844.00, update_by = 'micky - POC0030', dt_update = GetDate()
  FROM poprd with(nolock)
 WHERE id_poprd IN (2810449)
ORDER BY 1, 2

SELECT id_popo, id_popod, id_poprd, stat_void, id_expect_received, status_popod, id_icstockroom, qty_apply, qty_buy, qty_release, qty_receive, qty_pass, qty_iqc, qty_reject, up, stat_no_charge, dt_need, dt_forceclose, create_by, dt_create, update_by, dt_update, stat_void, record_info, *
--UPDATE popod SET stat_void = 9, update_by = 'micky - POC0030', dt_update = GetDate()
--UPDATE popod SET qty_apply = 432.00, qty_buy = 432.00, update_by = 'micky - POC0030', dt_update = GetDate()  --No mind modity popod_qty_buy to poprd_qty_buy
  FROM popod with(nolock)
WHERE id_poprd IN (2810449)
  --WHERE id_popod IN (2879856)
ORDER BY 3, 1, 2

SELECT * FROM admuser WHERE user_id = 'J1638006'

SELECT id_popo, po_no = RTRIM(po_no), id_popr, id_buyer, id_vendor_order, business_type, status_po, status_popo, currency, currency_pay, amt_orig_po, amt_orig_ap, amt_approval, dt_forceclose, create_by, dt_create, update_by, dt_update, stat_void, record_info, *
--UPDATE popo SET stat_void = 9, update_by = 'saktt - POC0030', dt_update = GetDate()
  FROM popo with(nolock)
 WHERE id_popo IN (409008)
ORDER BY 3, 1

SELECT id_popo, id_popod, id_poprd, id_expect_received, status_popod, id_icstockroom, qty_apply, qty_buy, qty_release, qty_receive, qty_pass, qty_iqc, qty_reject, up, stat_no_charge, dt_need, dt_forceclose, create_by, dt_create, update_by, dt_update, stat_void, record_info, *
  FROM popod with(nolock)
 WHERE id_popo IN (409008)
   AND id_icim_comp = 411525
ORDER BY 3, 1, 2

SELECT id_expect_receive, id_expect_received, status_received, source_id, qty_expect_receive, qty_received, qty_pass, qty_iqc, qty_reject, nocharge, create_by, dt_create, update_by, dt_update, stat_void, *
--UPDATE expect_received SET qty_expect_receive = ?, update_by = 'saktt - POC0030', dt_update = GetDate()
--UPDATE expect_received SET stat_void = 9, update_by = 'saktt - POC0030', dt_update = GetDate()
  FROM expect_received with(nolock)
 WHERE id_expect_received IN ('4223409','4228356','4228364','4223411','4228355',
'4223413','4228354','4223415')
ORDER BY 2

SELECT id_expect_receive, status_receive, expect_receive_no, source_no, source_id, source_code, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM expect_receive with(nolock)
 WHERE id_expect_receive IN ()
ORDER BY 1

SELECT id_expect_receive, id_expect_received, status_received, source_id, qty_expect_receive, qty_received, qty_pass, qty_iqc, qty_reject, nocharge, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM expect_received with(nolock)
 WHERE id_expect_receive IN ()
ORDER BY 2

SELECT id_receive, id_received, id_expect_received, source_id, quantity, qty_pass, qty_iqc, qty_reject, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM received with(nolock)
 WHERE id_expect_received IN ()
ORDER BY 1, 2

SELECT id_receive, id_receive_invoice, id_expect_receive, receive_no, status_receive, dt_received, invoice_no, id_ictr, dt_process, source_code, source_no, source_id, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM receive with(nolock)
 WHERE id_receive IN ()
ORDER BY 1, 2

SELECT id_receive, id_received, id_expect_received, source_id, quantity, qty_pass, qty_iqc, qty_reject, create_by, dt_create, update_by, dt_update, stat_void, *
  FROM received with(nolock)
 WHERE id_receive IN ()
ORDER BY 1, 2
*/