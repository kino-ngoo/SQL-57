-- [---MISSQL*Urgent*QC1211*Check PO*POC0102*Check Vendor reason <> PO -- Expect Receive --Receive reason---]

--sp_helptext zp_rs_QC1211_POC0102

---------------------------------------------------------------------------------------------------------

/*
create by  : micky_wu
create date: 2017-12-28
create goal: Check VBpo Vendor reason <> PO--Expect Receive--Receive reason
*/-------------------------------------------------------------------------- Fixed segament: Don't change  

     IF Object_id('tempdb.dbo.#tmp_qc') is not null DROP TABLE #tmp_qc
	   
   SELECT type               = '1. VBpo Vendor reason <> PO reason'
         ,vendor_reason      = vendor.id_admslip_reason
         ,vendor             = RTRIM(LTRIM(vendor.vendor_no)) + ' : ' + RTRIM(LTRIM(vendor.vendor_name))
         ,po_no              = RTRIM(LTRIM(popo.po_no))
         ,status_po          = popo.status_po
         ,status_popo        = popo.status_popo
         ,id_popod           = popod.id_popod
         ,popod_create       = popod.dt_create
         ,popod_reason       = popod.id_admslip_reason
         ,status_popod       = popod.status_popod
         ,id_expect_received = expect_received.id_expect_received
         ,exp_create         = expect_received.dt_create
         ,exp_reason         = expect_received.id_admreason
         ,status_received    = expect_received.status_received
         ,id_received        = received.id_received
         ,rcv_create         = received.dt_create
         ,rcv_reason         = received.id_admreason
         ,buyer_id           = RTRIM(LTRIM(admuser.user_id))
         ,buyer              = RTRIM(LTRIM(admuser.user_name))
--       ,password           = admuser.password
     INTO #tmp_qc
     FROM vendor with(nolock)
         ,popo with(nolock)
LEFT JOIN admuser with(nolock) on popo.id_buyer = admuser.id_admuser
         ,popod with(nolock)
         ,expect_received with(nolock)
		 ,received with(nolock)
    WHERE vendor.id_vendor = popo.id_vendor_order
	  AND popo.id_popo = popod.id_popo
	  AND popod.id_expect_received = expect_received.id_expect_received
	  AND expect_received.id_expect_received = received.id_expect_received
	  AND popod.id_popod = received.source_id
	  AND popo.business_type <> 0
      AND vendor.stat_void = 0
      AND popo.stat_void = 0
      AND popod.stat_void = 0
	  AND expect_received.stat_void = 0 
	  AND received.stat_void = 0 
    --AND popo.dt_forceclose is null
	  AND vendor.id_admslip_reason <> popod.id_admslip_reason
      AND popo.dt_create >= DATEADD(month, -5, GetDate())
UNION
   SELECT type               = '2. VBpo Vendor reason <> Expect Receive reason'
         ,vendor_reason      = vendor.id_admslip_reason
         ,vendor             = RTRIM(LTRIM(vendor.vendor_no)) + ' : ' + RTRIM(LTRIM(vendor.vendor_name))
         ,po_no              = RTRIM(LTRIM(popo.po_no))
         ,status_po          = popo.status_po
         ,status_popo        = popo.status_popo
         ,id_popod           = popod.id_popod
         ,popod_create       = popod.dt_create
         ,popod_reason       = popod.id_admslip_reason
         ,status_popod       = popod.status_popod
         ,id_expect_received = expect_received.id_expect_received
         ,exp_create         = expect_received.dt_create
         ,exp_reason         = expect_received.id_admreason
         ,status_received    = expect_received.status_received
         ,id_received        = received.id_received
         ,rcv_create         = received.dt_create
         ,rcv_reason         = received.id_admreason
         ,buyer_id           = RTRIM(LTRIM(admuser.user_id))
         ,buyer              = RTRIM(LTRIM(admuser.user_name))
--       ,password           = admuser.password
     FROM vendor with(nolock)
         ,popo with(nolock)
LEFT JOIN admuser with(nolock) on popo.id_buyer = admuser.id_admuser
         ,popod with(nolock)
         ,expect_received with(nolock)
		 ,received with(nolock)
    WHERE vendor.id_vendor = popo.id_vendor_order
	  AND popo.id_popo = popod.id_popo
	  AND popod.id_expect_received = expect_received.id_expect_received
	  AND expect_received.id_expect_received = received.id_expect_received
	  AND popod.id_popod = received.source_id
	  AND popo.business_type <> 0
      AND vendor.stat_void = 0
      AND popo.stat_void = 0
      AND popod.stat_void = 0
	  AND expect_received.stat_void = 0 
	  AND received.stat_void = 0 
    --AND popo.dt_forceclose is null
	  AND vendor.id_admslip_reason <> expect_received.id_admreason
      AND popo.dt_create >= DATEADD(month, -5, GetDate())
