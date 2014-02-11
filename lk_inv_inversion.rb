require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

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

plazos_fijos =
extract(from: bases['sinensup'], table: 'INV_PLAZOS_FIJOS_RECIBIDOS', exclude: true) do
  field 'id_banco', map: 'BIC', strip: true
  field 'id_inv_subtipo_especie', map: 'ID_ssn_tipo_plazo_fijo',
    type: Integer
  field 'id_mon_moneda', map: 'id_ssn_moneda_origen',
    strip: true
  field 'tipo_tasa', strip: true
  field 'tasa', type: String
end

bancos =
extract(from: bases['sinensup'], table: 'BANCOS', exclude: true) do
  field 'id_banco', map: 'BIC', strip: true
  field 'ds_banco', map: 'institucion', strip: true
  field 'id_geo_pais', map: 'ID_pais', strip: true
end

plazos_fijos =
transform plazos_fijos, join: bancos, on: 'id_banco' do
  new_field 'ds_inv_empresa', nil
  new_field 'id_inv_inciso_k', 'No'
  new_field 'ds_inv_inversion', ds_banco + ' ' + tasa + '% ' + (tipo_tasa == 'F' ? 'tasa fija' : 'tasa variable')
  new_field 'id_temporal', id_banco + tasa + tipo_tasa + id_mon_moneda + id_inv_subtipo_especie.to_s
  field 'id_inv_subtipo_especie', id_inv_subtipo_especie + 100
  field 'id_mon_moneda', case id_mon_moneda
                         when 'EUE' then 'EUR'
                         when 'BRE' then 'BRL'
                         end
  
  field 'id_geo_pais', case id_geo_pais
                       when 'XX' then 'NN'
                       when 'AN' then 'NL'
                       when 'UE' then 'NN'
                       end
  
  del_field 'id_banco'
  del_field 'ds_banco'
  del_field 'tasa'
  del_field 'tipo_tasa'
end

plazos_fijos =
transform plazos_fijos, unique: 'id_temporal' do
  new_field 'id_inv_inversion', 'PLAZO' + row_number.to_s
end

id_plazos_fijos =
transform plazos_fijos, exclude: true do
  field 'id_temporal'
  field 'id_inv_inversion'
end

plazos_fijos =
transform plazos_fijos do
  del_field 'id_temporal'
end

load id_plazos_fijos, to: 'id_plazos_fijos.csv', append: false

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

load plazos_fijos, to: bases['panel'], table: 'lk_inv_inversion', append: false
load inversiones, to: bases['panel'], table: 'lk_inv_inversion', append: true
