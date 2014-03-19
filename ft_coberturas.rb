require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

coberturas =
extract from: bases['dw-sinensup'], table: 'DW_FINANCIERA', exclude: true do
  field 'id_com_compania', map: 'ciaID',
    type: Integer
  field 'id_tie_trimestre', map: 'periodo'
  field 'subtotal12'
  field 'suma3'
end

coberturas =
transform coberturas do
  new_field 'i_cob_imp_cobertura', suma3 >= 1 ? (subtotal12 / suma3).to_i : 0
  del_field 'suma3'
  del_field 'subtotal12'
  field 'id_tie_trimestre', id_tie_trimestre.gsub('-', '0').to_i
end

load coberturas, to: bases['panel'], table: 'ft_coberturas', append: false