UNION
   SELECT type               = '3. VBpo Vendor reason <> Receive reason'
         ,vendor_reason      = vendor.id_admslip_reason
         ,vendor             = RTRIM(LTRIM(vendor.vendor_no)) + ' : ' + RTRIM(LTRIM(vendor.vendor_name))
         ,po_no              = RTRIM(LTRIM(popo.po_no))
         ,status_po          = popo.status_po
         ,status_popo        = popo.status_popo
         ,id_popod           = popod.id_popod
         ,popod_create       = popod.dt_create
         ,popod_reason       = popod.id_admslip_reason
         ,status_popod       = popod.status_popod
         ,id_expect_received = expect_received.id_expect_received
         ,exp_create         = expect_received.dt_create
         ,exp_reason         = expect_received.id_admreason
         ,status_received    = expect_received.status_received
         ,id_received        = received.id_received
         ,rcv_create         = received.dt_create
         ,rcv_reason         = received.id_admreason
         ,buyer_id           = RTRIM(LTRIM(admuser.user_id))
         ,buyer              = RTRIM(LTRIM(admuser.user_name))
--       ,password           = admuser.password
     FROM vendor with(nolock)
         ,popo with(nolock)
LEFT JOIN admuser with(nolock) on popo.id_buyer = admuser.id_admuser
         ,popod with(nolock)
         ,expect_received with(nolock)
		 ,received with(nolock)
    WHERE vendor.id_vendor = popo.id_vendor_order
	  AND popo.id_popo = popod.id_popo
	  AND popod.id_expect_received = expect_received.id_expect_received
	  AND expect_received.id_expect_received = received.id_expect_received
	  AND popod.id_popod = received.source_id
	  AND popo.business_type <> 0
      AND vendor.stat_void = 0
      AND popo.stat_void = 0
      AND popod.stat_void = 0
	  AND expect_received.stat_void = 0 
	  AND received.stat_void = 0 
    --AND popo.dt_forceclose is null
	  AND vendor.id_admslip_reason <> received.id_admreason
      AND popo.dt_create >= DATEADD(month, -5, GetDate())
    ORDER BY type

   SELECT * FROM #tmp_qc

/*
Table name : popo
==================================================
status_popr  Note√±ße
-----------  ---------------------
0            New
1            In Approve
2            Reject
3            Approve ok
7            Force close
8            Close
10           B2B message sending

status_popo  Note√±ße
-----------  ---------------------
0            New
1            In Approve
2            Reject
3            Approve ok
7            Force close
8            Close
10           B2B message sending

status_po  po status
---------  -----------------------
0          New
1          Release
7          Forceclose
8          Close
9          Hold
10         B2B message sending
*/
--select * from admuser where user_id = 'A1000446'
/*
SELECT id_admslip_reason ,descrip ,*
  FROM admslip_reason with(nolock)
 WHERE id_admslip_reason IN (2766)

SELECT id_admslip_reason ,*
  FROM vendor with(nolock)
 WHERE id_vendor IN (5149)

SELECT id_popo, po_no, id_popr, status_popo, status_po, id_admfacility, dt_approval, dt_forceclose, create_by, dt_create, update_by, dt_update, stat_void, record_info, *
--UPDATE popo SET stat_void = 0, status_popo = 0, status_po = 0, update_by = 'micky - POC0025', dt_update = GetDate()
  FROM popo with(nolock)
 WHERE id_popo IN (828127)
 -- WHERE po_no in ('M17081005JA' ,'M17081102JA')
ORDER BY 1

SELECT id_popo, id_popod, id_poprd, id_expect_received, status_popod, id_icim_comp, qty_apply, qty_buy, qty_release, qty_shipped, qty_receive, qty_pass, qty_iqc, qty_reject, dt_forceclose, create_by, dt_create, update_by, dt_update, stat_void, record_info, dt_need, linenumber, seller_linenumber, *
  FROM popod with(nolock)
 WHERE id_popo IN (395421 ,395535)
ORDER BY 1, 2

SELECT *
  FROM expect_received with(nolock)
 WHERE id_expect_received IN (4014947 ,4014948)

SELECT *
  FROM received with(nolock)
 WHERE id_received IN (4149311 ,4149312)

SELECT *
  FROM cost_ictr with(nolock)
 WHERE id_ictrd IN ()
*/