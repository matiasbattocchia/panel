require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: '/home/matias/proyectos/panel/datos/ramos.csv' do
  field 'id_pro_ramo_produccion', map: 'codigo', type: Integer
  field 'ds_pro_ramo_produccion', map: 'ramo'
end

datos =
transform datos do
  new_field 'cd_pro_ramo_produccion', 'vacío'
end

load datos, to: bases['panel'], table: 'lk_pro_ramo_produccion', append: false
