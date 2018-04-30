
/*-------------------------------------------------------------------------------------------------------
�iDT007�jPR �� PO
pr.status_popr = 3 ->Approval!
pr.dt_forceclose = null
*/-------------------------------------------------------------------------------------------------------

   select source_code, * from receive where source_code not in ('PO','CS','PX')
   select distinct source_code from receive --> ' ', 'CS', 'PO', 'RO', 'TO'
   select * from admslip where prefix in ('CS', 'PO', 'RO', 'TO')

   select status_popr, pr_no, * from popr where create_by = 'AM1060701'
   select * from poprd where id_popr = 727861
   select * from popo where create_by = 'AM1060701'

   select *
-- update popr set status_popr = 3, dt_forceclose = NULL, update_by = 'A1060259'
     from popr where pr_no = 'PF17070001'

   select * from admslip where id_admslip = 62  --pr_no = 'E17070009'
   select * from admslip where id_admslip = 417 --pr_no = 'F17070001'  �� �̫�s���o�O�o�@�i��
   select * from admslip where id_admslip = 811 --pr_no = 'PF17070001' �� �}�Fpo�o�{�S��popod & �����D������ status_po = 8
   select * from admslip where id_admslip = 613 --pr_no = 'BL17080001'

-- Choose Vendor �� Detail > �b�ƥ�W���k�� pr->po �� up, qty_buy <> qty_apply, dt_need �� 3.�k�� > E-Approve
   select * from popr where pr_no like 'E%' order by dt_create desc
   select * from popo where id_popr = 558343 -->id_vendor_order = 13960

   select * from popr where pr_no like 'F%' and currency = 'USD' order by dt_create desc
   select * from popo where id_popr = 727861 -->id_vendor_order = 15940   

   select * from popr where pr_no like 'PF%' order by dt_create desc
   select * from popo where id_popr = 777016 -->id_vendor_order = 1341

   select * from popr where pr_no like 'BL%' order by dt_create desc
   select * from popo where id_popr = 780620 -->id_vendor_order = 3661


/*-------------------------------------------------------------------------------------------------------
�iDT080�jPR �� PO �� PO release 
po.status_popo = 3 --Approval!
*/-------------------------------------------------------------------------------------------------------

   select status_po, status_popo, po_type, * from popo where create_by = 'AM1060701'
   select * from popod where id_popo in ('746848','746849')

   select * 
 --update popo set stat_void = 0, update_by = 'A1060259'
   from popo where id_popo = 746848

   select *
 --update admuser set user_id = 'A1060259', dept_id = '3294', update_by = 'ACCTON\micky_wu'
   from admuser where user_logon like 'micky_wu'

   select * from admuser where user_id = 'A1040178'
   select * from admdept where id_admdept in ('3491', '3294')

 --Choose facility: Accton--�s�� �� ���k��release
   select *
 --update popo set status_popo = 3, update_by ='A1060259'
   from popo where id_popo = 746849

   
/*-------------------------------------------------------------------------------------------------------
�iDT084�jPR �� PO �� PO release �� receive to buffer
popod.id_expect_received�i���expect_received.id_expect_received�B���@��@
expect_received.status_received < 7
expect_receive.id_admfacility_receive=�ҿ諸facility
*/-------------------------------------------------------------------------------------------------------

--1. �V�Jpo_no
 --popo.po_no = expect_receive.source_no = F17100001A     
   select expect_receive_no, * from expect_receive where id_expect_receive = 92839102
   select qty_expect_receive, qty_received, qty_pass, qty_iqc, qty_reject, * from expect_received where id_expect_received = 2305722

--2. ���U�誺data window���k���new�A�M��V�J�Ƹ��A�k�䪺data window�N�|�a�X��vendor�Ҧ����禬�����ʳ椤�ӮƸ����Ҧ����ơC
   select * from icim_comp where id_icim_comp = 1 -- part_no = 000000-000
   select * from admslip_reason where id_admslip_reason = 1853

--3. �����J�禬�ƶq�A�k����k���uDispatch�v�A�t�Φ۰ʱN�禬�ƶq�H���i���X�k�R�P�o�Ǳ��ʶ���
-- Dispatch��A������J���ƶq(qty_receive)�|����k�䪺Qty Receiving

-- The application No. has been changed !

-- Extend Message: RN171000001


/*-------------------------------------------------------------------------------------------------------
�iDT115�jPR �� PO �� PO release �� receive to buffer �� IQC
receive.stat_outiqc = 0
*/-------------------------------------------------------------------------------------------------------

-- Retrieve �� ref_no = RN171000001 �� �k��pass��reject 
   select * from receive where receive_no = 'RN171000001'

-- The part no '000000-000' have not define ICIM Classify�iDT075�j
   select * from icim_purchase
   
   SELECT   icimpurchase.id_icim_comp,
			icimcomp.part_no ,
			icimcomp.descrip,
			icimpurchase.id_iqcclassify     ,
			iqc_rish_level=isnull(icimpurchase.iqc_rish_level,0)
 FROM icim_comp icimcomp,
		icim_purchase icimpurchase
 WHERE icimpurchase.id_icim_comp = icimcomp.id_icim_comp and
		 (icimcomp.id_admcomp = :arg_comp )


   SELECT * FROM received WHERE id_expect_received = 2305722
   SELECT * FROM received WHERE id_receive = 2353053
   SELECT * FROM receive WHERE id_receive = 2353053
