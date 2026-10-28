SELECT 
	plan_tier,
	ROUND(AVG(is_churned) * 100, 2) AS churn_rate_percent,
	SUM(monthly_recurring_revenue) FILTER (WHERE is_churned = 1) AS churned_mrr
FROM clean_data
GROUP BY plan_tier;

SELECT 
	account_manager,
	ROUND(AVG(is_churned) * 100, 2) AS churn_rate,
	RANK() OVER(ORDER BY AVG(is_churned) DESC) 
FROM clean_data
GROUP BY account_manager;

WITH segment_churn AS (
    SELECT 
        mrr_segment,
        SUM(monthly_recurring_revenue) FILTER (WHERE is_churned = 1) as lost_mrr
    FROM clean_data
    GROUP BY mrr_segment
)
SELECT 
    mrr_segment,
    lost_mrr,
    SUM(lost_mrr) OVER(ORDER BY lost_mrr DESC) as cumulative_lost_mrr,
    ROUND(
    	(SUM(lost_mrr) OVER(ORDER BY lost_mrr DESC) * 100.0) / 
        SUM(lost_mrr) OVER(), 2
    ) as cumulative_share_percent
FROM segment_churn
ORDER BY lost_mrr DESC;
