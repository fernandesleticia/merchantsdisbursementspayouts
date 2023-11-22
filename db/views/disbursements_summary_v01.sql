SELECT
  EXTRACT(YEAR FROM disbursement.created_at)::TEXT AS year,
  COUNT(disbursement.id) AS number_of_disbursements,
  TO_CHAR(SUM(disbursement.amount), 'FM999G999G999G999G999D00 €') AS amount_disbursed_to_merchants,
  TO_CHAR(SUM(disbursement.commision_fee), 'FM999G999G999G999G999D00 €') AS amount_of_order_fees,
  COUNT(monthly_fee_debit.id) AS number_of_monthly_fees_charged,
  COALESCE(TO_CHAR(SUM(monthly_fee_debit.amount), 'FM999G999G999G999G999D00 €'), '0.00 €') AS amount_of_monthly_fee_charged
FROM
  disbursements disbursement
LEFT JOIN
  monthly_fee_debits monthly_fee_debit ON monthly_fee_debit.disbursement_id = disbursement.id
GROUP BY
  year
ORDER BY
  year
