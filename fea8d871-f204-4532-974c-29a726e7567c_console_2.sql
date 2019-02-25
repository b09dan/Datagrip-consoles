-- Какой команде принадлежат какие источники рекламы
SELECT DISTINCT unnest(string_to_array(afftrack_group.affs, ','::text))::bigint AS aff_id,
            afftrack_group.name AS traffic_name
           FROM afftrack_group
          WHERE afftrack_group.name::text = ANY (ARRAY['Red team (main group)'::character varying::text, 'Black team (партнерка)'::character varying::text, 'Blue Team'::character varying::text])

--

