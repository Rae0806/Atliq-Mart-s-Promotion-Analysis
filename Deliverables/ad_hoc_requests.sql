/* Query 1: Provide a list of products with base price greater than 500 
	 and that are featured in " BOGOF" (Buy One Get One Free) promotion  */

SELECT
    DISTINCT product_name
FROM
    fact_events e
    JOIN
    dim_products p
    ON 
		p.product_code = e.product_code
WHERE	
	base_price > 500 AND
    promo_type = 'BOGOF';


/* Query 2 : Generate a report that provides an overview of number of stores in each city. 
				The result will be sorted in descending order of store count.  */

SELECT
    city,
    COUNT(store_id) store_cnt
FROM 
    dim_stores
GROUP BY 
    city
ORDER BY 
    store_cnt DESC;


/* Query 3: Generate a report that display each campaign along with the revenue generated before and after campaign
			The report includes three fields : campaing name, total_revenue(before_promotion) and total_revenue(after promotion)
			Display values in millions */

SELECT 
    campaign_name,
    ROUND(SUM(base_price * cast(quantity_sold_before_promo AS INT))/ 1000000.0 ,2) total_revenue_before_promo_in_millions,
    ROUND(SUM(base_price * CAST(quantity_sold_after_promo AS INT))/ 1000000.0 , 2) total_revenue_after_promo_in_millions
FROM 
    fact_events fe
    JOIN 
    dim_campaigns dc 
    ON 
    fe.campaign_id = dc.campaign_id
GROUP BY campaign_name;

-- Query 4

WITH
    incremental_sold_quantity
    as
    (

        SELECT
            category,
            100.0 * (SUM(quantity_sold_after_promo) - SUM(quantity_sold_before_promo))/SUM(quantity_sold_before_promo) ISQ
        FROM
            fact_events fe
            JOIN
            dim_products dp
            ON 
        fe.product_code = dp.product_code
        WHERE 
        campaign_id = 'CAMP_DIW_01'
        GROUP BY category 
    )

    SELECT 
            category,
            ISQ,
            RANK()OVER(ORDER BY ISQ DESC) as ranking
    FROM    
            incremental_sold_quantity;


-- Query 5 

WITH
    revenue
    AS
    (
        SELECT product_name,
            category,
            SUM(base_price * CAST(quantity_sold_before_promo AS INT)) revenue_before_promo,
            SUM(base_price * CAST(quantity_sold_after_promo AS INT ))  revenue_after_promo
        FROM fact_events fe
            JOIN dim_products dp on fe.product_code = dp.product_code
        GROUP BY product_name, category
    )

SELECT TOP 5
    product_name,
    category,
    100.0 * (revenue_after_promo - revenue_before_promo) / revenue_before_promo incremental_revenue_percent
FROM revenue
ORDER BY incremental_revenue_percent DESC

