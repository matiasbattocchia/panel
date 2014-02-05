require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

inversiones =
extract(from: bases['sinensup'], table: 'MAESTRO_INVERSIONES', exclude: true) do
  field 'id_inv_inversion', map: 'cod_ssn',
    strip: true
  field 'ds_inv_inversion', map: 'descripcion',
    strip: true
  field 'id_mon_moneda', map: 'Moneda',
    strip: true
  field 'id_geo_pais', map: 'pais',
    strip: true
  field 'id_inv_inciso_k', map: 'incisoK'
  field 'id_inv_subtipo_especie', map: 'IdSubtipo',
    type: Integer
end

inversiones =
transform inversiones do
  new_field 'ds_inv_empresa', ds_inv_inversion.match(/YPF/) ? 'YPF' : nil
  field 'id_inv_inciso_k', id_inv_inciso_k == 1 ? 'Sí' : 'No'
  field 'ds_inv_inversion', ds_inv_inversion.gsub("'", "''")
  field 'id_mon_moneda', case id_mon_moneda
                         when 'EUE' then 'EUR'
                         when 'BRE' then 'BRL'
                         end
  
  field 'id_geo_pais', case id_geo_pais
                       when 'XX' then 'NN'
                       when 'AN' then 'NL'
                       when 'UE' then 'NN'
                       end
end

load inversiones, to: bases['panel'], table: 'lk_inv_inversion', append: false
