-- [---MISSQL*Urgent*QC1211*Check PO*POC0025*Check PO E-approve , but notesgateway not exists !---]

--sp_helptext zp_rs_QC1211_POC0025

-----------------------------------------------------------------------------------------------------

IF Object_id('tempdb.dbo.#tmp_qc') is not null DROP TABLE #tmp_qc

SELECT type        = '1. In-Eapprove But Not Exists Gateway'
      ,id_admcomp  = popo.id_admcomp
      ,id_popo     = popo.id_popo
      ,po_no       = RTRIM(LTRIM(popo.po_no))
      ,id_popr     = popo.id_popr
      ,pr_no       = RTRIM(LTRIM(popr.pr_no))
      ,status_popo = popo.status_popo
      ,status_po   = popo.status_po
      ,stat_b2b    = popo.stat_b2b
      ,status_popr = popr.status_popr
      ,buyer_id    = RTRIM(LTRIM(admuser.user_id))
      ,buyer       = RTRIM(LTRIM(admuser.user_name))
--      ,password    = admuser.password
      ,vendor      = RTRIM(LTRIM(vendor.vendor_no)) + ' : ' + RTRIM(LTRIM(vendor.vendor_name))
      ,dt_create   = popo.dt_create
  INTO #tmp_qc
  FROM popo with(nolock)
         LEFT JOIN admuser with(nolock) on popo.id_buyer = admuser.id_admuser
      ,vendor with(nolock)
      ,popr with(nolock)
 WHERE popo.id_vendor_order = vendor.id_vendor
   and popo.id_popr = popr.id_popr
   and popo.stat_void = 0
   and vendor.stat_void = 0
   and popr.stat_void = 0
   and popo.status_popo = 1
   and popo.dt_forceclose is null
   and popo.dt_create >= DATEADD(month, -3, GetDate())
   and popo.po_no NOT IN (SELECT apply_no FROM request with(nolock) WHERE request.stat_void = 0 and request.sys_code = 'PO')
   and popo.po_no NOT IN (SELECT po_no FROM popo with(nolock) WHERE popo.stat_void = 0 and popo.id_admcomp = 10 and popo.po_no like 'MI%')
--   and popo.id_admcomp = @id_admcomp
UNION
SELECT type        = '2. New But Exists Gateway'
      ,id_admcomp  = popo.id_admcomp
      ,id_popo     = popo.id_popo
      ,po_no       = RTRIM(LTRIM(popo.po_no))
      ,id_popr     = popo.id_popr
      ,pr_no       = RTRIM(LTRIM(popr.pr_no))
      ,status_popo = popo.status_popo
      ,status_po   = popo.status_po
      ,stat_b2b    = popo.stat_b2b
      ,status_popr = popr.status_popr
      ,buyer_id    = RTRIM(LTRIM(admuser.user_id))
      ,buyer       = RTRIM(LTRIM(admuser.user_name))
--      ,password    = admuser.password
      ,vendor      = RTRIM(LTRIM(vendor.vendor_no)) + ' : ' + RTRIM(LTRIM(vendor.vendor_name))
      ,dt_create   = popo.dt_create
  FROM popo with(nolock)
         LEFT JOIN admuser with(nolock) on popo.id_buyer = admuser.id_admuser
      ,vendor with(nolock)
      ,popr with(nolock)
 WHERE popo.id_vendor_order = vendor.id_vendor
   and popo.id_popr = popr.id_popr
   and popo.stat_void = 0
   and vendor.stat_void = 0
   and popr.stat_void = 0
   and popo.status_popo = 0
   and popo.dt_forceclose is null
   and popo.dt_create >= DATEADD(month, -3, GetDate())
   and exists(SELECT 1
                FROM request with(nolock)
               WHERE popo.po_no = request.apply_no
                 and request.stat_void = 0
                 and request.sys_code = 'PO')
--   and popo.id_admcomp = @id_admcomp
ORDER BY popo.id_admcomp, popo.id_popr, popo.status_popo, popo.id_popo

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



/* --modify by micky
   SELECT popr.id_popr, poprd.id_poprd, poprd.qty_apply, poprd.qty_buy, popr.dt_forceclose, popr.stat_void, poprd.dt_forceclose, poprd.stat_void, *
     FROM popr, poprd
    WHERE popr.id_popr = poprd.id_popr
      AND popr.id_popr IN (781845)

   SELECT id_popo, po_no, id_popr, status_popo, status_po, id_admfacility, dt_approval, dt_forceclose, create_by, dt_create, update_by, dt_update, stat_void, record_info, *
 --UPDATE popo SET status_popo = 0, status_po = 0, update_by = 'micky - POC0025', dt_update = GetDate()
     FROM popo with(nolock)
    WHERE id_popo IN (409911)
    ORDER BY 1

   SELECT id_popo, id_popod, id_poprd, record_info, id_expect_received, status_popod, id_icim_comp, qty_apply, qty_buy, qty_release, qty_shipped, qty_receive, qty_pass, qty_iqc, qty_reject, dt_forceclose, create_by, dt_create, update_by, dt_update, stat_void, record_info, dt_need, linenumber, seller_linenumber, *
     FROM popod with(nolock)
    WHERE id_popo IN (810490)
	--AND stat_void = 0
    ORDER BY 1, 2

-- add by micky
   SELECT * 
     FROM admuser 
    WHERE user_id = 'A1000222'

   SELECT *
     FROM icim_comp
    WHERE id_icim_comp = '629673'
--

   SELECT *
     FROM request with(nolock)
    WHERE apply_no IN (M17090890A)

   SELECT *
     FROM hist_request with(nolock)
    WHERE apply_no IN ()

   SELECT *
     FROM requestd with(nolock)
    WHERE id_request IN ()
    ORDER BY id_request, id_requestd

   SELECT *
     FROM hist_requestd with(nolock)
    WHERE id_request IN ()
    ORDER BY id_request, id_requestd
*/