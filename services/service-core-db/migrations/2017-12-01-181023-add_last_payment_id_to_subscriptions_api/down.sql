DROP VIEW "payment_service_api"."subscriptions";
CREATE OR REPLACE VIEW "payment_service_api"."subscriptions" AS 
 SELECT s.id,
    s.project_id,
        CASE
            WHEN core.is_owner_or_admin(s.user_id) THEN s.credit_card_id
            ELSE NULL::uuid
        END AS credit_card_id,
        CASE
            WHEN (core.is_owner_or_admin(p.user_id) OR core.is_owner_or_admin(s.user_id)) THEN stats.paid_count
            ELSE NULL::bigint
        END AS paid_count,
        CASE
            WHEN (core.is_owner_or_admin(p.user_id) OR core.is_owner_or_admin(s.user_id)) THEN stats.total_paid
            ELSE (NULL::bigint)::numeric
        END AS total_paid,
    s.status,
    payment_service.paid_transition_at(ROW(last_paid_payment.id, last_paid_payment.platform_id, last_paid_payment.project_id, last_paid_payment.user_id, last_paid_payment.subscription_id, last_paid_payment.reward_id, last_paid_payment.data, last_paid_payment.gateway, last_paid_payment.gateway_cached_data, last_paid_payment.created_at, last_paid_payment.updated_at, last_paid_payment.common_contract_data, last_paid_payment.gateway_general_data, last_paid_payment.status, last_paid_payment.external_id)) AS paid_at,
    (payment_service.paid_transition_at(ROW(last_paid_payment.id, last_paid_payment.platform_id, last_paid_payment.project_id, last_paid_payment.user_id, last_paid_payment.subscription_id, last_paid_payment.reward_id, last_paid_payment.data, last_paid_payment.gateway, last_paid_payment.gateway_cached_data, last_paid_payment.created_at, last_paid_payment.updated_at, last_paid_payment.common_contract_data, last_paid_payment.gateway_general_data, last_paid_payment.status, last_paid_payment.external_id)) + (core.get_setting('subscription_interval'::character varying))::interval) AS next_charge_at,
        CASE
            WHEN core.is_owner_or_admin(s.user_id) THEN ((((s.checkout_data - 'card_id'::text) - 'card_hash'::text) - 'current_ip'::text) || jsonb_build_object('customer', (((s.checkout_data ->> 'customer'::text))::jsonb || jsonb_build_object('name', (u.data ->> 'name'::text), 'email', (u.data ->> 'email'::text), 'document_number', (u.data ->> 'document_number'::text)))))
            ELSE NULL::jsonb
        END AS checkout_data,
    s.created_at,
    s.user_id,
    s.reward_id,
    ((last_paid_payment.data ->> 'amount'::text))::numeric AS amount,
    p.external_id AS project_external_id,
    r.external_id AS reward_external_id,
    u.external_id AS user_external_id,
    COALESCE((last_paid_payment.data ->> 'payment_method'::text), (last_payment.data ->> 'payment_method'::text)) AS payment_method
   FROM ((((((payment_service.subscriptions s
     JOIN project_service.projects p ON ((p.id = s.project_id)))
     JOIN community_service.users u ON ((u.id = s.user_id)))
     LEFT JOIN project_service.rewards r ON ((r.id = s.reward_id)))
     LEFT JOIN LATERAL ( SELECT sum(((cp.data ->> 'amount'::text))::numeric) FILTER (WHERE (cp.status = 'paid'::payment_service.payment_status)) AS total_paid,
            count(1) FILTER (WHERE (cp.status = 'paid'::payment_service.payment_status)) AS paid_count,
            count(1) FILTER (WHERE (cp.status = 'refused'::payment_service.payment_status)) AS refused_count
           FROM payment_service.catalog_payments cp
          WHERE (cp.subscription_id = s.id)) stats ON (true))
     LEFT JOIN LATERAL ( SELECT cp.id,
            cp.platform_id,
            cp.project_id,
            cp.user_id,
            cp.subscription_id,
            cp.reward_id,
            cp.data,
            cp.gateway,
            cp.gateway_cached_data,
            cp.created_at,
            cp.updated_at,
            cp.common_contract_data,
            cp.gateway_general_data,
            cp.status,
            cp.external_id
           FROM payment_service.catalog_payments cp
          WHERE ((cp.subscription_id = s.id) AND (cp.status = 'paid'::payment_service.payment_status))
          ORDER BY cp.created_at DESC
         LIMIT 1) last_paid_payment ON (true))
     LEFT JOIN LATERAL ( SELECT cp.id,
            cp.platform_id,
            cp.project_id,
            cp.user_id,
            cp.subscription_id,
            cp.reward_id,
            cp.data,
            cp.gateway,
            cp.gateway_cached_data,
            cp.created_at,
            cp.updated_at,
            cp.common_contract_data,
            cp.gateway_general_data,
            cp.status,
            cp.external_id
           FROM payment_service.catalog_payments cp
          WHERE (cp.subscription_id = s.id)
          ORDER BY cp.created_at DESC
         LIMIT 1) last_payment ON (true))
  WHERE ((s.platform_id = core.current_platform_id()) AND (core.is_owner_or_admin(s.user_id) OR core.is_owner_or_admin(p.user_id)));

    grant select on payment_service_api.subscriptions to platform_user, scoped_user;