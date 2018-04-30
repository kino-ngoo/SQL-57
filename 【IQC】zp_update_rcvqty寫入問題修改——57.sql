
---------------------------------------------------------------------------------------------------------
-- 當source_id = 0 (為hub(CS))時,在zp_update_rcvqty會落入Where pod.id_popod = @source_id並update
---------------------------------------------------------------------------------------------------------


-- Accton
   select * from admuser where user_id = 'A1000222'
   select * from admuser where user_id = '850377'


-- JoyTech
   select * from admuser where user_id = 'J1116173'
   select * from admuser where user_id = 'J1116118'


   select pod.dt_create, pod.dt_update, pod.create_by, pod.update_by, pod.qty_iqc, pod.qty_reject, pod.stat_void ,*
 --update pod set stat_void = 9,update_by = 'micky-verify' ,dt_update = getdate()
     From popod pod
    Where pod.id_popod = 0
	  and pod.stat_void = 0


   select po.po_no, pr.pr_no, pod.dt_create, pod.dt_update, pod.create_by, pod.update_by, pod.qty_iqc, pod.qty_reject
       ,pod.stat_void,* 
 --update pod set stat_void = 9,update_by = 'jill-- verify' ,dt_update = getdate()
     From popod pod
		, popo po
	    , popr pr
		, poprd prd
    Where pod.id_popod = 0
      and pr.id_popr = prd.id_popr
      and prd.id_poprd = pod.id_poprd
      and pr.id_popr = po.id_popr
	  and pod.stat_void = 0


   select * from popr where id_popr = 209561 
   select * from poprd where  id_poprd = 2749706 
   select stat_void,* from popod where id_popod = 0 


