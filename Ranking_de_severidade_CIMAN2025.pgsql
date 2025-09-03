--RANKING DE SEVERIDADE EXCLUINDO ÁREAS DE INTERESSE FEDERAL
SELECT
    sub.id_evento AS "ID",
    sub.dt_passagem AS "Data Passagem",
    sub.peso_global_passagem AS "Índice de Severidade",
    sub.area_acumulada_ha "Área de influência (ha)",
    sub.tempo_acumulado_horas/24 "Duração Dias",
    sub.nome "Município",
    sub.sg_uf "UF",   
    sub.geom_acumulada AS "geom"   
FROM (
        --Selecionar geometria da ultima detecção por id_evento
        SELECT DISTINCT ON (mv.id_evento)
            id_evento,           
            dt_passagem,
            peso_global_passagem,
            area_acumulada_ha, 
            tempo_acumulado_horas,
            uf.sg_uf,
            uf.nome,
            geom_acumulada          
        FROM 
            queimadas.mv_indicadores_queimadas mv
        JOIN 
            queimadas.tb_escopo_queimadas ep 
            ON st_intersects(mv.geom_acumulada, ep.geom) 
		LEFT JOIN 
		    op_incra.tb_assentamento_federal AS incra_quilom
		    ON ST_Intersects(mv.geom_acumulada, incra_quilom.geom)				
		LEFT JOIN 
		    op_incra.tb_area_quilombola AS incra_assent
		    ON ST_Intersects(mv.geom_acumulada, incra_assent.geom)		
		LEFT JOIN 
		    bases_auxiliares.funai_terra_indigena AS ti
		    ON ST_Intersects(mv.geom_acumulada, ti.geom)			
		JOIN 
		    bases_auxiliares.ibge_bc250_lim_municipio_a AS uf
		    ON ST_Intersects(mv.geom_acumulada, uf.geom)
		JOIN
		    bases_auxiliares.mma_cnuc_unidade_conservacao as uc
		    ON ST_intersects(mv.geom_acumulada, uc.geom)			
		WHERE    		    
		    mv.area_acumulada_ha > 100
		    AND mv.dt_passagem >= '2025-09-02'   
		    AND uc.esfera !='Federal'
			AND ti.geom IS NULL
			AND incra_quilom.geom IS NULL
			AND incra_assent.geom IS NULL
            --AND uf.sg_uf = 'TO' -- Filtro para a UF	(Habilitar se necessário)		
        ORDER BY 
            mv.id_evento, mv.dt_passagem DESC
) AS sub   
 
ORDER BY sub.peso_global_passagem DESC
LIMIT 10;     
