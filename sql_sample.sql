SELECT   @store_name                 = Namek
                           , @store_type                 = CAST(store_type AS VARCHAR(1))
                           , @approval_date              = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR, created, 20),'-',''),':',''), ' ','')
                           , @transaction_amount         = transaction_amount
                           , @vat                        = vat
                           , @refund_amount              = refund_amount
                           , @refundable_status          = refundable_status
                           , @city_refund_status         = city_refund_status
                           , @export_status              = export_status
                           , @registered_refund_agency   = mapping_agency
                           , @registered_passport_number = passport_number
                           , @state                      = a.[state]
                           , @is_excced_3month           = CASE WHEN a.created < DATEADD(MONTH, -3, GETDATE()) THEN 'Y' ELSE 'N' END
						   , @post_refund_type			 = case when mobileTaxRefundStatus = 1 then 'MRR' when downTownRefund = 1 then 'SCR' else 'TPR' end
						   , @completed_date = completed_date
                      FROM            [KCS].[dbo].[approval_histories]    AS a WITH (NOLOCK)
                           INNER JOIN [KCS].[dbo].[approval_posthumously] AS p WITH (NOLOCK)
                                   ON transaction_type = 2
                                  AND result_code      = '0000'
                                  AND slip_number      = @slip_number
                                  AND a.idx            = p.approval_number -- 사후환급 성공인것에서만
                           INNER JOIN [LORDPAYNEW].[dbo].[Member]         AS m WITH (NOLOCK)
                                   ON a.store_idx = m.idx
						   left outer join [LORDPAYNEW].[dbo].TaxRefund t with (nolock)		-- 원 데이터가 불확실함
								on a.slip_number = t.receptNo