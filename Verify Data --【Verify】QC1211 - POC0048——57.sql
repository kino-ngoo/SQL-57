-- [---MISSQL*Alert*QC1211*Check PO*POC0048*check ictrd.partno <> icim_comp.part_no---]

--sp_helptext zp_rs_QC1211_POC0048

-----------------------------------------------------------------------------------------------------

IF Object_id('tempdb.dbo.#tmp_qc') is not null DROP TABLE #tmp_qc

SELECT id_admcomp     = ictr.id_admcomp
      ,id_ictr        = ictr.id_ictr
      ,apply_no       = RTRIM(LTRIM(ictr.apply_no))
      ,tran_type      = RTRIM(LTRIM(ictr.tran_type))
      ,ref_no         = RTRIM(LTRIM(ictr.ref_no))
      ,source_code    = RTRIM(LTRIM(ictr.source_code))
      ,id_glvh        = ictr.id_glvh
      ,dt_process     = ictr.dt_process
      ,dt_create      = ictr.dt_create
      ,id_ictrd       = ictrd.id_ictrd
      ,id_reference   = ictrd.id_reference
      ,id_icim_comp   = ictrd.id_icim_comp
      ,id_icstockroom = ictrd.id_icstockroom
      ,partno         = RTRIM(LTRIM(ictrd.partno))
      ,part_no        = RTRIM(LTRIM(icim_comp.part_no))
--      ,model_no       = RTRIM(LTRIM(icim_sale.model_no))
--      ,stock_room     = RTRIM(LTRIM(icstockroom.room_code)) + ' / ' + RTRIM(LTRIM(icstockroom.room_name))
--      ,room_code      = RTRIM(LTRIM(icstockroom.room_code))
--      ,room_name      = RTRIM(LTRIM(icstockroom.room_name))
--      ,qty_apply      = ictrd.qty_apply
      ,qty_actual     = ictrd.qty_actual
--      ,up             = ictrd.up
      ,sign           = ictrd.sign
  INTO #tmp_qc
  FROM ictr with(nolock)
      ,ictrd with(nolock)
      ,icim_comp with(nolock)
--      ,icim_sale with(nolock)
--      ,icstockroom with(nolock)
 WHERE ictr.id_ictr = ictrd.id_ictr
   and ictr.id_admcomp = icim_comp.id_admcomp
   and ictrd.id_icim_comp = icim_comp.id_icim_comp
--   and ictrd.id_icim_comp = icim_sale.id_icim_comp
--   and ictrd.id_icstockroom = icstockroom.id_icstockroom
   and ictr.stat_void = 0
   and ictrd.stat_void = 0
   and icim_comp.stat_void = 0
--   and icstockroom.stat_void = 0
   and ictr.dt_process >= DateAdd(month, -3, GetDate())
   and isnull(ictrd.partno, '') <> icim_comp.part_no
ORDER BY ictr.id_admcomp, ictr.id_ictr, ictrd.id_ictrd

SELECT * FROM #tmp_qc

/* if id_glvh = 0 and yyyymm is curret month --57
SELECT id_cost_ictr, id_ictr, id_glvh, *
--DELETE cost_ictr
  FROM cost_ictr with(nolock)
 WHERE id_ictr IN (9257872)
ORDER BY 2

SELECT *
  FROM receive with(nolock)
 WHERE receive_no LIKE 'RI17121985%'
ORDER BY id_ictr

SELECT *
  FROM ictr with(nolock)
 WHERE id_ictr IN (22851686)
ORDER BY id_ictr

SELECT ictrd.id_ictr, ictrd.id_ictrd, icim_comp.part_no, ictrd.partno, ictrd.id_reference, ictrd.create_by, ictrd.dt_create, ictrd.update_by, ictrd.dt_update, *
--UPDATE ictrd SET partno = icim_comp.part_no, update_by = 'micky - POC0048', dt_update = GetDate()
  FROM ictrd with(nolock)
         LEFT JOIN icim_comp with(nolock) on ictrd.id_icim_comp = icim_comp.id_icim_comp
 WHERE ictrd.id_ictrd IN (42918787)
-- WHERE ictrd.id_ictr IN ()
ORDER BY 1, 2

SELECT *
  FROM received with(nolock)
 WHERE id_receive IN (3271197)

SELECT top 1 *
--update received_extension set part_no = '119A00000039A' ,model_no = '119A00000039A' ,description = '*CONN SFP+ 1X1P 90 FEMALE H5.25mm 15u SMD20 AMPHENOL(07)'
--id_received = 4251590
  FROM received_extension with(nolock)
 --WHERE id_received IN (4251590)
 WHERE id_received = 4251590

SELECT receive.id_receive, receive.id_ictr, receive.id_icim_comp, icim_comp.part_no, receive.part_no, receive.model_no, receive.qty_receive, receive.stat_apvh, receive.stat_costvh, receive.create_by, receive.dt_create, receive.update_by, receive.dt_update, receive.*
--UPDATE receive SET part_no = icim_comp.part_no, update_by = 'saktt - POC0048', dt_update = GetDate()
  FROM receive with(nolock)
         LEFT JOIN icim_comp with(nolock) on receive.id_icim_comp = icim_comp.id_icim_comp
 WHERE receive.id_receive IN ()
*/