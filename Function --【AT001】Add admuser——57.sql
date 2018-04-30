------------------------------------------------------------------------------------------------------

   SELECT * FROM admuser WHERE user_logon = 'nina_lee' 
      AND dt_expire_user is null 

   SELECT a.user_id ,a.user_name ,a.user_name_foreign ,a.email ,a.user_logon
		 ,b.dept_id ,b.dept_name ,id_admdept ,dt_expire ,dt_expire_user ,a.create_by ,a.dt_create
	   --,* 
     FROM admuser a (nolock), admdept b  (nolock)
    WHERE a.dept_id = b.id_admdept
      AND user_id in ('AL820128')  --,'J1012718','A1040007')


   SELECT * FROM admuser with(nolock) WHERE user_logon = 'Tina_jing'
   SELECT * FROM admuser with(nolock) WHERE user_logon = 'IRIS_LO'

   SELECT * FROM admdept WHERE dept_id = 'QT0000' --id_admdept in (3490,3491)
   SELECT * FROM admuser WHERE dept_id = 1703 -- admdept.id_admdept

   SELECT 'AL'+admuser.user_id, * 
     FROM admuser ,admdept
	WHERE admdept.id_parentdept = 1703 -- = admdept.id_admdept
      AND admdept.id_admdept = admuser.dept_id AND admuser.dt_expire_user is null 
------------------------------------------------------------------------------------------------------

--需求簡述(Subject) : 
--申請開立EC USA 系統權限, 及FR061、FR069、FR056、FR043、FR085 等ready only權限 for 工作需求


/*--57note :
			1.AL的賬號用原來的ad賬號在前面加上AL etc Axxxxx → ALAxxxxx
			2.原本在MISSQL的ALDB，現在在METAERP裡面
			3.
*/
--step 1 : 查詢要掛在哪個部門
--select * from JOY_SQL.joyDB.dbo.admuser where user_id= 'JS20090017'
--select * from METAERP.alDB.dbo.admuser where user_id= 'JS20090017'

 --SELECT user_logon, stat_void, stat_active, *
 --  FROM admuser
 -- WHERE (user_id collate Chinese_Taiwan_Stroke_BIN) IN (SELECT user_id  FROM JOY_SQL.joyDB.dbo.admuser WHERE dept_id IN (900))
 
--step 2 : insert admuser
  DECLARE @id_admuser int
         ,@user_id char(20)  

   SELECT @id_admuser = max(id_admuser) + 1
     FROM admuser

   SELECT @user_id = 'J1012718' --放user_id --A1000246

---------------------------------------------------------------------------------------------------------

   INSERT admuser(
          id_admuser ,id_admcomp ,dept_id ,user_id ,user_name ,user_name_foreign ,password ,email ,tel_no
         ,fax_no ,ext_no ,dt_expire_user ,dt_expire_password ,dt_update_password ,spid ,sys_code 
		 ,dt_login ,dt_logout ,login_counter ,dt_create ,dt_update ,create_by ,update_by ,stat_void 
		 ,stat_active ,id_emp_base ,bank_no ,user_logon ,machine_information ,id_admlanguage ,stat_folder 		 ,id_processing ,user_info ,id_admcomp_from ,id_bank_code ,objectguid ,objectdomain ,domain 
		 ,user_doain ,stat_virtual
)
   SELECT id_admuser          = @id_admuser
         ,id_admcomp          = 2  -- 2 / 60  --對應的公司
         ,dept_id             =3677 --對應的部門
         ,user_id             = @user_id
         ,user_name           = '劉蕊'            --TBD
         ,user_name_foreign   
         ,password            = '00000000' 
         ,email               = ''               --TBD
         ,tel_no              = NULL
         ,fax_no              = NULL
         ,ext_no              = NULL
         ,dt_expire_user      = NULL
         ,dt_expire_password  = NULL
         ,dt_update_password  = NULL
         ,spid                = NULL
         ,sys_code            = NULL
         ,dt_login            = NULL
         ,dt_logout           = NULL
         ,login_counter       = 0
         ,dt_create           = GetDate()
         ,dt_update           = NULL
         ,create_by           = 'MR201701-009Y'  --TBD
         ,update_by           = NULL
         ,stat_void           = 0
         ,stat_active         = 1
         ,id_emp_base         = 0
         ,bank_no             = NULL
         ,user_logon          = ''               --TBD
         ,machine_information = NULL
         ,id_admlanguage      = 0
         ,stat_folder         = 1
         ,id_processing       = 0
         ,user_info           = ''               --TBD
         ,id_admcomp_from     = 10 --*
         ,id_bank_code        = 0
         ,objectguid          = NULL
         ,objectdomain        = NULL
         ,domain              = NULL
         ,user_domain         = 'joytech'  --accton & awb & ect 過來的 = 'accton', joytech 過來的 = 'joytech'
         ,stat_virtual        = 1 --**
     FROM JOY_SQL.joyDB.dbo.admuser WITH(NOLOCK)       
    WHERE user_id =  @user_id 
 
  --check data
   SELECT *
     FROM admuser
    WHERE user_id =  'J1012718'


    --MIS public 
   SELECT * FROM admuser with(nolock)
 --UPDATE admuser set domain='*ACCTON\flk*ACCTON\boolean*ACCTON\brian*ACCTON\khuang*ACCTON\jyang*ACCTON\chalin_chang*ACCTON\saktt_hsu*ACCTON\renee_tseng*Accton\suwu_hsu*ACCTON\jillkuo*ACCTON\ryan_liu*ACCTON\andiran_chen*Accton\amber_shi*ACCTON\carol_kuo*Accton\micky_wu*'
    WHERE user_name like '%MI%'
