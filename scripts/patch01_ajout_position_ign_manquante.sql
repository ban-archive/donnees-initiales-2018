\set ON_ERROR_STOP 1
\timing
\COPY (select format('{"type":"position", "kind":"%s" %s, "positioning":"%s", "housenumber:ign": "%s","ign": "%s","geometry": {"type":"Point","coordinates":[%s,%s]}, "source":"%s"}',kind, case when name is not null then ',"name":"'||name||'"' end, positioning, housenumber_ign, i.ign, lon, lat,source_init) from position p left join position_ign_debug i on (p.ign = i.ign) where (source_init like '%IGN%') and (insee1 like '54%' OR insee2 like '54%') and i.ign is null) to '/home/bduni/ban/init/EXPORT_JSON/54/09_positions_debug.json';
