-- View: datedimension

-- DROP VIEW datedimension;

CREATE OR REPLACE VIEW datedimension AS 
 WITH relativeperiods AS (
         SELECT dates.id,
            dense_rank() OVER (ORDER BY dates.salesyearnumber, dates.salesquarterofyearnumber) AS salesquarterofyearnumberrank,
            dense_rank() OVER (ORDER BY dates.salesyearnumber, dates.salesperiodofyearnumber) AS salesperiodofyearnumberrank,
            dense_rank() OVER (ORDER BY dates.salesyearnumber, dates.salesweekofyearnumber) AS salesweekofyearnumberrank
           FROM dates
        ), today AS (
         SELECT t_1.salesyearnumber AS currentsalesyearnumber,
            t_1.salesquarterofyearnumber AS currentsalesquarterofyearnumber,
            t_1.salesperiodofyearnumber AS currentsalesperiodofyearnumber,
            t_1.salesweekofyearnumber AS currentsalesweekofyearnumber,
            t_1.salesdayofyearnumber AS currentsalesdayofyearnumber,
            t_1.salesdayofquarternumber AS currentsalesdayofquarternumber,
            t_1.salesdayofperiodnumber AS currentsalesdayofperiodnumber,
            t_1.salesdayofweeknumber AS currentsalesdayofweeknumber,
            rp_1.salesquarterofyearnumberrank AS currentsalesquarterofyearnumberrank,
            rp_1.salesperiodofyearnumberrank AS currentsalesperiodofyearnumberrank,
            rp_1.salesweekofyearnumberrank AS currentsalesweekofyearnumberrank
           FROM dates t_1
             JOIN relativeperiods rp_1 ON t_1.id = rp_1.id
          WHERE t_1.thisdate = 'now'::text::date
        )
 SELECT d.id,
    d.thisdate,
    'Current Period'::bpchar AS periodid,
    d.salesyearnumber,
    d.salesyearnumber - t.currentsalesyearnumber AS salesrelativeyearnumber,
        CASE
            WHEN (d.salesyearnumber - t.currentsalesyearnumber) = 0 THEN 'Current Year'::text
            WHEN (d.salesyearnumber - t.currentsalesyearnumber) > 0 THEN (((d.salesyearnumber - t.currentsalesyearnumber)::character varying)::text) || ' Years From Now'::text
            ELSE abs(d.salesyearnumber - t.currentsalesyearnumber)::character varying::text || ' Years Ago'::text
        END AS salesrelativeyearlabel,
        CASE
            WHEN d.salesdayofyearnumber <= t.currentsalesdayofyearnumber THEN 'TRUE'::text
            ELSE 'FALSE'::text
        END AS isparallelsalesytdbyday,
    d.salesquarterofyearnumber,
    (d.salesyearnumber::character varying::text || ' Q'::text) || d.salesquarterofyearnumber::character varying::text AS salesquarterofyearuniquelabel,
    'Q'::text || d.salesquarterofyearnumber::character varying::text AS salesquarterofyearlabel,
    rp.salesquarterofyearnumberrank - t.currentsalesquarterofyearnumberrank AS salesrelativequarternumber,
        CASE
            WHEN (rp.salesquarterofyearnumberrank - t.currentsalesquarterofyearnumberrank) = 0 THEN 'Current Quarter '::text
            WHEN (rp.salesquarterofyearnumberrank - t.currentsalesquarterofyearnumberrank) > 0 THEN (((rp.salesquarterofyearnumberrank - t.currentsalesquarterofyearnumberrank)::character varying)::text) || ' Quarters From Now'::text
            ELSE abs(rp.salesquarterofyearnumberrank - t.currentsalesquarterofyearnumberrank)::character varying::text || ' Quarters Ago'::text
        END AS salesrelativequarterlabel,
        CASE
            WHEN d.salesdayofquarternumber <= t.currentsalesdayofquarternumber AND d.salesquarterofyearnumber = t.currentsalesquarterofyearnumber THEN 'TRUE'::text
            ELSE 'FALSE'::text
        END AS isparallelsalesqtdsamequarterbyday,
        CASE
            WHEN d.salesdayofquarternumber <= t.currentsalesdayofquarternumber THEN 'TRUE'::text
            ELSE 'FALSE'::text
        END AS isparallelsalesqtdanyquarterbyday,
    d.salesperiodofyearnumber,
    ((d.salesyearnumber::character varying::text || ' P'::text) ||
        CASE
            WHEN d.salesperiodofyearnumber < 10 THEN '0'::text
            ELSE ''::text
        END) || d.salesperiodofyearnumber::character varying::text AS salesperiodofyearuniquelabel,
    ('P'::text ||
        CASE
            WHEN d.salesperiodofyearnumber < 10 THEN '0'::text
            ELSE ''::text
        END) || d.salesperiodofyearnumber::character varying::text AS salesperiodofyearlabel,
    rp.salesperiodofyearnumberrank - t.currentsalesperiodofyearnumberrank AS salesrelativeperiodnumber,
        CASE
            WHEN (rp.salesperiodofyearnumberrank - t.currentsalesperiodofyearnumberrank) = 0 THEN 'Current Period'::text
            WHEN (rp.salesperiodofyearnumberrank - t.currentsalesperiodofyearnumberrank) > 0 THEN (((rp.salesperiodofyearnumberrank - t.currentsalesperiodofyearnumberrank)::character varying)::text) || ' Months From Now'::text
            ELSE abs(rp.salesperiodofyearnumberrank - t.currentsalesperiodofyearnumberrank)::character varying::text || ' Months Ago'::text
        END AS salesrelativeperiodlabel,
        CASE
            WHEN d.salesdayofperiodnumber <= t.currentsalesdayofperiodnumber AND d.salesperiodofyearnumber = t.currentsalesperiodofyearnumber THEN 'TRUE'::text
            ELSE 'FALSE'::text
        END AS isparallelsalesptdsameperiodbyday,
        CASE
            WHEN d.salesdayofperiodnumber <= t.currentsalesdayofperiodnumber THEN 'TRUE'::text
            ELSE 'FALSE'::text
        END AS isparallelsalesptdanyperiodbyday,
    d.salesweekofyearnumber,
    first_value(d.thisdate) OVER (PARTITION BY d.salesyearnumber, d.salesweekofyearnumber ORDER BY d.thisdate DESC) AS salesweekenddate,
    ((d.salesyearnumber::character varying::text || ' W'::text) ||
        CASE
            WHEN d.salesweekofyearnumber < 10 THEN '0'::text
            ELSE ''::text
        END) || d.salesweekofyearnumber::character varying::text AS salesweekofyearuniquelabel,
    ('W'::text ||
        CASE
            WHEN d.salesweekofyearnumber < 10 THEN '0'::text
            ELSE ''::text
        END) || d.salesweekofyearnumber::character varying::text AS salesweekofyearlabel,
    rp.salesweekofyearnumberrank - t.currentsalesweekofyearnumberrank AS salesrelativeweeknumber,
        CASE
            WHEN (rp.salesweekofyearnumberrank - t.currentsalesweekofyearnumberrank) = 0 THEN 'Current Week'::text
            WHEN (rp.salesweekofyearnumberrank - t.currentsalesweekofyearnumberrank) > 0 THEN (((rp.salesweekofyearnumberrank - t.currentsalesweekofyearnumberrank)::character varying)::text) || ' Weeks From Now'::text
            ELSE abs(rp.salesweekofyearnumberrank - t.currentsalesweekofyearnumberrank)::character varying::text || ' Weeks Ago'::text
        END AS salesrelativeweeklabel,
        CASE
            WHEN d.salesdayofweeknumber <= t.currentsalesdayofweeknumber AND d.salesweekofyearnumber = t.currentsalesweekofyearnumber THEN 'TRUE'::text
            ELSE 'FALSE'::text
        END AS isparallelsaleswtdsameweekbyday,
        CASE
            WHEN d.salesdayofweeknumber <= t.currentsalesdayofweeknumber THEN 'TRUE'::text
            ELSE 'FALSE'::text
        END AS isparallelsaleswtdanyweekbyday,
    d.salesdayofyearnumber,
    d.salesdayofquarternumber,
    d.salesdayofperiodnumber,
    d.salesdayofweeknumber,
    t.currentsalesyearnumber,
    t.currentsalesquarterofyearnumber,
    t.currentsalesperiodofyearnumber,
    t.currentsalesweekofyearnumber,
    t.currentsalesdayofyearnumber,
    t.currentsalesdayofquarternumber,
    t.currentsalesdayofperiodnumber,
    t.currentsalesdayofweeknumber
   FROM dates d
     JOIN relativeperiods rp ON d.id = rp.id
     CROSS JOIN today t;

ALTER TABLE datedimension
  OWNER TO eric;
