
/*-------------------------------------------------------------------------------------------------------

MIS Request#MR171200051J

*/-------------------------------------------------------------------------------------------------------


select * from icim_comp where part_no = '107100000199A'


select * from popo where po_no = 'VB1709001J'
select * from popod where id_popo = 397216 --id_popod = 2764482


select top 10 * from shipment where source_no = 'VB1709001J'
select * from shipmentd where id_shipment = 605817
select * from shipmentd_relation where id_relation = 1653558
select * from shipping_invoice_relation where id_shipment = 605817 -->id_shipping_invoice
select * from shipping_invoice where id_shipping_invoice = 821135


select * from ictr ,ictrd 
where ictrd.id_reference = 1653558 --id_shipmentd
  and ictr.id_ictr = ictrd.id_ictr
  and source_code = 'PO'


select stat_void ,* from apinvd 
--update apinvd set stat_void = 0 ,dt_update = getdate() ,update_by = 'MR171200051J'
where id_apinvd = 3248020 --po_no = 'VB1709001J'
select id_admuser_owner ,stat_void ,* 
--update apinv set stat_void = 0 ,dt_update = getdate() ,update_by = 'MR171200051J'
from apinv where id_apinv = 472750 -- ¡÷ find owner(id_admuser_owner) for using FT007
select * 
--update apallow set stat_void = 0 ,dt_update = getdate() ,update_by = 'MR171200051J'
from apallow where id_apinv = 472750



select * from admuser where id_admuser = 26171


select * from vendor where id_vendor = 4947
select * from vendor where vendor_alias = 'VIRTIUM'